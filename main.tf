provider "alicloud" {
  access_key = "xxxxxxxx-xxxxxxxxx"
  secret_key = "xxxxxxxx-xxxxxxxxx"
  region     = "cn-hangzhou"
}

# 创建VPC
resource "alicloud_vpc" "vpc" {
  name = "terraform-vpc"
  cidr_block = "10.1.0.0/21"
}

# 添加vswitch。vswitch 必须位于指定的vswitch。
resource "alicloud_vswitch" "vsw" {
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "10.1.1.0/24"
  availability_zone = "cn-hangzhou-b"
}

# 增加安全组
resource "alicloud_security_group" "sg" {
  name   = "terraform-sg"
  vpc_id = "${alicloud_vpc.vpc.id}" 
}

# 设置安全组规则 22
resource "alicloud_security_group_rule" "allow_22" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

# 设置安全组规则 80
resource "alicloud_security_group_rule" "allow_80" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}
# 设置安全组规则 80
resource "alicloud_security_group_rule" "allow_3306" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "3306/3306"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

# 设置安全组规则 80
resource "alicloud_security_group_rule" "allow_5000" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "5000/5000"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}
# 创建ECS服务器
resource "alicloud_instance" "docker" {
  count = "16"
  instance_name = "terraform-ecs"
  password = "Test12345"
  allocate_public_ip = "true"
  internet_max_bandwidth_out = 10
  availability_zone = "cn-hangzhou-b"
  image_id = "ubuntu_16_0402_64_20G_alibase_20170818.vhd"
  instance_type = "ecs.n4.small"
  io_optimized = "optimized"
  system_disk_category = "cloud_efficiency"
  security_groups = ["${alicloud_security_group.sg.id}"] 
  vswitch_id = "${alicloud_vswitch.vsw.id}"
}
