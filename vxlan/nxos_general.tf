
locals {
  # device_interface_map = {
  #   for device in try(local.devices, []) : device.name => {
  #     for interface in try(device.interfaces, []) : interface.id => {
  #       key         = format("%s-%s", device.name, interface.id)
  #       id          = interface.id
  #       name        = device.name
  #       ip          = interface.ip
  #       peering_ip  = try(interface.peering_ip, "")
  #       description = try(interface.description, "Configured by Terraform")
  #       mtu         = try(interface.mtu, 9216)
  #       speed       = try(interface.speed, "auto")
  #       layer       = try(interface.layer, "Layer3")
  #       link_type   = interface.link_type
  #     }
  #   }
  # }

  # bgp_global = {
  #   bgp_asn          = 65000
  #   vrf              = "default"
  #   routing_loopback = "lo0"
  #   vtep_loopback    = "lo1"
  #   rp_loopback      = "lo250"
  # }

  # ospf_global = {
  #   area_id       = "0.0.0.0"
  #   vrf           = "default"
  #   instance_name = "OSPF1"
  # }


}
