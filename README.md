# Terraform : path root - workspaces - configuration variables - environment

&nbsp;

&#x1F516; Information on the user's device.<br />
<pre>
    ❯ system_profiler SPSoftwareDataType SPHardwareDataType

        Software:
            System Software Overview:
                System Version: macOS 13.3.1 (22E261)
                Kernel Version: Darwin 22.4.0
                Boot Volume: Macintosh HD
                Boot Mode: Normal    
                . . .

        Hardware:
            Hardware Overview:
                Model Name: MacBook Pro
                Model Identifier: MacBookPro17,1
                Model Number: MYD82ID/A
                Chip: Apple M1
                Total Number of Cores: 8 (4 performance and 4 efficiency)
                Memory: 8 GB
                . . .
</pre>

&nbsp;

<div align="center">
    <img src="./gambar-petunjuk/ss_terraform_logo_black.png" alt="ss_terraform_logo_black" style="display: block; margin: 0 auto;">
</div> 

&nbsp;

---

&nbsp;

Project structure.
<pre>
    ❯ tree -L 3 -a -I 'README.md|.DS_Store|.git|.gitignore|gambar-petunjuk|.terraform|*.hcl|*.tfstate|*.tfstate.backup|*.tfstate.d|*.txt' ./
        ├── main.tf
        ├── outputs.tf
        ├── provider.tf
        ├── tfvar_abumuhammad.tfvars
        └── variables.tf

        0 directories, 5 files
</pre>

&nbsp;

&nbsp;

### Code : 

<pre>
    ❯ vim provider.tf  

    
        terraform {
          required_providers {
            null = {
              source = "hashicorp/null"
            }
          }
        }
</pre>

&nbsp;

<pre>
    ❯ vim variables.tf


        locals {
          root_directory = path.root
        }
        
        locals {
          folder_types={
            dev = "development"
            prod = "production"
          }
        }
        
        variable "user_directory" {}
</pre>

&nbsp;

<pre>
    ❯ vim tfvar_abumuhammad.tfvars


        user_directory = "dhonyabumuhammad"
</pre>

&nbsp;

<pre>
    ❯ vim main.tf



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
            command = &lt;&lt;EOT
              echo "REPORTS" &gt; directory_name.txt
              echo "  Trigger Name: ${self.triggers.trigger_name}" &gt;&gt; directory_name.txt
              echo "  Terraform Workspace: $(terraform workspace show)" &gt;&gt; directory_name.txt
              echo "  Environment USERDIRECTORY: ${var.user_directory}" &gt;&gt; directory_name.txt
              echo "  Created Directory: ${local.root_directory}/${local.folder_types[terraform.workspace]}-dir-${var.user_directory}" &gt;&gt; directory_name.txt
              echo "  Timestamp: $(date)" &gt;&gt; directory_name.txt
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
            command = &lt;&lt;EOT
              if [ ! -f "directory_name.txt" ]; then
                echo "REPORTS" &gt; directory_name.txt
              fi
        
              echo "" &gt;&gt; directory_name.txt
              echo "  Trigger Name: ${self.triggers.trigger_name}" &gt;&gt; directory_name.txt
              echo "  Terraform Workspace: $(terraform workspace show)" &gt;&gt; directory_name.txt
              echo "  Environment USERDIRECTORY: ${var.user_directory}" &gt;&gt; directory_name.txt
              echo "  Created File: ${local.root_directory}/${local.folder_types[terraform.workspace]}-dir-${var.user_directory}/file-${timestamp()}" &gt;&gt; directory_name.txt
              echo "  Timestamp: $(date)" &gt;&gt; directory_name.txt
            EOT
          }
        }
</pre>

&nbsp;

<pre>
  ❯ vim outputs.tf



        data "local_file" "load_directory_name" {
          depends_on = [null_resource.create_file]
          filename   = "directory_name.txt"
        }
        
        output "load_directory_name" {
          value = data.local_file.load_directory_name.content
        }
</pre>

&nbsp;

