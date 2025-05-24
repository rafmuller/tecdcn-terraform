# .__   __. ____    ____  _______ 
# |  \ |  | \   \  /   / |   ____|
# |   \|  |  \   \/   /  |  |__   
# |  . `  |   \      /   |   __|  
# |  |\   |    \    /    |  |____ 
# |__| \__|     \__/     |_______|

#  __  .__   __. .___________. _______ .______       _______    ___       ______  _______ 
# |  | |  \ |  | |           ||   ____||   _  \     |   ____|  /   \     /      ||   ____|
# |  | |   \|  | `---|  |----`|  |__   |  |_)  |    |  |__    /  ^  \   |  ,----'|  |__   
# |  | |  . `  |     |  |     |   __|  |      /     |   __|  /  /_\  \  |  |     |   __|  
# |  | |  |\   |     |  |     |  |____ |  |\  \----.|  |    /  _____  \ |  `----.|  |____ 
# |__| |__| \__|     |__|     |_______|| _| `._____||__|   /__/     \__\ \______||_______|
#
# NVE interfaces are used to create Virtual Extensible LAN (VXLAN) tunnels on Cisco Nexus devices.
# These tunnels are used to encapsulate Layer 2 Ethernet frames in Layer 3 packets for 
# transport over an IP network. The NVE interfaces are typically associated with a Virtual 
# Tunnel Endpoint (VTEP).



resource "nxos_nve_interface" "vxlan_nve_interface" {
  for_each                   = { for device in local.devices : device.name => device if device.role == "leaf" }
  device                     = each.value.name
  admin_state                = "enabled"
  host_reachability_protocol = "bgp"
  source_interface           = local.global.vtep_loopback
  depends_on                 = [nxos_feature_nv_overlay.nv_overlay, nxos_feature_evpn.evpn]
}

resource "nxos_nve_vni_container" "vxlan_nve_interface_container" {
  for_each   = { for device in local.devices : device.name => device if device.role == "leaf" }
  device     = each.value.name
  depends_on = [nxos_nve_interface.vxlan_nve_interface]
}


resource "nxos_nve_vni" "vxlan_nve_interface_vrfs" {
  for_each      = { for vrf in local.vrfs : vrf.key => vrf }
  vni           = each.value.vni
  device        = each.value.device
  associate_vrf = true
  depends_on = [
    nxos_ipv4_vrf.vxlan_ipv4_vrf,
  nxos_nve_vni_container.vxlan_nve_interface_container]
}

resource "nxos_nve_vni" "vxlan_nve_interface_networks" {
  for_each        = { for vlan in local.vlans : vlan.key => vlan }
  vni             = each.value.vn-segment
  device          = each.value.device_name
  multicast_group = "239.1.1.1"
  depends_on      = [nxos_nve_vni.vxlan_nve_interface_vrfs]
}
