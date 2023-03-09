include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "network" {
  config_path = "../../network"

  mock_outputs = {
    subnet_public_a_id = "dummy"
  }
}

dependency "storage" {
  config_path = "../../storage"

  mock_outputs = {
    s3_bucket_name = "dummy"
    s3_object_name = "dummy"
  }
}

inputs = {
  product        = include.root.locals.product
  env            = include.root.locals.env_vars.locals.env
  subnet_id      = dependency.network.outputs.subnet_public_a_id
  s3_bucket_name = dependency.storage.outputs.s3_bucket_name
  s3_object_name = dependency.storage.outputs.s3_object_name
}
