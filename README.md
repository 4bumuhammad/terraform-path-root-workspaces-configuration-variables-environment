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
    ❯ tree -L 3 -a -I 'README.md|.DS_Store|.git|.gitignore|gambar-petunjuk|.terraform|*.hcl|*.tfstate|*.tfstate.backup|*.tfstate.d' ./

        ├── main.tf
        ├── provider.tf
        ├── tfvar_abumuhammad.tfvars
        └── variables.tf

        0 directories, 4 files
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
</pre>

&nbsp;

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



            Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
            + create

            Terraform will perform the following actions:

            # null_resource.create_file will be created
            + resource "null_resource" "create_file" {
                + id       = (known after apply)
                + triggers = {
                    + "always_run" = (known after apply)
                    }
                }

            # null_resource.make_directory will be created
            + resource "null_resource" "make_directory" {
                + id       = (known after apply)
                + triggers = {
                    + "always_run" = (known after apply)
                    }
                }

            Plan: 2 to add, 0 to change, 0 to destroy.

            ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

            Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
</pre>

<pre>
    ❯ terraform apply -var-file=tfvar_abumuhammad.tfvars -auto-approve



            Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
            + create

            Terraform will perform the following actions:

            # null_resource.create_file will be created
            + resource "null_resource" "create_file" {
                + id       = (known after apply)
                + triggers = {
                    + "always_run" = (known after apply)
                    }
                }

            # null_resource.make_directory will be created
            + resource "null_resource" "make_directory" {
                + id       = (known after apply)
                + triggers = {
                    + "always_run" = (known after apply)
                    }
                }

            Plan: 2 to add, 0 to change, 0 to destroy.
            null_resource.make_directory: Creating...
            null_resource.make_directory: Provisioning with 'local-exec'...
            null_resource.make_directory (local-exec): Executing: ["bash" "-c" "mkdir -p ./development-dir-$USERDIRECTORY"]
            null_resource.make_directory: Creation complete after 0s [id=2964119630432058196]
            null_resource.create_file: Creating...
            null_resource.create_file: Provisioning with 'local-exec'...
            null_resource.create_file (local-exec): Executing: ["bash" "-c" "touch ./development-dir-$USERDIRECTORY/file-2024-04-07T16:30:54Z"]
            null_resource.create_file: Creation complete after 0s [id=5498691487426809591]

            Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
</pre>

&nbsp;

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

<div align="center">
    <img src="./gambar-petunjuk/well_done.png" alt="well_done" style="display: block; margin: 0 auto;">
</div> 

&nbsp;

---

&nbsp;

&nbsp;