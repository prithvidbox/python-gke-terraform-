variable "gcp_project_id" {
  type = string

}

variable "cluster_name" {
  type = string

}

variable "gcp_location" {
  type = string
}

variable "daily_maintenance_window_start_time" {
  type = string
}

variable "node_pools" {
  type = list(map(string))
  
}

variable "vpc_network_name" {
  type = string


}

variable "vpc_subnetwork_name" {
  type = string


}

variable "cluster_secondary_range_name" {
  type = string


}

variable "services_secondary_range_name" {
  type = string

}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"


}

variable "access_private_images" {
  type    = bool
  default = false

}

variable "http_load_balancing_disabled" {
  type    = bool
  default = false


}

variable "master_authorized_networks_cidr_blocks" {
  type = list(map(string))

  default = [
    {
      # External network that can access Kubernetes master through HTTPS. Must
      # be specified in CIDR notation. This block should allow access from any
      # address, but is given explicitly to prevent Google's defaults from
      # fighting with Terraform.
      cidr_block = "0.0.0.0/0"
      # Field for users to identify CIDR blocks.
      display_name = "default"
    },
  ]


}

variable "min_master_version" {
  type = string

  default = ""

}

variable "release_channel" {
  type = string

  default = "REGULAR"

}

variable "authenticator_security_group" {
  type = string

  default = ""
}

variable "stackdriver_logging" {
  type    = bool
  default = true
}

variable "stackdriver_monitoring" {
  type    = bool
  default = true
}

variable "private_endpoint" {
  type    = bool
  default = false
}

variable "private_nodes" {
  type    = bool
  default = true
}

variable "pod_security_policy_enabled" {
  type = bool

  default = false
}

variable "identity_namespace" {
  type = string

  default = ""

}
