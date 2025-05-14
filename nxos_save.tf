# .__   __. ___   ___   ______        _______.        _______.     ___   ____    ____  _______ 
# |  \ |  | \  \ /  /  /  __  \      /       |       /       |    /   \  \   \  /   / |   ____|
# |   \|  |  \  V  /  |  |  |  |    |   (----`      |   (----`   /  ^  \  \   \/   /  |  |__   
# |  . `  |   >   <   |  |  |  |     \   \           \   \      /  /_\  \  \      /   |   __|  
# |  |\   |  /  .  \  |  `--'  | .----)   |      .----)   |    /  _____  \  \    /    |  |____ 
# |__| \__| /__/ \__\  \______/  |_______/       |_______/    /__/     \__\  \__/     |_______|
# This reource is used to save the configuration of the Nexus devices. It is executed after 
# all the resources have been created ( via the dependency map ).                                                                                        


resource "nxos_save_config" "save_config" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  depends_on = [
    nxos_feature_bgp.bgp,
    nxos_feature_evpn.evpn,
    nxos_feature_nv_overlay.nv_overlay,
    nxos_feature_vn_segment.vn_segment,
    nxos_feature_interface_vlan.interface_vlan,
    nxos_feature_lacp.lacp,
    nxos_feature_pim.pim,
    nxos_feature_ngmvpn.ngmvpn,
    nxos_feature_ngoam.ngoam,
    nxos_vrf.vxlan_vrf,
    nxos_bridge_domain.vxlan_vlans
  ]
}
