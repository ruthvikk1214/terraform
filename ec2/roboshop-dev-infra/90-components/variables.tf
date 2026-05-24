variable "component" {
  default = {
    catalogue = {
      rule_priority = 110
    },
    cart = {
      rule_priority = 111  # Moving away from the stuck priority 11 slot
    },
    shipping = {
      rule_priority = 114
    },
    payment = {
      rule_priority = 112
    },
    user = {
      rule_priority = 113
    },
    frontend = {
      rule_priority = 105
    }
  }
}