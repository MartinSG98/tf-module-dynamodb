# DynamoDB table resource
resource "aws_dynamodb_table" "this" {
  name         = "${var.name_prefix}-ddb-${module.helpers.name_suffix_global}"
  billing_mode = var.billing_mode
  hash_key     = var.partition_key
  range_key    = var.sort_key

  # Only meaningful (and only allowed to be set) in PROVISIONED mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Key attributes of the table and its indexes. DynamoDB only accepts attributes that some key uses.
  dynamic "attribute" {
    for_each = local.key_attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    iterator = index
    content {
      name               = index.value.name
      projection_type    = index.value.projection_type
      non_key_attributes = index.value.non_key_attributes

      # key_schema replaces the index's hash_key and range_key, which the provider deprecated in 6.x.
      key_schema {
        attribute_name = index.value.partition_key
        key_type       = "HASH"
      }
      dynamic "key_schema" {
        for_each = index.value.sort_key != null ? [index.value.sort_key] : []
        content {
          attribute_name = key_schema.value
          key_type       = "RANGE"
        }
      }

      read_capacity  = var.billing_mode == "PROVISIONED" ? coalesce(index.value.read_capacity, var.read_capacity) : null
      write_capacity = var.billing_mode == "PROVISIONED" ? coalesce(index.value.write_capacity, var.write_capacity) : null
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

  deletion_protection_enabled = var.deletion_protection_enabled

  tags = local.tags
}
