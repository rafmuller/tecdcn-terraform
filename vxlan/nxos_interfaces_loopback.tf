#  __        ______     ______   .______   .______        ___       ______  __  ___      _______.
# |  |      /  __  \   /  __  \  |   _  \  |   _  \      /   \     /      ||  |/  /     /       |
# |  |     |  |  |  | |  |  |  | |  |_)  | |  |_)  |    /  ^  \   |  ,----'|  '  /     |   (----`
# |  |     |  |  |  | |  |  |  | |   ___/  |   _  <    /  /_\  \  |  |     |    <       \   \    
# |  `----.|  `--'  | |  `--'  | |  |      |  |_)  |  /  _____  \ |  `----.|  .  \  .----)   |   
# |_______| \______/   \______/  | _|      |______/  /__/     \__\ \______||__|\__\ |_______/    
#
# All configuration for loopback interfaces. 

locals {
  vxlan_underlay_routing_lo_interfaces = flatten([
    for device in try(local.devices, []) : [
      for interface in try(device.interfaces, []) : {
        key         = format("%s-%s", device.name, interface.id)
        device      = device.name
        id          = interface.id
        ip          = interface.ip
        admin_state = try(interface.admin_state, "up")
        description = try(interface.description, "Configured by Terraform")
        link_type   = interface.link_type
      } if interface.link_type == "underlay-lo" && interface.id == local.global.routing_loopback
    ]
  ])

  vxlan_underlay_vtep_lo_interfaces = flatten([
    for device in try(local.devices, []) : [
      for interface in try(device.interfaces, []) : {
        key         = format("%s-%s", device.name, interface.id)
        device      = device.name
        id          = interface.id
        ip          = interface.ip
        admin_state = try(interface.admin_state, "up")
        description = try(interface.description, "Configured by Terraform")
        link_type   = interface.link_type
      } if interface.link_type == "underlay-lo" && interface.id == local.global.vtep_loopback && device.role == "leaf"
    ]
  ])

  vxlan_underlay_rp_lo_interfaces = flatten([
    for device in try(local.devices, []) : [
      for interface in try(device.interfaces, []) : {
        key         = format("%s-%s", device.name, interface.id)
        device      = device.name
        id          = interface.id
        ip          = interface.ip
        admin_state = try(interface.admin_state, "up")
        description = try(interface.description, "Configured by Terraform")
        link_type   = interface.link_type
      } if interface.link_type == "underlay-lo" && interface.id == local.global.rp_loopback && device.role == "spine"
    ]
  ])

}

output "vxlan_underlay_routing_lo_interfaces" {
  description = "List of loopback interfaces for underlay routing"
  value       = local.vxlan_underlay_routing_lo_interfaces
}

output "vxlan_underlay_vtep_lo_interfaces" {
  description = "List of loopback interfaces for VTEP"
  value       = local.vxlan_underlay_vtep_lo_interfaces
}

output "vxlan_underlay_rp_lo_interfaces" {
  description = "List of loopback interfaces for RP"
  value       = local.vxlan_underlay_rp_lo_interfaces
}



# .______        ______    __    __  .___________. __  .__   __.   _______ 
# |   _  \      /  __  \  |  |  |  | |           ||  | |  \ |  |  /  _____|
# |  |_)  |    |  |  |  | |  |  |  | `---|  |----`|  | |   \|  | |  |  __  
# |      /     |  |  |  | |  |  |  |     |  |     |  | |  . `  | |  | |_ | 
# |  |\  \----.|  `--'  | |  `--'  |     |  |     |  | |  |\   | |  |__| | 
# | _| `._____| \______/   \______/      |__|     |__| |__| \__|  \______| 
#
# All Routing loopback interfaces. These are used for the underlay routing protocol.

