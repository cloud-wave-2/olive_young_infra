module "stage-eks" {
    source = "../../modules/eks"
    cluster-name = "stg-ecommerce-eks"
    vpc_name = "stg-ecommerce-vpc"

}