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
  devices = [
    {
      name      = "CLspine1"
      url       = "https://10.15.37.100"
      role      = "spine"
      managed   = true
      router_id = "10.0.0.1"
      interfaces = {
        loopback0 = {
          ip = "10.0.0.1/32"
        },
        loopback1 = {
          ip = "10.100.100.1/32"
        },
        loopback250 = {
          ip = "10.250.250.1/32"
        }
      }
    },
    {
      name      = "CLleaf1"
      url       = "https://10.15.37.101"
      role      = "leaf"
      managed   = true
      router_id = "10.0.0.2"
      interfaces = {
        loopback0 = {
          ip = "10.0.0.2/32"
        },
        loopback1 = {
          ip = "10.100.100.2/32"
        },
        loopback250 = {
          ip = "10.250.250.2/32"
        }
      }
    },
    {
      name      = "CLleaf2"
      url       = "https://10.15.37.102"
      role      = "leaf"
      managed   = true
      router_id = "10.0.0.3"
      interfaces = {
        loopback0 = {
          ip = "10.0.0.3/32"
        },
        loopback1 = {
          ip = "10.100.100.3/32"
        },
        loopback250 = {
          ip = "10.250.250.3/32"
        }
      }
    },
  ]
}
