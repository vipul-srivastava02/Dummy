output "web_server_ip" {
  value = aws_instance.web.public_ip
}

output "app_server_ip" {
  value = aws_instance.app.private_ip
}

output "db_server_ip" {
  value = aws_instance.db.private_ip
}
