# Troubleshooting Playbook

Use these templates as read-only investigation accelerators.

## Logging source priority

Start with `AzureDiagnostics` first for every investigation, because all resource logs are routed there in this environment.
Use table-specific queries (`requests`, `dependencies`, `exceptions`, `traces`, `AzureActivity`) as secondary drill-down after initial `AzureDiagnostics` evidence.

## A) Input checklist

- Environment name provided and mapped to `vars/<environment>.yaml`
- Subscription context resolved from `vars/<environment>.yaml` (`serviceConnection` pattern `AZR-MMO-<ENV>1`, and/or `subscriptionId`)
- Impacted applications list
- Time window provided or defaulted to 1 hour
- Deployed branch confirmed per impacted repo
- Resource names resolved from `common.yaml` + env vars + templates
- User is connected to client network/VPN (required for private endpoint-integrated resources)
- Azure MCP server/session is available before querying Azure resources
- No local git operations and no local cloning of application repositories
- No `az` CLI usage (Azure MCP only)

## B) KQL starter snippets (adapt per table schema)

### 0. First check - AzureDiagnostics (mandatory)

```kusto
AzureDiagnostics
| where TimeGenerated between (ago(1h) .. now())
| summarize Count=count() by ResourceProvider=tostring(ResourceProvider), ResourceType=tostring(ResourceType), Category=tostring(Category), ResultType=tostring(ResultType)
| order by Count desc
```

### 1. Exceptions by cloud role

```kusto
exceptions
| where timestamp between (ago(1h) .. now())
| summarize count() by cloud_RoleName, type, outerMessage
| order by count_ desc
```

### 2. Failed requests

```kusto
requests
| where timestamp between (ago(1h) .. now())
| where success == false or toint(resultCode) >= 500
| project timestamp, cloud_RoleName, operation_Id, operation_Name, resultCode, duration, url
| order by timestamp desc
```

### 3. Failed dependencies

```kusto
dependencies
| where timestamp between (ago(1h) .. now())
| where success == false
| project timestamp, cloud_RoleName, operation_Id, target, type, resultCode, duration, name
| order by timestamp desc
```

### 4. Correlate request + dependency + exception

```kusto
let winStart = ago(1h);
let req = requests
| where timestamp between (winStart .. now())
| where success == false or toint(resultCode) >= 500
| project reqTime=timestamp, operation_Id, operation_Name, reqRole=cloud_RoleName, reqCode=resultCode, reqDuration=duration;
let dep = dependencies
| where timestamp between (winStart .. now())
| where success == false
| project depTime=timestamp, operation_Id, depRole=cloud_RoleName, depTarget=target, depType=type, depCode=resultCode, depDuration=duration;
let ex = exceptions
| where timestamp between (winStart .. now())
| project exTime=timestamp, operation_Id, exRole=cloud_RoleName, exType=type, exMessage=outerMessage;
req
| join kind=leftouter dep on operation_Id
| join kind=leftouter ex on operation_Id
| project reqTime, operation_Id, operation_Name, reqRole, reqCode, depRole, depTarget, depType, depCode, exRole, exType, exMessage
| order by reqTime desc
```

### 5. Activity Log checks (platform-level)

```kusto
AzureActivity
| where TimeGenerated between (ago(1h) .. now())
| where ResourceProviderValue in~ ("MICROSOFT.WEB", "MICROSOFT.INSIGHTS", "MICROSOFT.OPERATIONALINSIGHTS")
| project TimeGenerated, OperationNameValue, ActivityStatusValue, ResourceGroup, ResourceId, Caller, CorrelationId, Properties
| order by TimeGenerated desc
```

### 6. Web App app-vs-platform signal split

- Validate application-side failures first (`requests`, `dependencies`, `exceptions`, `traces`).
- Validate platform-side signals next (App Service diagnostics/Activity Log for restart/config/platform incidents).
- Correlate both timelines before asserting root cause.

### 7. ACR image/tag validation (read-only)

- Confirm expected image repository and deployed tag exist in ACR.
- Compare deployed app image/tag references with available tags/manifests.
- Do not perform any registry mutation operations.

