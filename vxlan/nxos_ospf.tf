#   ______        _______..______    _______ 
#  /  __  \      /       ||   _  \  |   ____|
# |  |  |  |    |   (----`|  |_)  | |  |__   
# |  |  |  |     \   \    |   ___/  |   __|  
# |  `--'  | .----)   |   |  |      |  |     
#  \______/  |_______/    | _|      |__|     
#
# All resources for the underlay OSPF configuraiton.                                        


resource "nxos_ospf" "ospf" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.value.name
  admin_state = "enabled"
  depends_on  = [nxos_feature_ospf.ospf]
}

resource "nxos_ospf_instance" "ospf_instance" {
  for_each   = { for device in local.devices : device.name => device }
  device     = each.value.name
  name       = local.ospf_global.instance_name
  depends_on = [nxos_ospf.ospf]
}

resource "nxos_ospf_vrf" "ospf_vrf" {
  for_each      = { for device in local.devices : device.name => device }
  device        = each.value.name
  instance_name = local.ospf_global.instance_name
  name          = local.ospf_global.vrf
  router_id     = each.value.router_id
  depends_on    = [nxos_ospf_instance.ospf_instance]
}

resource "nxos_ospf_area" "ospf_area" {
  for_each      = { for device in local.devices : device.name => device }
  device        = each.value.name
  instance_name = local.ospf_global.instance_name
  vrf_name      = local.ospf_global.vrf
  area_id       = local.ospf_global.area_id
  depends_on    = [nxos_ospf_vrf.ospf_vrf]
}

resource "nxos_ospf_interface" "ospf_interface_physical" {
  for_each      = { for interface in local.vxlan_underlay_l3_interfaces : interface.key => interface }
  device        = each.value.device
  instance_name = local.ospf_global.instance_name
  vrf_name      = local.ospf_global.vrf
  interface_id  = each.value.id
  area          = local.ospf_global.area_id
  network_type  = "p2p"
  depends_on = [nxos_ospf_area.ospf_area,
    nxos_ipv4_interface_address.vxlan_underlay_routing_lo_ipv4_interface_address,
  nxos_ipv4_interface_address.vxlan_underlay_routed_ethernet_interfaces_ipv4_address]
}

resource "nxos_ospf_interface" "ospf_interface_routing_loopback" {
  for_each      = { for interface in local.vxlan_underlay_routing_lo_interfaces : interface.key => interface }
  device        = each.value.device
  instance_name = local.ospf_global.instance_name
  vrf_name      = local.ospf_global.vrf
  interface_id  = each.value.id
  area          = local.ospf_global.area_id
  network_type  = "p2p"
  depends_on = [nxos_ospf_area.ospf_area,
    nxos_ipv4_interface_address.vxlan_underlay_routing_lo_ipv4_interface_address,
  nxos_ipv4_interface_address.vxlan_underlay_routed_ethernet_interfaces_ipv4_address]
}

resource "nxos_ospf_interface" "ospf_interface_rp_loopback" {
  for_each      = { for interface in local.vxlan_underlay_rp_lo_interfaces : interface.key => interface }
  device        = each.value.device
  instance_name = local.ospf_global.instance_name
  vrf_name      = local.ospf_global.vrf
  interface_id  = each.value.id
  area          = local.ospf_global.area_id
  network_type  = "p2p"
  depends_on = [nxos_ospf_area.ospf_area,
    nxos_ipv4_interface_address.vxlan_underlay_routing_lo_ipv4_interface_address,
  nxos_ipv4_interface_address.vxlan_underlay_routed_ethernet_interfaces_ipv4_address]
}

resource "nxos_ospf_interface" "ospf_interface_vtep_loopback" {
  for_each      = { for interface in local.vxlan_underlay_vtep_lo_interfaces : interface.key => interface }
  device        = each.value.device
  instance_name = local.ospf_global.instance_name
  vrf_name      = local.ospf_global.vrf
  interface_id  = each.value.id
  area          = local.ospf_global.area_id
  network_type  = "p2p"
  depends_on = [nxos_ospf_area.ospf_area,
    nxos_ipv4_interface_address.vxlan_underlay_routing_lo_ipv4_interface_address,
  nxos_ipv4_interface_address.vxlan_underlay_routed_ethernet_interfaces_ipv4_address]
}
