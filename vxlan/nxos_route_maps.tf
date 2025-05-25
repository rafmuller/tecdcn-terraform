# .______        ______    __    __  .___________. _______    .___  ___.      ___      .______     _______.
# |   _  \      /  __  \  |  |  |  | |           ||   ____|   |   \/   |     /   \     |   _  \   /       |
# |  |_)  |    |  |  |  | |  |  |  | `---|  |----`|  |__      |  \  /  |    /  ^  \    |  |_)  | |   (----`
# |      /     |  |  |  | |  |  |  |     |  |     |   __|     |  |\/|  |   /  /_\  \   |   ___/   \   \    
# |  |\  \----.|  `--'  | |  `--'  |     |  |     |  |____    |  |  |  |  /  _____  \  |  |   .----)   |   
# | _| `._____| \______/   \______/      |__|     |_______|   |__|  |__| /__/     \__\ | _|   |_______/    


resource "nxos_route_map_rule" "vxlan_tag_route_map_rule" {
  for_each = { for device in local.devices : device.name => device if device.role == "leaf" }
  device   = each.value.name
  name     = "fabric-rmap-redist-subnet"
}

resource "nxos_route_map_rule_entry" "vxlan_tag_route_map_rule_priority" {
  for_each = { for device in local.devices : device.name => device if device.role == "leaf" }

  device    = each.value.name
  order     = "10"     # 1-65535 is mandatory
  action    = "permit" # permit or deny is mandatory
  rule_name = "fabric-rmap-redist-subnet"

  depends_on = [nxos_route_map_rule.vxlan_tag_route_map_rule]
}

resource "nxos_route_map_rule_entry_match_tag" "vxlan_tag_route_map_rule_entry_match_tag" {
  for_each = { for device in local.devices : device.name => device if device.role == "leaf" }

  device    = each.value.name
  order     = "10" # 1-65535 is mandatory
  rule_name = "fabric-rmap-redist-subnet"
  tag       = "12345"

  depends_on = [nxos_route_map_rule_entry.vxlan_tag_route_map_rule_priority]
}
