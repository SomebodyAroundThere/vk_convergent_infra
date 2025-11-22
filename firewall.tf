resource "vkcs_networking_secgroup" "secgroup_haproxy" {
  name        = "Sokolova_secgroup_haproxy"
  description = "My security group"
}
# Блок создания правила для группы безопасности
resource "vkcs_networking_secgroup_rule" "secgroup_rule_haproxy" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.secgroup_haproxy.id}"
}
resource "vkcs_networking_secgroup_rule" "secgroup_rule_haproxy1" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.secgroup_haproxy.id}"
}
resource "vkcs_networking_secgroup_rule" "secgroup_rule_haproxy2" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.secgroup_haproxy.id}"
}

resource "vkcs_networking_secgroup" "secgroup_app" {
  name        = "Sokolova_secgroup_app"
  description = "My security group"
}
# Блок создания правила для группы безопасности
resource "vkcs_networking_secgroup_rule" "secgroup_rule_app" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.secgroup_app.id}"
}
resource "vkcs_networking_secgroup_rule" "secgroup_rule_app1" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 5000
  port_range_max    = 5000
  remote_group_id   = vkcs_networking_secgroup.secgroup_haproxy.id
  security_group_id = "${vkcs_networking_secgroup.secgroup_app.id}"
}

resource "vkcs_networking_secgroup" "secgroup_db" {
  name        = "Sokolova_secgroup_db"
  description = "My security group"
}
# Блок создания правила для группы безопасности
resource "vkcs_networking_secgroup_rule" "secgroup_rule_db" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_group_id   = vkcs_networking_secgroup.secgroup_app.id
  security_group_id = "${vkcs_networking_secgroup.secgroup_db.id}"
}