&nbsp;


### &#x1F530; TERRAFORM STAGES :

&nbsp;

<pre>
    ❯ terraform init


            Initializing the backend...

            Initializing provider plugins...
            - Finding latest version of hashicorp/null...
            - Installing hashicorp/null v3.2.2...
            - Installed hashicorp/null v3.2.2 (signed by HashiCorp)

            Terraform has created a lock file .terraform.lock.hcl to record the provider
            selections it made above. Include this file in your version control repository
            so that Terraform can guarantee to make the same selections by default when
            you run "terraform init" in the future.

            Terraform has been successfully initialized!

            You may now begin working with Terraform. Try running "terraform plan" to see
            any changes that are required for your infrastructure. All Terraform commands
            should now work.

            If you ever set or change modules or backend configuration for Terraform,
            rerun this command to reinitialize your working directory. If you forget, other
            commands will detect it and remind you to do so if necessary.    
</pre>

&nbsp;

<pre>
    ❯ terraform workspace new dev

            Created and switched to workspace "dev"!

            You're now on a new, empty workspace. Workspaces isolate their state,
            so if you run "terraform plan" Terraform will not see any existing state
            for this configuration.




    ❯ terraform workspace new prod

            Created and switched to workspace "prod"!

            You're now on a new, empty workspace. Workspaces isolate their state,
            so if you run "terraform plan" Terraform will not see any existing state
            for this configuration.




    ❯ terraform workspace list

            default
            dev
            * prod



    ❯ terraform workspace select dev

            Switched to workspace "dev".
</pre>
 
&nbsp;

<pre>
    ❯ terraform fmt

    ❯ terraform validate

            Success! The configuration is valid.
</pre>

&nbsp;

<pre>
    ❯ terraform plan -var-file=tfvar_abumuhammad.tfvars



            null_resource.make_directory: Refreshing state... [id=1672252347760177823]
            null_resource.create_file: Refreshing state... [id=5840028482044876675]

            Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
            -/+ destroy and then create replacement
            <= read (data resources)

            Terraform will perform the following actions:

              # data.local_file.load_directory_name will be read during apply
              # (depends on a resource or a module with changes pending)
            <= data "local_file" "load_directory_name" {
                  + content              = (known after apply)
                  + content_base64       = (known after apply)
                  + content_base64sha256 = (known after apply)
                  + content_base64sha512 = (known after apply)
                  + content_md5          = (known after apply)
                  + content_sha1         = (known after apply)
                  + content_sha256       = (known after apply)
                  + content_sha512       = (known after apply)
                  + filename             = "directory_name.txt"
                  + id                   = (known after apply)
                }

              # null_resource.create_file must be replaced
            -/+ resource "null_resource" "create_file" {
                  ~ id       = "5840028482044876675" -> (known after apply)
                  ~ triggers = { # forces replacement
                      ~ "always_run"   = "2024-04-07T21:32:05Z" -> (known after apply)
                        # (1 unchanged element hidden)
                    }
                }

              # null_resource.make_directory must be replaced
            -/+ resource "null_resource" "make_directory" {
                  ~ id       = "1672252347760177823" -> (known after apply)
                  ~ triggers = { # forces replacement
                      ~ "always_run"   = "2024-04-07T21:32:05Z" -> (known after apply)
                        # (1 unchanged element hidden)
                    }
                }

            Plan: 2 to add, 0 to change, 2 to destroy.

            Changes to Outputs:
              ~ load_directory_name = &lt;&lt;-EOT
                    REPORTS
                      Trigger Name: trigger-make-directory
                      Terraform Workspace: dev
                      Environment USERDIRECTORY: dhonyabumuhammad
                      Created Directory: ./development-dir-dhonyabumuhammad
                      Timestamp: Mon Apr  8 04:32:05 WIB 2024
                    
                      Trigger Name: trigger-create-file
                      Terraform Workspace: dev
                      Environment USERDIRECTORY: dhonyabumuhammad
                      Created File: ./development-dir-dhonyabumuhammad/file-2024-04-07T21:32:05Z
                      Timestamp: Mon Apr  8 04:32:05 WIB 2024
                EOT -> (known after apply)
