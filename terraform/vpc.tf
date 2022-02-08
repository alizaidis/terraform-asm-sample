# # Place holder to add customer vpc if required for gke clusters
# module "vpc" {
#   source       = "terraform-google-modules/network/google"
#   version      = "~> 2.5"
#   project_id   = var.project_id

#   for_each = var.regions
#   network_name = each.value.network_name

#   subnets = [
#     {
#       subnet_name   =  each.value.subnet_name 
#       subnet_ip     =  each.value.subnet_ip
#       subnet_region =  each.value.subnet_region
#     },
#   ]

#   secondary_ranges = {
#     (each.value.subnet_name) = [
#       {
#         range_name    = each.value.secondary_ranges_pods_name
#         ip_cidr_range = each.value.secondary_ranges_pods_ips
#       },
#       {
#         range_name    = each.value.secondary_ranges_services_name
#         ip_cidr_range = each.value.secondary_ranges_services_ips
#       },
#   ] }
#     depends_on                  = [time_sleep.wait_120_seconds]
# }
