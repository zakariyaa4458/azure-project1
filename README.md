# Azure Container Apps Infrastructure Project

This project demonstrates how I built and deployed a containerised Flask application on Microsoft Azure using Terraform and GitHub Actions.

The main goal was not just to get an application running, but to build the surrounding infrastructure in a way that reflects a more realistic cloud environment. 
This includes Infrastructure as Code, CI/CD, container security scanning, private networking, HTTPS, WAF protection, managed identities, monitoring and external DNS/proxying through Cloudflare.

---

## Project Structure

```Text
|-- app
|   |-- Dockerfile
|   |-- app.py
|   |-- requirements.txt
|   |-- static
|   |   |-- images
|   |   |-- script.js
|   |   `-- style.css
|   `-- templates
|       `-- index.html
`-- terraform
    |-- backend.tf
    |-- main.tf
    |-- modules
    |   |-- acr
    |   |   |-- main.tf
    |   |   |-- output.tf
    |   |   `-- variable.tf
    |   |-- app
    |   |   |-- main.tf
    |   |   |-- output.tf
    |   |   `-- variable.tf
    |   |-- logs
    |   |   |-- main.tf
    |   |   |-- output.tf
    |   |   `-- variable.tf
    |   |-- networking
    |   |   |-- main.tf
    |   |   |-- output.tf
    |   |   `-- variable.tf
    |   `-- security
    |       |-- main.tf
    |       |-- output.tf
    |       `-- variable.tf
    |-- output.tf
    |-- provider.tf
    |-- terraform.tfvars
    `-- variable.tf

```
---

## App Image
<img width="1917" height="1092" alt="image" src="https://github.com/user-attachments/assets/8fac7d37-9e6c-4c60-a188-cca924cb888f" />


## Architecture

The application follows roughly this traffic flow:

```text
User
  |
  | HTTPS
  v
Cloudflare
  |
  | HTTPS - Full (Strict)
  v
Azure Application Gateway + WAF
  |
  | HTTPS :443
  v
Azure Container Apps
  |
  v
Flask Application
```

The container image is built through GitHub Actions and stored in Azure Container Registry.

```text
GitHub
   |
   | GitHub Actions
   v
Docker Build
   |
   | Trivy Scan
   v
Azure Container Registry
   |
   v
Azure Container Apps
```

## Technologies Used

- Microsoft Azure
- Terraform
- GitHub Actions
- Docker
- Azure Container Apps
- Azure Container Registry
- Azure Application Gateway
- Azure Web Application Firewall
- Azure Key Vault
- Azure Log Analytics
- Azure Virtual Network
- Azure RBAC
- Managed Identities
- Cloudflare
- Trivy
- Python / Flask

## Infrastructure

The Azure infrastructure is managed using Terraform and split into modules to make the configuration easier to maintain.

The main resources include:

- Resource Group
- Virtual Network
- Public and private subnets
- Network Security Groups
- Azure Container Registry
- Azure Container Apps Environment
- Azure Container App
- Application Gateway WAF v2
- Web Application Firewall policy
- Azure Key Vault
- User Assigned Managed Identities
- Log Analytics Workspace
- Application Gateway diagnostic settings

Terraform state is stored remotely using Azure Blob Storage rather than locally. This allows the CI/CD pipeline and local Terraform operations to work against the same state while also providing state locking.

## Networking

The project uses a `10.0.0.0/16` Azure Virtual Network.

Separate subnets are used for the Application Gateway and Azure Container Apps environment.

```text
Azure VNet - 10.0.0.0/16
|
|-- Application Gateway Subnet
|     10.0.1.0/24
|
|-- Container Apps Subnet
      10.0.2.0/24
```

Network Security Groups are used to control traffic between resources.

The Application Gateway accepts HTTPS traffic on port `443`, while the required Application Gateway infrastructure ports are also allowed through the NSG.

## HTTPS and Cloudflare

The application is available through:

```text
https://app.zakariyaalab.com
```

Cloudflare acts as the public-facing reverse proxy.

Cloudflare provides the browser-facing TLS connection, while communication between Cloudflare and Azure uses HTTPS with **Full (Strict)** encryption.

A Cloudflare Origin CA certificate is stored securely inside Azure Key Vault.

The Application Gateway uses a User Assigned Managed Identity with the `Key Vault Secrets User` role to retrieve the certificate rather than storing certificate material directly in the Terraform configuration.

This creates an encrypted path from the user all the way to the application:

```text
Browser
   |
   | HTTPS
   v
Cloudflare
   |
   | HTTPS
   v
Application Gateway
   |
   | HTTPS
   v
