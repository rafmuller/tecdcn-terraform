locals {
  defined_vrfs = [
    {
      name        = "VRF1"
      description = "Cisco Live VRF1"
      vrf_id      = 10000
    },
    {
      name        = "VRF2"
      description = "Cisco Live VRF2"
      vrf_id      = 20000
    },
    {
      name        = "VRF3"
      description = "Cisco Live VRF3"
      vrf_id      = 30000
    },
  ]

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

resource "nxos_ipv4_vrf" "vxlan_ipv4_vrf_default" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.value.name
  name     = "default"
}
