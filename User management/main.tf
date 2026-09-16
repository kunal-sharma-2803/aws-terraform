# creating Iam Users
resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  name = "${substr(each.value.first_name, 0, 1)}${each.value.last_name}"
  # format Ksharma, Dkaushik

  path = "/users/"

  tags = {
    "Display-Name" = "${each.value.first_name} ${each.value.last_name}"
    "Department"   = each.value.department
    "Job-Title"    = each.value.job_title
  }
}


# creting Iam user login profile (password )
resource "aws_iam_user_login_profile" "example" {
  for_each = aws_iam_user.users

  user                    = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }

}

# creating iam groups 
resource "aws_iam_group" "iam_groups" {
  for_each = toset([for user in local.users : user.department])
  name     = replace(each.value," ","-")
  path     = "/groups/"
}

# putting users in respective departments
resource "aws_iam_group_membership" "iam_group_members" {

  for_each = aws_iam_group.iam_groups
  name = "${each.value.name}-group-membership"
  group = aws_iam_group.iam_groups[each.key].name

  users = [
    for user in aws_iam_user.users:
        user.name if user.tags.Department == each.value
  ]
}
