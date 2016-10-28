# Outputs
output "private_ip" {
  value = "${aws_instance.server.private_ip}"
}
#output "public_ip" {
#  value = "${aws_instance.server.public_ip}"
#}
output "security_group_id" {
  value = "${aws_security_group.server.id}"
}
output "elastic_ip" {
  value = "${aws_eip.elastic_ip.public_ip}"
}
