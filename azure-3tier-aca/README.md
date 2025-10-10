# Azure 3-Tier Architecture with Container Apps

This project implements a modern 3-tier web application architecture on Microsoft Azure using Container Apps, featuring a React frontend, Spring Boot backend, and Azure SQL Database with comprehensive security and monitoring.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │    │     Business    │    │      Data       │
│     Tier        │    │      Tier       │    │      Tier       │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ Application     │    │ Container Apps  │    │ Azure SQL       │
│ Gateway (WAF)   │    │ Environment     │    │ Database        │
│                 │    │                 │    │                 │
│ React Frontend  │    │ Spring Boot API │    │ Private         │
│ (Container App) │    │ (Container App) │    │ Endpoint        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Features

- **Security First**: WAF protection, private networking, and least privilege access
- **Scalability**: Auto-scaling Container Apps with KEDA
- **Monitoring**: Comprehensive logging and monitoring with Azure Monitor
- **DevOps**: CI/CD pipelines with GitHub Actions
- **Infrastructure as Code**: Terraform modules for consistent deployments

## Technology Stack

### Frontend
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **Container**: Nginx on Alpine Linux
- **Testing**: Vitest + Testing Library

### Backend  
- **Framework**: Spring Boot 3.2+ with Java 21
- **Database**: JPA/Hibernate with PostgreSQL driver
- **Container**: Eclipse Temurin JRE 21 on Alpine
- **Testing**: JUnit 5 + Spring Boot Test

### Infrastructure
- **Container Platform**: Azure Container Apps
- **Database**: Azure SQL Database
- **Networking**: Azure Virtual Network with private endpoints
- **Security**: Azure Application Gateway with WAF v2
- **Monitoring**: Azure Log Analytics + Application Insights
- **IaC**: Terraform with modular design

## Quick Start

### Prerequisites

