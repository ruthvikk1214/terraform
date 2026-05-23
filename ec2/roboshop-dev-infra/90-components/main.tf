module "component" {
  source        = "git::https://github.com/ruthvikk1214/terraform-roboshop-component.git?ref=main"
  for_each      = var.component
  component     = each.key
  rule_priority = each.value.rule_priority

}