</pre>

<pre>
    ❯ terraform apply -var-file=tfvar_abumuhammad.tfvars -auto-approve



            null_resource.make_directory: Refreshing state... [id=7714679182606336800]
            null_resource.create_file: Refreshing state... [id=955515706683786597]

            Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
            -/+ destroy and then create replacement
            <= read (data resources)

            Terraform will perform the following actions:

              # data.local_file.load_directory_name will be read during apply
              # (depends on a resource or a module with changes pending)
            <= data "local_file" "load_directory_name" {
                  + content              = (known after apply)
                  + content_base64       = (known after apply)
                  + content_base64sha256 = (known after apply)
                  + content_base64sha512 = (known after apply)
                  + content_md5          = (known after apply)
                  + content_sha1         = (known after apply)
                  + content_sha256       = (known after apply)
                  + content_sha512       = (known after apply)
                  + filename             = "directory_name.txt"
                  + id                   = (known after apply)
                }

              # null_resource.create_file must be replaced
            -/+ resource "null_resource" "create_file" {
                  ~ id       = "955515706683786597" -> (known after apply)
                  ~ triggers = { # forces replacement
                      ~ "always_run"   = "2024-04-07T21:23:28Z" -> (known after apply)
                        # (1 unchanged element hidden)
                    }
                }

              # null_resource.make_directory must be replaced
            -/+ resource "null_resource" "make_directory" {
                  ~ id       = "7714679182606336800" -> (known after apply)
                  ~ triggers = { # forces replacement
                      ~ "always_run"   = "2024-04-07T21:23:28Z" -> (known after apply)
                        # (1 unchanged element hidden)
                    }
                }

            Plan: 2 to add, 0 to change, 2 to destroy.

            Changes to Outputs:
              ~ load_directory_name = &lt;&lt;-EOT
                    REPORTS
                      Trigger Name: trigger-make-directory
                      Terraform Workspace: dev
                      Environment USERDIRECTORY: dhonyabumuhammad
                      Created Directory: ./development-dir-dhonyabumuhammad
                      Timestamp: Mon Apr  8 04:23:28 WIB 2024
                    
                      Trigger Name: trigger-create-file
                      Terraform Workspace: dev
                      Environment USERDIRECTORY: dhonyabumuhammad
                      Created File: ./development-dir-dhonyabumuhammad/file-2024-04-07T21:23:28Z
                      Timestamp: Mon Apr  8 04:23:28 WIB 2024
                EOT -> (known after apply)
            null_resource.create_file: Destroying... [id=955515706683786597]
            null_resource.create_file: Destruction complete after 0s
            null_resource.make_directory: Destroying... [id=7714679182606336800]
            null_resource.make_directory: Destruction complete after 0s
            null_resource.make_directory: Creating...
            null_resource.make_directory: Provisioning with 'local-exec'...
            null_resource.make_directory (local-exec): Executing: ["bash" "-c" "mkdir -p ./development-dir-$USERDIRECTORY"]
            null_resource.make_directory: Provisioning with 'local-exec'...
            null_resource.make_directory (local-exec): Executing: ["/bin/sh" "-c" "      echo \"REPORTS\" > directory_name.txt\n      echo \"  Trigger Name: trigger-make-directory\" &gt;&gt; directory_name.txt\n      echo \"  Terraform Workspace: $(terraform workspace show)\" &gt;&gt; directory_name.txt\n      echo \"  Environment USERDIRECTORY: dhonyabumuhammad\" &gt;&gt; directory_name.txt\n      echo \"  Created Directory: ./development-dir-dhonyabumuhammad\"&gt;&gt; directory_name.txt\n      echo \"  Timestamp: $(date)\" &gt;&gt; directory_name.txt\n"]
            null_resource.make_directory: Creation complete after 0s [id=1672252347760177823]
            null_resource.create_file: Creating...
            null_resource.create_file: Provisioning with 'local-exec'...
            null_resource.create_file (local-exec): Executing: ["bash" "-c" "touch ./development-dir-$USERDIRECTORY/file-2024-04-07T21:32:05Z"]
            null_resource.create_file: Provisioning with 'local-exec'...
            null_resource.create_file (local-exec): Executing: ["/bin/sh" "-c" "      if [ ! -f \"directory_name.txt\" ]; then\n        echo \"REPORTS\" > directory_name.txt\n      fi\n\n      echo \"\" &gt;&gt; directory_name.txt\n      echo \"  Trigger Name: trigger-create-file\" &gt;&gt; directory_name.txt\n      echo \"  Terraform Workspace: $(terraform workspace show)\" &gt;&gt; directory_name.txt\n      echo \"  Environment USERDIRECTORY: dhonyabumuhammad\" &gt;&gt; directory_name.txt\n      echo \"  Created File: ./development-dir-dhonyabumuhammad/file-2024-04-07T21:32:05Z\" &gt;&gt; directory_name.txt\n      echo \"  Timestamp: $(date)\" &gt;&gt; directory_name.txt\n"]
            null_resource.create_file: Creation complete after 0s [id=5840028482044876675]
            data.local_file.load_directory_name: Reading...
            data.local_file.load_directory_name: Read complete after 0s [id=17159525d71785d193ca89f274ea521b9b84daeb]

            Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

            Outputs:

            load_directory_name = &lt;&lt;EOT
            REPORTS
              Trigger Name: trigger-make-directory
              Terraform Workspace: dev
              Environment USERDIRECTORY: dhonyabumuhammad
              Created Directory: ./development-dir-dhonyabumuhammad
              Timestamp: Mon Apr  8 04:32:05 WIB 2024

              Trigger Name: trigger-create-file
              Terraform Workspace: dev
              Environment USERDIRECTORY: dhonyabumuhammad
              Created File: ./development-dir-dhonyabumuhammad/file-2024-04-07T21:32:05Z
              Timestamp: Mon Apr  8 04:32:05 WIB 2024

            EOT
