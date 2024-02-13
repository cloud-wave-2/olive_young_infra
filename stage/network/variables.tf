data "aws_vpc" "bastion_vpc"{
  filter {
     name = "tag-key"
     values = ["Name"]
   }
  filter {
     name = "tag-value"
     values = ["stg-ecommerce-vpc"]
   }
}

data "aws_subnets" "bastion_subnet" { 
    filter {
     name = "tag-key"
     values = ["kubernetes.io/cluster/stg-ecommerce-eks"]
   }
   filter {
     name = "tag-value"
     values = ["shared"]
   }
}
