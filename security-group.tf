locals {
  cluster_security_group_id = one(aws_eks_cluster.default[*].vpc_config[0].cluster_security_group_id)
}

# Optional: Egress rule allowing all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  description       = "Allow all outbound traffic"
  security_group_id = local.cluster_security_group_id
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"  # Use "-1" for all protocols
  cidr_ipv4         = "0.0.0.0/0"  # Corrected to use cidr_ipv4
}

resource "aws_vpc_security_group_ingress_rule" "managed_ingress_security_groups" {
  count = length(var.allowed_security_group_ids)

  description                  = "Allow inbound traffic from existing Security Groups"
  ip_protocol                  = "-1"
  referenced_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id            = local.cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "managed_ingress_cidr_blocks" {
  count = length(var.allowed_cidr_blocks)

  description       = "Allow inbound traffic from CIDR blocks"
  ip_protocol       = "-1"
  cidr_ipv4         = var.allowed_cidr_blocks[count.index]
  security_group_id = local.cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "custom_ingress_rules" {
  for_each = { for sg_rule in var.custom_ingress_rules : sg_rule.source_security_group_id => sg_rule }

  description                  = each.value.description
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  referenced_security_group_id = each.value.source_security_group_id
  security_group_id            = local.cluster_security_group_id
}
