variable "component" {
  default = {
    catalogue = {
      rule_priority = 10
    },
    cart = {
      rule_priority = 11
    },
    shipping = {
      rule_priority = 11
    },
    payment = {
      rule_priority = 12
    },
    user = {
      rule_priority = 13
    },
    frontend = {
      rule_priority = 5
    }
  }
}
