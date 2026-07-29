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

variable "account_shortname" {
  type        = string
  description = "Optional short name for the current account, used in resource name suffixes. Falls back to the raw account ID when not set."
  default     = null
}
