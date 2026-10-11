# Validacion de la arquitectura

Region: `mexicocentral` · Grupo de recursos: `rg-lz-mx` · Suscripcion: Azure for Students

## Resultado del despliegue

| Proyecto | Recursos | Resultado |
|---|---|---|
| 01-network | 21 | Apply complete |
| 02-data | 6 | Apply complete |
| 03-compute | 9 | Apply complete (VM `Standard_B2ats_v2`) |
| 04-bastion | 2 | Apply complete (el Bastion tardo ~14 min) |

## Prueba 1 - DNS privado (dentro de la VNet)

Desde `vm-worker` (10.0.3.4), conectada por Azure Bastion con clave SSH:

```
$ nslookup psql-lz-prod-un1zgk.postgres.database.azure.com
canonical name = psql-lz-prod-un1zgk.privatelink.postgres.database.azure.com.
Address: 10.0.2.4

$ nslookup stlzprodun1zgk.blob.core.windows.net
canonical name = stlzprodun1zgk.privatelink.blob.core.windows.net.
Address: 10.0.4.4
```

Ambos nombres resuelven a la IP privada del Private Endpoint.

## Prueba 2 - Resolucion desde fuera de la VNet

Desde un equipo externo (red domestica):

```
psql-lz-prod-un1zgk.postgres.database.azure.com -> 68.155.159.132 (publica)
stlzprodun1zgk.blob.core.windows.net            -> 20.60.97.1   (publica)
```

El nombre devuelve una IP publica, pero ambos servicios tienen
`public_network_access_enabled = false`, por lo que no aceptan conexiones desde Internet.

## Problemas encontrados y solucion

| Problema | Causa | Solucion |
|---|---|---|
| `RequestDisallowedByAzure` al crear VNet y NSG en `eastus2` | La suscripcion solo permite 5 regiones (`mexicocentral`, `chilecentral`, `canadacentral`, `francecentral`, `northcentralus`) | Usar una region permitida |
| `SkuNotAvailable` para `B2ats_v2`, `B2as_v2` y `B1s` en `canadacentral` | Sin capacidad de VM en esa region para la suscripcion | Migrar a `mexicocentral` |
| Errores `Root object was present, but now absent` y `Access is denied` en `terraform.tfstate` | Proyecto dentro de `C:\Windows\System32` (requiere administrador) y ventanas con distintos permisos | Clonar el repositorio en la carpeta de usuario |
| Bastion no abria la terminal | El navegador bloqueaba las ventanas emergentes | Desmarcar "Abrir en la nueva pestana" |

## Limitaciones

- La VM no tiene salida a Internet (sin NAT Gateway): no se pueden instalar paquetes.
- No se probo conexion a PostgreSQL ni a Blob con la identidad administrada, porque
  requiere instalar `psql` o Azure CLI en la VM.
- La App Service solo tiene la infraestructura; no se desplego codigo de aplicacion.
