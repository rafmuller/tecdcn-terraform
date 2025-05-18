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
