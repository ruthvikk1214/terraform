output "sg_ids" {
  description = "Security Group IDs mapped by SG name"

  value = {
    for idx, sg in module.sg :
    var.sg_names[idx] => sg.sg_id
  }
}