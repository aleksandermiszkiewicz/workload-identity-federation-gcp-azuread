# Workload Identity Federation - Granting Azure workloads access to GCP Services without secrets management.

### Introduction
Workload Identity Federation eliminates the need for secret management and reduces the overhead of security management. It enables you to grant access to specific service accounts based on Azure AD identities, such as applications service principal, managed identities, or groups of identities. This eliminates the need to create and manage secrets and provides a more secure and manageable solution for granting access to GCP APIs from Azure workloads.

This project contains terraform code responsible for setting up Workload Identity Federation between GCP and Azure AD in two variants:
1. Accessing GCP resources as Azure AD Application (service principal)
2. Accessing GCP resources as Azure AD managed identity

Assumption for each use case is granting secure access to GCP services for Azure AD identities (application service principal, managed identity) without necessity to create secrets for GCP service accounts. Each use case is focused on giving possibility to view GCP compute resources through impersonation of GCP service accounts by Azure identities. 

### Prerequisites

* terraform - (tested with 1.3.3v)
* gcloud (to authenticate as a user or service account) 
* az cli (to authenticate as a user or service principal)

### Project structure

Project is seperated into 3 different directories:
1. <i>modules</i> directory holds generic terraform modules used for each use case
2. <i>wif-application</i> directory holds terraform code responsible to setup workload identity federation for the use case no. 1
3. <i>wif-managed-identity</i> directory holds terraform code responsible to setup workload identity federation for the use case no. 2

### Accessing GCP resources as Azure AD Application (service principal)

This use case is focused on granting Application service principal an access to view compute resources in the GCP project. The terraform code required to setup workload identity federation is located in the <i>wif-application</i> directory. 

The terraform code located in <i>wif-application</i> directory is responsible for:

1. Creation of Resource Group on Azure side
2. Registering Application in Azure AD
3. Creating user managed identity in Azure AD
4. Creating a test VM with all required resources (VPC, subnet, etc.) on the Azure side and assigning user managed identity to the VM
5. Creating Azure group and assigning the managed identity to this group
6. Creating workload identity federation components on the GCP side
7. Creating service accounts for testing purposes on the GCP side
8. Generating testing script and copying it to Azure test VM
9. Generating configuration .json files to configure gcloud on test VM to impersonate as a service account and copy files to test VM


### Accessing GCP resources as Azure AD managed identity

This use case is focused on granting user managed identity an access to view compute resources in the GCP project. The terraform code required to setup workload identity federation is located in the <i>wif-managed-identity</i> directory. 

