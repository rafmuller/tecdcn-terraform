#  ___________    ____ .______   .__   __. 
# |   ____\   \  /   / |   _  \  |  \ |  | 
# |  |__   \   \/   /  |  |_)  | |   \|  | 
# |   __|   \      /   |   ___/  |  . `  | 
# |  |____   \    /    |  |      |  |\   | 
# |_______|   \__/     | _|      |__| \__| 
#
# EVPN configuration for VXLAN under the BGP process.                                         



resource "nxos_evpn" "vxlan_evpn" {
  for_each    = { for vlan in local.vlans : vlan.key => vlan }
  device      = each.value.device_name
  admin_state = "enabled"
  depends_on  = [nxos_feature_evpn.evpn]
}

resource "nxos_evpn_vni" "vxlan_evpn_vni" {
  for_each            = { for vlan in local.vlans : vlan.key => vlan }
  device              = each.value.device_name
  encap               = "vxlan-${each.value.vn-segment}"
  route_distinguisher = "rd:unknown:0:0"
  depends_on          = [nxos_evpn.vxlan_evpn]
}

resource "nxos_evpn_vni_route_target_direction" "vxlan_evpn_vni_route_target_import_direction" {
  for_each   = { for vlan in local.vlans : vlan.key => vlan }
  device     = each.value.device_name
  encap      = "vxlan-${each.value.vn-segment}"
  direction  = "import"
  depends_on = [nxos_evpn_vni.vxlan_evpn_vni]
}


resource "nxos_evpn_vni_route_target" "vxlan_evpn_vni_route_import_target" {
  for_each     = { for vlan in local.vlans : vlan.key => vlan }
  device       = each.value.device_name
  encap        = "vxlan-${each.value.vn-segment}"
  direction    = "import"
  route_target = "route-target:unknown:0:0"
  depends_on   = [nxos_evpn_vni_route_target_direction.vxlan_evpn_vni_route_target_import_direction]
}

resource "nxos_evpn_vni_route_target_direction" "vxlan_evpn_vni_route_target_export_direction" {
  for_each   = { for vlan in local.vlans : vlan.key => vlan }
  device     = each.value.device_name
  encap      = "vxlan-${each.value.vn-segment}"
  direction  = "export"
  depends_on = [nxos_evpn_vni.vxlan_evpn_vni]
}


resource "nxos_evpn_vni_route_target" "vxlan_evpn_vni_route_export_target" {
  for_each     = { for vlan in local.vlans : vlan.key => vlan }
  device       = each.value.device_name
  encap        = "vxlan-${each.value.vn-segment}"
  direction    = "export"
  route_target = "route-target:unknown:0:0"
  depends_on   = [nxos_evpn_vni_route_target_direction.vxlan_evpn_vni_route_target_export_direction]
}