## F) Network access failure response template

Use this exact style when private endpoint-integrated resources are unreachable:

"Read-only troubleshooting is currently blocked by network access constraints. These app and monitoring resources are private endpoint-integrated and require client network/VPN connectivity. Please confirm you are connected to the client network, then retry. No Azure resources were modified."

## G) Chat debug/status message templates

Use these messages before each troubleshooting action so the user sees progress and target resource context.
Use them for every Azure connect/read action and every repository inspection action (mandatory).
After each action, post the corresponding completion message (mandatory).

- Subscription selection:
  - `Checking subscription context: AZR-MMO-DEV1`
  - `Checking subscription context: 6605237e-040b-4bdd-a6b0-5dd29b734fc9`
- Azure connection:
  - `Connecting to Azure subscription: AZR-MMO-DEV1`
  - `Connecting to Azure subscription: 6605237e-040b-4bdd-a6b0-5dd29b734fc9`
  - `Connected to Azure subscription: AZR-MMO-DEV1`
- Resource lookup:
  - `Resolving resources for DEV: Web App DEV-MMO-FES-EXTERNAL-FE-WA`
  - `Resolving resources for DEV: Log Analytics workspace DEVMMOINFLW1401`
  - `Resolved resources for DEV: Web App DEV-MMO-FES-EXTERNAL-FE-WA`
- Log checks:
  - `Checking logs for DEV-MMO-FES-EXTERNAL-FE-WA app`
  - `Checking platform logs for DEV-MMO-FES-EXTERNAL-FE-WA app`
  - `Checking AzureDiagnostics for DEV environment resources`
  - `Completed log check for DEV-MMO-FES-EXTERNAL-FE-WA app`
- Resource reads:
  - `Reading Web App DEV-MMO-FES-EXTERNAL-FE-WA in AZR-MMO-DEV1`
  - `Reading Log Analytics workspace DEVMMOINFLW1401 in AZR-MMO-DEV1`
  - `Completed reading Web App DEV-MMO-FES-EXTERNAL-FE-WA in AZR-MMO-DEV1`
- Correlation step:
  - `Correlating errors across DEV-MMO-FES-EXTERNAL-FE-WA -> DEV-MMO-FES-ORCHESTRATION-WA`
  - `Completed correlation across DEV-MMO-FES-EXTERNAL-FE-WA -> DEV-MMO-FES-ORCHESTRATION-WA`
- Repository checks:
  - `Checking code in eutd-mmo-fes-core-infra`
  - `Checking code in eutd-mmo-fes-pipeline-common`
  - `Checking code in DEFRA/eutd-mmo-fes-function-app`
  - `Completed code check in eutd-mmo-fes-core-infra`

## H) Message sequence checklist (Start -> Action -> Complete)

For each troubleshooting unit of work, use this 3-step sequence (mandatory):

- **Start**: announce intent and target.

`Connecting to Azure subscription: AZR-MMO-DEV1`

- **Action**: announce the exact read/query operation.

`Reading Web App DEV-MMO-FES-EXTERNAL-FE-WA in AZR-MMO-DEV1`

- **Complete**: confirm completion for the same target.

`Completed reading Web App DEV-MMO-FES-EXTERNAL-FE-WA in AZR-MMO-DEV1`

Apply the same sequence to repository inspections:

- `Checking code in eutd-mmo-fes-core-infra`
- `Checking code in DEFRA/eutd-mmo-fes-function-app`
- `Completed code check in DEFRA/eutd-mmo-fes-function-app`

## C) Iterative window procedure

1. Query at 1h.
2. If empty/non-actionable, repeat with 2h.
3. Continue 4h, 8h, 12h, 24h.
4. Stop at 24h maximum.

## D) Dead-end template

"Investigation reached a dead end for [component] within [window]. Checked [sources]. No deterministic correlation found. Need one of: [missing branch], [missing app name], [exact error timestamp], [request/correlation ID]."

## E) Final report table template

| Time window | Environment | Component | Resource | Error signature | Correlation IDs | Evidence (query/source) | Likely root cause | Confidence | Recommended next read-only checks |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
