module "this_context" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # requires Terraform >= 0.13.0

  enabled       = var.enabled                # Keep as is, from variables.tf
  namespace     = var.namespace              # Keep as is, from variables.tf
  environment   = var.environment            # Keep as is, from variables.tf
  delimiter      = var.delimiter
  attributes    = var.attributes
  tags          = var.tags
  labels_as_tags = var.labels_as_tags
}

# Removed the enabled variable declaration
variable "module_namespace" {
  type        = string
  default     = null
  description = "Module specific namespace ID."
}

variable "module_environment" {
  type        = string
  default     = null
  description = "Module specific environment ID."
}

variable "stage" {
  type        = string
  default     = null
  description = "ID element to specify the stage, e.g., 'build', 'test', 'deploy'."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to use between ID elements. Defaults to '-' (hyphen)."
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes to append to ID, joined by the delimiter."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for resources (e.g., `{'Owner': 'Gloopro'}`)."
}

variable "labels_as_tags" {
  type        = set(string)
  default     = ["default"]
  description = "Set of labels to include as tags in the `tags` output. Default includes all labels."
}
