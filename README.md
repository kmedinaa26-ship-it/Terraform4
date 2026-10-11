# Terraform4 - Landing Zone en Azure for Students

Practica de Terraform basada en la arquitectura de referencia
"Azure for Students (Landing Zone + Well-Architected)".

Se construye paso a paso, un proyecto Terraform por etapa:

| Paso | Proyecto | Estado |
|---|---|---|
| 1 | `01-network` - VNet, subredes, NSG, zonas DNS privadas | desplegado (21 recursos) |
| 2 | `02-data` - PostgreSQL y Storage con Private Endpoints | desplegado (6 recursos) |
| 3 | `03-compute` - App Service, VM worker, Managed Identities | codigo listo, por desplegar |
| 4 | `04-bastion` - Azure Bastion | pendiente |

Requisitos: Terraform >= 1.6, Azure CLI (`az login`).

## Region

La suscripcion Azure for Students solo permite desplegar en: `mexicocentral`,
`chilecentral`, `canadacentral`, `francecentral` y `northcentralus`
(politica "Allowed resource deployment regions"). Con `eastus2` Azure responde
`RequestDisallowedByAzure`. Este proyecto usa **`mexicocentral`** (grupo de recursos `rg-lz-mx`).

`canadacentral` tambien esta permitida, pero no tiene capacidad de VM para esta
suscripcion: `Standard_B2ats_v2`, `Standard_B2as_v2` y `Standard_B1s` fallaron con
`SkuNotAvailable`. Por eso se migro a `mexicocentral`.

Nota: no trabaje dentro de `C:\Windows\System32` (requiere administrador y
provoca errores de acceso en el estado de Terraform). Clone el repo en su
carpeta de usuario.

Para consultar las regiones permitidas:

```
az policy assignment list --query "[].parameters.listOfAllowedLocations.value" -o json
```
