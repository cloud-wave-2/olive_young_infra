module "bastion" {
    source = "../../modules/bastion"

    key_name = "stg-ecommerce-eksBastion-keypair"
    bastion_name = "stg-ecommerce-eksBastion-pub01a"

    iam_role_name = "stg-ecommerce-eksBastion-iam"
    iam_instance_profile_name = "stg-ecommerce-eksBastion-profile"
    
    vpc_name = "stg-ecommerce-vpc"
    subnet_name = "stg-ecommerce-subnet-pub01a"

    cluster-name = "stg-ecommerce-eks"
}