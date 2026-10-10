# Terraform4 - Landing Zone en Azure for Students

Practica de Terraform basada en la arquitectura de referencia
"Azure for Students (Landing Zone + Well-Architected)".

Se construye paso a paso, un proyecto Terraform por etapa:

| Paso | Proyecto | Estado |
|---|---|---|
| 1 | `01-network` - VNet, subredes, NSG, zonas DNS privadas | listo |
| 2 | `02-data` - PostgreSQL y Storage con Private Endpoints | pendiente |
| 3 | `03-compute` - App Service, VM worker, Managed Identities | pendiente |
| 4 | `04-bastion` - Azure Bastion | pendiente |

Requisitos: Terraform >= 1.6, Azure CLI (`az login`).
