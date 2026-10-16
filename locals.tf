locals {
  # Every attribute used as a key by the table or an index, declared once each. Grouping (the trailing ...) keeps
  # an attribute that several keys share from being a duplicate map key; the inputs check that its types agree.
  key_attribute_types = {
    for key in concat(
      [{ name = var.partition_key, type = var.partition_key_type }],
      var.sort_key != null ? [{ name = var.sort_key, type = var.sort_key_type }] : [],
      [for index in var.global_secondary_indexes : { name = index.partition_key, type = index.partition_key_type }],
      [for index in var.global_secondary_indexes : { name = index.sort_key, type = index.sort_key_type } if index.sort_key != null],
    ) : key.name => key.type...
  }
  key_attributes = { for name, types in local.key_attribute_types : name => types[0] }

  # Used to tag all resources created by the module
  tags = merge(
    var.tags,
    { "InfraModule" = join(":", compact(["tf-module-dynamodb", lookup(var.tags, "InfraModule", "")])) }
  )
}
