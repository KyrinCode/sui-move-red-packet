module red_packet::red_packet {
    use sui::coin::{Self, Coin};
    use sui::bcs::{Self};
    use sui::hash::blake2b256;
    use sui::balance::{Self, Balance};
    use sui::package;
    use std::ascii::String;
    use sui::event;
    use sui::address;
    use std::debug::print;
    use std::type_name;
    use sui::tx_context::{sender, digest};
    use sui::clock::{Self, Clock};


    /* === errors === */

    const EAlreadyClaimed: u64 = 0;
    const ENotInSpecifiedRecipients: u64 = 1;
    const EEmptyPacket: u64 = 2;

    /* === Events === */

    public struct NewRedPacket<phantom T> has copy, drop {
        id: ID,
        sender: address,
        coin_type: String,
        value: u64,
        amount: u64,
    }

    public struct ClaimRedPacket<phantom T> has copy, drop {
        id: ID,
        claimer: address,
        coin_type: String,
        value_claimed: u64,
    }

    /* === witness === */

    public struct RED_PACKET has drop {}

    /* === RedPacket === */

    public struct RedPacket<phantom T> has key, store {
        id: UID,
        sender: address,
        coin_type: String,
        value: u64,
        balance_left: Balance<T>,
        amount: u64,
        amount_left: u64,
        claimer_addresses: vector<address>,
        specified_recipients: Option<vector<address>>
    }

    #[test_only]
    public fun red_packet_info<T>(red_packet: &RedPacket<T>): (String, u64, u64) {
        (
            red_packet.coin_type,
            balance::value(&red_packet.balance_left),
            red_packet.amount_left,
        )
    }

    /* === main logic === */

    fun init(otw: RED_PACKET, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx); // used for module owner check and can modify display
        transfer::public_transfer(publisher, sender(ctx));
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(RED_PACKET {}, ctx);
    }

    public entry fun send_new_red_packet<T>(
        amount: u64,
        coin: Coin<T>,
        specified_recipients: Option<vector<address>>,
        ctx: &mut TxContext,
    ) {
        let coin_type = type_name::get<T>();
        let coin_type_string = *type_name::borrow_string(&coin_type);

        let red_packet = RedPacket<T> {
            id: object::new(ctx),
            sender: sender(ctx),
            coin_type: coin_type_string,
            value: coin::value(&coin),
            balance_left: coin::into_balance(coin),
            amount,
            amount_left: amount,
            claimer_addresses: vector::empty<address>(),
            specified_recipients,
        };

        event::emit(NewRedPacket<T> {
            id: object::uid_to_inner(&red_packet.id),
            sender: red_packet.sender,
            coin_type: coin_type_string,
            value: red_packet.value,
            amount,
        });

        transfer::public_share_object(red_packet);
    }

    public entry fun claim_red_packet<T>(red_packet:&mut RedPacket<T>, clock: &Clock, ctx: &mut TxContext) {
        let sender = sender(ctx);

        assert!(!vector::contains(&red_packet.claimer_addresses, &sender), EAlreadyClaimed);

        if(!option::is_none(&red_packet.specified_recipients)) {
            let specified = option::borrow(&red_packet.specified_recipients);
            assert!(vector::contains(specified, &sender), ENotInSpecifiedRecipients);
        };

        let value_left = balance::value(&red_packet.balance_left);

        assert!(value_left > 0, EEmptyPacket);

        let coin_type = type_name::get<T>();
        let coin_type_string = *type_name::borrow_string(&coin_type);

        let mut _value_claim: u64 = 0;
        if (red_packet.amount_left == 1) {
            red_packet.amount_left = red_packet.amount_left - 1;
            _value_claim = value_left;
            let coin_claimed = coin::take(&mut red_packet.balance_left, value_left, ctx);
            transfer::public_transfer(coin_claimed, sender);
        } else {
            let max = (value_left / red_packet.amount_left) * 2;
            print(&max);
            let value_claim = get_random(max, clock, ctx);
            _value_claim = value_claim;
            let balance_claim = balance::split(&mut red_packet.balance_left, value_claim);
            let coin_claim = coin::from_balance(balance_claim, ctx);
            red_packet.amount_left = red_packet.amount_left - 1;
            transfer::public_transfer(coin_claim, sender);
        };

        vector::push_back(&mut red_packet.claimer_addresses, sender);
        // print(&_value_claim);
        event::emit(ClaimRedPacket<T> {
            id: object::uid_to_inner(&red_packet.id),
            claimer: sender,
            coin_type: coin_type_string,
            value_claimed: _value_claim,
        })
    }

    fun u64_to_ascii(mut num: u64): vector<u8> {
        if (num == 0) {
            return b"0"
        };
        let mut bytes = vector::empty<u8>();
        while (num > 0) {
            let remainder = num % 10; // get the last digit
            num = num / 10; // remove the last digit
            vector::push_back(&mut bytes, (remainder as u8) + 48); // ASCII value of 0 is 48
        };
        vector::reverse(&mut bytes);
        
        bytes
    }

    fun get_random(max: u64, clock: &Clock,ctx: &TxContext): u64 {
        let sender = sender(ctx);
        let tx_digest = digest(ctx);

        let mut random_vector = vector::empty<u8>();
        vector::append(&mut random_vector, address::to_bytes(sender));
        vector::append(&mut random_vector, u64_to_ascii(clock::timestamp_ms(clock)));
        vector::append(&mut random_vector, *copy tx_digest);

        let temp1 = blake2b256(&random_vector);
        let random_num_ex = bcs::peel_u64(&mut bcs::new(temp1));
        let random_value = ((random_num_ex % max) as u64);
        print(&random_value);

        random_value
    }
}