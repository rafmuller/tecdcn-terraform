locals {
  defined_vrfs = local.model.vxlan-ciscolive.networks.vrfs


  vrfs = flatten([
    for device in try(local.devices, []) : [
      for vrf in try(local.defined_vrfs, []) : {
        key         = format("%s-%s-%s", device.name, vrf.name, vrf.vrf_id)
        name        = vrf.name
        description = vrf.description
        encap       = vrf.vrf_id
        device      = device
      }
    ]
  ])
}

resource "nxos_vrf" "vxlan_vrf" {
  for_each    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device      = each.value.device.name
  encap       = "vxlan-${each.value.encap}"
  name        = each.value.name
  description = try(each.value.description, "Configured by Terraform")
}

resource "nxos_ipv4_vrf" "vxlan_ipv4_vrf" {
  for_each   = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device     = each.value.device.name
  name       = each.value.name
  depends_on = [nxos_vrf.vxlan_vrf]
}

resource "nxos_ipv4_vrf" "vxlan_ipv4_vrf_default" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.value.name
  name     = "default"
}

resource "nxos_vrf_routing" "vxlan_vrf_routing" {
  for_each            = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device              = each.value.device.name
  vrf                 = each.value.name
  route_distinguisher = "rd:unknown:0:0"
  depends_on          = [nxos_vrf.vxlan_vrf]
}

resource "nxos_vrf_address_family" "vxlan_vrf_routing_ipv4_addr_family" {
  for_each       = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device         = each.value.device.name
  vrf            = each.value.name
  address_family = "ipv4-ucast"
  depends_on     = [nxos_vrf_routing.vxlan_vrf_routing]
}

resource "nxos_vrf_route_target_address_family" "vxlan_vrf_route_target_l2vpn_ipv4_address_family" {
  for_each                    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device                      = each.value.device.name
  vrf                         = each.value.name
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"
  depends_on                  = [nxos_vrf_address_family.vxlan_vrf_routing_ipv4_addr_family]
}

resource "nxos_vrf_route_target_address_family" "vxlan_vrf_route_target_ipv4ucast_address_family" {
  for_each                    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device                      = each.value.device.name
  vrf                         = each.value.name
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"
  depends_on                  = [nxos_vrf_address_family.vxlan_vrf_routing_ipv4_addr_family]
}

resource "nxos_vrf_route_target_direction" "vxlan_vrf_route_target_direction_l2evpn_ipv4_import" {
  for_each                    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device                      = each.value.device.name
  vrf                         = each.value.name
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "import"
  depends_on                  = [nxos_vrf_route_target_address_family.vxlan_vrf_route_target_l2vpn_ipv4_address_family]
}

resource "nxos_vrf_route_target_direction" "vxlan_vrf_route_target_direction_l2evpn_ipv4_export" {
  for_each                    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device                      = each.value.device.name
  vrf                         = each.value.name
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "export"
  depends_on                  = [nxos_vrf_route_target_address_family.vxlan_vrf_route_target_l2vpn_ipv4_address_family]
}

resource "nxos_vrf_route_target_direction" "vxlan_vrf_route_target_direction_ipv4ucast_import" {
  for_each                    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device                      = each.value.device.name
  vrf                         = each.value.name
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"
  direction                   = "import"
  depends_on                  = [nxos_vrf_route_target_address_family.vxlan_vrf_route_target_ipv4ucast_address_family]
}

resource "nxos_vrf_route_target_direction" "vxlan_vrf_route_target_direction_ipv4ucast_export" {
  for_each                    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device                      = each.value.device.name
  vrf                         = each.value.name
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"
  direction                   = "export"
  depends_on                  = [nxos_vrf_route_target_address_family.vxlan_vrf_route_target_ipv4ucast_address_family]
}

resource "nxos_vrf_route_target" "vxlan_vrf_route_target_l2evpn_ipv4_import" {
  for_each                    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device                      = each.value.device.name
  vrf                         = each.value.name
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "import"
  route_target                = "route-target:unknown:0:0"
  depends_on                  = [nxos_vrf_route_target_direction.vxlan_vrf_route_target_direction_l2evpn_ipv4_import]
}

resource "nxos_vrf_route_target" "vxlan_vrf_route_target_ipv4ucast_import" {
  for_each                    = { for vrf in try(local.vrfs, []) : vrf.key => vrf if vrf.device.role != "spine" }
  device                      = each.value.device.name
  vrf                         = each.value.name
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"
  direction                   = "import"
  route_target                = "route-target:unknown:0:0"
  depends_on                  = [nxos_vrf_route_target_direction.vxlan_vrf_route_target_direction_ipv4ucast_import]
}
