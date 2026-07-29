# tf-module-dynamodb

This module creates a DynamoDB table with best-practice settings including point-in-time recovery, server-side encryption, and deletion protection. Billing is on-demand by default, with optional provisioned capacity.

Note: This module currently supports basic features only - no capacity auto-scaling, replication, or secondary indexes.

## Inputs

* `environment`: The name of the environment in which this module is being invoked.
* `tags`: Additional tags to be applied to all resources created by this module.
* `name_prefix`: Used for naming all resources created.
* `partition_key`: Partition key (hash key) for the DynamoDB table.
* `partition_key_type`: Partition key type - must be S (string), N (number), or B (binary).
* `sort_key`: Sort key (range key) for the DynamoDB table. Optional. Required if sort_key_type is set.
* `sort_key_type`: Sort key type - must be S (string), N (number), or B (binary). Optional. Required if sort_key is set.
* `ttl_attribute`: Attribute name for TTL (Time To Live). Optional. When set, DynamoDB will automatically delete items after the timestamp (which uses Unix epoch seconds) in this attribute has passed.
* `billing_mode`: PAY_PER_REQUEST (default) or PROVISIONED. Small PROVISIONED capacities stay within the DynamoDB always-free tier (25 RCU + 25 WCU per account).
* `read_capacity`, `write_capacity`: capacity units, required when billing_mode is PROVISIONED.
* `deletion_protection_enabled`: default true. Set false only for tables that are safe to destroy and recreate.
* `account_shortname`: optional short name for the current account, used in resource name suffixes.

## Outputs

* `table_name`: The name of the DynamoDB table.
* `table_arn`: The ARN of the DynamoDB table.
