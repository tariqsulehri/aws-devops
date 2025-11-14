Commands:
 terraform fmt -recursive

 
 terraform  init \
            -backend-config="bucket=tf-state-bucket-ci-cd" \
            -backend-config="key=infra/prod/terraform.tfstate" \
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


----------------

Step 0 — Prep: confirm who you are/credentials
==============================================
aws sts get-caller-identity


If this fails or returns an unexpected account, fix credentials now (SSO, AWS CLI profile, or CI role). If using GitHub Actions, ensure the role/session duration is long enough.

output
-------
aws sts get-caller-identity
{
    "UserId": "AIDAYW7WWHTQNYAPCF6UK",
    "Account": "599128423648",
    "Arn": "arn:aws:iam::599128423648:user/admin"
}



Step 1 — Diagnostics (discover blockers)
Run these and save outputs.
ENIs in the VPC (shows any ENI with public IP or SG attachments):
==============================================
aws ec2 describe-network-interfaces \
  --filters Name=vpc-id,Values=vpc-07b937c51ecba7932 \
  --query "NetworkInterfaces[*].{ENI:NetworkInterfaceId,Instance:Attachment.InstanceId,PublicIP:Association.PublicIp,Groups:Groups[*].GroupId}" \
  --output json

   [ 
     {
        "ENI": "eni-017ace067dc7b0abc",
        "Instance": null,
        "PublicIP": "13.62.202.114",
        "Groups": []
    },
    {
        "ENI": "eni-07efe9c11f27a86d7",
        "Instance": null,
        "PublicIP": "16.16.72.173",
        "Groups": []
    },
    {
        "ENI": "eni-0162701076d7aed72",
        "Instance": null,
        "PublicIP": "13.50.85.177",
        "Groups": [
            "sg-01f88c8626441f012"
        ]
    }
]


Step # 2
EIPs and associations (shows allocation & association IDs):
==========================================
aws ec2 describe-addresses \
  --query "Addresses[*].[PublicIp,AllocationId,AssociationId,InstanceId,NetworkInterfaceId]" \
    --output json
[
    [
        "13.62.202.114",
        "eipalloc-026769837fbe3dfbf",
        "eipassoc-0ce800ee98d727068",
        null,
        "eni-017ace067dc7b0abc"
    ],
    [
        "16.16.72.173",
        "eipalloc-07c287073571f857d",
        "eipassoc-02c2728bbfbac43b9",
        null,
        "eni-07efe9c11f27a86d7"
    ]
]


Step # 3 NAT Gateways in the VPC:
=============================
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-07b937c51ecba7932" \
  --query "NatGateways[*].[NatGatewayId,State,NatGatewayAddresses]" --output json

[
    [
        "nat-09ecd621b58e4548d",
        "available",
        [
            {
                "AllocationId": "eipalloc-07c287073571f857d",
                "NetworkInterfaceId": "eni-07efe9c11f27a86d7",
                "PrivateIp": "10.0.1.104",
                "PublicIp": "16.16.72.173",
                "AssociationId": "eipassoc-02c2728bbfbac43b9",
                "IsPrimary": true,
                "Status": "succeeded"
            }
        ]
    ],
    [
        "nat-05f5f209850583782",
        "available",
        [
            {
                "AllocationId": "eipalloc-026769837fbe3dfbf",
                "NetworkInterfaceId": "eni-017ace067dc7b0abc",
                "PrivateIp": "10.0.3.45",
                "PublicIp": "13.62.202.114",
                "AssociationId": "eipassoc-0ce800ee98d727068",
                "IsPrimary": true,
                "Status": "succeeded"
            }
        ]
    ]
]

Step # 4 ALBs in the VPC (public vs internal):
==============================================
aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='vpc-07b937c51ecba7932'].[LoadBalancerArn,Scheme,State,AvailabilityZones]" --output json
[
    [
        "arn:aws:elasticloadbalancing:eu-north-1:599128423648:loadbalancer/app/myproject-dev-alb/a838d359fb38333c",
        "internet-facing",
        {
            "Code": "active"
        },
        [
            {
                "ZoneName": "eu-north-1b",
                "SubnetId": "subnet-012162860e5afc658",
                "LoadBalancerAddresses": []
            },
            {
                "ZoneName": "eu-north-1a",
                "SubnetId": "subnet-0fd737573bd6a32a9",
                "LoadBalancerAddresses": []
            }
        ]
    ]
]

Step # 5 CloudFront distributions referencing OAC:
=================================================
aws cloudfront list-distributions --query "DistributionList.Items[*].[Id,ARN,Origins.Items[*].OriginAccessControlId]" --output json
[
    [
        "E3PD81QZDWBOHC",
        "arn:aws:cloudfront::599128423648:distribution/E3PD81QZDWBOHC",
        [
            "E2JJ95NC75A9W0"
        ]
    ]
]