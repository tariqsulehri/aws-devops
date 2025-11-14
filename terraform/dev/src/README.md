Commands:
 terraform fmt -recursive

 
 terraform  init \
            -backend-config="bucket=tf-state-bucket-ci-cd" \
            -backend-config="key=infra/dev/terraform.tfstate" \
            -backend-config="region=eu-north-1" \
            -backend-config="encrypt=true"


terraform plan


Bad Practice Example (What NOT to Do)

If you omit variables in the module and directly reference var.project_name inside the module —
Terraform will throw an error because modules cannot access parent variables directly.

Each module only knows the variables explicitly passed into it.

✅ Professional Tip

To keep things DRY and clean:

Define global values in root variables.tf

Define required inputs for each module in its own variables.tf

Pass them explicitly via the module call

🧭 Visual Flow Diagram
terraform.tfvars
     ↓
(root) variables.tf
     ↓
(root) main.tf → module "vpc" { project_name = var.project_name }
     ↓
(modules/vpc) variables.tf
     ↓
(modules/vpc) main.tf uses var.project_name