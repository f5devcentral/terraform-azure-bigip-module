provider "bigip" {
  address  = format("https://%s:%s", module.bigip.mgmtPublicDNS, module.bigip.mgmtPort)
  username = format("%s", module.bigip.f5_username)
  password = format("%s", module.bigip.bigip_password)
}

resource "bigip_as3" "as3-example1" {
  as3_json = templatefile(
    "${path.module}/example1.tmpl",
    {
      pool_members = jsonencode(["192.168.50.1"])
    }
  )
  // as3_json = "${file("example1.json")}"
  //depends_on          = [module.bigip]

}
resource "bigip_do" "do-example" {
  do_json    = module.bigip.onboard_do
  depends_on = [module.bigip]
}