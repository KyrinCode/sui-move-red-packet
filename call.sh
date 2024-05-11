PACKAGE_ID=0x9c0c38725af3c9d5d701d92339e6dd0da9e50a9a6f3a68a1d931c531cf85e99f
SUI_TYPE=0x2::sui::SUI

# # send new red packet
# AMOUNT=1
# SUI_COIN=0xe0a3ede58686f775f255e92b3bbbcbd5e615e7c98d009fff6d830af5254de7c6
# SPECIFIED_RECIPIENTS='[]' # '[0x0f36590f2960c8b4133409623736937be071afbb30dce84b0035e556f1ef0a07]'
# sui client call --package $PACKAGE_ID \
#                 --module red_packet \
#                 --function send_new_red_packet \
#                 --type-args $SUI_TYPE \
#                 --args $AMOUNT $SUI_COIN $SPECIFIED_RECIPIENTS \
#                 --gas-budget 100000000

# claim red packet
RED_PACKET=0xddaf6a24a527f1b675d30ea4914e65ce03ade86e67d72caa20da5c91879ec9ae
CLOCK=0x6
sui client call --package $PACKAGE_ID \
                --module red_packet \
                --function claim_red_packet \
                --type-args $SUI_TYPE \
                --args $RED_PACKET $CLOCK \
                --gas-budget 100000000