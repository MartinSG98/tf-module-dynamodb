# tf-module-dynamodb

Creates a DynamoDB table with safe defaults: point-in-time recovery, encryption at rest with the AWS managed KMS key, and deletion protection. Billing is on demand unless you choose provisioned capacity, items can expire through an optional TTL attribute, and the table can have global secondary indexes. The module covers the basics only, so there is no capacity auto scaling, no replication and there are no local secondary indexes.

The table is named `<name_prefix>-ddb-<environment>-gbl-<account>`, with the global name suffix from [tf-module-helpers](https://github.com/MartinSG98/tf-module-helpers). Point-in-time recovery keeps one day of history (`recovery_period_in_days = 1`). The module needs Terraform 1.9 or newer, because some input validations refer to other inputs, and the AWS provider 6.37 or newer, the first release where an index's `key_schema` works without known bugs.

```hcl
module "orders_table" {
  source = "git::https://github.com/MartinSG98/tf-module-dynamodb.git?ref=1.2.0"

  environment = var.environment
  name_prefix = "myapp_orders"

  partition_key      = "pk"
  partition_key_type = "S"
  sort_key           = "sk"
  sort_key_type      = "S"
  ttl_attribute      = "expires_at"

  tags = local.tags
}
```

For a small table that should stay within the DynamoDB always-free tier (25 read and 25 write capacity units per account), switch to provisioned capacity:

```hcl
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
```

To query the table by another key, add a global secondary index. Each index names its keys, and the module declares every key attribute on the table once, so two indexes can share one. Indexes project every attribute unless you pick `KEYS_ONLY`, or `INCLUDE` with a list of attributes. With provisioned billing an index takes the table's capacity unless it sets its own.

```hcl
  global_secondary_indexes = [
    {
      name               = "by-customer"
      partition_key      = "customerId"
      partition_key_type = "S"
      sort_key           = "createdAt"
      sort_key_type      = "S"
    },
  ]
```

Deletion protection is on by default. Turn it off with `deletion_protection_enabled = false` only for tables that are safe to destroy and create again.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `environment` | `string` | required | Environment the module is used in: `sand`, `dev`, `uat`, `perf`, `stage`, `prod`, `core` or `shared` |
| `name_prefix` | `string` | required | Prefix for the table name, in lower-case letters, digits and underscores |
| `partition_key` | `string` | required | Partition (hash) key attribute |
| `partition_key_type` | `string` | required | Partition key type: `S` (string), `N` (number) or `B` (binary) |
| `sort_key` | `string` | `null` | Sort (range) key attribute. Set together with `sort_key_type` or not at all |
| `sort_key_type` | `string` | `null` | Sort key type: `S`, `N` or `B` |
| `global_secondary_indexes` | `list(object)` | `[]` | Indexes, each with a `name`, `partition_key` and `partition_key_type`, and optionally `sort_key` and `sort_key_type`, `projection_type` (`ALL`, `KEYS_ONLY` or `INCLUDE`), `non_key_attributes` for `INCLUDE`, and `read_capacity` and `write_capacity` for provisioned billing |
| `ttl_attribute` | `string` | `null` | Attribute holding an expiry time in Unix epoch seconds. When set, DynamoDB deletes items once that time has passed |
| `billing_mode` | `string` | `"PAY_PER_REQUEST"` | `PAY_PER_REQUEST` (on demand) or `PROVISIONED` |
| `read_capacity` | `number` | `null` | Read capacity units. Required with `PROVISIONED`, ignored otherwise |
| `write_capacity` | `number` | `null` | Write capacity units. Required with `PROVISIONED`, ignored otherwise |
| `deletion_protection_enabled` | `bool` | `true` | Protect the table from deletion. Keep it on for anything that holds real data |
| `account_shortname` | `string` | `null` | Short name for the current account in name suffixes. Falls back to the account ID |
| `tags` | `map(string)` | `{}` | Extra tags for the table. An `InfraModule` tag is added with `tf-module-dynamodb`, followed by any `InfraModule` value you pass here |

## Outputs

| Name | Description |
|---|---|
| `table_name` | Name of the DynamoDB table |
| `table_arn` | ARN of the DynamoDB table |
