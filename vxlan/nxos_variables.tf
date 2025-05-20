# ____    ____  ___      .______       __       ___      .______    __       _______     _______.
# \   \  /   / /   \     |   _  \     |  |     /   \     |   _  \  |  |     |   ____|   /       |
#  \   \/   / /  ^  \    |  |_)  |    |  |    /  ^  \    |  |_)  | |  |     |  |__     |   (----`
#   \      / /  /_\  \   |      /     |  |   /  /_\  \   |   _  <  |  |     |   __|     \   \    
#    \    / /  _____  \  |  |\  \----.|  |  /  _____  \  |  |_)  | |  `----.|  |____.----)   |   
#     \__/ /__/     \__\ | _| `._____||__| /__/     \__\ |______/  |_______||_______|_______/    
#
# Here we define the variables for the VXLAN module. These variables are used to configure the module 
# and pass the data to it. You can see the definitions of these variables in the main.tf file 
# of the root directory in this repository.

variable "yaml_directories" {
  description = "Paths to YAML files with data for VXLAN configuration."
  type        = list(string)
  default     = []
}

variable "yaml_files" {
  description = "List of paths to YAML files."
  type        = list(string)
  default     = []
}

variable "model" {
  description = "As an alternative to YAML files, a native Terraform data structure can be provided as well."
  type        = map(any)
  default     = {}
}

variable "save_config" {
  description = "Write changes to startup-config on all devices."
  type        = bool
  default     = false
}
