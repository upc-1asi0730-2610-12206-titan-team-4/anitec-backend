# AniTec Platform Backend

Backend ASP.NET Core para AniTec, construido a partir de la estructura usada en clase en `learning-center-platform-master`.

## Tecnologias

- ASP.NET Core
- Entity Framework Core
- MySQL
- JWT para autenticacion
- BCrypt para hashing de contrasenas
- Repository, Unit of Work, Command Services, Query Services y REST Resources

## Bounded contexts

- `Shared`: base comun, repositorios, Unit of Work, EF Core, middleware y problem details.
- `Iam`: usuarios, sign-in, sign-up, JWT y hashing.
- `Profiles`: perfiles de usuario.
- `Livestock`: rebanos y animales.
- `Sanitary`: eventos sanitarios e historial medico de animales.
- `Financial`: ingresos y egresos.
- `Activities`: actividades de la granja.
- `Analytics`: metricas de reportes para dashboard.
- `Devices`: balanzas, collares inteligentes, camaras termicas, aretes de identificacion, estaciones meteorologicas y sensores ambientales.
- `Metrics`: lecturas generadas por los dispositivos.
- `Subscriptions`: planes y suscripciones con campos preparados para Stripe.

## Base de datos

La cadena por defecto esta en `Anitec.Platform/appsettings.Development.json`:

```json
"DefaultConnection": "server=localhost;user=root;password=password;database=anitec-platform"
```

Tambien se puede usar la variable de entorno `ANITEC_CONNECTION_STRING` para generar migraciones en otra base.

## Migraciones

Cuando el SDK de .NET este disponible:

```powershell
dotnet tool install --global dotnet-ef
dotnet ef migrations add InitialCreate --project Anitec.Platform --startup-project Anitec.Platform --output-dir Shared/Infrastructure/Persistence/EntityFrameworkCore/Migrations
dotnet ef database update --project Anitec.Platform --startup-project Anitec.Platform
```

Al ejecutar la API, tambien se aplican las migraciones pendientes con `context.Database.Migrate()`, siguiendo el mismo patron del backend usado en clase.

## Ejecucion

```powershell
dotnet run --project Anitec.Platform
```

Swagger quedara disponible en el puerto configurado por ASP.NET Core cuando el entorno sea `Development`.
