variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "germanywestcentral"
}

variable "github_user" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_access_token" {
  type = string
}