# Declare the label module
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # Use the appropriate version

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  tags        = var.tags  # Ensure you pass any other required variables from your configuration
}

# Declare the data resource for aws_partition
data "aws_partition" "current" {}

locals {
  create_eks_service_role = local.enabled && var.create_eks_service_role
  eks_service_role_arn    = local.create_eks_service_role ? one(aws_iam_role.default[*].arn) : var.eks_cluster_service_role_arn
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_eks_service_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count                = local.create_eks_service_role ? 1 : 0
  name                 = module.label.id
  assume_role_policy   = one(data.aws_iam_policy_document.assume_role[*].json)
  tags                 = module.label.tags # Updated for consistency
  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  count = local.create_eks_service_role ? 1 : 0

  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", one(data.aws_partition.current[*].partition))
  role       = one(aws_iam_role.default[*].name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_service_policy" {
  count = local.create_eks_service_role ? 1 : 0

  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSServicePolicy", one(data.aws_partition.current[*].partition))
  role       = one(aws_iam_role.default[*].name)
}

data "aws_iam_policy_document" "cluster_elb_service_role" {
  count = local.create_eks_service_role ? 1 : 0

  statement {
    sid    = "AllowElasticLoadBalancer"
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInternetGateways",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSubnets"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyCreateLogGroup"
    effect = "Deny"
    actions = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_elb_service_role" {
  count = local.create_eks_service_role ? 1 : 0

  name   = "${module.label.id}-ServiceRole"
  policy = one(data.aws_iam_policy_document.cluster_elb_service_role[*].json)
  tags   = module.label.tags # Ensures tagging consistency
}

resource "aws_iam_role_policy_attachment" "cluster_elb_service_role" {
  count      = local.create_eks_service_role ? 1 : 0
  policy_arn = one(aws_iam_policy.cluster_elb_service_role[*].arn)
  role       = one(aws_iam_role.default[*].name)
}
