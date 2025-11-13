Initalize backend for terraform tfstate file
===========================================
 terraform init -migrate-state  # Migrate existing state file
 terraform init -reconfigure    # REconfigure State

 pull state to localfile
 -------------------------
 terraform state pull  > abc.tfstate


#Resources
=================
spacelift for terraform deployment



aws s3 sync dist/ s3://<your-bucket-name> --delete