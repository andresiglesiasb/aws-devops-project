## Running all modules

To initialize, plan, and apply all the modules in your Terraform porject, run:
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
> - Use `-target` carefully; it applies changes to only a specific module and its dependiencies. It is useful for debugging.
> - For a full, consistent deployment, running without `-target` is recommended.