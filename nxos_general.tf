
locals {
  device_interface_map = {
    for device in try(local.devices, []) : device.name => {
      for interface in try(device.interfaces, []) : interface.id => {
        key         = format("%s-%s", device.name, interface.id)
        name        = device.name
        ip          = interface.ip
        description = try(interface.description, "Configured by Terraform")
        mtu         = try(interface.mtu, 9216)
        speed       = try(interface.speed, "auto")
        layer       = try(interface.layer, "Layer3")
        link_type   = interface.link_type
      }
    }
  }


}
