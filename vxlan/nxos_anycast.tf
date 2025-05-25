#      ___      .__   __. ____    ____  ______     ___           _______.___________.
#     /   \     |  \ |  | \   \  /   / /      |   /   \         /       |           |
#    /  ^  \    |   \|  |  \   \/   / |  ,----'  /  ^  \       |   (----`---|  |----`
#   /  /_\  \   |  . `  |   \_    _/  |  |      /  /_\  \       \   \       |  |     
#  /  _____  \  |  |\   |     |  |    |  `----./  _____  \  .----)   |      |  |     
# /__/     \__\ |__| \__|     |__|     \______/__/     \__\ |_______/       |__|   
# 
# Anycast configuration for VLAN interfaces.

resource "nxos_hmm" "vxlan_hmm_fabric_forwarding" {
  for_each    = { for device in local.devices : device.name => device if device.role == "leaf" }
  device      = each.key
  admin_state = "enabled"
  depends_on  = [nxos_feature_nv_overlay.nv_overlay]
}

resource "nxos_hmm_instance" "vxlan_hmm_fabric_forwarding_instance" {
  for_each    = { for device in local.devices : device.name => device if device.role == "leaf" }
  device      = each.key
  admin_state = "enabled"
  anycast_mac = "00:12:34:56:78:9A"
  depends_on  = [nxos_hmm.vxlan_hmm_fabric_forwarding]
}


resource "nxos_hmm_interface" "vxlan_nxos_hmm_vlan_interfaces" {
  for_each     = { for vlan in local.vlans : vlan.key => vlan }
  device       = each.value.device_name
  interface_id = "vlan${each.value.vlan_id}"
  mode         = "anycastGW"
  depends_on = [nxos_hmm_instance.vxlan_hmm_fabric_forwarding_instance,
    nxos_svi_interface.vxlan_svi_interface,
  nxos_svi_interface_vrf.vxlan_svi_interface_vrf]
}
