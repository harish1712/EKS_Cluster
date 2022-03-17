provider "aws" {
   region = "us-east-1"
   access_key = "AKIAZJ3JJO2FBJ7TMUFK"
   secret_key = "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"
 }

 /*provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint
    token = data.aws_eks_cluster_auth.cluster.token
    insecure = true
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
}*/

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig_EKS-Cluster"
  }
}
