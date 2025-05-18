# .__   __. ___   ___   ______        _______.    _______   ___________    ____  __    ______  _______     _______.
# |  \ |  | \  \ /  /  /  __  \      /       |   |       \ |   ____\   \  /   / |  |  /      ||   ____|   /       |
# |   \|  |  \  V  /  |  |  |  |    |   (----`   |  .--.  ||  |__   \   \/   /  |  | |  ,----'|  |__     |   (----`
# |  . `  |   >   <   |  |  |  |     \   \       |  |  |  ||   __|   \      /   |  | |  |     |   __|     \   \    
# |  |\   |  /  .  \  |  `--'  | .----)   |      |  '--'  ||  |____   \    /    |  | |  `----.|  |____.----)   |   
# |__| \__| /__/ \__\  \______/  |_______/       |_______/ |_______|   \__/     |__|  \______||_______|_______/    
# 
# This file just contains the local variable definion for the devices. Any additinoal add of 
# devices to this list, would trigger the creation of resources for that device and configure 
# everything for that device.                                                                                                    


locals {

  # devices = local.devices


  # devices = [
  #   {
  #     name      = "CLspine1"
  #     url       = "https://10.15.37.100"
  #     role      = "spine"
  #     managed   = true
  #     router_id = "10.0.0.1"
  #     bgp = {
  #       asn              = local.bgp_global.bgp_asn
  #       vrf              = local.bgp_global.vrf
  #       routing_loopback = local.bgp_global.routing_loopback
  #       vtep_loopback    = local.bgp_global.vtep_loopback
  #       rp_loopback      = local.bgp_global.rp_loopback
  #     }
  #     interfaces = [
  #       {
  #         id          = "lo0" # Must match output show int brief
  #         description = "Routing Loopback"
  #         layer       = "Layer3"
  #         ip          = "10.0.0.1/32"
  #         peering_ip  = "10.0.0.1"
  #         link_type   = "underlay"
  #       },
  #       {
  #         id          = "lo1" # Must match output show int brief
  #         description = "VTEP Loopback"
  #         layer       = "Layer3"
  #         ip          = "10.100.100.1/32"
  #         peering_ip  = "10.100.100.1"
  #         link_type   = "underlay-lo"
  #       },
  #       {
  #         id          = "lo250" # Must match output show int brief
  #         description = "RP Loopback"
  #         speed       = "auto"
  #         layer       = "Layer3"
  #         ip          = "10.250.250.1/32"
  #         peering_ip  = "10.250.250.1"
  #         link_type   = "underlay-lo"
  #       },
  #       {
  #         id          = "eth1/1" # Must match output show int brief
  #         description = "Uplink to Leaf1"
  #         mtu         = 9216
  #         speed       = "auto"
  #         layer       = "Layer3"
  #         ip          = "10.1.1.1/30"
  #         link_type   = "underlay-l3"
  #       },
  #       {
  #         id          = "eth1/2" # Must match output show int brief
  #         description = "Uplink to Leaf2"
  #         mtu         = 9216
  #         speed       = "auto"
  #         layer       = "Layer3"
  #         ip          = "10.1.1.5/30"
  #         link_type   = "underlay-l3"
  #       }
  #     ]
  #   },
  #   {
  #     name      = "CLleaf1"
  #     url       = "https://10.15.37.101"
  #     role      = "leaf"
  #     managed   = true
  #     router_id = "10.0.0.2"
  #     bgp = {
  #       asn              = local.bgp_global.bgp_asn
  #       vrf              = local.bgp_global.vrf
  #       routing_loopback = local.bgp_global.routing_loopback
  #       vtep_loopback    = local.bgp_global.vtep_loopback
  #       rp_loopback      = local.bgp_global.rp_loopback
  #     }
  #     interfaces = [
  #       {
  #         id          = "lo0" # Must match output show int brief
  #         description = "Routing Loopback"
  #         layer       = "Layer3"
  #         ip          = "10.0.0.2/32"
  #         peering_ip  = "10.0.0.2"
  #         link_type   = "underlay-lo"
  #       },
  #       {
  #         id          = "lo1" # Must match output show int brief
  #         description = "VTEP Loopback"
  #         layer       = "Layer3"
  #         ip          = "10.100.100.2/32"
  #         peering_ip  = "10.100.100.2"
  #         link_type   = "underlay-lo"
  #       },
  #       {
  #         id          = "lo250" # Must match output show int brief
  #         description = "RP Loopback"
  #         speed       = "auto"
  #         layer       = "Layer3"
  #         ip          = "10.250.250.2/32"
  #         peering_ip  = "10.250.250.2"
  #         link_type   = "underlay-lo"
  #       },
  #       {
  #         id          = "eth1/1" # Must match output show int brief
  #         description = "Uplink to Spine"
  #         mtu         = 9216
  #         speed       = "auto"
  #         layer       = "Layer3"
  #         ip          = "10.1.1.2/30"
  #         link_type   = "underlay-l3"
  #       },

  #     ]
  #   },
  #   {
  #     name      = "CLleaf2"
  #     url       = "https://10.15.37.102"
  #     role      = "leaf"
  #     managed   = true
  #     router_id = "10.0.0.3"
  #     bgp = {
  #       asn              = local.bgp_global.bgp_asn
  #       vrf              = local.bgp_global.vrf
  #       routing_loopback = local.bgp_global.routing_loopback
  #       vtep_loopback    = local.bgp_global.vtep_loopback
  #       rp_loopback      = local.bgp_global.rp_loopback
  #     }
  #     interfaces = [
  #       {
  #         id          = "lo0" # Must match output show int brief
  #         description = "Routing Loopback"
  #         layer       = "Layer3"
  #         ip          = "10.0.0.3/32"
  #         peering_ip  = "10.0.0.3"
  #         link_type   = "underlay-lo"
  #       },
  #       {
  #         id          = "lo1" # Must match output show int brief
  #         description = "VTEP Loopback"
  #         layer       = "Layer3"
  #         ip          = "10.100.100.3/32"
  #         peering_ip  = "10.100.100.3"
  #         link_type   = "underlay-lo"
  #       },
  #       {
  #         id          = "lo50" # Must match output show int brief
  #         description = "RP Loopback"
  #         speed       = "auto"
  #         layer       = "Layer3"
  #         ip          = "10.250.250.3/32"
  #         peering_ip  = "10.250.250.3"
  #         link_type   = "underlay-lo"
  #       },
  #       {
  #         id          = "eth1/1" # Must match output show int brief
  #         description = "Uplink to Spine"
  #         mtu         = 9216
  #         speed       = "auto"
  #         layer       = "Layer3"
  #         ip          = "10.1.1.6/30"
  #         link_type   = "underlay-l3"
  #       },
  #     ]
  #   }
  # ]
}
