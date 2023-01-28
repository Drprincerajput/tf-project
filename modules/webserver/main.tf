resource "aws_security_group" "myapp-sg" {
   
    vpc_id = var.vpc_id
    name = "myapp-sg"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []

    }
    tags = {
           Name: "${var.env_prefix}-def-sg"
       }
}

data "aws_ami" "latest-amz-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        # values = ["amzn2-ami-hvm-*-x86_64-gp2"]
        values = [var.image_name]
    }
}



resource "aws_key_pair" "ssh_key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)


}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amz-linux-image.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh_key.key_name

    user_data = file("modules/webserver/ud-script.sh")

    tags = {
               Name: "${var.env_prefix}-server"
        }

}