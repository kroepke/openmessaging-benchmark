public_key_path = "~/.ssh/pulsar_aws.pub"
region          = "us-west-2"

instance_types = {
  "pulsar"      = "i3en.2xlarge"
  "zookeeper"   = "t2.small"
  "client"      = "c5.2xlarge"
  "prometheus"  = "t2.small"
}

num_instances = {
  "client"      = 4
  "pulsar"      = 3
  "zookeeper"   = 3
  "prometheus"  = 1
}

ami_per_region = {
  "eu-north-1" : "ami-00b58289121a373eb"
  "ap-south-1" : "ami-076c98a5e1ae50b38"
  "eu-west-3" : "ami-0ecd678c334f50475"
  "eu-west-2" : "ami-014ec3973fd627c70"
  "eu-west-1" : "ami-0dc09040ff55c0cae"
  "ap-northeast-2" : "ami-01d1eee3b48c9ad02"
  "ap-northeast-1" : "ami-038a794b902fa0afc"
  "sa-east-1" : "ami-0c8c472213613e73a"
  "ca-central-1" : "ami-045a1fd6de0a3b39e"
  "ap-southeast-1" : "ami-030191cbee64dcc9f"
  "ap-southeast-2" : "ami-0c854fdd51006d91a"
  "eu-central-1" : "ami-02ab606eae7264892"
  "us-east-1" : "ami-08e923f2f38197e46"
  "us-east-2" : "ami-0aaba9ba5c26d33c7"
  "us-west-1" : "ami-0b3f30648b83fb82e"
  "us-west-2" : "ami-0be2c515a090d16b0"
}
