resource "aws_service_discovery_service" "this" {
  count = !var.enable_service_discovery || var.delete_service ? 0 : 1
  name  = var.app_name

  dns_config {
    namespace_id = var.cloud_map_namespace_id

    dns_records {
      ttl  = 60
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}
