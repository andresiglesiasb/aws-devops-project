# -------------------------------
# IAM GROUP
# -------------------------------
resource "aws_iam_group" "devops_student_group" {
  name = "devops-student-group-test"
}

# IAM Group Policy Attachments
resource "aws_iam_group_policy_attachment" "ec2_full" {
  group      = aws_iam_group.devops_student_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "vpc_full" {
  group      = aws_iam_group.devops_student_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_group_policy_attachment" "elb_full" {
  group      = aws_iam_group.devops_student_group.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_iam_group_policy_attachment" "iam_readonly" {
  group      = aws_iam_group.devops_student_group.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "cloudwatch_readonly" {
  group      = aws_iam_group.devops_student_group.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# -------------------------------
# IAM USER
# -------------------------------
resource "aws_iam_user" "devops_student" {
  name          = "devops-student-test"
  force_destroy = true # Allows deletion in "cascade" of the user, without it terra will fail if the user has resources attached
  tags          = var.common_tags
}

# Deliberately NOT created here: aws_iam_access_key and aws_iam_user_login_profile.
# Both write their secret (access key secret / console password) to terraform.tfstate
# in plain text, even when the output is marked sensitive. Create credentials out of
# band (console / `aws iam create-access-key`) or use a secrets manager instead.

# Add User to Group
resource "aws_iam_user_group_membership" "group_membership" {
  user   = aws_iam_user.devops_student.name
  groups = [aws_iam_group.devops_student_group.name]
}
