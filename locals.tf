locals {
  # Used to tag all resources created by the module
  tags = merge(
    var.tags,
    { "InfraModule" = join(":", compact(["tf-module-dynamodb", lookup(var.tags, "InfraModule", "")])) }
  )
}
