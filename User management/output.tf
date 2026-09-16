# how to get values from the local map
# output "user_names" {
#   value = [ for user in local.users: "${user.first_name}-${user.last_name}" ]
# }

# output "account_id" {
#   value = data.aws_caller_identity.account_id
# }

# output "users" {
#   value = [ for user in local.users : user]
# }

# output "iam_groups" {
#   value = aws_iam_group.iam_groups
# }