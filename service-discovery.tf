locals {
  namespace_id = var.namespace_id != null ? var.namespace_id : try(data.aws_service_discovery_dns_namespace.dns[0].id, null)
}

resource "aws_service_discovery_service" "this" {
  count = var.enable_service_discovery ? 1 : 0
  name  = var.app_name

  dns_config {
    namespace_id   = local.namespace_id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 60
      type = "A"
    }
  }

}
