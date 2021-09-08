/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  project = var.project_id
}

# [START cloudloadbalancing_ext_http_cloudrun]
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 5.1"
  name    = "tf-cr-lb"
  project = var.project_id

  ssl                             = var.ssl
  managed_ssl_certificate_domains = [var.domain]
  https_redirect                  = var.ssl

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.sneg-appkidsflixfinlandia.id
        },
        {
          group = google_compute_region_network_endpoint_group.sneg-appkidsflixeua.id
        }

      ]
      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = false
        sample_rate = null
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "sneg-appkidsflixfinlandia" {
#  provider              = google-beta
  name                  = "sneg-appkidsflixfinlandia"
  network_endpoint_type = "SERVERLESS"
  region                = var.region_eu
  cloud_run {
#    service = appkidsflixfinlandia
    service = google_cloud_run_service.appkidsflixfinlandia.name
   }
}

resource "google_compute_region_network_endpoint_group" "sneg-appkidsflixeua" {
#  provider              = google-beta
  name                  = "sneg-appkidsflixeua"
  network_endpoint_type = "SERVERLESS"
  region                = var.region_us
  cloud_run {
#    service = appkidsflixeua
    service = google_cloud_run_service.appkidsflixeua.name
   }
}

resource "google_cloud_run_service" "appkidsflixfinlandia" {
  name     = "appkidsflixfinlandia"
  location = var.region_eu
  project  = var.project_id
#  location = data.google_cloud_run_locations.available.locations[0]

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/appkidsflixfinlandia"
        ports {
            container_port = 5000
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

#data "google_cloud_run_locations" "available" {
#}

resource "google_cloud_run_service" "appkidsflixeua" {
  name     = "appkidsflixeua"
  location = var.region_us
  project  = var.project_id

#  location = data.google_cloud_run_locations.available.locations[1]

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/appkidsflixeua"
        ports {
            container_port = 5000
        }

      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noautheu" {
  location    = google_cloud_run_service.appkidsflixfinlandia.location
  project     = google_cloud_run_service.appkidsflixfinlandia.project
  service     = google_cloud_run_service.appkidsflixfinlandia.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service_iam_policy" "noauthus" {
  location    = google_cloud_run_service.appkidsflixeua.location
  project     = google_cloud_run_service.appkidsflixeua.project
  service     = google_cloud_run_service.appkidsflixeua.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "kidsflix-frontend-global"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
}

resource "google_compute_target_http_proxy" "default" {
  name        = "lb-kidsflix-httpproxy"
  description = "a description"
  url_map     = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  name            = "lb-kidsflix-global"
  description     = "a description"
  default_service = google_compute_backend_service.default.id

  host_rule {
	hosts        = [var.website]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.default.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.default.id
    }
  }
}

resource "google_compute_backend_service" "default" {
  name        = "kidsflix-backend-global"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_http_health_check" "default" {
  name               = "check-backend"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
# [END cloudloadbalancing_ext_http_cloudrun]