Azure Container Apps
```

## Application Gateway and WAF

Azure Application Gateway sits in front of the Container App.

It provides:

- Layer 7 routing
- HTTPS termination
- Web Application Firewall protection
- Backend health monitoring
- Integration with Azure Key Vault

The WAF uses an Azure WAF policy with the OWASP managed ruleset.

The Application Gateway forwards requests to the Azure Container Apps FQDN over HTTPS.

## Managed Identities and RBAC

Managed identities are used to avoid relying on long-lived credentials inside the infrastructure.

The Container App uses a User Assigned Managed Identity to authenticate with Azure Container Registry and pull application images.

The Application Gateway uses a separate User Assigned Managed Identity to access its TLS certificate stored in Azure Key Vault.

This keeps permissions separated between workloads.

## CI/CD

The project uses separate GitHub Actions workflows for infrastructure and application deployment.

### Infrastructure Pipeline

Terraform deployments authenticate to Azure through GitHub OIDC.

This avoids storing a long-lived Azure client secret in GitHub.

The infrastructure workflow runs Terraform against the remote Azure backend and manages the Azure resources defined in the repository.

### Application Pipeline

Changes to the application trigger the application deployment pipeline.

The pipeline:

1. Checks out the repository
2. Authenticates to Azure using OIDC
3. Authenticates with Azure Container Registry
4. Builds the Docker image
5. Scans the image using Trivy
6. Pushes the image to ACR
7. Updates the Azure Container App

Images are tagged using the Git commit SHA, giving each application version a unique image tag.

## Container Security

The Flask application runs inside a Docker container and images are stored in Azure Container Registry.

Trivy is included in the CI pipeline to scan images for `HIGH` and `CRITICAL` vulnerabilities before they are pushed and deployed.

If the scan detects vulnerabilities above the configured threshold, the pipeline fails before deployment.

## Monitoring and Logging

Azure Log Analytics is used as the central logging workspace.

Application Gateway diagnostic settings send:

- Application Gateway access logs
- WAF logs
- Application Gateway metrics

to Log Analytics.

This provides a central location for investigating traffic, WAF events and infrastructure behaviour.

## Scaling

Azure Container Apps handles application scaling.

The application is configured with minimum and maximum replica counts and can scale based on concurrent HTTP requests.

This means additional replicas can be created when traffic increases without manually provisioning additional servers.

## Challenges and Troubleshooting

A large part of this project involved troubleshooting problems between services rather than simply provisioning resources.

One issue involved Azure Container Apps failing to resolve Azure Container Registry. The VNet had been configured with custom DNS server addresses that did not actually provide DNS services. Removing those addresses allowed the VNet to use Azure-provided DNS and restored ACR resolution.

Another issue involved Application Gateway infrastructure traffic. Application Gateway v2 requires traffic from `GatewayManager` on specific high ports. The gateway initially failed to provision because the NSG did not allow this traffic.

The Application Gateway also initially failed to retrieve its certificate from Key Vault because the Key Vault role had been assigned to the Container App identity rather than the Application Gateway identity.

Finally, although Azure reported the original Application Gateway configuration as successfully provisioned, TCP connections to its HTTPS listener on port 443 continued to time out. After validating the listener, NSG, routing rules, public IP, backend health and Key Vault configuration, the gateway was recreated from the corrected Terraform configuration. The new gateway successfully accepted HTTPS traffic.

These issues made the project useful for learning how to troubleshoot the connections between cloud services rather than treating each Azure resource in isolation.

## Security Considerations

Several security practices were implemented throughout the project:

- GitHub OIDC instead of long-lived Azure credentials
- Azure RBAC
- User Assigned Managed Identities
- HTTPS between external and internal components
- TLS certificates stored in Azure Key Vault
- WAF protection
- Network Security Groups
- Trivy container vulnerability scanning
- Remote Terraform state
- ACR authentication through managed identity

## Future Improvements

There are several areas I would like to improve as the project develops.

One improvement would be to make the network more restrictive. Some Azure services currently rely on public endpoints, so introducing Private Endpoints and tighter Key Vault/ACR network controls would reduce public exposure.

I would also like to expand the monitoring side of the project. Application Gateway diagnostics are already sent to Log Analytics, but these could be developed into Azure Monitor dashboards and alerts for things such as unusual WAF activity, application errors, unhealthy backends and high response times.

Other potential improvements include:

- Adding automated HTTP to HTTPS redirection
- Adding more detailed Azure Monitor alerts
- Introducing Private Endpoints where appropriate
- Tightening Key Vault firewall rules
- Adding automated certificate rotation
- Expanding Terraform security scanning
- Adding automated integration tests after deployments
- Implementing deployment strategies such as blue/green or revision-based rollbacks
- Adding persistent storage/database support to replace the application's current in-memory task storage
- Automating more of the Cloudflare configuration through Terraform
- Adding cost monitoring and budget alerts

## What I Learned

This project gave me a much better understanding of how Azure works and how its different services integrate with each other. Building the infrastructure from the ground up helped me become more familiar with Azure networking, identity and access management, Container Apps, Application Gateway, Key Vault and monitoring. More importantly, troubleshooting issues between these services helped me understand how Azure resources work together as part of a complete cloud environment rather than as individual components.

Provisioning individual Azure resources with Terraform was only one part of the challenge. A lot of the learning came from understanding why resources could be healthy individually while the complete request path still failed.

In particular, the project strengthened my understanding of:

- Azure networking
- DNS and reverse proxies
- TLS and certificate chains
- Application Gateway
- Web Application Firewalls
- Managed identities
- Azure RBAC
- Terraform state and modules
- CI/CD with GitHub Actions
- Container security
- Troubleshooting distributed cloud infrastructure

It also reinforced the importance of validating infrastructure from both sides: checking what the cloud control plane says is configured, while also testing whether the actual network and application traffic behaves as expected.
