# .______     ______   .______     .___________.    _______.
# |   _  \   /  __  \  |   _  \    |           |   /       |
# |  |_)  | |  |  |  | |  |_)  |   `---|  |----`  |   (----`
# |   ___/  |  |  |  | |      /        |  |        \   \    
# |  |      |  `--'  | |  |\  \----.   |  |    .----)   |   
# | _|       \______/  | _| `._____|   |__|    |_______/    
#
# These reources are used to create the phyiscal interface ports that connect to the 
# switches.

locals {
  l2_access_ports = flatten([
    for device in try(local.devices, []) : [
      for interface in try(device.interfaces, []) : {
        key         = format("%s-%s", device.name, interface.id)
        device      = device.name
        id          = interface.id
        description = try(interface.description, "Configured by Terraform")
        mtu         = try(interface.mtu, 9216)
        speed       = try(interface.speed, "auto")
        admin_state = try(interface.admin_state, "up")
        layer       = "Layer2"
        l2_mode     = "access"
        vlan        = interface.vlans
      } if interface.link_type == "service-l2" && try(interface.l2_mode, null) == "access"
    ]
  ])

  l2_trunk_ports = flatten([
    for device in try(local.devices, []) : [
      for interface in try(device.interfaces, []) : {
        key         = format("%s-%s", device.name, interface.id)
        device      = device.name
        id          = interface.id
        description = try(interface.description, "Configured by Terraform")
        mtu         = try(interface.mtu, 9216)
        admin_state = try(interface.admin_state, "up")
        speed       = try(interface.speed, "auto")
        layer       = "Layer2"
        l2_mode     = "trunk"
        trunk_vlans = interface.vlans
      } if interface.link_type == "service-l2" && try(interface.l2_mode, null) == "trunk"
    ]
  ])
}

output "l2_access_ports" {
  description = "List of L2 Access Ports"
  value       = local.l2_access_ports
}

output "l2_trunk_ports" {
  description = "List of L2 Trunk Ports"
  value       = local.l2_trunk_ports
}

resource "nxos_physical_interface" "vxlan_access_port_service_interface" {
  for_each     = { for interface in try(local.l2_access_ports, []) : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  description  = each.value.description
  mode         = "access"
  mtu          = each.value.mtu
  access_vlan  = "vlan-${each.value.vlan}"
  admin_state  = each.value.admin_state
  speed        = each.value.speed
  layer        = "Layer2"
}
resource "nxos_physical_interface" "vxlan_trunk_port_service_interface" {
  for_each     = { for interface in try(local.l2_trunk_ports, []) : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  description  = each.value.description
  mode         = "trunk"
  mtu          = each.value.mtu
  admin_state  = each.value.admin_state
  speed        = each.value.speed
  layer        = "Layer2"
  trunk_vlans  = each.value.trunk_vlans
  depends_on   = [nxos_feature_lacp.lacp]
}
