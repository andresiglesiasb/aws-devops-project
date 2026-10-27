## Running all modules

To initialize, plan, and apply all the modules in your Terraform project, run:
```bash
terraform init
terraform plan
terraform apply
```

## Running only one module
If you want to run Terraform for just a specific module (for example, the `vpc` module), use the `-target` flag:
```bash
terraform init
terraform plan -target=module.vpc
terraform apply -target=module.vpc 
```

## Notes
> - Run `terraform init` first to initialize your working directory.
> - Use `-target` carefully; it applies changes to only a specific module and its dependencies. It is useful for debugging.
> - For a full, consistent deployment, running without `-target` is recommended.

## State management

The state is local (`terraform.tfstate`, git-ignored). For a one-person lab a remote backend wasn't worth the setup. For a team it would go in S3, which now supports locking by itself, so no DynamoDB table is needed (Terraform >= 1.10):

```hcl
terraform {
  backend "s3" {
    bucket       = "my-tfstate-bucket"   # versioning and encryption on, public access blocked
    key          = "aws-devops-project/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true                  # lock file stored next to the state in the bucket
  }
}
```

To move the existing state: `terraform init -migrate-state`.

## Secrets and state

The IAM module doesn't create an access key or a console password on purpose. Both end up in plain text in the state file, even if the output is `sensitive`, which only hides the value in the CLI. Credentials are created by hand instead.

Worth remembering: `sensitive` values are still saved in state and plan files, while `ephemeral` values (Terraform >= 1.10) are never saved.
