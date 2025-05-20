locals {
  defined_vlans = local.model.vxlan-ciscolive.networks.vlans

  vlans = flatten([
    for device in try(local.devices, []) : [
      for vlan in try(local.defined_vlans, []) : {
        key         = format("%s-%s-%s", device.name, vlan.vlan_id, vlan.vni)
        name        = vlan.name
        vlan_id     = vlan.vlan_id
        vrf_name    = vlan.vrf_name
        vni         = vlan.vni
        gw_ip       = vlan.gw_ip
        device_name = device.name
        device_role = device.role
      }
    ]
  ])
}

resource "nxos_bridge_domain" "vxlan_vlans" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  fabric_encap = "vlan-${each.value.vlan_id}"
  access_encap = "vxlan-${each.value.vni}"
  name         = each.value.name
  depends_on   = [nxos_vrf.vxlan_vrf]
}

resource "nxos_svi_interface" "vxlan_svi_vrf_interface" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  admin_state  = "up"
  description  = try(each.value.vrf_description, "Configured by NetAsCode")
  medium       = "bcast"
  mtu          = 1500
  depends_on   = [nxos_feature_interface_vlan.interface_vlan]
}

resource "nxos_svi_interface_vrf" "vxlan_svi_vrf_interface_vrf" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  vrf_dn       = "sys/inst-${each.value.vrf_name}"
  depends_on   = [nxos_svi_interface.vxlan_svi_vrf_interface]
}

resource "nxos_ipv4_interface" "vxlan_svi_vrf_interface_ipv4" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  vrf          = each.value.vrf_name
  interface_id = "vlan${each.value.vlan_id}"
  forward      = "disabled"
  depends_on   = [nxos_svi_interface_vrf.vxlan_svi_vrf_interface_vrf]
}

resource "nxos_svi_interface" "vxlan_svi_network_interface" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  admin_state  = "up"
  description  = try(each.value.int_desc, "Configured by NetAsCode")
  medium       = "bcast"
  mtu          = 1500
  depends_on   = [nxos_feature_interface_vlan.interface_vlan]
}

resource "nxos_svi_interface_vrf" "vxlan_svi_network_interface_vrf" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  vrf_dn       = "sys/inst-${each.value.vrf_name}"
  depends_on   = [nxos_svi_interface.vxlan_svi_network_interface]
}


resource "nxos_ipv4_interface" "vxlan_svi_networks_interface_ipv4" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  vrf          = each.value.vrf_name
  interface_id = "vlan${each.value.vlan_id}"
  forward      = "disabled"
  depends_on = [
    nxos_svi_interface_vrf.vxlan_svi_network_interface_vrf,
  nxos_ipv4_vrf.vxlan_ipv4_vrf]
}

resource "nxos_ipv4_interface_address" "vxlan_ipv4_svi_network_interface_address" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  vrf          = each.value.vrf_name
  interface_id = "vlan${each.value.vlan_id}"
  address      = each.value.gw_ip
  type         = "primary"
  depends_on   = [nxos_ipv4_interface.vxlan_svi_networks_interface_ipv4]
}

resource "nxos_icmpv4_vrf" "vxlan_icmpv4_vrf" {
  for_each   = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device     = each.value.device_name
  vrf_name   = each.value.vrf_name
  depends_on = [nxos_icmpv4_instance.vxlan_icmpv4_instance]
}


resource "nxos_icmpv4_interface" "vxlan_icmpv4_svi_interface" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device_role != "spine" }
  device       = each.value.device_name
  vrf_name     = each.value.vrf_name
  interface_id = "vlan${each.value.vlan_id}"
  control      = "port-unreachable"
  depends_on   = [nxos_icmpv4_vrf.vxlan_icmpv4_vrf]
}


