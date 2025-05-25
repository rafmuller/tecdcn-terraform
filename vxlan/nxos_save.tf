# .__   __. ___   ___   ______        _______.        _______.     ___   ____    ____  _______ 
# |  \ |  | \  \ /  /  /  __  \      /       |       /       |    /   \  \   \  /   / |   ____|
# |   \|  |  \  V  /  |  |  |  |    |   (----`      |   (----`   /  ^  \  \   \/   /  |  |__   
# |  . `  |   >   <   |  |  |  |     \   \           \   \      /  /_\  \  \      /   |   __|  
# |  |\   |  /  .  \  |  `--'  | .----)   |      .----)   |    /  _____  \  \    /    |  |____ 
# |__| \__| /__/ \__\  \______/  |_______/       |_______/    /__/     \__\  \__/     |_______|
# This reource is used to save the configuration of the Nexus devices. It is executed after 
# all the resources have been created ( via the dependency map ).                                                                                        


resource "nxos_save_config" "save_config" {
  for_each = { for device in local.devices : device.name => device if local.global.save_config }
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
    nxos_hmm_interface.vxlan_nxos_hmm_vlan_interfaces,
    nxos_bgp_address_family.vxlan_bgp_network_ipv4_address_family,
    nxos_evpn_vni_route_target.vxlan_evpn_vni_route_export_target,
    nxos_icmpv4_instance.vxlan_icmpv4_instance,
    nxos_ipv4_interface_address.vxlan_underlay_routing_lo_ipv4_interface_address,
    nxos_ipv4_interface_address.vxlan_underlay_vtep_lo_ipv4_interface_address,
    nxos_ipv4_interface_address.vxlan_underlay_rp_lo_ipv4_interface_address,
    nxos_nve_vni.vxlan_nve_interface_networks,
    nxos_physical_interface.vxlan_trunk_port_service_interface,
    nxos_physical_interface.vxlan_underlay_routed_ethernet_interfaces_admin_state,
    nxos_bridge_domain.vxlan_vrf_vlans,
    nxos_icmpv4_interface.vxlan_icmpv4_svi_interface,
    nxos_icmpv4_interface.vxlan_vrf_svi_interface_ipv4_icmp,
    nxos_ospf_interface.ospf_interface_vtep_loopback,
    nxos_ospf_interface.ospf_interface_rp_loopback,
    nxos_ospf_interface.ospf_interface_vtep_loopback,
    nxos_ospf_interface.ospf_interface_physical,
    nxos_pim_static_rp_group_list.vxlan_pim_static_rp_group_list,
    nxos_route_map_rule_entry_match_tag.vxlan_tag_route_map_rule_entry_match_tag,
    nxos_vrf_route_target.vxlan_vrf_route_target_ipv4ucast_import,
    nxos_vrf_route_target.vxlan_vrf_route_target_l2evpn_ipv4_import,
  ]
}
