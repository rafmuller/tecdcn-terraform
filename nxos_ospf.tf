


resource "nxos_ospf" "ospf" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.value.name
  admin_state = "enabled"
  depends_on  = [nxos_feature_ospf.ospf]
}

resource "nxos_ospf_instance" "ospf_instance" {
  for_each   = { for device in local.devices : device.name => device }
  device     = each.value.name
  name       = "OSPF1"
  depends_on = [nxos_ospf.ospf]
}

resource "nxos_ospf_vrf" "ospf_vrf" {
  for_each      = { for device in local.devices : device.name => device }
  device        = each.value.name
  instance_name = "OSPF1"
  name          = "default"
  router_id     = each.value.router_id
  depends_on    = [nxos_ospf_instance.ospf_instance]
}

resource "nxos_ospf_area" "ospf_area" {
  for_each      = { for device in local.devices : device.name => device }
  device        = each.value.name
  instance_name = "OSPF1"
  vrf_name      = "default"
  area_id       = "0.0.0.0"
  depends_on    = [nxos_ospf_vrf.ospf_vrf]
}

resource "nxos_ospf_interface" "ospf_interface_physical" {
  for_each      = { for interface in local.vxlan_underlay_l3_interfaces : interface.key => interface }
  device        = each.value.device
  instance_name = "OSPF1"
  vrf_name      = "default"
  interface_id  = each.value.id
  area          = "0.0.0.0"
  network_type  = "p2p"
  depends_on = [nxos_ospf_area.ospf_area,
    nxos_ipv4_interface_address.loopback_ipv4_interface_address,
  nxos_ipv4_interface_address.vxlan_underlay_routed_ethernet_interfaces_ipv4_address]
}

resource "nxos_ospf_interface" "ospf_interface_loopback" {
  for_each      = { for interface in local.vxlan_underlay_lo_interfaces : interface.key => interface }
  device        = each.value.device
  instance_name = "OSPF1"
  vrf_name      = "default"
  interface_id  = each.value.id
  area          = "0.0.0.0"
  network_type  = "p2p"
  depends_on = [nxos_ospf_area.ospf_area,
    nxos_ipv4_interface_address.loopback_ipv4_interface_address,
  nxos_ipv4_interface_address.vxlan_underlay_routed_ethernet_interfaces_ipv4_address]
}
