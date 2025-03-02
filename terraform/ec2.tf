

resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile = aws_iam_instance_profile.InstanceProfile.name
  key_name = var.key_name
  metadata_options {
    http_tokens = "required"
  }

  
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 11
    volume_type = "gp2"
    encrypted = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get -y install git binutils rustc cargo pkg-config libssl-dev gettext
              git clone https://github.com/aws/efs-utils
              cd efs-utils
              ./build-deb.sh
              apt-get -y install ./build/amazon-efs-utils*deb
              mkdir -p /mnt/efs
              mount -t efs ${aws_efs_file_system.main.id}:/ /mnt/efs
              echo "${aws_efs_file_system.main.id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab
              curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt-get install -y nodejs
              EOF

  tags = {
    Name = "${var.system}-${var.env}-ec2"
  }
}

# resource "aws_lb_target_group_attachment" "main" {
#   target_group_arn = aws_lb_target_group.main.arn
#   target_id        = aws_instance.main.id
#   port             = 80
# }