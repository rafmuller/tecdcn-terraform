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
# This is the main terraform file that will load the VXLAN module. This files passes the information of 
# the YAML files into the module that reads this and creates a single in memory data structure that is used to
# that is read by the NXOS resources. 


module "vxlan" {
  source = "./vxlan"

  yaml_directories = ["data/", "data/interfaces/"]
}



