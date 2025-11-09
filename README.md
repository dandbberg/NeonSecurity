# AWS NeonSecurityTask Platform

This repository provisions an end-to-end AWS environment for the **NeonSecurityTask** workload. 
Terraform builds the network and compute foundation (VPC, EKS, RDS, IAM, ECR, KMS), while GitHub Actions automates Docker image builds and Helm deployments. The Python application runs behind NGINX Ingress, connects to Amazon RDS (PostgreSQL 17) and stores credentials in AWS Secrets Manager accessed through IRSA.

---

## Highlights

- **Modular Terraform** (under `Infra/`) creates VPC, Bastion host, EKS cluster, RDS PostgreSQL, ECR, and KMS resources.
- **NeonSecurityTask app** lives in `Docker/dockerfiles/NeonSecurityTask`; it serves HTTPS, writes each visit to `neonsecuritytask_messages`, and forwards credentials from Secrets Manager.
- **Helm chart** (`Deployment/NeonSecurityTask-chart`) installs the app, ServiceAccount (IRSA), Service, Ingress, and ExternalSecret objects.
- **CI/CD** via GitHub Actions builds the Docker image (`docker-ecr.yml`) and deploys the chart (`helmchart.yml`) using GitHub OIDC to assume AWS roles.

---

## Terraform Infrastructure

| Module | Purpose | Key Outputs |
| ------ | ------- | ----------- |
| `vpc` | Dedicated VPC with 3× public + 3× private subnets, IGW, NAT gateways |
| `bastion_ec2` | Public EC2 instance for SSH/SSM access to private subnets |
| `eks` | Private EKS cluster with managed node group, IRSA support, GitHub Actions IAM role, and optional add-ons |
| `kms` | Customer-managed KMS key encrypting the RDS secret in Secrets Manager |
| `rds` | PostgreSQL 17 instance in private subnets |
| `ecr` | Repository `neonsecurity-ecr` for the service container image |

Remote state is stored in the S3 bucket defined in `terraform { backend "s3" … }`.

### Running Terraform (perf environment)

```bash
cd Infra
terraform init -var-file=envs/perf.auto.tfvars
terraform plan -var-file=envs/perf.auto.tfvars
terraform apply -var-file=envs/perf.auto.tfvars
```
---

## Repository Layout

```
Infra/
├── envs/                   # perf, qa, prod tfvars
├── modules/                # bastion_ec2, eks, vpc, kms, rds, ecr
├── main.tf                 # module composition
├── variables.tf            # global var definitions
├── outputs.tf              # outputs consumed by CI/CD and operators
└── provider.tf             # AWS provider + backend configuration

Docker/
└── dockerfiles/
    └── NeonSecurityTask/   # app.py, Dockerfile, requirements

Deployment/
└── NeonSecurityTask-chart/
    ├── Chart.yaml
    ├── values.yaml (defaults)
    └── templates/          # deployment.yaml, service.yaml, ingress.yaml, external secret, secret store, service account

.github/workflows/
├── docker-ecr.yml          # Build + push image to ECR
└── helmchart.yml           # Install/upgrade Helm release on EKS
```

`Deployment/app-values/NeonSecurity.yaml` contains perf-specific Helm values: enabling the ExternalSecret, customizing the ingress annotations, and wiring the IRSA role ARN.

---

## CI/CD Workflow

1. **Docker build** 🛠️ (`docker-ecr.yml`)
   - Uses GitHub Actions OIDC to assume `dberg-perf-github-actions-role`
   - Builds `Docker/dockerfiles/NeonSecurityTask/Dockerfile`
   - Pushes to `neonsecurity-ecr:NeonSecurityTask-latest`

2. **Helm deploy** 🚀 (`helmchart.yml`)
   - Confirms External Secrets CRDs via Helm install
   - Renders `Deployment/NeonSecurityTask-chart` using the perf values file
   - Applies rendered YAML (ServiceAccount, Service, Ingress, ExternalSecret, Deployment)

Pull policy is `Always`, so pods fetch the newest image on every rollout.

---

## Application Details

- Serves HTTPS on port 8443 (self-signed cert generated during build)
- Environment variables (`POSTGRES_*`, `NEONSECURITYTASK_MESSAGE`) populated from `neonsecuritytask-db-credentials`
- Every page view inserts a row into `neonsecuritytask_messages` and displays the latest entries plus “Your last acccess is logged!”
- Backend database connection string is retrieved securely via IRSA + AWS Secrets Manager

### Checking the DB using Bastion

Connect to the Database is throught the bastion.

```bash
ssh -i ~/.ssh/KEYPAIR.pem ec2-user@BASTION
```
Install PSQL client
```bash
sudo dnf install -y postgresql15
psql "host=dberg-perf-app-db.cnuosesa6h72.eu-west-1.rds.amazonaws.com \
      port=5432 dbname=neonsecurity user=dbergadmin sslmode=require"
```

Then:
```sql
SELECT count(*) FROM neonsecuritytask_messages;
SELECT * FROM neonsecuritytask_messages ORDER BY id DESC LIMIT 10;
```
---

## Secrets & IAM

- `Infra/envs/perf.auto.tfvars` tracks the latest secret ARN and KMS key 
- `Deployment/app-values/NeonSecurity.yaml` uses the same secret ARN for the ExternalSecret.
- IRSA role (`dberg-perf-NeonSecurityTask-irsa`) allows `secretsmanager:GetSecretValue` and `kms:Decrypt` on those ARNs.
- Credentials are never stored in git; Terraform and the app rely on Secrets Manager at runtime.

---

## Architecture Diagram

![Architecture Diagram](./Architecture%20Design.png)

