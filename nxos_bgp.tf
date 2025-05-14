locals {
  bgp_global = {
    bgp_asn          = 65000
    vrf              = "default"
    routing_loopback = "loopback0"
    vtep_loopback    = "loopback1"
    rp_loopback      = "loopback250"
  }

  bgp_devices = [
    {
      name             = "CLspine1"
      role             = "spine"
      asn              = local.bgp_global.bgp_asn
      vrf              = local.bgp_global.vrf
      routing_loopback = local.bgp_global.routing_loopback
      vtep_loopback    = local.bgp_global.vtep_loopback
      rp_loopback      = local.bgp_global.rp_loopback
    },
    {
      name             = "CLleaf1"
      role             = "leaf"
      asn              = local.bgp_global.bgp_asn
      vrf              = local.bgp_global.vrf
      routing_loopback = local.bgp_global.routing_loopback
      vtep_loopback    = local.bgp_global.vtep_loopback
      rp_loopback      = local.bgp_global.rp_loopback
    },
    {
      name             = "CLleaf2"
      role             = "leaf"
      asn              = local.bgp_global.bgp_asn
      vrf              = local.bgp_global.vrf
      routing_loopback = local.bgp_global.routing_loopback
      vtep_loopback    = local.bgp_global.vtep_loopback
      rp_loopback      = local.bgp_global.rp_loopback
    }
  ]


}


resource "nxos_bgp" "bgp" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.key
  admin_state = "enabled"

  depends_on = [nxos_feature_bgp.bgp]
}

resource "nxos_bgp_instance" "vxlan_bgp_instance" {
  for_each    = { for device in local.devices : device.name => device if try(local.bgp_global.bgp_asn, null) != null }
  device      = each.value.name
  admin_state = "enabled"
  asn         = try(local.bgp_global.bgp_asn)

  depends_on = [nxos_bgp.bgp]
}

resource "nxos_bgp_vrf" "vxlan_bgp_vrf" {
  for_each  = { for device in local.devices : device.name => device if try(local.global.bgp_asn, null) != null }
  device    = each.value.name
  asn       = try(local.bgp_global.bgp_asn)
  name      = try(local.bgp_global.vrf, "default")
  router_id = each.value.router_id

  depends_on = [
    nxos_bgp_instance.vxlan_bgp_instance
  ]
}
