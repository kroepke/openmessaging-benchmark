provider "aws" {
  region  = var.region
  version = "~> 2.7"
  profile = "default"
}

provider "random" {
  version = "2.1"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/pulsar_aws.pub
DESCRIPTION
}

resource "random_id" "hash" {
  byte_length = 8
}

variable "key_name" {
  default     = "pulsar-benchmark-key"
  description = "Desired name prefix for the AWS key pair"
}

variable "region" {}

variable "instance_types" {
  type = map(string)
}

variable "num_instances" {
  type = map(string)
}

variable "ami_per_region" {
  type = map(string)
}

# Create a VPC to launch our instances into
resource "aws_vpc" "benchmark_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Pulsar-Benchmark-VPC-${random_id.hash.hex}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "pulsar" {
  vpc_id = aws_vpc.benchmark_vpc.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.benchmark_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pulsar.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "benchmark_subnet" {
  vpc_id                  = aws_vpc.benchmark_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}

# Get public IP of this machine
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "benchmark_security_group" {
  name   = "terraform-pulsar-${random_id.hash.hex}"
  vpc_id = aws_vpc.benchmark_vpc.id

  # All ports open within the VPC
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # All ports open to this machine
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Benchmark-Security-Group-${random_id.hash.hex}"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}-${random_id.hash.hex}"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "zookeeper" {
  ami                    = var.ami_per_region[var.region]
  instance_type          = var.instance_types["zookeeper"]
  key_name               = aws_key_pair.auth.id
  subnet_id              = aws_subnet.benchmark_subnet.id
  vpc_security_group_ids = [aws_security_group.benchmark_security_group.id]
  count                  = var.num_instances["zookeeper"]

  tags = {
    Name = "zk-${count.index}"
  }
}

resource "aws_instance" "pulsar" {
  ami                    = var.ami_per_region[var.region]
  instance_type          = var.instance_types["pulsar"]
  key_name               = aws_key_pair.auth.id
  subnet_id              = aws_subnet.benchmark_subnet.id
  vpc_security_group_ids = [aws_security_group.benchmark_security_group.id]
  count                  = var.num_instances["pulsar"]

  tags = {
    Name = "pulsar-${count.index}"
  }
}

resource "aws_instance" "client" {
  ami                    = var.ami_per_region[var.region]
  instance_type          = var.instance_types["client"]
  key_name               = aws_key_pair.auth.id
  subnet_id              = aws_subnet.benchmark_subnet.id
  vpc_security_group_ids = [aws_security_group.benchmark_security_group.id]
  count                  = var.num_instances["client"]

  tags = {
    Name = "pulsar-client-${count.index}"
  }
}

resource "aws_instance" "prometheus" {
  ami                    = var.ami_per_region[var.region]
  instance_type          = var.instance_types["prometheus"]
  key_name               = aws_key_pair.auth.id
  subnet_id              = aws_subnet.benchmark_subnet.id
  vpc_security_group_ids = [aws_security_group.benchmark_security_group.id]
  count                  = var.num_instances["prometheus"]

  tags = {
    Name = "prometheus-${count.index}"
  }
}

output "client_ssh_host" {
  value = aws_instance.client[0].public_ip
}

output "client1" {
  value = aws_instance.client[1].public_ip
}

output "client2" {
  value = aws_instance.client[2].public_ip
}

output "client3" {
  value = aws_instance.client[3].public_ip
}

output "prometheus_host" {
  value = aws_instance.prometheus[0].public_ip
}

output "server0" {
  value = aws_instance.pulsar[0].public_ip
}

output "server1" {
  value = aws_instance.pulsar[1].public_ip
}

output "server2" {
  value = aws_instance.pulsar[2].public_ip
}

output "zk0" {
  value = aws_instance.zookeeper[0].public_ip
}

output "zk1" {
  value = aws_instance.zookeeper[1].public_ip
}

output "zk2" {
  value = aws_instance.zookeeper[2].public_ip
}


