# Prod does not follow base.tfvars patterns for keeping compatibility with pre-existing components
config_bucket_name                 = "ipfs-peer-bitswap-config"
multihashes_topic_name             = "multihashes-topic"
cars_table_name                    = "cars"
blocks_table_name                  = "blocks"
multihashes_send_policy_name       = "sqs-multihashes-send"
multihashes_receive_policy_name    = "sqs-multihashes-receive"
multihashes_delete_policy_name     = "sqs-multihashes-delete"
config_bucket_read_policy_name     = "s3-config-peer-bucket-read"
dotstorage_bucket_read_policy_name = "s3-dotstorage-prod-0-read"
