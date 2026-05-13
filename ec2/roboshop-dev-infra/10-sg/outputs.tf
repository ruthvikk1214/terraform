output "sg_ids" {
  value = { for k, v in module.sg : k => v.sg_id }
}