</pre>

&nbsp;

### Result : 
<pre>
    ❯ find ./ -maxdepth 1 -type d -name '*-dir-*' -exec tree -L 3 -- {} \;

            .//development-dir-dhonyabumuhammad
            └── file-2024-04-07T16:30:54Z

            0 directories, 1 file

</pre>

&nbsp;

&nbsp;

---

&nbsp;

<pre>
    ❯ terraform destroy -var-file=tfvar_abumuhammad.tfvars -auto-approve


            null_resource.make_directory: Refreshing state... [id=2964119630432058196]
            null_resource.create_file: Refreshing state... [id=5498691487426809591]

            Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
            - destroy

            Terraform will perform the following actions:

            # null_resource.create_file will be destroyed
            - resource "null_resource" "create_file" {
                - id       = "5498691487426809591" -> null
                - triggers = {
                    - "always_run" = "2024-04-07T16:30:54Z"
                    } -> null
                }

            # null_resource.make_directory will be destroyed
            - resource "null_resource" "make_directory" {
                - id       = "2964119630432058196" -> null
                - triggers = {
                    - "always_run" = "2024-04-07T16:30:54Z"
                    } -> null
                }

            Plan: 0 to add, 0 to change, 2 to destroy.
            null_resource.create_file: Destroying... [id=5498691487426809591]
            null_resource.create_file: Destruction complete after 0s
            null_resource.make_directory: Destroying... [id=2964119630432058196]
            null_resource.make_directory: Destruction complete after 0s

            Destroy complete! Resources: 2 destroyed.
</pre>

&nbsp;

---

&nbsp;

<div align="center">
    <img src="./gambar-petunjuk/well_done.png" alt="well_done" style="display: block; margin: 0 auto;">
</div> 

&nbsp;

---

&nbsp;

&nbsp;