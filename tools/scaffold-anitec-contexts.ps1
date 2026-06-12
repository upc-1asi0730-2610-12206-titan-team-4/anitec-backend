$ErrorActionPreference = "Stop"

$ProjectRoot = Join-Path $PSScriptRoot "..\Anitec.Platform"

function Ensure-Dir($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

function Write-File($relativePath, $content) {
    $path = Join-Path $ProjectRoot $relativePath
    Ensure-Dir (Split-Path $path -Parent)
    Set-Content -LiteralPath $path -Value $content -NoNewline
}

function Add-SimpleContext($context, $entity, $plural, $endpoint, $properties, $resourceParams, $ctorBody, $modelConfig) {
    $lower = $context.ToLowerInvariant()
    $ns = "Anitec.Platform.$context"
    $entityArgs = (($properties | ForEach-Object { "entity.$($_.Name)" }) -join ', ')
    $resourceArgs = (($properties | ForEach-Object { "resource.$($_.Name)" }) -join ', ')

    Write-File "$context\Domain\Model\Entities\$entity.cs" @"
using $ns.Domain.Model.Commands;

namespace $ns.Domain.Model.Entities;

public class $entity
{
    public $entity()
    {
$ctorBody
    }

    public $entity(Create${entity}Command command)
    {
$($properties | ForEach-Object { "        $($_.Name) = command.$($_.Name);" } | Out-String)
    }

    public int Id { get; set; }
$($properties | ForEach-Object { "    public $($_.Type) $($_.Name) { get; set; }" } | Out-String)}
}
"@

    Write-File "$context\Domain\Model\Commands\Create${entity}Command.cs" @"
namespace $ns.Domain.Model.Commands;

public record Create${entity}Command($resourceParams);
"@

    Write-File "$context\Domain\Model\Commands\Update${entity}Command.cs" @"
namespace $ns.Domain.Model.Commands;

public record Update${entity}Command(int Id, $resourceParams);
"@

    Write-File "$context\Domain\Model\Commands\Delete${entity}Command.cs" @"
namespace $ns.Domain.Model.Commands;

public record Delete${entity}Command(int Id);
"@

    Write-File "$context\Domain\Model\Queries\GetAll${plural}Query.cs" @"
namespace $ns.Domain.Model.Queries;

public record GetAll${plural}Query;
"@

    Write-File "$context\Domain\Model\Queries\Get${entity}ByIdQuery.cs" @"
namespace $ns.Domain.Model.Queries;

public record Get${entity}ByIdQuery(int Id);
"@

    Write-File "$context\Domain\Repositories\I${entity}Repository.cs" @"
using $ns.Domain.Model.Entities;
using Anitec.Platform.Shared.Domain.Repositories;

namespace $ns.Domain.Repositories;

public interface I${entity}Repository : IBaseRepository<$entity>
{
}
"@

    Write-File "$context\Application\CommandServices\I${entity}CommandService.cs" @"
using $ns.Domain.Model.Commands;
using $ns.Domain.Model.Entities;
using Anitec.Platform.Shared.Application.Model;

namespace $ns.Application.CommandServices;

public interface I${entity}CommandService
{
    Task<Result<$entity>> Handle(Create${entity}Command command, CancellationToken cancellationToken);
    Task<Result<$entity>> Handle(Update${entity}Command command, CancellationToken cancellationToken);
    Task<Result> Handle(Delete${entity}Command command, CancellationToken cancellationToken);
}
"@

    Write-File "$context\Application\QueryServices\I${entity}QueryService.cs" @"
using $ns.Domain.Model.Entities;
using $ns.Domain.Model.Queries;

namespace $ns.Application.QueryServices;

public interface I${entity}QueryService
{
    Task<$entity?> Handle(Get${entity}ByIdQuery query, CancellationToken cancellationToken);
    Task<IEnumerable<$entity>> Handle(GetAll${plural}Query query, CancellationToken cancellationToken);
}
"@

    Write-File "$context\Application\Internal\CommandServices\${entity}CommandService.cs" @"
using $ns.Application.CommandServices;
using $ns.Domain.Model.Commands;
using $ns.Domain.Model.Entities;
using $ns.Domain.Repositories;
using Anitec.Platform.Shared.Application.Model;
using Anitec.Platform.Shared.Domain.Repositories;

namespace $ns.Application.Internal.CommandServices;

public class ${entity}CommandService(I${entity}Repository repository, IUnitOfWork unitOfWork)
    : I${entity}CommandService
{
    public async Task<Result<$entity>> Handle(Create${entity}Command command, CancellationToken cancellationToken)
    {
        var entity = new $entity(command);
        await repository.AddAsync(entity, cancellationToken);
        await unitOfWork.CompleteAsync(cancellationToken);
        return Result<$entity>.Success(entity);
    }

    public async Task<Result<$entity>> Handle(Update${entity}Command command, CancellationToken cancellationToken)
    {
        var entity = await repository.FindByIdAsync(command.Id, cancellationToken);
        if (entity is null) return Result<$entity>.Failure(${context}Error.${entity}NotFound, "$entity not found.");
$($properties | ForEach-Object { "        entity.$($_.Name) = command.$($_.Name);" } | Out-String)
        repository.Update(entity);
        await unitOfWork.CompleteAsync(cancellationToken);
        return Result<$entity>.Success(entity);
    }

    public async Task<Result> Handle(Delete${entity}Command command, CancellationToken cancellationToken)
    {
        var entity = await repository.FindByIdAsync(command.Id, cancellationToken);
        if (entity is null) return Result.Failure(${context}Error.${entity}NotFound, "$entity not found.");
        repository.Remove(entity);
        await unitOfWork.CompleteAsync(cancellationToken);
        return Result.Success();
    }
}
"@

    Write-File "$context\Application\Internal\QueryServices\${entity}QueryService.cs" @"
using $ns.Application.QueryServices;
using $ns.Domain.Model.Entities;
using $ns.Domain.Model.Queries;
using $ns.Domain.Repositories;

namespace $ns.Application.Internal.QueryServices;

public class ${entity}QueryService(I${entity}Repository repository) : I${entity}QueryService
{
    public async Task<$entity?> Handle(Get${entity}ByIdQuery query, CancellationToken cancellationToken)
    {
        return await repository.FindByIdAsync(query.Id, cancellationToken);
    }

    public async Task<IEnumerable<$entity>> Handle(GetAll${plural}Query query, CancellationToken cancellationToken)
    {
        return await repository.ListAsync(cancellationToken);
    }
}
"@

    Write-File "$context\Domain\Model\${context}Error.cs" @"
namespace $ns.Domain.Model;

public enum ${context}Error
{
    ${entity}NotFound
}
"@

    Write-File "$context\Infrastructure\Persistence\EntityFrameworkCore\Repositories\${entity}Repository.cs" @"
using $ns.Domain.Model.Entities;
using $ns.Domain.Repositories;
using Anitec.Platform.Shared.Infrastructure.Persistence.EntityFrameworkCore.Configuration;
using Anitec.Platform.Shared.Infrastructure.Persistence.EntityFrameworkCore.Repositories;

namespace $ns.Infrastructure.Persistence.EntityFrameworkCore.Repositories;

public class ${entity}Repository(AppDbContext context) : BaseRepository<$entity>(context), I${entity}Repository
{
}
"@

    Write-File "$context\Infrastructure\Persistence\EntityFrameworkCore\Configuration\Extensions\ModelBuilderExtensions.cs" @"
using $ns.Domain.Model.Entities;
using Microsoft.EntityFrameworkCore;

namespace $ns.Infrastructure.Persistence.EntityFrameworkCore.Configuration.Extensions;

public static class ModelBuilderExtensions
{
    public static void Apply${context}Configuration(this ModelBuilder builder)
    {
$modelConfig
    }
}
"@

    Write-File "$context\Interfaces\Rest\Resources\${entity}Resource.cs" @"
namespace $ns.Interfaces.Rest.Resources;

public record ${entity}Resource(int Id, $resourceParams);
"@

    Write-File "$context\Interfaces\Rest\Resources\Create${entity}Resource.cs" @"
namespace $ns.Interfaces.Rest.Resources;

public record Create${entity}Resource($resourceParams);
"@

    Write-File "$context\Interfaces\Rest\Transform\${entity}ResourceFromEntityAssembler.cs" @"
using $ns.Domain.Model.Entities;
using $ns.Interfaces.Rest.Resources;

namespace $ns.Interfaces.Rest.Transform;

public static class ${entity}ResourceFromEntityAssembler
{
    public static ${entity}Resource ToResourceFromEntity($entity entity)
    {
        return new ${entity}Resource(entity.Id, $entityArgs);
    }
}
"@

    Write-File "$context\Interfaces\Rest\Transform\Create${entity}CommandFromResourceAssembler.cs" @"
using $ns.Domain.Model.Commands;
using $ns.Interfaces.Rest.Resources;

namespace $ns.Interfaces.Rest.Transform;

public static class Create${entity}CommandFromResourceAssembler
{
    public static Create${entity}Command ToCommandFromResource(Create${entity}Resource resource)
    {
        return new Create${entity}Command($resourceArgs);
    }
}
"@

    Write-File "$context\Interfaces\Rest\Transform\Update${entity}CommandFromResourceAssembler.cs" @"
using $ns.Domain.Model.Commands;
using $ns.Interfaces.Rest.Resources;

namespace $ns.Interfaces.Rest.Transform;

public static class Update${entity}CommandFromResourceAssembler
{
    public static Update${entity}Command ToCommandFromResource(int id, Create${entity}Resource resource)
    {
        return new Update${entity}Command(id, $resourceArgs);
    }
}
"@

    Write-File "$context\Interfaces\Rest\${plural}Controller.cs" @"
using System.Net.Mime;
using $ns.Application.CommandServices;
using $ns.Application.QueryServices;
using $ns.Domain.Model.Commands;
using $ns.Domain.Model.Queries;
using $ns.Interfaces.Rest.Resources;
using $ns.Interfaces.Rest.Transform;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace $ns.Interfaces.Rest;

[ApiController]
[Route("api/v1/$endpoint")]
[Produces(MediaTypeNames.Application.Json)]
[SwaggerTag("Available $plural endpoints")]
public class ${plural}Controller(
    I${entity}CommandService commandService,
    I${entity}QueryService queryService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await queryService.Handle(new GetAll${plural}Query(), cancellationToken);
        return Ok(result.Select(${entity}ResourceFromEntityAssembler.ToResourceFromEntity));
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken)
    {
        var result = await queryService.Handle(new Get${entity}ByIdQuery(id), cancellationToken);
        if (result is null) return NotFound();
        return Ok(${entity}ResourceFromEntityAssembler.ToResourceFromEntity(result));
    }

    [HttpPost]
    public async Task<IActionResult> Create(Create${entity}Resource resource, CancellationToken cancellationToken)
    {
        var command = Create${entity}CommandFromResourceAssembler.ToCommandFromResource(resource);
        var result = await commandService.Handle(command, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Value!.Id },
            ${entity}ResourceFromEntityAssembler.ToResourceFromEntity(result.Value));
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, Create${entity}Resource resource, CancellationToken cancellationToken)
    {
        var command = Update${entity}CommandFromResourceAssembler.ToCommandFromResource(id, resource);
        var result = await commandService.Handle(command, cancellationToken);
        if (result.IsFailure) return NotFound();
        return Ok(${entity}ResourceFromEntityAssembler.ToResourceFromEntity(result.Value!));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var result = await commandService.Handle(new Delete${entity}Command(id), cancellationToken);
        if (result.IsFailure) return NotFound();
        return NoContent();
    }
}
"@
}

