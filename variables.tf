locals {
  root_directory = path.root
}

locals {
  folder_types = {
    dev  = "development"
    prod = "production"
  }
}

variable "user_directory" {}