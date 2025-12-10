output "runs_on_stack_outputs" {
  description = "Map of outputs from the CloudFormation stack"
  value       = try(module.runs_on.stack_outputs, null)
}