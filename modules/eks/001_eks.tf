#########################################################################################################
## Create eks cluster
#########################################################################################################
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = var.cluster-name
  cluster_version = var.cluster-version
  iam_role_use_name_prefix = false

  # API 서버가 밖으로 나가야하는지 
  cluster_endpoint_public_access  = true
  # 밖으로 나갈 필요 없을 때 
  cluster_endpoint_private_access = true
  
  # EKS에서 사용해야할 추가 기능들 설정 
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      cluster_name = var.cluster-name
      most_recent = true
    }
    aws-ebs-csi-driver = {
      cluster_name             = var.cluster-name
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
    # EFS를 사용해야할 때
    aws-efs-csi-driver = {
      cluster_name             = var.cluster-name
      service_account_role_arn = module.efs_csi_irsa_role.iam_role_arn
    }
  }

  # 해당 cluster가 관리할 VPC와 서브넷 
  vpc_id                   = data.aws_vpc.eks_vpc.id
  subnet_ids               = ["subnet-0077620333280526d", "subnet-01480e62953b41d7a", "subnet-056ca5878cfe2a414", "subnet-04e20f2e53da38171"]

  # EKS Managed Node Group
  eks_managed_node_group_defaults = {
    instance_types = ["c7i.large"]
  }

  eks_managed_node_groups = {
    web = {
      name = "stg-web-nodegroup"
			# min, max size를 변경해야함.d
      min_size     = 3
      max_size     = 6 
      desired_size = 3
      # instance_types = ["c7i.large"]
			# which subnets node-group should be located 
			subnet_ids = ["subnet-056ca5878cfe2a414", "subnet-04e20f2e53da38171"]
			# for auto scaling
			tags = {
		    Environment = "dev"
			  Terraform   = "true"
		  }
			labels = {
		    server = "web"
		  }
    }
    was = {
      name = "stg-was-nodegroup"
      min_size     = 3
      max_size     = 6
      desired_size = 3
      # instance_types = ["c7i.large"]
			# which subnets node-group should be located 
			subnet_ids = ["subnet-01480e62953b41d7a", "subnet-0077620333280526d"]
			# for auto scaling
			tags = {
		    Environment = "dev"
			  Terraform   = "true"
		  }
			labels = {
		    server = "was"
		  }
    }
  }
  
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
    common = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "efs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}


############################################################################################
## 로드밸런서 콘트롤러 설정
## EKS 에서 Ingress 를 사용하기 위해서는 반듯이 로드밸런서 콘트롤러를 설정 해야함.
## 참고 URL : https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html
############################################################################################

######################################################################################################################
# 로컬변수
# 쿠버네티스 추가 될때마다 lb_controller_iam_role_name 을 추가해야함.
######################################################################################################################

locals {
  # data-eks 를 위한 role name
  wave_eks_lb_controller_iam_role_name = "wave-eks-aws-lb-controller-role"

  k8s_aws_lb_service_account_namespace = "kube-system"
  lb_controller_service_account_name   = "aws-load-balancer-controller"
}

######################################################################################################################
# EKS 클러스터 인증 데이터 소스 추가
######################################################################################################################

data "aws_eks_cluster_auth" "wave-eks" {
  name = var.cluster-name
}

######################################################################################################################
# Load Balancer Controller ROLE 설정
######################################################################################################################

# load balancer controller에 role을 부여하도록 설정함.
module "wave_eks_lb_controller_role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "v5.1.0"
  create_role = true

  # 아래의 경로에 존재하는 role을 사용할 것임.
  role_name        = local.wave_eks_lb_controller_iam_role_name
  role_path        = "/"
  role_description = "Used by AWS Load Balancer Controller for EKS"

  role_permissions_boundary_arn = ""

  provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${local.k8s_aws_lb_service_account_namespace}:${local.lb_controller_service_account_name}"
  ]
  oidc_fully_qualified_audiences = [
    "sts.amazonaws.com"
  ]
}
