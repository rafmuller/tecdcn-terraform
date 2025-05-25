# .______    __  .___  ___. 
# |   _  \  |  | |   \/   | 
# |  |_)  | |  | |  \  /  | 
# |   ___/  |  | |  |\/|  | 
# |  |      |  | |  |  |  | 
# | _|      |__| |__|  |__| 
# These resources are used to create the required Multicast structure 
# needed for VXLAN traffic.

locals {
  vxlan_rp_int_devices = {
    for device in local.devices : device.name => {
      name                 = device.name
      role                 = device.role
      rp_loopback_int      = local.global.rp_loopback
      routing_loopback_int = local.global.routing_loopback
    } if try(local.device_map[device.name]["rendezvous_point"], false)
  }

  # vxlan_underlay_lo_pim_interfaces = flatten([
  #   for device in local.devices : [
  #     for interface in device.interfaces : {
  #       key       = format("%s/%s", device.name, interface.id)
  #       device    = device.name
  #       interface = interface.id
  #     } if try(interface.link_type == "underlay-lo", false)
  #   ]
  # ])
}

output "vxlan_rp_int_devices" {
  description = "List of devices with RP loopback interfaces"
  value       = local.vxlan_rp_int_devices
}

resource "nxos_pim" "vxlan_pim" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.value.name
  admin_state = "enabled"
  depends_on  = [nxos_feature_pim.pim]
}

resource "nxos_pim_instance" "vxlan_pim_instance" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.value.name
  admin_state = "enabled"
  depends_on  = [nxos_pim.vxlan_pim]
}


resource "nxos_pim_vrf" "vxlan_pim_vrf" {
  for_each    = { for device in local.devices : device.name => device }
  name        = "default"
  device      = each.value.name
  admin_state = "enabled"
  depends_on  = [nxos_pim_instance.vxlan_pim_instance]
}

resource "nxos_pim_interface" "vxlan_fl_rp_lo_pim_interface" {
  for_each     = { for vxlan_underlay_pim_interface in local.vxlan_underlay_rp_lo_interfaces : vxlan_underlay_pim_interface.key => vxlan_underlay_pim_interface }
  device       = each.value.device
  vrf_name     = "default"
  interface_id = each.value.id
  admin_state  = "enabled"
  passive      = false
  sparse_mode  = true

  depends_on = [nxos_pim_vrf.vxlan_pim_vrf]
}

resource "nxos_pim_interface" "vxlan_fl_vtep_lo_pim_interface" {
  for_each     = { for vxlan_underlay_pim_interface in local.vxlan_underlay_vtep_lo_interfaces : vxlan_underlay_pim_interface.key => vxlan_underlay_pim_interface }
  device       = each.value.device
  vrf_name     = "default"
  interface_id = each.value.id
  admin_state  = "enabled"
  passive      = false
  sparse_mode  = true

  depends_on = [nxos_pim_vrf.vxlan_pim_vrf]
}

resource "nxos_pim_interface" "vxlan_fl_routing_lo_pim_interface" {
  for_each     = { for vxlan_underlay_pim_interface in local.vxlan_underlay_routing_lo_interfaces : vxlan_underlay_pim_interface.key => vxlan_underlay_pim_interface }
  device       = each.value.device
  vrf_name     = "default"
  interface_id = each.value.id
  admin_state  = "enabled"
  passive      = false
  sparse_mode  = true

  depends_on = [nxos_pim_vrf.vxlan_pim_vrf]
}

resource "nxos_pim_interface" "vxlan_fl_l3_pim_interface" {
  for_each     = { for vxlan_underlay_pim_interface in local.vxlan_underlay_l3_interfaces : vxlan_underlay_pim_interface.key => vxlan_underlay_pim_interface }
  device       = each.value.device
  vrf_name     = "default"
  interface_id = each.value.id
  admin_state  = "enabled"
  passive      = false
  sparse_mode  = true

  depends_on = [nxos_pim_vrf.vxlan_pim_vrf]
}

resource "nxos_pim_anycast_rp" "vxlan_pim_anycast_rp" {
  for_each         = { for device in local.devices : device.name => device }
  device           = each.value.name
  vrf_name         = "default"
  local_interface  = local.global.rp_loopback
  source_interface = local.global.rp_loopback
  depends_on       = [nxos_pim_vrf.vxlan_pim_vrf]
}

resource "nxos_pim_anycast_rp_peer" "vxlan_pim_anycast_rp_peer" {
  for_each       = { for device in local.devices : device.name => device if try(device.rendezvous_point, false) }
  device         = each.value.name
  vrf_name       = "default"
  address        = local.global.rp_loopback_ip                                                      # This is the RP Loopback
  rp_set_address = local.device_interface_map[each.value.name][local.global.routing_loopback]["ip"] # This is the Routing Loopback
  # rp_set_address = each.value.routing_lo_address # This is the Routing Loopback
  depends_on = [nxos_pim_anycast_rp.vxlan_pim_anycast_rp]
}

resource "nxos_pim_static_rp_policy" "vxlan_pim_static_rp_policy" {
  for_each   = { for device in local.devices : device.name => device }
  device     = each.value.name
  vrf_name   = "default"
  depends_on = [nxos_pim_vrf.vxlan_pim_vrf]
}

resource "nxos_pim_static_rp" "vxlan_pim_static_rp" {
  for_each   = { for device in local.devices : device.name => device }
  device     = each.value.name
  vrf_name   = "default"
  address    = local.global.rp_loopback_ip
  depends_on = [nxos_pim_static_rp_policy.vxlan_pim_static_rp_policy]
}


resource "nxos_pim_static_rp_group_list" "vxlan_pim_static_rp_group_list" {
  for_each   = { for device in local.devices : device.name => device }
  device     = each.value.name
  vrf_name   = "default"
  rp_address = local.global.rp_loopback_ip
  address    = local.global.pim_group_address
  depends_on = [nxos_pim_static_rp.vxlan_pim_static_rp]
}
