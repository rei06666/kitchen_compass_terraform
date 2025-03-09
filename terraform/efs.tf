resource "aws_efs_file_system" "main" {
  creation_token = "${var.system}-${var.env}-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "private" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.efs.id]
}
