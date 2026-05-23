variable "component" {
  default = {
    catalogue = {
      rule_priority = 10
    },
    cart = {
      rule_priority = 11
    },
    # shipping = {
    #   rule_priority = 11
    # },
    # payment = {
    #   rule_priority = 11
    # },
    # user = {
    #   rule_priority = 11
    # },
    frontend = {
      rule_priority = 5
    }
  }
}
