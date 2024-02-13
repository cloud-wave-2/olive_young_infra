######################################################################################################################
# IAM Policy 설정
######################################################################################################################

# Load balancer의 iam_policy를 깃허브에서 가져옴
data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json"
}

# 이를 사용하여 load balancer controller에 대한 역할을 생성함.
resource "aws_iam_role_policy" "wave-eks-controller" {
  name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  role        = module.wave_eks_lb_controller_role.iam_role_name
  policy      = data.http.iam_policy.response_body
}
