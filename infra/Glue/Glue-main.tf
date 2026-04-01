resource "aws_glue_catalog_database" "scan_results" {
  name = var.glue_database_name
}