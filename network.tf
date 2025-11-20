data "vkcs_networking_network" "extnet" {
  name = "internet"
}

resource "vkcs_networking_network" "network" {
  name           = "Sokolova-net"
  admin_state_up = true
}

resource "vkcs_networking_subnet" "subnet" {
  name            = "Sokolova-subnet"
  network_id      = vkcs_networking_network.network.id
  cidr            = "192.168.200.0/24"
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "vkcs_networking_router" "router" {
  name                = "Sokolova-router"
  admin_state_up      = true
  external_network_id = data.vkcs_networking_network.extnet.id
}

resource "vkcs_networking_router_interface" "int" {
  router_id = vkcs_networking_router.router.id
  subnet_id = vkcs_networking_subnet.subnet.id
}
