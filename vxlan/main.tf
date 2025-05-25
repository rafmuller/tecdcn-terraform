
# .___  ___.   ______    _______   __    __   __       _______    .___  ___.      ___       __  .__   __. 
# |   \/   |  /  __  \  |       \ |  |  |  | |  |     |   ____|   |   \/   |     /   \     |  | |  \ |  | 
# |  \  /  | |  |  |  | |  .--.  ||  |  |  | |  |     |  |__      |  \  /  |    /  ^  \    |  | |   \|  | 
# |  |\/|  | |  |  |  | |  |  |  ||  |  |  | |  |     |   __|     |  |\/|  |   /  /_\  \   |  | |  . `  | 
# |  |  |  | |  `--'  | |  '--'  ||  `--'  | |  `----.|  |____    |  |  |  |  /  _____  \  |  | |  |\   | 
# |__|  |__|  \______/  |_______/  \______/  |_______||_______|   |__|  |__| /__/     \__\ |__| |__| \__| 
#
# This is the main module that will be used to construct the VXLAN fabric. This receives the 
# data structure from the YAML files defined in the main terrraform file. The module then 
# performs a merge using some special utilities created by Cisco engineers that are then 
# broken apart into smaller data structures below. 

locals {
  devices     = local.model.vxlan-ciscolive.devices
  bgp_global  = local.model.vxlan-ciscolive.bgp_global
  ospf_global = local.model.vxlan-ciscolive.ospf_global
  networks    = local.model.vxlan-ciscolive.networks
  global      = local.model.vxlan-ciscolive.global

  device_map = { for device in try(local.devices, []) : device.name => device }

  device_interface_map = {
    for device in try(local.devices, []) : device.name => {
      for interface in try(device.interfaces, []) : interface.id => {
        key         = format("%s-%s", device.name, interface.id)
        id          = interface.id
        name        = device.name
        ip          = try(interface.ip, null)
        peering_ip  = try(interface.peering_ip, "")
        description = try(interface.description, "Configured by Terraform")
        mtu         = try(interface.mtu, 9216)
        speed       = try(interface.speed, "auto")
        layer       = try(interface.layer, "Layer3")
        link_type   = interface.link_type
      }
    }
  }
}

output "device_interface_map" {
  description = "Map of devices and their interfaces"
  value       = local.device_interface_map
}


terraform {
  required_version = ">= 1.5.7"
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "0.5.10"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.2.6"
    }
  }
}

provider "nxos" {
  username = "admin"
  password = "cisco"
  devices  = local.devices
}
