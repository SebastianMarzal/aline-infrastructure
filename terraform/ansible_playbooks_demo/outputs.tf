output "control_node_dns" {
  value = aws_instance.control.public_dns
}

output "worker_node_dns" {
  value = aws_instance.workers[*].public_dns
}

output "worker_node_amis" {
  value = aws_instance.workers[*].ami
}