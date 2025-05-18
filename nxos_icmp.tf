
#  ___  ____ __  __ ____    _____             _     _                             _
# |_ _|/ ___|  \/  |  _ \  | ____|_ __   __ _| |__ | | ___  _ __ ___   ___  _ __ | |_
#  | || |   | |\/| | |_) | |  _| | '_ \ / _` | '_ \| |/ _ \| '_ ` _ \ / _ \| '_ \| __|
#  | || |___| |  | |  __/  | |___| | | | (_| | |_) | |  __/| | | | | |  __/| | | | |_
# |___|\____|_|  |_|_|     |_____|_| |_|\__,_|_.__/|_|\___||_| |_| |_|\___||_| |_|\__|
# 
# ICMP is enabled on the switches and then at the VRF level. Then each interface that 
# requires redirect disabled, or other ICMP settings for VXLAN are done at the interface location

resource "nxos_icmpv4" "vxlan_icmpv4" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.value.name
  admin_state = "enabled"
}

resource "nxos_icmpv4_instance" "vxlan_icmpv4_instance" {
  for_each    = { for device in local.devices : device.name => device }
  device      = each.value.name
  admin_state = "enabled"
  depends_on  = [nxos_icmpv4.vxlan_icmpv4]
}
