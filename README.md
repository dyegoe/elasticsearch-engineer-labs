# Elasticsearch Engineer Labs

This repository provides a Terraform to deploy the resources required by Elasticsearch Engineer Labs.
By now, it has only the Engineer 1 lab, which comes with three servers to use as Elasticsearch nodes and one server as a jump host.

## Deploy

To deploy it, you need to follow these steps:

- Make sure that you have `~/.terraformrc` adequately set up.
- That you have `~/.aws/credentials` and `~/.aws/config` adequately set up.
- Create a `terraform.tfvars` and specify your `ssh_public_key`.
- Copy a private key `id_rsa` to `templates/` folder.

If you would like to change some defaults values, please take a look into `variables.tf` and specify the desired variable value using `terraform.tfvars`.

## NB

This repository still under construction. As soon as possible I'll include Engineer 2 lab.

If you have any suggestion or found a bug, you are very welcome to open an issue.
