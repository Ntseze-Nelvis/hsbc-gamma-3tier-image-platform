resource "aws_cloudwatch_log_group" "web" {
  name              = "/hsbc-gamma/web"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/hsbc-gamma/app"
  retention_in_days = 14
}


# # iam policy for cloudwatch logs (ec2 instances need permissions to create log groups/streams and put log events)
# resource "aws_iam_policy" "cw_logs_policy" {
#   name = "cloudwatch-logs-policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ]
#       Resource = "*"
#     }]
#   })
# }

# # then attach the policy to the web and app roles
# resource "aws_iam_role_policy_attachment" "web_logs" {
#   role       = aws_iam_role.web_role.name
#   policy_arn = aws_iam_policy.cw_logs_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "app_logs" {
#   role       = aws_iam_role.app_role.name
#   policy_arn = aws_iam_policy.cw_logs_policy.arn
# }
