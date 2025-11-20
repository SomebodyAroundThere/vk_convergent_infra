variable "db-instance-flavor" {
  type    = string
  default = "STD2-2-8"
}

variable "db_user_password" {
  type      = string
  sensitive = true
}

data "vkcs_compute_flavor" "db" {
  name = var.db-instance-flavor
}

resource "vkcs_compute_keypair" "ssh" {
  # Название SSH-ключа. Ключ будет отображаться в настройках аккаунта на вкладке *Ключевые пары*
  name = "terraform_ssh_key"
  # Путь до открытого ключа
  public_key = file("${path.module}/id_rsa.pub")

}
resource "vkcs_compute_keypair" "ssh1" {
  # Название SSH-ключа. Ключ будет отображаться в настройках аккаунта на вкладке *Ключевые пары*
  name = "terraform_ssh_key1"
  # Путь до открытого ключа
  public_key = file("${path.module}/id_rsa1.pub")

}
resource "vkcs_compute_keypair" "ssh2" {
  # Название SSH-ключа. Ключ будет отображаться в настройках аккаунта на вкладке *Ключевые пары*
  name = "terraform_ssh_key2"
  # Путь до открытого ключа
  public_key = file("${path.module}/id_rsa2.pub")

}
resource "vkcs_compute_keypair" "ssh3" {
  # Название SSH-ключа. Ключ будет отображаться в настройках аккаунта на вкладке *Ключевые пары*
  name = "terraform_ssh_key3"
  # Путь до открытого ключа
  public_key = file("${path.module}/id_rsa3.pub")

}

resource "vkcs_db_instance" "db-instance" {
  name        = "Sokolova_db_MYSQL8"
  #keypair = "${vkcs_compute_keypair.ssh.name}"
  datastore {
    type    = "mysql"
    version = "8.0"
  }
  #floating_ip_enabled = true
  flavor_id   = data.vkcs_compute_flavor.db.id
  size        = 8
  volume_type = "ceph-ssd"
  disk_autoexpand {
    autoexpand    = true
    max_disk_size = 1000
  }
  network {
    uuid = vkcs_networking_network.network.id
    security_groups = [vkcs_networking_secgroup.secgroup_db.id]
  }
}

resource "vkcs_db_database" "db-database" {
  name        = "testdb-Sokolova"
  dbms_id = vkcs_db_instance.db-instance.id
  charset     = "utf8"
}
resource "vkcs_db_user" "db-user" {
  name        = "testuser"
  password    = var.db_user_password
  dbms_id = vkcs_db_instance.db-instance.id
  databases   = [vkcs_db_database.db-database.name]
}
data "vkcs_compute_flavor" "compute" {
  name = var.compute_flavor
}

data "vkcs_images_image" "compute" {
  visibility = "public"
  default    = true
  properties = {
    mcs_os_distro  = "ubuntu"
    mcs_os_version = "22.04"
  }
}

resource "vkcs_compute_instance" "compute1" {
  name                    = "Ubuntu-Sokolova-haproxy"
  flavor_id               = data.vkcs_compute_flavor.compute.id
  key_pair                = "${vkcs_compute_keypair.ssh1.name}"
  security_group_ids      = [vkcs_networking_secgroup.secgroup_haproxy.id]
  availability_zone       = "MS1"

  block_device {
    uuid                  = data.vkcs_images_image.compute.id
    source_type           = "image"
    destination_type      = "volume"
    volume_type           = "ceph-ssd"
    volume_size           = 10
    boot_index            = 0
    delete_on_termination = true
  }
  network {
    uuid = vkcs_networking_network.network.id
  }

  depends_on = [
    vkcs_networking_network.network,
    vkcs_networking_subnet.subnet
  ]

}

resource "vkcs_compute_instance" "compute2" {
  name                    = "Ubuntu-Sokolova-app1"
  flavor_id               = data.vkcs_compute_flavor.compute.id
  key_pair                = "${vkcs_compute_keypair.ssh2.name}"
  security_group_ids      = [vkcs_networking_secgroup.secgroup_app.id]
  availability_zone       = "GZ1"

  block_device {
    uuid                  = data.vkcs_images_image.compute.id
    source_type           = "image"
    destination_type      = "volume"
    volume_type           = "ceph-ssd"
    volume_size           = 10
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid = vkcs_networking_network.network.id
  }

  depends_on = [
    vkcs_networking_network.network,
    vkcs_networking_subnet.subnet
  ]

}

resource "vkcs_compute_instance" "compute3" {
  name                    = "Ubuntu-Sokolova-app2"
  flavor_id               = data.vkcs_compute_flavor.compute.id
  key_pair                = "${vkcs_compute_keypair.ssh3.name}"
  security_group_ids      = [vkcs_networking_secgroup.secgroup_app.id]
  availability_zone       = "ME1"

  block_device {
    uuid                  = data.vkcs_images_image.compute.id
    source_type           = "image"
    destination_type      = "volume"
    volume_type           = "ceph-ssd"
    volume_size           = 10
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid = vkcs_networking_network.network.id
  }

  depends_on = [
    vkcs_networking_network.network,
    vkcs_networking_subnet.subnet
  ]

}
resource "vkcs_networking_floatingip" "fip1" {
  pool = data.vkcs_networking_network.extnet.name
}

resource "vkcs_networking_floatingip" "fip2" {
  pool = data.vkcs_networking_network.extnet.name
}

resource "vkcs_networking_floatingip" "fip3" {
  pool = data.vkcs_networking_network.extnet.name
}

resource "vkcs_compute_floatingip_associate" "fip1" {
  floating_ip = vkcs_networking_floatingip.fip1.address
  instance_id = vkcs_compute_instance.compute1.id
}

output "instance_fip1" {
  value = vkcs_networking_floatingip.fip1.address
}
resource "vkcs_compute_floatingip_associate" "fip2" {
  floating_ip = vkcs_networking_floatingip.fip2.address
  instance_id = vkcs_compute_instance.compute2.id
}

output "instance_fip2" {
  value = vkcs_networking_floatingip.fip2.address
}
resource "vkcs_compute_floatingip_associate" "fip3" {
  floating_ip = vkcs_networking_floatingip.fip3.address
  instance_id = vkcs_compute_instance.compute3.id
}

output "instance_fip3" {
  value = vkcs_networking_floatingip.fip3.address
}

