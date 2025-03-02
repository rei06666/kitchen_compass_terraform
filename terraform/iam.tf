resource "aws_iam_role" "InstanceRole" {
  name = "${var.system}-${var.env}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "InstanceProfile" {
  name = "${var.system}-${var.env}-instance-profile"
  role = aws_iam_role.InstanceRole.name
  path = "/"
}

resource "aws_iam_policy_attachment" "InstancePolicyAttachmentSSM" {
  name = "${var.system}-${var.env}-instance-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.InstanceRole.name]
}

resource "aws_iam_policy_attachment" "InstancePolicyAttachmentEFS" {
  name = "${var.system}-${var.env}-instance-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  roles      = [aws_iam_role.InstanceRole.name]
}




