resource "null_resource" "make_directory" {
  triggers = {
    always_run   = "${timestamp()}"
    trigger_name = "trigger-make-directory"
  }

  provisioner "local-exec" {
    command     = "mkdir -p ${local.root_directory}/${local.folder_types[terraform.workspace]}-dir-$USERDIRECTORY"
    interpreter = ["bash", "-c"]

    environment = {
      USERDIRECTORY = var.user_directory
    }
  }
  provisioner "local-exec" {
    command = <<EOT
      echo "REPORTS" > directory_name.txt
      echo "  Trigger Name: ${self.triggers.trigger_name}" >> directory_name.txt
      echo "  Terraform Workspace: $(terraform workspace show)" >> directory_name.txt
      echo "  Environment USERDIRECTORY: ${var.user_directory}" >> directory_name.txt
      echo "  Created Directory: ${local.root_directory}/${local.folder_types[terraform.workspace]}-dir-${var.user_directory}" >> directory_name.txt
      echo "  Timestamp: $(date)" >> directory_name.txt
    EOT
  }
}

resource "null_resource" "create_file" {
  depends_on = [null_resource.make_directory]

  triggers = {
    always_run   = "${timestamp()}"
    trigger_name = "trigger-create-file"
  }

  provisioner "local-exec" {
    command     = "touch ${local.root_directory}/${local.folder_types[terraform.workspace]}-dir-$USERDIRECTORY/file-${timestamp()}"
    interpreter = ["bash", "-c"]
    when        = create

    environment = {
      USERDIRECTORY = var.user_directory
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      if [ ! -f "directory_name.txt" ]; then
        echo "REPORTS" > directory_name.txt
      fi

      echo "" >> directory_name.txt
      echo "  Trigger Name: ${self.triggers.trigger_name}" >> directory_name.txt
      echo "  Terraform Workspace: $(terraform workspace show)" >> directory_name.txt
      echo "  Environment USERDIRECTORY: ${var.user_directory}" >> directory_name.txt
      echo "  Created File: ${local.root_directory}/${local.folder_types[terraform.workspace]}-dir-${var.user_directory}/file-${timestamp()}" >> directory_name.txt
      echo "  Timestamp: $(date)" >> directory_name.txt
    EOT
  }
}