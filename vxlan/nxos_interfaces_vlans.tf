locals {

  vlan_map = { for vlan in try(local.networks.vlans, []) : vlan.vlan_id => vlan }

  vrf_segments = flatten([
    for vrf in try(local.networks.vrfs, []) : [
      for attach in try(vrf.attach, []) : {
        key         = format("%s-%s", attach.name, vrf.vni)
        name        = vrf.name
        vlan_id     = vrf.vlan_id
        vni         = vrf.vni
        device_name = attach.name
        device_role = local.device_map[attach.name].role
      }
    ]
  ])


  vlans = flatten([
    for vlan in try(local.networks.vlans, []) : [
      for attach in try(vlan.attach, []) : {
        key         = format("%s-%s-%s", attach.name, vlan.vlan_id, local.vrf_map[vlan.vrf_name].vni)
        name        = vlan.name
        vlan_id     = vlan.vlan_id
        vrf_name    = vlan.vrf_name
        vni         = local.vrf_map[vlan.vrf_name].vni
        vn-segment  = vlan.vn-segment
        gw_ip       = vlan.gw_ip
        device_name = attach.name
        device_role = local.device_map[attach.name].role
      }
    ]
  ])
}

output "vlans" {
  description = "List of VLANs"
  value       = local.vlans
}

# ____    ____  __          ___      .__   __.      _______.
# \   \  /   / |  |        /   \     |  \ |  |     /       |
#  \   \/   /  |  |       /  ^  \    |   \|  |    |   (----`
#   \      /   |  |      /  /_\  \   |  . `  |     \   \    
#    \    /    |  `----./  _____  \  |  |\   | .----)   |   
#     \__/     |_______/__/     \__\ |__| \__| |_______/    
#
# This section creates the VLANS.

resource "nxos_bridge_domain" "vxlan_vlans" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan }
  device       = each.value.device_name
  fabric_encap = "vlan-${each.value.vlan_id}"
  access_encap = "vxlan-${each.value.vn-segment}"
  name         = each.value.name
  depends_on   = [nxos_vrf.vxlan_vrf]
}

resource "nxos_bridge_domain" "vxlan_vrf_vlans" {
  for_each     = { for vlan in try(local.vrf_segments, []) : vlan.key => vlan }
  device       = each.value.device_name
  fabric_encap = "vlan-${each.value.vlan_id}"
  access_encap = "vxlan-${each.value.vni}"
  name         = each.value.name
  depends_on   = [nxos_vrf.vxlan_vrf]
}


#      _______.____    ____  __     ____    ____  __          ___      .__   __. 
#     /       |\   \  /   / |  |    \   \  /   / |  |        /   \     |  \ |  | 
#    |   (----` \   \/   /  |  |     \   \/   /  |  |       /  ^  \    |   \|  | 
#     \   \      \      /   |  |      \      /   |  |      /  /_\  \   |  . `  | 
# .----)   |      \    /    |  |       \    /    |  `----./  _____  \  |  |\   | 
# |_______/        \__/     |__|        \__/     |_______/__/     \__\ |__| \__| 
#
# This section creates the SVI interfaces for the VLANs.

resource "nxos_svi_interface" "vxlan_svi_interface" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  admin_state  = "up"
  description  = try(each.value.vrf_description, "Configured by NetAsCode")
  medium       = "bcast"
  mtu          = 1500
  depends_on   = [nxos_feature_interface_vlan.interface_vlan]
}



resource "nxos_svi_interface_vrf" "vxlan_svi_interface_vrf" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  vrf_dn       = "sys/inst-${each.value.vrf_name}"
  depends_on   = [nxos_svi_interface.vxlan_svi_interface]
}


resource "nxos_ipv4_interface" "vxlan_svi_interface_ipv4" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan }
  device       = each.value.device_name
  vrf          = each.value.vrf_name
  interface_id = "vlan${each.value.vlan_id}"
  forward      = "disabled"
  depends_on   = [nxos_svi_interface_vrf.vxlan_svi_interface_vrf]
}

resource "nxos_ipv4_interface_address" "vxlan_ipv4_svi_network_interface_address" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan }
  device       = each.value.device_name
  vrf          = each.value.vrf_name
  interface_id = "vlan${each.value.vlan_id}"
  address      = each.value.gw_ip
  tag          = "12345"
  type         = "primary"
  depends_on   = [nxos_ipv4_interface.vxlan_svi_interface_ipv4]
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


#      _______.____    ____  __     ____    ____ .______       _______ 
#     /       |\   \  /   / |  |    \   \  /   / |   _  \     |   ____|
#    |   (----` \   \/   /  |  |     \   \/   /  |  |_)  |    |  |__   
#     \   \      \      /   |  |      \      /   |      /     |   __|  
# .----)   |      \    /    |  |       \    /    |  |\  \----.|  |     
# |_______/        \__/     |__|        \__/     | _| `._____||__|    
#
# These resources create the SVI interfaces for the VRF VNI segments.

resource "nxos_svi_interface" "vxlan_vrf_svi_interface" {
  for_each     = { for vlan in try(local.vrf_segments, []) : vlan.key => vlan }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  admin_state  = "up"
  description  = try(each.value.vrf_description, "Configured by NetAsCode")
  medium       = "bcast"
  mtu          = 1500
  depends_on   = [nxos_feature_interface_vlan.interface_vlan]
}

resource "nxos_svi_interface_vrf" "vxlan_vrf_svi_interface_vrf" {
  for_each     = { for vlan in try(local.vrf_segments, []) : vlan.key => vlan }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  vrf_dn       = "sys/inst-${each.value.name}"
  depends_on   = [nxos_svi_interface.vxlan_vrf_svi_interface]
}


resource "nxos_ipv4_interface" "vxlan_vrf_svi_interface_ipv4" {
  for_each     = { for vlan in try(local.vrf_segments, []) : vlan.key => vlan }
  device       = each.value.device_name
  vrf          = each.value.name
  interface_id = "vlan${each.value.vlan_id}"
  forward      = "enabled"
  depends_on   = [nxos_svi_interface_vrf.vxlan_svi_interface_vrf]
}

resource "nxos_icmpv4_interface" "vxlan_vrf_svi_interface_ipv4_icmp" {
  for_each     = { for vlan in try(local.vrf_segments, []) : vlan.key => vlan }
  device       = each.value.device_name
  vrf_name     = each.value.name
  interface_id = "vlan${each.value.vlan_id}"
  control      = "port-unreachable"
  depends_on   = [nxos_ipv4_interface.vxlan_vrf_svi_interface_ipv4]
}
