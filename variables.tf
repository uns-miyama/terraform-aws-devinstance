variable "prefix" {
  description = "リソースの接頭辞の指定。名前などを一意の値を入力"
}
variable "vpc_cidr_block" {
  description = "VPC CIDR ブロックの設定。デフォルト値は`10.0.0.0/16`"
  default = "10.0.0.0/16"
}
variable "subnet_prefix" {
  description = "Subnet レンジの設定。デフォルト値は`10.0.0.0/24`"
  default = "10.0.10.0/24"
}
variable "ami" {
  description = "AMI IDの指定。Ubuntu Linuxを推奨"
  default = "ami-06d9ad3f86032262d"
}
variable "hello_tf_instance_type" {
  description = "インスタンスのサイズの指定"
  default = "t2.micro"
}
variable "route_table_cidr_block" {
  description = "Route Tableの CIDR ブロックの設定。デフォルト値は0.0.0.0/0"
  default = "0.0.0.0/0"
}
