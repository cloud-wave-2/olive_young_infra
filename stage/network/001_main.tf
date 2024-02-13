module "webserver_cluster" {
  source = "../../modules/network"

  vpc_name = "stg-ecommerce-vpc"
  public_subnet_a_name = "stg-ecommerce-subnet-pub01a"
  public_subnet_c_name = "stg-ecommerce-subnet-pub01c"
  private_subnet_01a_name = "stg-ecommerce-subnet-pri01a"
  private_subnet_01c_name = "stg-ecommerce-subnet-pri01c"
  private_subnet_02a_name = "stg-ecommerce-subnet-pri02a"
  private_subnet_02c_name = "stg-ecommerce-subnet-pri02c"
  internet_gateway_name = "stg-ecommerce-igw"

  nat_gateway_a_name = "stg-ecommerce-ngw-pub01a"
  nat_gateway_c_name = "stg-ecommerce-ngw-pub02a"

  public_rtb_a_name = "stg-ecommerce-rtb-pub01a"
  public_rtb_c_name = "stg-ecommerce-rtb-pub01c"

  private_rtb_01a_name = "stg-ecommerce-rtb-pri01a"
  private_rtb_01c_name = "stg-ecommerce-rtb-pri01c"
  private_rtb_02a_name = "stg-ecommerce-rtb-pri02a"
  private_rtb_02c_name = "stg-ecommerce-rtb-pri02c"

  cluster-name = "stg-ecommerce-eks"
  
}