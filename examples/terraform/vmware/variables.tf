variable "vsphere_server" {
  description = "URL of vSphere server"
}

variable "vsphere_user" {
  description = "Username for connecting to vSphere"
}

variable "vsphere_password" {
  description = "Password for vSphere connection"
}

variable "datacenter" {
  default = ""
}

variable "resource_pool" {
}

variable "folder" {
  default = ""
}

variable "datastore_cluster" {
}

variable "network" {
}

variable "template_vm_linux" {
  description = "VM to use as a template for the linux nodes (managers, workers)"
}

# variable "template_vm_windows" {
#     description = "VM to use as a template for the Windows nodes (Windows workers)"
# }

variable "ssh_private_key_file" {
  description = "Private key for SSH connections to created virtual machines; currently all machines must use the same key"
}

variable "ucp_admin_username" {
  description = "Desired username for the UCP admin account"
  default     = "admin"
}

variable "ucp_admin_password" {
  description = "Desired password for the UCP admin account"
}

variable "ucp_lb_dns_name" {
  description = "DNS name of the UCP load balancer"
}

variable "quantity_managers" {
  description = "Number of UCP manager VMs to create"
  default     = 3
}

variable "quantity_workers" {
  description = "Number of UCP worker VMs to create"
  default     = 3
}

# variable "quantity_workers_windows" {
#   description = "Number of UCP worker VMs to create (Windows)"
#   default = 0
# }