$stringDefault = '        '

Add-SimpleContext "Livestock" "Herd" "Herds" "herds" @(
    @{ Type = "string"; Name = "Name" },
    @{ Type = "string"; Name = "Location" },
    @{ Type = "string"; Name = "Owner" },
    @{ Type = "int"; Name = "OwnerId" },
    @{ Type = "int?"; Name = "VeterinarianId" },
    @{ Type = "string"; Name = "MainType" }
) "string Name, string Location, string Owner, int OwnerId, int? VeterinarianId, string MainType" "        Name = string.Empty;`n        Location = string.Empty;`n        Owner = string.Empty;`n        MainType = string.Empty;" @"
        builder.Entity<Herd>().HasKey(h => h.Id);
        builder.Entity<Herd>().Property(h => h.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<Herd>().Property(h => h.Name).IsRequired().HasMaxLength(80);
        builder.Entity<Herd>().Property(h => h.Location).IsRequired().HasMaxLength(80);
        builder.Entity<Herd>().Property(h => h.Owner).IsRequired().HasMaxLength(80);
        builder.Entity<Herd>().Property(h => h.MainType).IsRequired().HasMaxLength(40);
"@

Add-SimpleContext "Livestock" "Animal" "Animals" "animals" @(
    @{ Type = "string"; Name = "Tag" },
    @{ Type = "string"; Name = "Name" },
    @{ Type = "string"; Name = "Species" },
    @{ Type = "string"; Name = "Breed" },
    @{ Type = "string"; Name = "Gender" },
    @{ Type = "DateOnly?"; Name = "BirthDate" },
    @{ Type = "decimal"; Name = "Weight" },
    @{ Type = "string"; Name = "Status" },
    @{ Type = "int"; Name = "HerdId" }
) "string Tag, string Name, string Species, string Breed, string Gender, DateOnly? BirthDate, decimal Weight, string Status, int HerdId" "        Tag = string.Empty;`n        Name = string.Empty;`n        Species = string.Empty;`n        Breed = string.Empty;`n        Gender = string.Empty;`n        Status = string.Empty;" @"
        builder.Entity<Animal>().HasKey(a => a.Id);
        builder.Entity<Animal>().Property(a => a.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<Animal>().Property(a => a.Tag).IsRequired().HasMaxLength(30);
        builder.Entity<Animal>().Property(a => a.Name).IsRequired().HasMaxLength(80);
        builder.Entity<Animal>().Property(a => a.Species).IsRequired().HasMaxLength(40);
        builder.Entity<Animal>().Property(a => a.Breed).IsRequired().HasMaxLength(60);
        builder.Entity<Animal>().Property(a => a.Gender).IsRequired().HasMaxLength(20);
        builder.Entity<Animal>().Property(a => a.Status).IsRequired().HasMaxLength(30);
"@

Add-SimpleContext "Sanitary" "HealthEvent" "HealthEvents" "health-events" @(
    @{ Type = "int"; Name = "AnimalId" },
    @{ Type = "string"; Name = "Type" },
    @{ Type = "DateOnly"; Name = "Date" },
    @{ Type = "string"; Name = "Description" },
    @{ Type = "string"; Name = "Veterinarian" },
    @{ Type = "string"; Name = "Diagnosis" },
    @{ Type = "string"; Name = "Treatment" },
    @{ Type = "string"; Name = "Prescription" },
    @{ Type = "string"; Name = "FollowUp" },
    @{ Type = "DateOnly?"; Name = "NextDueDate" }
) "int AnimalId, string Type, DateOnly Date, string Description, string Veterinarian, string Diagnosis, string Treatment, string Prescription, string FollowUp, DateOnly? NextDueDate" "        Type = string.Empty;`n        Description = string.Empty;`n        Veterinarian = string.Empty;`n        Diagnosis = string.Empty;`n        Treatment = string.Empty;`n        Prescription = string.Empty;`n        FollowUp = string.Empty;" @"
        builder.Entity<HealthEvent>().HasKey(h => h.Id);
        builder.Entity<HealthEvent>().Property(h => h.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<HealthEvent>().Property(h => h.Type).IsRequired().HasMaxLength(40);
        builder.Entity<HealthEvent>().Property(h => h.Description).IsRequired().HasMaxLength(500);
        builder.Entity<HealthEvent>().Property(h => h.Veterinarian).HasMaxLength(80);
"@

Add-SimpleContext "Financial" "FinancialRecord" "FinancialRecords" "financial-records" @(
    @{ Type = "int"; Name = "OwnerId" },
    @{ Type = "string"; Name = "Type" },
    @{ Type = "string"; Name = "Category" },
    @{ Type = "decimal"; Name = "Amount" },
    @{ Type = "DateOnly"; Name = "Date" },
    @{ Type = "string"; Name = "Description" }
) "int OwnerId, string Type, string Category, decimal Amount, DateOnly Date, string Description" "        Type = string.Empty;`n        Category = string.Empty;`n        Description = string.Empty;" @"
        builder.Entity<FinancialRecord>().HasKey(f => f.Id);
        builder.Entity<FinancialRecord>().Property(f => f.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<FinancialRecord>().Property(f => f.Type).IsRequired().HasMaxLength(20);
        builder.Entity<FinancialRecord>().Property(f => f.Category).IsRequired().HasMaxLength(80);
        builder.Entity<FinancialRecord>().Property(f => f.Amount).HasPrecision(10, 2);
"@

Add-SimpleContext "Activities" "FarmActivity" "FarmActivities" "farm-events" @(
    @{ Type = "int?"; Name = "OwnerId" },
    @{ Type = "int?"; Name = "VeterinarianId" },
    @{ Type = "string"; Name = "Title" },
    @{ Type = "string"; Name = "Type" },
    @{ Type = "DateOnly"; Name = "Date" },
    @{ Type = "string"; Name = "Priority" },
    @{ Type = "string"; Name = "Status" }
) "int? OwnerId, int? VeterinarianId, string Title, string Type, DateOnly Date, string Priority, string Status" "        Title = string.Empty;`n        Type = string.Empty;`n        Priority = string.Empty;`n        Status = string.Empty;" @"
        builder.Entity<FarmActivity>().HasKey(a => a.Id);
        builder.Entity<FarmActivity>().Property(a => a.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<FarmActivity>().Property(a => a.Title).IsRequired().HasMaxLength(120);
        builder.Entity<FarmActivity>().Property(a => a.Type).IsRequired().HasMaxLength(40);
        builder.Entity<FarmActivity>().Property(a => a.Priority).IsRequired().HasMaxLength(20);
        builder.Entity<FarmActivity>().Property(a => a.Status).IsRequired().HasMaxLength(30);
"@

Add-SimpleContext "Analytics" "ReportMetric" "ReportMetrics" "report-metrics" @(
    @{ Type = "string"; Name = "Label" },
    @{ Type = "string"; Name = "Value" },
    @{ Type = "string"; Name = "Trend" }
) "string Label, string Value, string Trend" "        Label = string.Empty;`n        Value = string.Empty;`n        Trend = string.Empty;" @"
        builder.Entity<ReportMetric>().HasKey(m => m.Id);
        builder.Entity<ReportMetric>().Property(m => m.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<ReportMetric>().Property(m => m.Label).IsRequired().HasMaxLength(80);
        builder.Entity<ReportMetric>().Property(m => m.Value).IsRequired().HasMaxLength(40);
        builder.Entity<ReportMetric>().Property(m => m.Trend).HasMaxLength(80);
"@

Add-SimpleContext "Devices" "Device" "Devices" "devices" @(
    @{ Type = "string"; Name = "Name" },
    @{ Type = "string"; Name = "Type" },
    @{ Type = "string"; Name = "SerialNumber" },
    @{ Type = "string"; Name = "Status" },
    @{ Type = "int?"; Name = "HerdId" },
    @{ Type = "int?"; Name = "AnimalId" }
) "string Name, string Type, string SerialNumber, string Status, int? HerdId, int? AnimalId" "        Name = string.Empty;`n        Type = string.Empty;`n        SerialNumber = string.Empty;`n        Status = string.Empty;" @"
        builder.Entity<Device>().HasKey(d => d.Id);
        builder.Entity<Device>().Property(d => d.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<Device>().Property(d => d.Name).IsRequired().HasMaxLength(80);
        builder.Entity<Device>().Property(d => d.Type).IsRequired().HasMaxLength(60);
        builder.Entity<Device>().Property(d => d.SerialNumber).IsRequired().HasMaxLength(80);
        builder.Entity<Device>().Property(d => d.Status).IsRequired().HasMaxLength(30);
"@

Add-SimpleContext "Metrics" "DeviceMetric" "DeviceMetrics" "device-metrics" @(
    @{ Type = "int"; Name = "DeviceId" },
    @{ Type = "string"; Name = "Type" },
    @{ Type = "decimal"; Name = "Value" },
    @{ Type = "string"; Name = "Unit" },
    @{ Type = "DateTime"; Name = "RecordedAt" }
) "int DeviceId, string Type, decimal Value, string Unit, DateTime RecordedAt" "        Type = string.Empty;`n        Unit = string.Empty;" @"
        builder.Entity<DeviceMetric>().HasKey(m => m.Id);
        builder.Entity<DeviceMetric>().Property(m => m.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<DeviceMetric>().Property(m => m.Type).IsRequired().HasMaxLength(60);
        builder.Entity<DeviceMetric>().Property(m => m.Unit).IsRequired().HasMaxLength(20);
        builder.Entity<DeviceMetric>().Property(m => m.Value).HasPrecision(12, 2);
"@

Add-SimpleContext "Subscriptions" "SubscriptionPlan" "SubscriptionPlans" "subscription-plans" @(
    @{ Type = "string"; Name = "Name" },
    @{ Type = "decimal"; Name = "Price" },
    @{ Type = "string"; Name = "StripePriceId" },
    @{ Type = "int"; Name = "MaxAnimals" },
    @{ Type = "bool"; Name = "IsActive" }
) "string Name, decimal Price, string StripePriceId, int MaxAnimals, bool IsActive" "        Name = string.Empty;`n        StripePriceId = string.Empty;" @"
        builder.Entity<SubscriptionPlan>().HasKey(p => p.Id);
        builder.Entity<SubscriptionPlan>().Property(p => p.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<SubscriptionPlan>().Property(p => p.Name).IsRequired().HasMaxLength(80);
        builder.Entity<SubscriptionPlan>().Property(p => p.Price).HasPrecision(10, 2);
        builder.Entity<SubscriptionPlan>().Property(p => p.StripePriceId).HasMaxLength(120);
"@

Add-SimpleContext "Subscriptions" "Subscription" "Subscriptions" "subscriptions" @(
    @{ Type = "int"; Name = "UserId" },
    @{ Type = "int"; Name = "PlanId" },
    @{ Type = "string"; Name = "StripeCustomerId" },
    @{ Type = "string"; Name = "StripeSubscriptionId" },
    @{ Type = "string"; Name = "Status" },
    @{ Type = "DateOnly"; Name = "StartedAt" },
    @{ Type = "DateOnly?"; Name = "EndsAt" }
) "int UserId, int PlanId, string StripeCustomerId, string StripeSubscriptionId, string Status, DateOnly StartedAt, DateOnly? EndsAt" "        StripeCustomerId = string.Empty;`n        StripeSubscriptionId = string.Empty;`n        Status = string.Empty;" @"
        builder.Entity<Subscription>().HasKey(s => s.Id);
        builder.Entity<Subscription>().Property(s => s.Id).IsRequired().ValueGeneratedOnAdd();
        builder.Entity<Subscription>().Property(s => s.StripeCustomerId).HasMaxLength(120);
        builder.Entity<Subscription>().Property(s => s.StripeSubscriptionId).HasMaxLength(120);
        builder.Entity<Subscription>().Property(s => s.Status).IsRequired().HasMaxLength(40);
"@
