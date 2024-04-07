variable "user_directory" {}

resource "null_resource" "make_directory" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${local.root_directory}/${local.folder_types[terraform.workspace]}-dir-$USERDIRECTORY"
    interpreter = ["bash", "-c"]

    environment = {
      USERDIRECTORY = var.user_directory
    }
  }
}

resource "null_resource" "create_file" {
  depends_on = [null_resource.make_directory]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "touch ${local.root_directory}/${local.folder_types[terraform.workspace]}-dir-$USERDIRECTORY/file-${timestamp()}"
    interpreter = ["bash", "-c"]
    when        = create

    environment = {
      USERDIRECTORY = var.user_directory
    }    
  }
}

