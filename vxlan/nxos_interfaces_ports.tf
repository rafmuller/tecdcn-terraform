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
      for interface in try(device.interfaces, []) : [
        for vlans in try(interface.vlans, []) : {
          key         = format("%s-%s", device.name, interface.id)
          device      = device.name
          id          = interface.id
          description = try(interface.description, "Configured by Terraform")
          mtu         = try(interface.mtu, 9216)
          speed       = try(interface.speed, "auto")
          layer       = "Layer2"
          link_type   = interface.link_type
          l2_mode     = "access"
          vlan        = vlans.vlan_id
        } if interface.link_type == "service-l2" && try(interface.l2_mode, null) == "access"
      ]
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
        speed       = try(interface.speed, "auto")
        layer       = "Layer2"
        link_type   = interface.link_type
        l2_mode     = "trunk"
        trunk_vlans = [for vlan in try(interface.vlans, []) : vlan.vlan_id]
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
