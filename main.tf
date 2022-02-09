data "terraform_remote_state" "locaiton" {
  backend = "remote"

  config = {
    organization = "Awesome-Company"
    workspaces = {
          name = "TFCloud-TriggerDeploy"
    }
  }
}
