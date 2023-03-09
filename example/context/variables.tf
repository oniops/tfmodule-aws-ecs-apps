variable "context" {
  type = object({
    # profile     = string # Identify a specific profile that used by provisioners like terraform.
    project     = string # project name is usally account's project name or platform name
    region      = string # describe default region to create a resource from aws
    environment = string # Distinguish between development, test, and production resources
    department  = string # Organization name of BSP
    owner       = string # Identify who is responsible for the resource
    customer    = string # Identify a specific client that a particular group of resources serves
    domain      = string # public toolchain domain name (ex, tools.customer.co.kr)
    pri_domain  = string # private domain name (ex, tools.customer.co.kr)
  })
}

variable "name_prefix" {
  description = "resource name prefix"
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

variable "team" {
  description = "The of team"
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Identify the cost center or business unit associated with a resource, typically for cost"
  type        = number
  default     = null
}

variable "provisioner" {
  description = "Provisioner tool like terraform, cloudformation"
  type        = string
  default     = "Terraform"
}
