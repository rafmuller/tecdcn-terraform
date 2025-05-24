locals {

  vxlan_underlay_l3_interfaces = flatten([
    for device in try(local.devices, []) : [
      for interface in try(device.interfaces, []) : {
        key         = format("%s-%s", device.name, interface.id)
        device      = device.name
        ip          = interface.ip
        id          = interface.id
        admin_state = try(interface.admin_state, "up")
        description = try(interface.description, "Configured by Terraform")
        mtu         = try(interface.mtu, 9216)
        speed       = try(interface.speed, "auto")
        layer       = "Layer3"
        link_type   = interface.link_type
      } if interface.link_type == "underlay-l3"
    ]
  ])
}

output "vxlan_underlay_l3_interfaces" {
  description = "List of devices with underlay L3 interfaces"
  value       = local.vxlan_underlay_l3_interfaces
}

resource "nxos_physical_interface" "vxlan_underlay_routed_ethernet_interfaces" {
  for_each     = { for interface in local.vxlan_underlay_l3_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  admin_state  = each.value.admin_state
  mtu          = each.value.mtu
  speed        = each.value.speed
  layer        = each.value.layer
  description  = each.value.description
}

resource "nxos_physical_interface_vrf" "vxlan_underlay_routed_ethernet_interfaces_vrf" {
  for_each     = { for interface in local.vxlan_underlay_l3_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  vrf_dn       = "sys/inst-default"
  depends_on   = [nxos_physical_interface.vxlan_underlay_routed_ethernet_interfaces]
}

resource "nxos_ipv4_interface" "vxlan_underlay_routed_ethernet_interfaces_ipv4" {
  for_each     = { for interface in local.vxlan_underlay_l3_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  depends_on   = [nxos_physical_interface.vxlan_underlay_routed_ethernet_interfaces]
}

resource "nxos_ipv4_interface_address" "vxlan_underlay_routed_ethernet_interfaces_ipv4_address" {
  for_each     = { for interface in local.vxlan_underlay_l3_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  address      = each.value.ip
  depends_on   = [nxos_ipv4_interface.vxlan_underlay_routed_ethernet_interfaces_ipv4]
}

resource "nxos_physical_interface" "vxlan_underlay_routed_ethernet_interfaces_admin_state" {
  for_each     = { for interface in local.vxlan_underlay_l3_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  admin_state  = each.value.admin_state
  mtu          = each.value.mtu
  speed        = each.value.speed
  layer        = each.value.layer
  description  = each.value.description
  depends_on   = [nxos_ipv4_interface_address.vxlan_underlay_routed_ethernet_interfaces_ipv4_address]
}
