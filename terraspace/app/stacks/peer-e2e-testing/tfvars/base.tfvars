## TODO: https://www.notion.so/IPFS-Elastic-Provider-log-868adc5d3a8f4094bf5cd0eb26679c15?v=6224285d255941269d9a8aee6b6c6171&p=18fa9755d88e4763afb86848735a5c43
subnet_id         = "subnet-06ff59acbc0a34548" # management-ipfs-elastic public subnet
security_group_id = "sg-0da8ec52f04fcca8d"
key_name          = "management-ipfs-elastic"
##
peer_e2e_testing_ami_name = "peer-e2e-testing"
ec2_instance_name      = "<%= expansion(':ENV') %>-ep-peer-e2e-testing"
