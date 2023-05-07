output "sonarqube_public_ip" {
  value = aws_instance.Sonarqube.public_ip
}

output "nexus_public_ip" {
  value = aws_instance.Nexus.public_ip
}

output "maven_public_ip" {
  value = aws_instance.Maven.public_ip
}