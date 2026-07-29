# Inputs into this module

# Used to build name of objects we create
variable "environment" {
  type        = string
  description = "The name of the environment in which this module is being invoked"
  validation {
    condition     = contains(["sand", "dev", "uat", "perf", "stage", "prod", "core", "shared"], var.environment)
    error_message = "Environment must be one of sand, dev, uat, perf, stage, prod, core or shared."
  }
}

# Tags to add on to the default set on the provider
variable "tags" {
  type        = map(string)
  description = "Additional tags to be applied to all resources created by this module"
  default     = {}
}

variable "name_prefix" {
  type        = string
  description = "Prefix for the DynamoDB table name"
  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.name_prefix))
    error_message = "Name prefix must be numbers, lowercase letters and underscores."
  }
}

variable "partition_key" {
  type        = string
  description = "Partition key for the DynamoDB table"
}

variable "partition_key_type" {
  type        = string
  description = "Partition key type - must be S (string), N (number), or B (binary)"

  validation {
    condition     = contains(["S", "N", "B"], var.partition_key_type)
    error_message = "partition_key_type must be one of: S (string), N (number), B (binary)"
  }
}

variable "sort_key" {
  type        = string
  description = "Sort key for the DynamoDB table. Required if sort_key_type is set"
  default     = null
}

variable "sort_key_type" {
  type        = string
  description = "Sort key type - must be S (string), N (number), or B (binary). Required if sort_key is set"
  default     = null
  validation {
    condition     = var.sort_key_type == null || contains(["S", "N", "B"], var.sort_key_type)
    error_message = "sort_key_type must be one of: S (string), N (number), B (binary)"
  }
  validation {
    condition     = (var.sort_key == null && var.sort_key_type == null) || (var.sort_key != null && var.sort_key_type != null)
    error_message = "sort_key and sort_key_type must both be set or both be null"
  }
}

variable "ttl_attribute" {
  type        = string
  description = "Attribute name for TTL (Time To Live) - optional"
  default     = null
}

variable "billing_mode" {
  type        = string
  description = "Billing mode: PAY_PER_REQUEST (on-demand, the default) or PROVISIONED. PROVISIONED with small capacities stays within the DynamoDB always-free tier (25 RCU + 25 WCU per account)."
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "read_capacity" {
  type        = number
  description = "Read capacity units. Required when billing_mode is PROVISIONED, ignored otherwise."
  default     = null
  validation {
    condition     = var.billing_mode != "PROVISIONED" || (var.read_capacity != null && var.write_capacity != null)
    error_message = "read_capacity and write_capacity are required when billing_mode is PROVISIONED."
  }
}

variable "write_capacity" {
  type        = number
  description = "Write capacity units. Required when billing_mode is PROVISIONED, ignored otherwise."
  default     = null
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "Protect the table from deletion. Keep true for anything holding real data; set false only for tables that are safe to destroy and recreate."
  default     = true
}

variable "account_shortname" {
  type        = string
  description = "Optional short name for the current account, used in resource name suffixes. Falls back to the raw account ID when not set."
  default     = null
}
