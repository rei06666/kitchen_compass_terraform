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
  name       = "${var.system}-${var.env}-instance-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.InstanceRole.name]
}

resource "aws_iam_policy_attachment" "InstancePolicyAttachmentEFS" {
  name       = "${var.system}-${var.env}-instance-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  roles      = [aws_iam_role.InstanceRole.name]
}

resource "aws_iam_policy_attachment" "InstancePolicyAttachmentCodeDeploy" {
  name       = "${var.system}-${var.env}-instance-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  roles      = [aws_iam_role.InstanceRole.name]
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.system}-${var.env}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticbeanstalk:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      }
    ]
  })
}



resource "aws_iam_role" "codedeploy_role" {
  name = "${var.system}-${var.env}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ServiceRolePolicyAttachmentCodeDeploy" {
  name       = "${var.system}-${var.env}-service-role-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  roles      = [aws_iam_role.codedeploy_role.name]
}