1. **Azure CLI** installed and configured
2. **Terraform** v1.5+ installed
3. **Docker** for building container images
4. **Node.js** 18+ for frontend development
5. **Java** 21+ for backend development

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd azure-3tier-aca
   ```

2. **Configure environment variables**
   ```bash
   cp env/environment.env.example env/environment.env
   # Edit env/environment.env with your values
   ```

3. **Set up Terraform backend** (one-time setup)
   ```bash
   # Create storage account for Terraform state
   az group create --name rg-terraform-state --location "East US"
   az storage account create --name sttfstate --resource-group rg-terraform-state --location "East US" --sku Standard_LRS
   az storage container create --name tfstate --account-name sttfstate
   ```

### Deployment

#### Infrastructure Deployment

1. **Initialize Terraform**
   ```bash
   cd terraform/main
   terraform init -backend-config="../backend.hcl"
   ```

2. **Plan deployment**
   ```bash
   terraform plan -var-file="../environments/dev.tfvars"
   ```

3. **Apply infrastructure**
   ```bash
   terraform apply -var-file="../environments/dev.tfvars"
   ```

#### Application Deployment

1. **Build and push container images**
   ```bash
   # Frontend
   cd frontend
   docker build -t <acr-name>.azurecr.io/frontend:latest .
   docker push <acr-name>.azurecr.io/frontend:latest

   # Backend
   cd ../backend
   docker build -t <acr-name>.azurecr.io/backend:latest .
   docker push <acr-name>.azurecr.io/backend:latest
   ```

2. **Update Container Apps**
   ```bash
   az containerapp update --name ca-frontend --resource-group <rg-name> --image <acr-name>.azurecr.io/frontend:latest
   az containerapp update --name ca-backend --resource-group <rg-name> --image <acr-name>.azurecr.io/backend:latest
   ```

## Project Structure

```
azure-3tier-aca/
├── frontend/                      # React + Vite application
│   ├── Dockerfile                 # Multi-stage build with Nginx
│   ├── src/                       # Source code
│   └── ...
├── backend/                       # Spring Boot application  
│   ├── Dockerfile                 # Multi-stage build with Maven
│   ├── src/                       # Source code
│   └── ...
├── env/                           # Environment configuration
│   ├── environment.env.example    # Template
│   └── environment.env            # Your values (gitignored)
├── terraform/                     # Infrastructure as Code
│   ├── backend.hcl                # Terraform backend config
│   ├── environments/              # Environment-specific values
│   │   ├── dev.tfvars
│   │   └── prod.tfvars
│   ├── main/                      # Root module (orchestrator)
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── modules/                   # Reusable modules
│       ├── resource_group/
│       ├── network/               # VNet + subnets + NSGs
│       ├── log_analytics/
│       ├── container_apps_env/    # ACA Environment
│       ├── container_app/         # Generic container app
│       ├── sql/                   # SQL Server + DB + Private Endpoint
│       ├── dns/                   # Private DNS zones
│       └── app_gateway/           # Application Gateway + WAF
├── .github/workflows/             # CI/CD pipelines
│   ├── fe-build-push.yml          # Frontend pipeline
│   ├── api-build-push.yml         # Backend pipeline
│   └── infra-plan-apply.yml       # Infrastructure pipeline
└── README.md                      # This file
```

## Terraform Modules

### Core Modules

- **resource_group**: Creates and manages Azure resource groups
- **network**: Virtual network with subnets for AGW, ACA, and private endpoints
- **log_analytics**: Centralized logging workspace
- **container_apps_env**: Container Apps environment with VNet integration
- **container_app**: Generic module for deploying container applications
- **sql**: SQL Server with private endpoint and DNS integration
- **dns**: Private DNS zones for service resolution
- **app_gateway**: Application Gateway with WAF v2 and path-based routing

### Security Features

- **Network Isolation**: All resources deployed in private subnets
- **Private Endpoints**: Database access only through private networking
- **WAF Protection**: OWASP Top 10 protection with custom rules
- **Managed Identity**: Service-to-service authentication without secrets
- **TLS Everywhere**: End-to-end encryption in transit

## CI/CD Pipelines

### Frontend Pipeline (`fe-build-push.yml`)
- **Triggers**: Changes to `frontend/` directory
- **Steps**: Install → Test → Lint → Build → Docker Build/Push → Deploy
- **Environments**: Automatic deployment to dev, manual approval for prod

### Backend Pipeline (`api-build-push.yml`)  
- **Triggers**: Changes to `backend/` directory
- **Steps**: Test → Checkstyle → Build → Docker Build/Push → Deploy
- **Features**: Maven dependency caching, multi-stage builds

### Infrastructure Pipeline (`infra-plan-apply.yml`)
- **Triggers**: Changes to `terraform/` directory or manual dispatch
- **Features**: Plan on PR, apply on merge, destroy capability
- **Environments**: Separate workflows for dev/prod with approval gates

## Environment Configuration

### Development Environment
- **Resource Group**: `rg-burgerbuilder-dev`
- **Container Registry**: `acrburgerbuilderdev.azurecr.io`
- **Scaling**: Min 1, Max 5 replicas
- **Database**: Basic tier for cost optimization

### Production Environment  
- **Resource Group**: `rg-burgerbuilder-prod`
- **Container Registry**: `acrburgerbuilder.azurecr.io`
- **Scaling**: Min 2, Max 20 replicas  
- **Database**: Standard tier with backup retention

## Monitoring and Observability

### Azure Monitor Integration
- **Application Logs**: Structured logging to Log Analytics
- **Performance Metrics**: CPU, memory, request latency
- **Health Checks**: Built-in health endpoints for both apps
- **Alerting**: Proactive notifications for failures and performance issues

### Key Metrics Monitored
- Container CPU and memory utilization
- HTTP request rates and response times
- Database connection pool metrics
- Application Gateway WAF events

## Security Considerations

### Network Security
- All subnets protected by Network Security Groups
- Database accessible only through private endpoints
- Container Apps in dedicated subnet with service delegation
- Application Gateway in separate subnet with WAF rules

### Identity and Access
- Service principals with minimal required permissions
- Managed identities for Azure service authentication
- Secrets stored in Azure Key Vault (recommended enhancement)
- RBAC for resource access control

## Cost Optimization

### Resource Sizing
- Container Apps auto-scale based on demand
- SQL Database right-sized for workload
- Application Gateway shared across environments
- Log Analytics with 30-day retention

### Recommendations
- Use Azure Reserved Instances for predictable workloads
- Implement auto-shutdown for development environments
- Monitor costs with Azure Cost Management

## Troubleshooting

### Common Issues

1. **Container App Won't Start**
   ```bash
   az containerapp logs show --name ca-backend --resource-group <rg-name>
   ```

2. **Database Connection Issues**
   - Verify private endpoint DNS resolution
   - Check NSG rules for database subnet
   - Validate connection string format

3. **Application Gateway 502 Errors**
   - Check backend health status
   - Verify container app ingress configuration
   - Review WAF logs for blocked requests

### Useful Commands

```bash
# Check container app status
az containerapp show --name ca-frontend --resource-group <rg-name> --query "properties.provisioningState"

# Scale container app manually
az containerapp update --name ca-backend --resource-group <rg-name> --min-replicas 2 --max-replicas 10

# View recent logs
az containerapp logs show --name ca-backend --resource-group <rg-name> --follow

# Check Terraform state
terraform state list
terraform show
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions and support:
- Create an issue in this repository
- Contact the DevOps team
- Check the Azure documentation for service-specific guidance