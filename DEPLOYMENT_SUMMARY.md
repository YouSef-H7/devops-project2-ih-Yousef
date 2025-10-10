# Yousef's Azure 3-Tier Container Apps Architecture

## Overview
This deployment creates a complete 3-tier architecture using Azure Container Apps with:
- **Frontend**: React application with Vite
- **Backend**: Spring Boot API with Hibernate/JPA
- **Database**: Azure SQL Database with private endpoint

## Resources Being Created

### Resource Group
- **Name**: `Yousef-rg`
- **Location**: West US 2
- **Tags**: Environment=Production, Owner=Yousef, Project=YousefBurgerBuilder

### Networking
- **VNet**: `vnet-prod` (10.2.0.0/16)
  - **AGW Subnet**: 10.2.1.0/24 (Application Gateway)
  - **ACA Subnet**: 10.2.2.0/23 (Container Apps with delegation)
  - **PE Subnet**: 10.2.4.0/24 (Private Endpoints)

### Container Apps
- **Environment**: `aca-env-yousef` (VNet integrated)
- **Frontend App**: `ca-frontend`
  - Image: `youkim7/frontend:dev-003`
  - Port: 80 (Nginx)
  - External ingress enabled
- **Backend App**: `ca-backend`
  - Image: `youkim7/backend:dev-001`
  - Port: 8080 (Spring Boot)
  - External ingress enabled
  - Environment variables for Azure SQL connection

### Application Gateway
- **Name**: `agw-yousef-burgerbuilder`
- **SKU**: WAF_v2 (Web Application Firewall)
- **Public IP**: `pip-agw-yousef-burgerbuilder`
- **Routing**: 
  - `/api/*` → Backend Container App
  - `/*` → Frontend Container App
- **Health Probes**: Configured for both apps

### SQL Database
- **Server**: `sql-yousef-burgerbuilder`
- **Database**: `sqldb-yousef-burgerbuilder`
- **Admin**: `yousef-admin` (password auto-generated)
- **Private Endpoint**: `pe-sql-yousef-burgerbuilder`
- **Version**: SQL Server 12.0
- **SKU**: S0 (Standard)

### DNS & Security
- **Private DNS Zone**: `privatelink.database.windows.net`
- **Network Security Groups**: Configured for Application Gateway
- **WAF Rules**: OWASP 3.2 with custom exclusions

### Monitoring
- **Log Analytics**: `law-yousef-burgerbuilder`
- **Diagnostic Settings**: Enabled for Container Apps

## Module Structure
Each Terraform module has been organized with separate files:
- `variables.tf` - Input variables
- `main.tf` - Resource definitions
- `outputs.tf` - Output values

## Modules Created:
1. **resource_group** - Resource group management
2. **network** - VNet, subnets, NSGs
3. **log_analytics** - Monitoring workspace
4. **container_apps_env** - Container Apps environment
5. **container_app** - Individual container apps
6. **sql** - Azure SQL Database with private endpoint
7. **dns** - Private DNS zones
8. **app_gateway** - Application Gateway with WAF

## Key Features:
- ✅ VNet-integrated Container Apps
- ✅ Private SQL Database connectivity
- ✅ Application Gateway with WAF protection
- ✅ Proper subnet delegation for Container Apps
- ✅ Health probes and load balancing
- ✅ Azure SQL Database with private endpoint
- ✅ Monitoring and diagnostics
- ✅ Yousef-branded naming convention

## Next Steps (After Deployment):
1. Get Application Gateway public IP
2. Update frontend environment variables
3. Build and push updated frontend image
4. Update Container App with new image
5. Test end-to-end functionality