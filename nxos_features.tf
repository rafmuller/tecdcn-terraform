# .__   __. ___   ___   ______        _______.
# |  \ |  | \  \ /  /  /  __  \      /       |
# |   \|  |  \  V  /  |  |  |  |    |   (----`
# |  . `  |   >   <   |  |  |  |     \   \    
# |  |\   |  /  .  \  |  `--'  | .----)   |   
# |__| \__| /__/ \__\  \______/  |_______/    

#  _______  _______     ___   .___________. __    __  .______       _______     _______.
# |   ____||   ____|   /   \  |           ||  |  |  | |   _  \     |   ____|   /       |
# |  |__   |  |__     /  ^  \ `---|  |----`|  |  |  | |  |_)  |    |  |__     |   (----`
# |   __|  |   __|   /  /_\  \    |  |     |  |  |  | |      /     |   __|     \   \    
# |  |     |  |____ /  _____  \   |  |     |  `--'  | |  |\  \----.|  |____.----)   |   
# |__|     |_______/__/     \__\  |__|      \______/  | _| `._____||_______|_______/    
#
# These resources are used to enable the features on the Nexus devices. The features are
# enabled based on the role of the device.                                                                               


resource "nxos_feature_bgp" "bgp" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_evpn" "evpn" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_nv_overlay" "nv_overlay" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"

  depends_on = [
    nxos_feature_vn_segment.vn_segment
  ]
}

resource "nxos_feature_vn_segment" "vn_segment" {
  for_each    = { for device in local.devices : device.name => device if device.role != "spine" }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_interface_vlan" "interface_vlan" {
  for_each    = { for device in local.devices : device.name => device if device.role != "spine" }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_lacp" "lacp" {
  for_each    = { for device in local.devices : device.name => device if device.role != "spine" }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_pim" "pim" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_ngmvpn" "ngmvpn" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_ngoam" "ngoam" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_feature_ospf" "ospf" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"
}
