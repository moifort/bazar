provider "google" {
  project               = var.project_id
  region                = var.region
  billing_project       = var.project_id
  user_project_override = true
}

provider "google-beta" {
  project               = var.project_id
  region                = var.region
  billing_project       = var.project_id
  user_project_override = true
}

locals {
  bucket_location = lookup(
    { eur3 = "EU", nam5 = "US", asia1 = "ASIA" },
    var.firestore_location,
    var.firestore_location,
  )
}
