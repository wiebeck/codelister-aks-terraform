resource "kubernetes_config_map" "cfg" {
  metadata {
    name = "codelister-configmap"
  }
  data = {
    gitHubUser = var.github_user
    gitHubRepo = var.github_repo
  }
}

resource "kubernetes_secret" "secret" {
  metadata {
    name = "codelister-secret"
  }
  type = "Opaque"
  data = {
    gitHubAccessToken = var.github_access_token
  }
}

resource "kubernetes_deployment" "codelister" {
  metadata {
    name = "codelister-deployment"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "Codelister"
      }
    }
    template {
      metadata {
        labels = {
          app = "Codelister"
        }
      }
      spec {
        container {
          name              = "codelister-container"
          image             = "acrriegedev001.azurecr.io/codelister:pr-3"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
          env {
            name = "CL_GITHUB_USER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.cfg.metadata[0].name
                key  = "gitHubUser"
              }
            }
          }
          env {
            name = "CL_GITHUB_REPO"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.cfg.metadata[0].name
                key  = "gitHubRepo"
              }
            }
          }
          env {
            name = "CL_GITHUB_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.secret.metadata[0].name
                key  = "gitHubAccessToken"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "codelister" {
  metadata {
    name = "codelister-service"
  }
  spec {
    selector = {
      app = "Codelister"
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = "8080"
    }
  }
}