resource "nxos_loopback_interface" "vxlan_underlay_routing_lo_interfaces" {
  for_each     = { for interface in local.vxlan_underlay_routing_lo_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  admin_state  = each.value.admin_state
  description  = each.value.description
}

resource "nxos_loopback_interface_vrf" "lvxlan_underlay_routing_lo_interface_vrf" {
  for_each     = { for interface in local.vxlan_underlay_routing_lo_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  vrf_dn       = "sys/inst-default"
  depends_on   = [nxos_loopback_interface.vxlan_underlay_routing_lo_interfaces]
}

resource "nxos_ipv4_interface" "vxlan_underlay_routing_lo_ipv4_interface" {
  for_each     = { for interface in local.vxlan_underlay_routing_lo_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  depends_on   = [nxos_loopback_interface_vrf.lvxlan_underlay_routing_lo_interface_vrf]
}

resource "nxos_ipv4_interface_address" "vxlan_underlay_routing_lo_ipv4_interface_address" {
  for_each     = { for interface in local.vxlan_underlay_routing_lo_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  address      = each.value.ip
  type         = "primary"
  depends_on   = [nxos_ipv4_interface.vxlan_underlay_routing_lo_ipv4_interface]
}

# ____    ____ .___________. _______ .______   
# \   \  /   / |           ||   ____||   _  \  
#  \   \/   /  `---|  |----`|  |__   |  |_)  | 
#   \      /       |  |     |   __|  |   ___/  
#    \    /        |  |     |  |____ |  |      
#     \__/         |__|     |_______|| _|      
#
# All VTEP loopback interfaces. These are used for VXLAN VTEP traffic.

resource "nxos_loopback_interface" "vxlan_underlay_vtep_lo_interfaces" {
  for_each     = { for interface in local.vxlan_underlay_vtep_lo_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  admin_state  = each.value.admin_state
  description  = each.value.description
}

resource "nxos_loopback_interface_vrf" "vxlan_underlay_vtep_lo_interface_vrf" {
  for_each     = { for interface in local.vxlan_underlay_vtep_lo_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  vrf_dn       = "sys/inst-default"
  depends_on   = [nxos_loopback_interface.vxlan_underlay_vtep_lo_interfaces]
}

resource "nxos_ipv4_interface" "vxlan_underlay_vtep_lo_ipv4_interface" {
  for_each     = { for interface in local.vxlan_underlay_vtep_lo_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  depends_on   = [nxos_loopback_interface_vrf.vxlan_underlay_vtep_lo_interface_vrf]
}

resource "nxos_ipv4_interface_address" "vxlan_underlay_vtep_lo_ipv4_interface_address" {
  for_each     = { for interface in local.vxlan_underlay_vtep_lo_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  address      = each.value.ip
  type         = "primary"
  depends_on   = [nxos_ipv4_interface.vxlan_underlay_vtep_lo_ipv4_interface]
}


# .______      .______   
# |   _  \     |   _  \  
# |  |_)  |    |  |_)  | 
# |      /     |   ___/  
# |  |\  \----.|  |      
# | _| `._____|| _|      
#
# All RP loopback interfaces. These are used for PIM RP traffic.

resource "nxos_loopback_interface" "vxlan_underlay_rp_lo_interfaces" {
  for_each     = { for interface in local.vxlan_underlay_rp_lo_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  admin_state  = each.value.admin_state
  description  = each.value.description
}

resource "nxos_loopback_interface_vrf" "vxlan_underlay_rp_lo_interface_vrf" {
  for_each     = { for interface in local.vxlan_underlay_rp_lo_interfaces : interface.key => interface }
  device       = each.value.device
  interface_id = each.value.id
  vrf_dn       = "sys/inst-default"
  depends_on   = [nxos_loopback_interface.vxlan_underlay_rp_lo_interfaces]
}

resource "nxos_ipv4_interface" "vxlan_underlay_rp_lo_ipv4_interface" {
  for_each     = { for interface in local.vxlan_underlay_rp_lo_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  depends_on   = [nxos_loopback_interface_vrf.vxlan_underlay_rp_lo_interface_vrf]
}

resource "nxos_ipv4_interface_address" "vxlan_underlay_rp_lo_ipv4_interface_address" {
  for_each     = { for interface in local.vxlan_underlay_rp_lo_interfaces : interface.key => interface }
  device       = each.value.device
  vrf          = "default"
  interface_id = each.value.id
  address      = each.value.ip
  type         = "primary"
  depends_on   = [nxos_ipv4_interface.vxlan_underlay_rp_lo_ipv4_interface]
}
