# 0001. AVM version and Azure API version policy

- Status: Accepted
- Date: 2026-11-23

## Context

The Bicep templates mix Azure Verified Module (AVM) references with raw resource declarations, pinned to a wide spread of AVM and Azure API versions. Older pins miss security and platform fixes and make later upgrades larger and riskier. Version choices need a single, repeatable rule.

## Decision

### AVM upgrade policy

- Pin every AVM module to the latest published version that builds with the pipeline's Bicep CLI.
- Upgrade module by module, reviewing the upstream changelog for breaking changes first.
- Network security group is held at `0.5.3` and Key Vault `vault` at `0.14.0`; newer versions need a newer Bicep CLI.
- AVM `enableTelemetry` is left at the module default (a telemetry-only deployment, no resource impact).
- Pins reflect live values so behaviour stays like-for-like. Security hardening (shared key access, IP masking, Key Vault network ACLs) is out of scope.

### API version selection rule

1. Use the newest **stable** API version present in the Bicep type catalog that builds without `BCP081`.
2. If the newest target is not in the catalog, fall back to the version the target AVM module itself uses.
3. Use a **preview** API version only where no stable version exists. Exceptions:
   - `Microsoft.Insights/diagnosticSettings@2021-05-01-preview` — the stable `2016-09-01` has no `categoryGroup`; all AVM modules use the preview version.
   - `Microsoft.Portal/dashboards` — no stable version exists; kept at `2022-12-01-preview` because `2025-04-01-preview` types add `BCP037` warnings.
4. Any other preview use must be justified in the pull request.

#### Deferred `2026-*` API versions

Bicep CLI 0.43.8 lacks the types (`BCP081`) for these, so they are deferred until the agent's Bicep is upgraded (>= 0.49.x):

- Cosmos DB `databaseAccounts` `2026-03-15` and `mongoClusters` `2026-06-01`.
- Storage, Network, Key Vault and Log Analytics `2026-*`.

#### API versions chosen

| Resource family | API version |
| --- | --- |
| Cosmos DB `databaseAccounts` family | `2025-10-15` |
| Cosmos DB `mongoClusters` | `2025-09-01` |
| Network | `2025-05-01` |
| Web | `2025-03-01` |
| Storage | `2025-06-01` |
| Key Vault | `2025-05-01` |
| Log Analytics | `2025-07-01` |
| Container Registry | `2025-11-01` |

### Retained raw-resource workarounds

| Resource | Why it stays raw |
| --- | --- |
| Cosmos DB RU `databaseAccounts` | AVM `database-account` 0.21.2 uses the `2026-04-01-preview` API, defaults `disableLocalAuthentication` to `true` and zone redundancy to `true`, and derives `kind`. |
| Cosmos DB vCore `mongoClusters` | AVM `mongo-cluster` 0.4.3 has no geo-replica support and always emits `administrator`/`authConfig`, which Azure rejects on replicated clusters. |
| `autoscalesettings` and role assignments | No AVM resource module exists; embedded AVM role-assignment naming would conflict with existing assignments. |
| Key Vault secrets | Using the `vault` module would re-PUT the vault. |

### Replaced workarounds

- Web app Front Door IP restrictions move into the `web/site` module `siteConfig`.
- `apiConnections` move from raw `Microsoft.Web/connections` to AVM `web/connection` `0.4.4`; `accessPolicies` remain raw.

### Deployment safety gate

Each change is validated with `az deployment group what-if` against DEV1 before merge. A change passes only if it has:

- no `Delete` and no resource recreate; and
- no immutable or one-way property changes.

### Deferred high-risk items

- `virtual-network` module upgrade.
- Redis cache.
- All `*SecondaryPE.bicep` templates (Container Registry, Key Vault, storage), pending a secondary region in DEV1.

These are handled in a separate, dedicated round.

## Consequences

- Version bumps follow one predictable rule and are reviewable against the what-if gate.
- Some raw workarounds remain until AVM closes the gaps above; each should be revisited when the upstream module changes.
- Using preview APIs is limited to the documented exceptions.
