// Create a new VPC.
resource "aws_vpc" "primary" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "${var.prefix}: Demo VPC"
  }
}
