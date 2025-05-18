# .___  ___.      ___       __  .__   __. 
# |   \/   |     /   \     |  | |  \ |  | 
# |  \  /  |    /  ^  \    |  | |   \|  | 
# |  |\/|  |   /  /_\  \   |  | |  . `  | 
# |  |  |  |  /  _____  \  |  | |  |\   | 
# |__|  |__| /__/     \__\ |__| |__| \__| 

# .___________. _______ .______      .______          ___       _______   ______   .______      .___  ___. 
# |           ||   ____||   _  \     |   _  \        /   \     |   ____| /  __  \  |   _  \     |   \/   | 
# `---|  |----`|  |__   |  |_)  |    |  |_)  |      /  ^  \    |  |__   |  |  |  | |  |_)  |    |  \  /  | 
#     |  |     |   __|  |      /     |      /      /  /_\  \   |   __|  |  |  |  | |      /     |  |\/|  | 
#     |  |     |  |____ |  |\  \----.|  |\  \----./  _____  \  |  |     |  `--'  | |  |\  \----.|  |  |  | 
#     |__|     |_______|| _| `._____|| _| `._____/__/     \__\ |__|      \______/  | _| `._____||__|  |__| 
#
# This is the main Terraform configuration file for managing Cisco Nexus devices. Here we define the 
# required providers and the first set of variables for the NXOS provider 
# to connect to each device.


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


