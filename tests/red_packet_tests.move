#[test_only]
module red_packet::red_packet_tests {
    use sui::test_scenario::{Self, Scenario, next_tx, ctx, take_shared, return_shared};
    use sui::balance;
    use sui::coin;
    use sui::sui::SUI;
    use sui::clock;
    use std::debug::print;
    use red_packet::red_packet;

    const ADDR1: address = @0xA;
    const ADDR2: address = @0xB;
    const ADDR3: address = @0xC;
    const ADDR4: address = @0xD;
    const ADDR5: address = @0xE;

    fun test_scenario_init(sender: address): Scenario {
        let mut scenario = test_scenario::begin(sender);
        {
            let ctx = ctx(&mut scenario);
            red_packet::test_init(ctx);
        };
        next_tx(&mut scenario, sender);

        scenario
    }

    #[test]
    fun test_red_packet_without_specified_recipients() {
        let mut scenario = test_scenario_init(ADDR1);
        {
            let ctx = ctx(&mut scenario);

            let balance = balance::create_for_testing<SUI>(100);
            let coin = coin::from_balance(balance, ctx);
            red_packet::send_new_red_packet(4, coin, option::none(), ctx)
        };

        next_tx(&mut scenario, ADDR2);
        {
            let mut red_packet_obj = take_shared<red_packet::RedPacket<SUI>>(&scenario);
            let ctx = ctx(&mut scenario);
            let mut clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, 100);

            red_packet::claim_red_packet(&mut red_packet_obj, &clock, ctx);

            let (coin_type, value_left, amount_left) = red_packet::red_packet_info(&red_packet_obj);
            print(&coin_type);
            print(&value_left);
            print(&amount_left);

            return_shared(red_packet_obj);
            clock::destroy_for_testing(clock);
        };

        next_tx(&mut scenario, ADDR3);
        {
            let mut red_packet_obj = take_shared<red_packet::RedPacket<SUI>>(&scenario);
            let ctx = ctx(&mut scenario);
            let mut clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, 101);

            red_packet::claim_red_packet(&mut red_packet_obj, &clock, ctx);

            let (coin_type, value_left, amount_left) = red_packet::red_packet_info(&red_packet_obj);
            print(&coin_type);
            print(&value_left);
            print(&amount_left);

            return_shared(red_packet_obj);
            clock::destroy_for_testing(clock);
        };

        next_tx(&mut scenario, ADDR4);
        {
            let mut red_packet_obj = take_shared<red_packet::RedPacket<SUI>>(&scenario);
            let ctx = ctx(&mut scenario);
            let mut clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, 102);

            red_packet::claim_red_packet(&mut red_packet_obj, &clock, ctx);

            let (coin_type, value_left, amount_left) = red_packet::red_packet_info(&red_packet_obj);
            print(&coin_type);
            print(&value_left);
            print(&amount_left);

            return_shared(red_packet_obj);
            clock::destroy_for_testing(clock);
        };

        next_tx(&mut scenario, ADDR5);
        {
            let mut red_packet_obj = take_shared<red_packet::RedPacket<SUI>>(&scenario);
            let ctx = ctx(&mut scenario);
            let mut clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, 103);

            red_packet::claim_red_packet(&mut red_packet_obj, &clock, ctx);

            let (coin_type, value_left, amount_left) = red_packet::red_packet_info(&red_packet_obj);
            print(&coin_type);
            print(&value_left);
            print(&amount_left);

            return_shared(red_packet_obj);
            clock::destroy_for_testing(clock);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_red_packet_with_specified_recipients() {
        let mut scenario = test_scenario_init(ADDR1);
        {
            let ctx = ctx(&mut scenario);

            let balance = balance::create_for_testing<SUI>(100);
            let coin = coin::from_balance(balance, ctx);
            let mut specified_recipients = vector::empty<address>();
            vector::push_back(&mut specified_recipients, ADDR2);
            vector::push_back(&mut specified_recipients, ADDR3);
            vector::push_back(&mut specified_recipients, ADDR4);
            red_packet::send_new_red_packet(3, coin, option::some(specified_recipients), ctx)
        };

        next_tx(&mut scenario, ADDR2);
        {
            let mut red_packet_obj = take_shared<red_packet::RedPacket<SUI>>(&scenario);
            let ctx = ctx(&mut scenario);
            let mut clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, 100);

            red_packet::claim_red_packet(&mut red_packet_obj, &clock, ctx);

            let (coin_type, value_left, amount_left) = red_packet::red_packet_info(&red_packet_obj);
            print(&coin_type);
            print(&value_left);
            print(&amount_left);

            return_shared(red_packet_obj);
            clock::destroy_for_testing(clock);
        };

        next_tx(&mut scenario, ADDR3);
        {
            let mut red_packet_obj = take_shared<red_packet::RedPacket<SUI>>(&scenario);
            let ctx = ctx(&mut scenario);
            let mut clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, 101);

            red_packet::claim_red_packet(&mut red_packet_obj, &clock, ctx);

            let (coin_type, value_left, amount_left) = red_packet::red_packet_info(&red_packet_obj);
            print(&coin_type);
            print(&value_left);
            print(&amount_left);

            return_shared(red_packet_obj);
            clock::destroy_for_testing(clock);
        };

        next_tx(&mut scenario, ADDR4);
        {
            let mut red_packet_obj = take_shared<red_packet::RedPacket<SUI>>(&scenario);
            let ctx = ctx(&mut scenario);
            let mut clock = clock::create_for_testing(ctx);
            clock::set_for_testing(&mut clock, 102);

            red_packet::claim_red_packet(&mut red_packet_obj, &clock, ctx);

            let (coin_type, value_left, amount_left) = red_packet::red_packet_info(&red_packet_obj);
            print(&coin_type);
            print(&value_left);
            print(&amount_left);

            return_shared(red_packet_obj);
            clock::destroy_for_testing(clock);
        };

        test_scenario::end(scenario);
    }
}