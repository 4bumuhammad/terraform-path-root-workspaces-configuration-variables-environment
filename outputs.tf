data "local_file" "load_directory_name" {
  depends_on = [null_resource.create_file]
  filename   = "directory_name.txt"
}

output "load_directory_name" {
  value = data.local_file.load_directory_name.content
}