# SRE Observability Lab automation

## GitHub Environment
Create an environment named `observability-deploy` and configure required reviewers.
Add environment variables:
- `AWS_REGION`: `us-east-1`
- `EC2_INSTANCE_ID`: `i-0093eb4b4caa000a0` (update if replaced)
- `AWS_DEPLOY_ROLE_ARN`: ARN of an IAM role trusted for GitHub OIDC.

The role must trust only this GitHub repository and `refs/heads/main`. Give it only required SSM permissions: `ssm:DescribeInstanceInformation`, `ssm:SendCommand` limited to the target instance and `AWS-RunShellScript`, and `ssm:GetCommandInvocation`. Validate the exact resource ARNs in your account before use.

The repository must be public for the included EC2 `git clone` method. For private repositories, use a short-lived artifact transfer method (such as S3) instead of storing a GitHub token on EC2.

## Grafana password
Before first deployment, create `/opt/sre-observability-lab/.env` securely on the instance containing:
`GRAFANA_ADMIN_PASSWORD=<unique-strong-password>`
Do not commit `.env`. The workflow intentionally fails if it is missing.

## Behavior
- Pull requests run configuration validation.
- Pushes to `main` and manual workflow dispatch validate, then deploy through SSM.
- Configure required reviewers on the `observability-deploy` GitHub Environment to gate deployments.
- Monitoring ports bind to host loopback only. Do not open public security-group ingress.

## Access
From a workstation with AWS CLI and Session Manager plugin:
`aws ssm start-session --target i-0093eb4b4caa000a0 --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["3000"],"localPortNumber":["3000"]}' --region us-east-1`
Then open `http://localhost:3000`.

Alertmanager is configured, but no external notification receiver is enabled. This is a single-host learning lab, not HA production infrastructure.
