# SRE & Observability Lab

A hands-on Site Reliability Engineering (SRE) and observability project built with AWS, Terraform, GitHub Actions, and HCP Terraform. The lab will evolve to include metrics, dashboards, alerting, service-level indicators (SLIs), service-level objectives (SLOs), and incident-response exercises.

## Project Goals

- Provision AWS infrastructure using reusable Terraform modules.
- Automate Terraform formatting and validation with GitHub Actions.
- Use HCP Terraform for remote runs and state management.
- Authenticate Terraform Cloud to AWS using OIDC-based dynamic credentials.
- Deploy a demo application and build a Prometheus and Grafana observability stack.
- Practice alerting, SLI/SLO design, troubleshooting, and incident response.

## Architecture

### Infrastructure

- **Cloud provider:** AWS
- **Region:** `us-east-1`
- **Infrastructure as Code:** Terraform
- **Terraform execution and state:** HCP Terraform
- **Source control:** GitHub
- **CI pipeline:** GitHub Actions
- **Compute:** Amazon EC2
- **Network:** VPC with public and private subnets across two Availability Zones
- **Administrative access:** AWS Systems Manager Session Manager

The initial infrastructure configuration is designed to deploy an EC2 instance in a private subnet without a public IP address. A single NAT Gateway is configured for private-subnet outbound connectivity.

> **Cost and availability note:** A NAT Gateway incurs ongoing charges. The single-NAT configuration is intended for a lab environment and is not a highly available production network design.

### Planned observability stack

- **Demo application:** Python Flask API
- **Metrics collection:** Prometheus
- **Visualization:** Grafana
- **Alerting:** Alertmanager
- **Host metrics:** Node Exporter

The observability services will be configured so that administrative interfaces are not exposed directly to the public internet.

## Repository Structure

```text
sre-observability-lab/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── environments/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── app/
│   └── tests/
├── observability/
│   ├── prometheus/
│   │   └── alerts/
│   ├── grafana/
│   │   ├── dashboards/
│   │   └── provisioning/
│   └── alertmanager/
├── scripts/
├── docs/
├── .gitignore
└── README.md
```

The repository will grow as the application, monitoring configuration, tests, and operational documentation are implemented.

## Terraform Module Repository

Reusable infrastructure modules are maintained separately:

[terraform-aws-platform-modules](https://github.com/Sudha-Verma-Adastra/terraform-aws-platform-modules)

The SRE project consumes modules from this repository instead of duplicating their implementation.

Current module integrations include:

- VPC and subnet provisioning
- IAM role creation with service-principal and OIDC trust support
- EC2 compute provisioning with configurable security groups, encrypted storage, and IMDSv2

Module inputs and outputs must remain consistent with the interfaces defined in the module repository.

## GitHub Actions CI

The Terraform CI workflow is located at:

`.github/workflows/terraform.yml`

It runs on applicable pushes to `main`, pull requests targeting `main`, and manual workflow dispatch.

The initial pipeline performs:

1. Terraform formatting checks
2. Terraform initialization without configuring a remote backend
3. Terraform configuration validation

This CI workflow validates Terraform configuration but does not provision AWS infrastructure.

## HCP Terraform

The development workspace is intended to use:

| Setting | Value |
|---|---|
| Workspace | `sre-observability-dev` |
| Working directory | `environments/dev` |
| AWS region | `us-east-1` |
| Apply mode | Manual approval |

HCP Terraform will manage remote state and execute Terraform runs through the connected GitHub repository.

## AWS Authentication and Security

The intended authentication design uses HCP Terraform dynamic AWS credentials through OpenID Connect (OIDC).

The workspace configuration uses phase-specific role variables:

- `TFC_AWS_PROVIDER_AUTH=true`
- `TFC_AWS_PLAN_ROLE_ARN`
- `TFC_AWS_APPLY_ROLE_ARN`

The plan role is intended for infrastructure inspection and planning. The apply role is intended for approved infrastructure changes.

The AWS IAM trust policies must restrict access to the intended HCP Terraform organization, project, workspace, and run phase. IAM permissions should be limited to the resources and actions required by the configuration.

**Authentication status:** Complete the OIDC provider, trust policies, role permissions, and workspace variable configuration before running the first authenticated AWS plan.

Never commit AWS access keys, Terraform Cloud tokens, credentials, private keys, or sensitive `.tfvars` files to GitHub.

## Local Development

### Prerequisites

- Git
- Terraform CLI
- Access to the GitHub repositories
- An HCP Terraform organization and workspace
- An AWS account with appropriate permissions

### Validate Terraform

From the repository root:

```bash
terraform fmt -check -recursive environments/dev
terraform -chdir=environments/dev init -backend=false -input=false
terraform -chdir=environments/dev validate
```

These commands perform local formatting, initialization, and validation checks. They do not deploy infrastructure.

### Terraform Cloud execution

Once the workspace and AWS OIDC configuration are ready, use HCP Terraform to trigger a remote plan. Review the planned changes before approving an apply.

Do not use `terraform apply` locally against the lab environment unless local execution is explicitly intended and its authentication and state configuration are correct.

## Cost Considerations

AWS resources may incur charges, including:

- NAT Gateway hourly and data-processing charges
- EC2 instance runtime
- EBS volumes
- Public IPv4 addresses associated with applicable resources
- VPC endpoints, if enabled

Review the Terraform plan before deployment. Destroy lab resources when they are no longer needed, after confirming that no required data or resources will be lost.

## Roadmap

- [x] Create the SRE project repository
- [x] Establish the initial directory structure
- [x] Add the Terraform development configuration
- [x] Implement GitHub Actions Terraform CI
- [x] Validate the initial Terraform configuration
- [ ] Complete HCP Terraform AWS OIDC authentication
- [ ] Review the first remote Terraform plan
- [ ] Provision and verify the AWS infrastructure
- [ ] Deploy the Python Flask demo application
- [ ] Configure Prometheus and Node Exporter
- [ ] Configure Grafana dashboards and data sources
- [ ] Configure Alertmanager and alert rules
- [ ] Define SLIs, SLOs, and error budgets
- [ ] Document incident-response and troubleshooting exercises

## Project Status

The repository structure and initial Terraform CI workflow are established. The next milestone is completing AWS authentication for HCP Terraform and reviewing the first remote infrastructure plan before deployment.
