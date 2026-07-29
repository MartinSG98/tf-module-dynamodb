# DynamoDB table resource
resource "aws_dynamodb_table" "this" {
  name         = "${var.name_prefix}-ddb-${module.helpers.name_suffix_global}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.partition_key
  range_key    = var.sort_key

  # Partition key (required)
  attribute {
    name = var.partition_key
    type = var.partition_key_type
  }

  dynamic "attribute" {
    for_each = var.sort_key != null ? [1] : []
    content {
      name = var.sort_key
      type = var.sort_key_type
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute
    }
  }

  # Point-in-time recovery for data protection
  point_in_time_recovery {
    enabled                 = true
    recovery_period_in_days = 1
  }

  # Server-side encryption at rest
  server_side_encryption {
    enabled = true
  }

  deletion_protection_enabled = true

  tags = local.tags
}
