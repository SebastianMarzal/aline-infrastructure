resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = "${var.namespace}-ingress"
    namespace = var.namespace
    labels = {
      component = "ingress"
    }
    annotations = {
      kubernetes.io / ingress.class           = "alb"
      alb.ingress.kubernetes.io / scheme      = "internet-facing"
      alb.ingress.kubernetes.io / target-type = "ip"
    }
  }

  spec {
    rule {
      host = "api.alinefinancial.com"
      http {
        path {
          path_type = "Prefix"
          path      = "/api/"
          backend {
            service {
              name = "gateway-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "admin.alinefinancial.com"
      http {
        path {
          path_type = "Prefix"
          path      = "/"
          backend {
            service {
              name = "admin-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "member.alinefinancial.com"
      http {
        path {
          path_type = "Prefix"
          path      = "/"
          backend {
            service {
              name = "dashboard-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "alinefinancial.com"
      http {
        path {
          path_type = "Prefix"
          path      = "/"
          backend {
            service {
              name = "landing-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}