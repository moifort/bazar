terraform {
  backend "gcs" {
    bucket = "polyforms-bazar-prod-tfstate"
    prefix = "terraform/state"
  }
}
