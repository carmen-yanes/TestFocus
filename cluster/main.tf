variable "do_token" {}
variable "region" {}
variable "project_name" {}
variable "node_count" {}
variable "machine_size" {}

provider "digitalocean" {
    token = var.do_token
}
data "digitalocean_kubernetes_versions" "versions" {}

resource "digitalocean_kubernetes_cluster" "cluster" {
    name    = "${var.project_name}-cluster"
    region  = var.region
    version = data.digitalocean_kubernetes_versions.versions.latest_version
    tags    = ["test"]
    node_pool {
        name       = "worker-pool"
        size       = var.machine_size
        node_count = var.node_count
    }
}
provider "kubernetes" {
    load_config_file = false
    host  = digitalocean_kubernetes_cluster.cluster.endpoint
    token = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
    )
}
/*

INSTEAD OF CIVO IS DIGITAL OCEAN
provider "helm" {
    kubernetes {
    host     = data.civo_kubernetes_cluster.cluster.api_endpoint
    client_certificate = base64decode(
      yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-certificate-data
    )
    client_key = base64decode(
      yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-key-data
    )
    cluster_ca_certificate = base64decode(
      yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).clusters[0].cluster.certificate-authority-data
    )
  }
}
*/
output "cluster-id" {
    value = digitalocean_kubernetes_cluster.cluster.id
}
output "endpoint" {
    value = digitalocean_kubernetes_cluster.cluster.endpoint
}
output "token" {
    value = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    sensitive = true
}

output "cert" {
    value = digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
    sensitive = true
}

output "k8s_version" {
    value = data.digitalocean_kubernetes_versions.versions.latest_version
}
output "kube_config" {
    value = digitalocean_kubernetes_cluster.cluster.kube_config[0]
    sensitive = true
}

