data "aws_s3_bucket" "model_bucket" {
  bucket = "${var.model_bucket}"
}

data "template_file" "processor" {
  template = "${file("${path.module}/templates/processor-user-data.tpl")}"

  vars {
    truecaser = "${var.truecaser}"
    cert = "${var.processor_certificate}"
    cert_key = "${var.processor_certificate_key}"
    ciphers = "${var.ciphers}"
  }
}

resource "aws_instance" "processor" {
  ami                   = "${var.ami_id}"
  subnet_id             = "${var.subnet_id}"
  instance_type         = "t2.large"
  key_name              = "${var.key_name}"

  iam_instance_profile  = "${aws_iam_instance_profile.remedi.id}"
  security_groups = ["${aws_security_group.remedi.id}"]

  tags = "${merge(map("Name", "remedi-processor"), "${var.tags}")}"
  user_data = "${data.template_file.processor.rendered}"
}

resource "aws_route53_record" "processor" {
  zone_id = "${var.zone_id}"
  name = "remedi-processor"
  type = "A"
  ttl  = "300"
  records = ["${aws_instance.processor.private_ip}"]
}

data "template_file" "balancer" {
  template = "${file("${path.module}/templates/balancer-user-data.tpl")}"

  vars {
    server_count = "${var.server_instances * length(var.languages)}"
    domain = "${substr(data.aws_route53_zone.zone.name, 0, length(data.aws_route53_zone.zone.name) - 1)}"
    cert = "${var.balancer_certificate}"
    cert_key = "${var.balancer_certificate_key}"
    ciphers = "${var.ciphers}"
  }
}

data aws_route53_zone "zone" {
  zone_id = "${var.zone_id}"
}

resource "aws_instance" "balancer" {
  ami                   = "${var.ami_id}"
  subnet_id             = "${var.subnet_id}"
  instance_type         = "t2.medium"
  key_name              = "${var.key_name}"

  iam_instance_profile  = "${aws_iam_instance_profile.remedi.id}"
  security_groups = ["${aws_security_group.remedi.id}"]

  tags = "${merge(map("Name", "remedi-balancer"), "${var.tags}")}"
  user_data = "${data.template_file.balancer.rendered}"
}

resource "aws_route53_record" "balancer" {
  zone_id = "${var.zone_id}"
  name = "remedi-balancer"
  type = "A"
  ttl  = "300"
  records = ["${aws_instance.balancer.private_ip}"]
}

data "template_file" "server" {
  template = "${file("${path.module}/templates/server-user-data.tpl")}"

  count = "${var.server_instances * length(var.languages)}"

  vars {
    models_bucket = "${data.aws_s3_bucket.model_bucket.id}"
    language = "${element(var.languages, count.index)}"
    language_name = "${element(var.language_names, count.index)}"
    model_volume_size = "${var.model_volume_size}"
  }
}

resource "aws_instance" "server" {
  ami                   = "${var.ami_id}"
  subnet_id             = "${var.subnet_id}"
  instance_type         = "m5.4xlarge"
  key_name              = "${var.key_name}"

  iam_instance_profile  = "${aws_iam_instance_profile.remedi.id}"
  security_groups = ["${aws_security_group.remedi.id}"]

  ebs_block_device {
    device_name = "/dev/sdg"
    volume_type = "gp2"
    volume_size = "${var.model_volume_size}"
    encrypted = true
  }

  count = "${var.server_instances * length(var.languages)}"

  tags = "${merge(map("Name", "remedi-server", "Language", element(var.languages, count.index)), "${var.tags}")}"
  user_data = "${element(data.template_file.server.*.rendered, count.index)}"
}

resource "aws_route53_record" "server" {
  count = "${var.server_instances * length(var.languages)}"
  zone_id = "${var.zone_id}"
  name = "remedi-server-${count.index + 1}"
  type = "A"
  ttl  = "300"
  records = ["${element(aws_instance.server.*.private_ip, count.index)}"]
}

## Securty and IAM

resource "aws_security_group" "remedi" {
  name = "remedi"
  vpc_id = "${var.vpc_id}"

  # SSH access
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cidrs}"]
  }

  # REMEDI access
  ingress {
    from_port = 9001
    to_port = 9003
    protocol = "tcp"
    cidr_blocks = ["${var.cidrs}"]
  }

  # Speak to yum
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Speak to AWS
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Speak to other REMEDI machines
  egress {
    from_port = 9001
    to_port = 9003
    protocol = "tcp"
    self = true
  }

  tags {
    Name = "remedi"
  }
}

resource "aws_iam_role" "remedi" {
  name               = "remedi"
  assume_role_policy = "${data.aws_iam_policy_document.assume-policy.json}"
}

data "aws_iam_policy_document" "assume-policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = "${aws_iam_role.remedi.name}"
}

resource "aws_iam_role_policy" "remedi_access_policy" {
  name     = "access_policy"
  role     = "${aws_iam_role.remedi.id}"

  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "RemediS3",
          "Effect": "Allow",
          "Action": [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListObjects"
          ],
          "Resource": [
              "${data.aws_s3_bucket.model_bucket.arn}",
              "${data.aws_s3_bucket.model_bucket.arn}/*"
          ]
        }
    ]
}


EOF
}

resource "aws_iam_instance_profile" "remedi" {
  name = "remedi"
  path = "/"
  role = "${aws_iam_role.remedi.name}"
}

resource "aws_iam_role_policy_attachment" "kms" {
  role       = "${aws_iam_role.remedi.name}"
  policy_arn = "${var.kms_policy_arn}"
}
