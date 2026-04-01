module "clamav_scanner" {
  source = "../clamav-scanning-folder"
}

module "glue" {
  source = "../Glue"

  scan_results_bucket = module.clamav_scanner.scan_results_bucket
  glue_database_name  = var.glue_database_name
}
