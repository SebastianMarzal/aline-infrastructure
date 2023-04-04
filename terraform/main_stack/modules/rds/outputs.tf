output "db_identifier" {
    value = aws_db_instance.this.identifier
}

output "db_id" {
    value = aws_db_instance.this.id
}

output "db_url" {
    value = aws_db_instance.this.address
}