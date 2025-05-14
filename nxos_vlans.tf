locals {
  defined_vlans = [
    {
      name    = "VLAN-100"
      vlan_id = 100
      vni     = 10000
    },
    {
      name    = "VLAN-200"
      vlan_id = 200
      vni     = 20000
    },
    {
      name    = "VLAN-300"
      vlan_id = 300
      vni     = 30000
    },
  ]

  vlans = flatten([
    for device in try(local.devices, []) : [
      for vlan in try(local.defined_vlans, []) : {
        key     = format("%s-%s-%s", device.name, vlan.vlan_id, vlan.vni)
        name    = vlan.name
        vlan_id = vlan.vlan_id
        vni     = vlan.vni
        device  = device
      }
    ]
  ])
}

resource "nxos_bridge_domain" "vxlan_vlans" {
  for_each     = { for vlan in try(local.vlans, []) : vlan.key => vlan if vlan.device.role != "spine" }
  device       = each.value.device.name
  fabric_encap = "vlan-${each.value.vlan_id}"
  access_encap = "vxlan-${each.value.vni}"
  name         = each.value.name
  depends_on   = [nxos_vrf.vxlan_vrf]
}
