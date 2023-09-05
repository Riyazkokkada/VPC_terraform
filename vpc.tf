#Do aws configure before
# aws configure
# AWS Access Key ID [****************LKXL]:
# AWS Secret Access Key [****************5lPU]:
# Default region name [ap-southeast-2]:
# Default output format [text]:
#
#
#



#VPC code
resource "aws_vpc" "riyaz-vpc"{
        cidr_block="10.0.0.0/16"
        tags ={
                Name="riyaz-vpc"
        }
}

#2. Subnet code
resource "aws_subnet" "riyaz-pub_subnet" {
  vpc_id     = aws_vpc.riyaz-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "riyaz-pub_subnet"
  }
}

resource "aws_subnet" "riyaz-pvt_subnet" {
  vpc_id     = aws_vpc.riyaz-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "riyaz-pvt_subnet"
  }
}

#code for Internet gateway
resource "aws_internet_gateway" "riyazIGW"{
    vpc_id = aws_vpc.riyaz-vpc.id
    tags = {
        Name = "riyazIGW"
    }
}

#Route table
resource "aws_route_table" "riyaz-pubRT" {
  vpc_id = aws_vpc.riyaz-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.riyazIGW.id
        }
   tags= {
        Name = "riyaz-pubRT"
    }
}

 #route table association
  resource "aws_route_table_association" "public_association"{
        subnet_id = aws_subnet.riyaz-pub_subnet.id
        route_table_id = aws_route_table.riyaz-pubRT.id
  }

  #Security group

resource "aws_security_group" "riyaz_tfSG" {
  name ="riyaz_tfSG"
  description="Allow TLS inbound traffic"

  vpc_id = aws_vpc.riyaz-vpc.id


   ingress {
    description      = "TLS from VPC " 
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "riyaz_tfsg"
  }
}

#Web server
resource "aws_instance" "riyaz-webserver" {
    ami= "ami-0f409bae3775dc8e5"
    instance_type ="t2.micro"
    subnet_id = aws.subnet.riyaz-pub_subnet.id
    vpc_security_group_ids =  [aws_security_group.riyaz_tfSG]
    key_name = "sydney-key"# should present in particular region

    tags ={
        Name ="riyaz-webserver"
    }

}
  
