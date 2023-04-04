resource "kubernetes_deployment" "back_end" {
  for_each = local.name_port_map

  metadata {
    name      = "${each.key}-microservice-${var.label_version}"
    namespace = var.namespace
    labels = {
      component = "deployment"
      version   = var.label_version
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        component = "deployment"
        version   = var.label_version
      }
    }

    template {
      metadata {
        labels = {
          component = "deployment"
          version   = var.label_version
        }
      }

      spec {
        container {
          name              = each.key
          image             = "${var.repository}-${each.key}:${var.label_version}"
          image_pull_policy = "IfNotPresent"
          port              = each.value
          env = {
            APP_PORT = "${each.value}"
          }

          env_from {
            config_map_ref {
              name = "backend-configmap"
            }
          }

          resources {
            limits = {
              memory = "512Mi"
              cpu    = "100m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "front_end" {
  for_each = toset(["admin", "dashboard", "landing"])

  metadata {
    name      = "${each.key}-microservice"
    namespace = var.namespace
    labels = {
      component = each.key
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        component = each.key
      }
    }

    template {
      metadata {
        labels = {
          component = each.key
        }
      }

      spec {
        container {
          name              = each.key
          image             = "${var.repository}-${each.key}:${var.label_version}"
          image_pull_policy = "IfNotPresent"
          port              = 80
          resources {
            limits = {
              memory = "256Mi"
              cpu    = "100m"
            }
          }
        }
      }
    }
  }
}



resource "kubernetes_deployment" "gateway" {
  metadata {
    name      = "gateway-microservice-${var.label_version}"
    namespace = var.namespace
    labels = {
      component = "gateway"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        component = "gateway"
        version   = var.label_version
      }
    }
    template {
      metadata {
        labels = {
          component = "gateway"
          version   = var.label_version
        }
      }

      spec {
        container {
          name              = gateway
          image             = "${var.repository}-gateway:${var.label_version}"
          image_pull_policy = "IfNotPresent"
          port              = 80
          env {
            APP_PORT         = "80"
            APP_SERVICE_HOST = "back-end-service"
            PORTAL_LANDING   = "landing-service"
            PORTAL_DASHBOARD = "dashboard-service"
            PORTAL_ADMIN     = "admin-service"
          }
          resources {
            limits = {
              memory = "512Mi"
              cpu    = "100m"
            }
          }
        }
      }
    }
  }
}