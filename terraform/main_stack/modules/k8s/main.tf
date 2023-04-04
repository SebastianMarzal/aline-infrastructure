locals {
  name_port_map = {
    account     = 8072,
    bank        = 8083,
    card        = 8084,
    transaction = 8073,
    underwriter = 8071,
    user        = 8070
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "this" {

}