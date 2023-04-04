resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace
  }

  spec {
    type          = "ExternalName"
    external_name = var.db_endpoint
  }
}

resource "kubernetes_service" "back-end" {
  metadata {
    name      = "back-end-service"
    namespace = var.namespace
    labels = {
      component = deployment
    }
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      "component" = "deployment"
    }

    dynamic "port" {
      for_each = local.name_port_map

      name        = "${each.key}-port"
      protocol    = "TCP"
      port        = each.value
      target_port = each.value
    }
  }
}

resource "kubernetes_service" "front-end" {
  for_each = toset(["admin", "dashboard", "landing"])

  metadata {
    name      = "${each.key}-service"
    namespace = var.namespace
    labels = {
      "component" = "admin"
    }
  }

  spec {
    type = "LoadBalancer"
    selector = {
      component = "admin"
    }
    port {
      name        = each.key
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_service" "gateway" {
  metadata {
    name      = "gateway-service"
    namespace = var.namespace
    labels = {
      component = "gateway"
    }
  }

  spec {
    type = "LoadBalancer"
    selector {
      component = "gateway"
    }
    port {
      name = "gateway"
      port = 80
    }
  }
}