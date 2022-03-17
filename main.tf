####################################################

# VPC Creation

####################################################

data "aws_availability_zones" "available" {}

module vpc {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.2.0"
    name = "EKS-VPC-Sashi"
    cidr = "10.0.0.0/16"
    azs = data.aws_availability_zones.available.names
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets =  ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    tags = {
        "Name" = "EKS-VPC-Sashi"
    }
    public_subnet_tags = {
        "Name" = "Demo-Public-Subnet"
    }
    private_subnet_tags = {
        "Name" = "Demo-Private-Subnet"
    }
}

############################################################

# AWS Security Group

############################################################

resource "aws_security_group" "worker_mgmt" {
    name_prefix = "worker_management"
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [
            "10.0.0.0/8"
        ]
    }
}


#########################################################################

# Cluster Creation

#########################################################################

module "eks"{
    source = "terraform-aws-modules/eks/aws"
    version = "17.1.0"
    cluster_name = local.cluster_name
    cluster_version = "1.20"
    subnets = module.vpc.private_subnets
    tags = {
        Name = "Demo-EKS-Cluster"
    }
    vpc_id = module.vpc.vpc_id
    workers_group_defaults = {
        root_volume_type = "gp2"
    }
    worker_groups = [
        {
            name = "Worker-Group"
            instance_type = "t2.small"
            asg_desired_capacity = 3
            additional_security_group_ids = [aws_security_group.worker_mgmt.id]
        }
    ]
}

data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

#########################################################################

# Grafana

#########################################################################

data "template_file" "grafana_values" {

    template = file("grafana-values.yaml")


    vars = {

      GRAFANA_SERVICE_ACCOUNT = "grafana"

      GRAFANA_ADMIN_USER = "admin"

      GRAFANA_ADMIN_PASSWORD = "password"

      NAMESPACE = "grafana"

    }

}


resource "helm_release" "grafana" {
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "grafana"
  name       = "grafana"
  namespace  = "grafana"
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  
}








