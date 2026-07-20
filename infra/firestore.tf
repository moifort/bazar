resource "google_firebaserules_ruleset" "firestore" {
  provider = google-beta
  project  = google_project.this.project_id

  source {
    files {
      name    = "firestore.rules"
      content = file("${path.root}/../firestore.rules")
    }
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firebaserules_release" "firestore" {
  provider     = google-beta
  project      = google_project.this.project_id
  name         = "cloud.firestore"
  ruleset_name = "projects/${google_project.this.project_id}/rulesets/${google_firebaserules_ruleset.firestore.name}"
}

locals {
  firestore_indexes = jsondecode(file("${path.root}/../firestore.indexes.json")).indexes
}

resource "google_firestore_index" "composite" {
  # Keyed by a stable identifier (collection + fields), not the array position, so
  # adding or removing an index never re-keys — and therefore never destroys and
  # recreates — the others. A position key churned every index that followed the
  # one being inserted.
  #
  # Switching *to* this key was itself a one-off re-key of everything, and it
  # failed on the first apply: Firestore deletes indexes asynchronously, so the
  # destroys returned before the indexes were gone and the immediate recreate hit
  # `409 index already exists` on the very ids just destroyed. Re-running the
  # apply once the deletions had settled fixed it. Any future change that re-keys
  # this resource needs the same two-pass treatment — or `moved` blocks, if the
  # old keys are still in state.
  for_each = {
    for idx in local.firestore_indexes :
    "${idx.collectionGroup}|${join(",", [for f in idx.fields : "${f.fieldPath}:${try(f.order, "NA")}"])}" => idx
  }

  provider    = google-beta
  project     = google_project.this.project_id
  database    = google_firestore_database.default.name
  collection  = each.value.collectionGroup
  query_scope = each.value.queryScope

  dynamic "fields" {
    for_each = each.value.fields
    content {
      field_path = fields.value.fieldPath
      order      = try(fields.value.order, null)
    }
  }
}
