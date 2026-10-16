terraform {
  # Input validations that refer to other inputs need 1.9.
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 6.37 is the first release where an index's key_schema works with dynamic blocks, a single range key
      # and index removal.
      version = ">= 6.37"
    }
  }
}
