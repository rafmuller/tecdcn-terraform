locals {

  leaf_peers = flatten([
    for conf_device in try(local.devices, []) : [
      for device in try(local.devices, []) : {
        key                = format("%s-%s", conf_device.name, local.device_interface_map[device.name][local.global.routing_loopback]["peering_ip"])
        name               = conf_device.name
        remote_bgp_peer_ip = local.device_interface_map[device.name][local.global.routing_loopback]["peering_ip"]
        source_interface   = local.device_interface_map[device.name][local.global.routing_loopback]["id"]
      } if device.role == "spine"
    ] if conf_device.role == "leaf"
  ])

  spine_peers = flatten([
    for conf_device in try(local.devices, []) : [
      for device in try(local.devices, []) : {
        key                = format("%s-%s", conf_device.name, local.device_interface_map[device.name][local.global.routing_loopback]["peering_ip"])
        name               = conf_device.name
        remote_bgp_peer_ip = local.device_interface_map[device.name][local.global.routing_loopback]["peering_ip"]
        source_interface   = local.device_interface_map[device.name][local.global.routing_loopback]["id"]
      } if device.role == "leaf"
    ] if conf_device.role == "spine"
  ])

}

output "leaf_peers" {
  description = "List of leaf peers"
  value       = local.leaf_peers
}

resource "nxos_bgp" "bgp" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"
  depends_on  = [nxos_feature_bgp.bgp]
}

resource "nxos_bgp_instance" "vxlan_bgp_instance" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.value.name
  admin_state = "enabled"
  asn         = local.bgp_global.bgp_asn
  depends_on  = [nxos_bgp.bgp]
}

resource "nxos_bgp_vrf" "vxlan_bgp_vrf" {
  for_each  = { for device in local.devices : device.name => device }
  device    = each.value.name
  asn       = local.bgp_global.bgp_asn
  name      = local.bgp_global.vrf
  router_id = each.value.router_id
  depends_on = [
    nxos_bgp_instance.vxlan_bgp_instance
  ]
}

resource "nxos_bgp_peer" "vxlan_bgp_spine_peers" {
  for_each         = { for peer in local.spine_peers : peer.key => peer }
  device           = each.value.name
  asn              = local.bgp_global.bgp_asn
  vrf              = "default"
  peer_type        = "fabric-internal"
  address          = each.value.remote_bgp_peer_ip
  remote_asn       = local.bgp_global.bgp_asn
  description      = "Peer to ${each.value.remote_bgp_peer_ip}"
  source_interface = each.value.source_interface
  depends_on       = [nxos_bgp_vrf.vxlan_bgp_vrf]
}

resource "nxos_bgp_peer" "vxlan_bgp_leaf_peers" {
  for_each         = { for peer in local.leaf_peers : peer.key => peer }
  device           = each.value.name
  asn              = local.bgp_global.bgp_asn
  vrf              = "default"
  peer_type        = "fabric-internal"
  remote_asn       = local.bgp_global.bgp_asn
  address          = each.value.remote_bgp_peer_ip
  description      = "Peer to ${each.value.remote_bgp_peer_ip}"
  source_interface = each.value.source_interface
  depends_on       = [nxos_bgp_vrf.vxlan_bgp_vrf]
}

resource "nxos_bgp_peer_address_family" "vxlan_vrf_spine_peer_address_family" {
  for_each       = { for peer in local.spine_peers : peer.key => peer }
  device         = each.value.name
  asn            = local.bgp_global.bgp_asn
  vrf            = "default"
  control        = "rr-client"
  address        = each.value.remote_bgp_peer_ip
  address_family = "l2vpn-evpn"
  #   control                 = "rr-client"
  send_community_extended = "enabled"
  send_community_standard = "enabled"

  depends_on = [nxos_bgp_peer.vxlan_bgp_leaf_peers]
}

resource "nxos_bgp_peer_address_family" "vxlan_vrf_leaf_peer_address_family" {
  for_each                = { for peer in local.leaf_peers : peer.key => peer }
  device                  = each.value.name
  asn                     = local.bgp_global.bgp_asn
  vrf                     = "default"
  address                 = each.value.remote_bgp_peer_ip
  address_family          = "l2vpn-evpn"
  control                 = "rr-client"
  send_community_extended = "enabled"
  send_community_standard = "enabled"
  depends_on              = [nxos_bgp_peer.vxlan_bgp_leaf_peers]
}

resource "nxos_bgp_vrf" "vxlan_bgp_network_vrf" {
  for_each  = { for vrf in local.vrfs : vrf.key => vrf }
  device    = each.value.device
  asn       = local.bgp_global.bgp_asn
  name      = each.value.name
  router_id = each.value.router_id

  depends_on = [
    nxos_bgp_instance.vxlan_bgp_instance
  ]
}

resource "nxos_bgp_address_family" "vxlan_bgp_network_ipv4_address_family" {
  for_each             = { for vrf in local.vrfs : vrf.key => vrf }
  address_family       = "ipv4-ucast"
  device               = each.value.device
  asn                  = local.bgp_global.bgp_asn
  vrf                  = each.value.name
  advertise_l2vpn_evpn = "enabled"
  max_ecmp_paths       = 2

  depends_on = [nxos_bgp_vrf.vxlan_bgp_network_vrf]
}
