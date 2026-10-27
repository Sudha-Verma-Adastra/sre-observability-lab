data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "vpc" {
  source = "git::https://github.com/Sudha-Verma-Adastra/terraform-aws-platform-modules.git//modules/vpc?ref=main"

  name                 = "${var.project_name}-${var.environment}"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway = true
  nat_gateway_mode   = "single"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "ec2_ssm_role" {
  source = "git::https://github.com/Sudha-Verma-Adastra/terraform-aws-platform-modules.git//modules/iam-role?ref=main"

  role_name         = "${var.project_name}-${var.environment}-ec2-ssm"
  trust_type        = "service"
  service_principal = "ec2.amazonaws.com"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-${var.environment}-instance-profile"
  role = module.ec2_ssm_role.role_name
}

module "observability_host" {
  source = "git::https://github.com/Sudha-Verma-Adastra/terraform-aws-platform-modules.git//modules/compute?ref=main"

  name          = "${var.project_name}-${var.environment}-host"
  ami_id        = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  iam_instance_profile_name   = aws_iam_instance_profile.this.name
  associate_public_ip_address = false
  root_volume_size            = 30

  # No inbound ports are exposed. Use Systems Manager
  # Session Manager for administrative access.
  ingress_rules = []

  tags = {
    Name        = "${var.project_name}-${var.environment}-host"
    Project     = var.project_name
    Environment = var.environment
  }
}
