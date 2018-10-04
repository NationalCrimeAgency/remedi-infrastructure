output "balancer_id" {
  description = "ID of the REMEDI balancer"
  value = "${aws_instance.balancer.id}"
}

output "processor_id" {
  description = "ID of the REMEDI processor"
  value = "${aws_instance.processor.id}"
}