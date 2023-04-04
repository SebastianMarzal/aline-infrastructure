output "awx_dns" {
  value = aws_instance.awx.public_dns
}

output "worker_dns" {
  value = aws_instance.workers[*].public_dns
}