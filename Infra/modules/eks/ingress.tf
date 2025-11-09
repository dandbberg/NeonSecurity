resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.0"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  values = [file("${path.module}/ingress-values.yaml")]
}