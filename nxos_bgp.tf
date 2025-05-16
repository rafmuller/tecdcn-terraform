locals {
  bgp_global = {
    bgp_asn          = 65000
    vrf              = "default"
    routing_loopback = "lo0"
    vtep_loopback    = "lo1"
    rp_loopback      = "lo250"
  }


  leaf_peers = flatten([
    for device in try(local.devices, []) : {
      name               = device.name
      remote_bgp_peer_ip = local.device_interface_map[device.name][device.bgp.routing_loopback]["ip"]
      # remote_bgp_peer_ip = device.interfaces[device.bgp.routing_loopback]["ip"]
    } if device.role == "spine"
  ])

  spine_peers = flatten([
    for device in try(local.devices, []) : {
      name               = device.name
      remote_bgp_peer_ip = local.device_interface_map[device.name][device.bgp.routing_loopback]["ip"]
      #remote_bgp_peer_ip = device.interfaces[device.bgp.routing_loopback]["ip"]
    } if device.role == "leaf"
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

  depends_on = [nxos_feature_bgp.bgp]
}

resource "nxos_bgp_instance" "vxlan_bgp_instance" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.value.name
  admin_state = "enabled"
  asn         = try(local.bgp_global.bgp_asn)
  depends_on  = [nxos_bgp.bgp]
}

resource "nxos_bgp_vrf" "vxlan_bgp_vrf" {
  for_each  = { for device in local.devices : device.name => device }
  device    = each.value.name
  asn       = each.value.bgp.asn
  name      = each.value.bgp.vrf
  router_id = each.value.router_id
  depends_on = [
    nxos_bgp_instance.vxlan_bgp_instance
  ]
}

# resource "nxos_bgp_peer" "vxlan_bgp_spine_peers" {
#   for_each    = { for device in local.devices : device.name => device }
#   device      = each.value.name
#   asn         = each.value.bgp.asn
#   vrf         = each.value.bgp.vrf
#   address     = each.value.neighbor_ip
#   description = "Peer to ${each.value.neighbor_ip}"
#   #   source_interface = local.underlay_routing_loopback_int
#   depends_on = [nxos_bgp_vrf.vxlan_bgp_vrf]
# }
