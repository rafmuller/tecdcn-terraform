#  __        ______     ______   .______   .______        ___       ______  __  ___      _______.
# |  |      /  __  \   /  __  \  |   _  \  |   _  \      /   \     /      ||  |/  /     /       |
# |  |     |  |  |  | |  |  |  | |  |_)  | |  |_)  |    /  ^  \   |  ,----'|  '  /     |   (----`
# |  |     |  |  |  | |  |  |  | |   ___/  |   _  <    /  /_\  \  |  |     |    <       \   \    
# |  `----.|  `--'  | |  `--'  | |  |      |  |_)  |  /  _____  \ |  `----.|  .  \  .----)   |   
# |_______| \______/   \______/  | _|      |______/  /__/     \__\ \______||__|\__\ |_______/    
#
# All configuration for loopback interfaces. 

locals {
  vxlan_underlay_lo_interfaces = flatten([
    for device in try(local.devices, []) : [
      for interface in try(device.interfaces, []) : {
        key         = format("%s-%s", device.name, interface.id)
        device      = device.name
        id          = interface.id
        ip          = interface.ip
        admin_state = try(interface.admin_state, "up")
        description = try(interface.description, "Configured by Terraform")
        link_type   = interface.link_type
      } if interface.link_type == "underlay-lo"
    ]
  ])

}


resource "nxos_loopback_interface" "vxlan_underlay_loopback_interfaces" {
  for_each     = { for interface in local.vxlan_underlay_lo_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  admin_state  = each.value.admin_state
  description  = each.value.description
}

resource "nxos_loopback_interface_vrf" "loopback_interface_vrf" {
  for_each     = { for interface in local.vxlan_underlay_lo_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  vrf_dn       = "sys/inst-default"
  depends_on   = [nxos_loopback_interface.vxlan_underlay_loopback_interfaces]
}

resource "nxos_ipv4_interface" "loopback_ipv4_interface" {
  for_each     = { for interface in local.vxlan_underlay_lo_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  depends_on   = [nxos_loopback_interface_vrf.loopback_interface_vrf]
}

resource "nxos_ipv4_interface_address" "loopback_ipv4_interface_address" {
  for_each     = { for interface in local.vxlan_underlay_lo_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  address      = each.value.ip
  type         = "primary"
  depends_on   = [nxos_ipv4_interface.loopback_ipv4_interface]
}
