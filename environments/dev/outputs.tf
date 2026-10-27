output "vpc_id" {
  description = "ID of the lab VPC."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "instance_id" {
  description = "Observability host EC2 instance ID."
  value       = module.observability_host.instance_id
}

output "instance_private_ip" {
  description = "Private IP address of the observability host."
  value       = module.observability_host.private_ip
}

output "instance_security_group_id" {
  description = "Security group attached to the observability host."
  value       = module.observability_host.security_group_id
}
