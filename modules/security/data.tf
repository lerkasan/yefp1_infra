# ------------- Obtain my public IP to grant SSH access -------------------
data "external" "admin_public_ip" {
  program = ["bash", "-c", "jq -n --arg admin_public_ip $(dig +short myip.opendns.com @resolver1.opendns.com -4) '{\"admin_public_ip\":$admin_public_ip}'"]
}
