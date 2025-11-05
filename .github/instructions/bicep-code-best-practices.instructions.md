---
description: 'Infrastructure as Code with Bicep'
applyTo: '**/*.bicep'
---

Prefer **Azure Verified Modules (AVM)** for Bicep to enforce Azure best practices via pre-built modules. Use Bicep resources ONLY when no AVM module exists for the required resource type or the module does not meet requirements or the expected functionality is missing on AVM modules.

## Discover AVM modules

- AVM Index: `https://azure.github.io/Azure-Verified-Modules/indexes/bicep/bicep-resource-modules/`
- GitHub: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/`

## Bicep Resources 
- Use Bicep resources when no AVM module exists for the required resource type or the module does not meet requirements or the expected functionality is missing on AVM modules.
- Follow Bicep best practices for resource declaration, naming, parameters, security, and documentation as outlined below.
- Refer to MS docs `https://learn.microsoft.com/en-us/azure/templates/` for bicep resource references and examples.

## Usage

- **Examples**: Copy from module documentation, update parameters, pin version
- **Registry**: Reference `br/avm:{service}/{resource}:{version}`

## Versioning

- MCR Endpoint: `https://mcr.microsoft.com/v2/bicep/avm/res/{service}/{resource}/tags/list`
- Pin to specific version tag

## Sources

- GitHub: `https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/{service}/{resource}`
- Registry: `br/avm:{service}/{resource}:{version}`

## Naming Conventions

-   When writing Bicep code, use lowerCamelCase for all names (variables, parameters, resources)
-   Use resource type descriptive symbolic names (e.g., 'storageAccount' not 'storageAccountName')
-   Avoid using 'name' in a symbolic name as it represents the resource, not the resource's name
-   Avoid distinguishing variables and parameters by the use of suffixes

## Structure and Declaration

-   Always declare parameters at the top of files with @description decorators
-   Use latest stable API versions for all resources
-   Use descriptive @description decorators for all parameters
-   Specify minimum and maximum character length for naming parameters

## Parameters

-   Set default values that are safe for test environments (use low-cost pricing tiers)
-   Use @allowed decorator sparingly to avoid blocking valid deployments
-   Use parameters for settings that change between deployments

## Variables

-   Variables automatically infer type from the resolved value
-   Use variables to contain complex expressions instead of embedding them directly in resource properties

## Resource References

-   Use symbolic names for resource references instead of reference() or resourceId() functions
-   Create resource dependencies through symbolic names (resourceA.id) not explicit dependsOn
-   For accessing properties from other resources, use the 'existing' keyword instead of passing values through outputs

## Resource Names

-   Use template expressions with uniqueString() to create meaningful and unique resource names
-   Add prefixes to uniqueString() results since some resources don't allow names starting with numbers

## Child Resources

-   Avoid excessive nesting of child resources
-   Use parent property or nesting instead of constructing resource names for child resources

## Security

-   Never include secrets or keys in outputs
-   Use resource properties directly in outputs (e.g., storageAccount.properties.primaryEndpoints)

## Documentation

-   Include helpful // comments within your Bicep files to improve readability
