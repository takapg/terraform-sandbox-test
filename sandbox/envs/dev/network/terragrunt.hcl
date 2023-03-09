include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  product = include.root.locals.product
  env     = include.root.locals.env_vars.locals.env
}
