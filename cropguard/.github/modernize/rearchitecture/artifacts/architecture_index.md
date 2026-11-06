# Architecture Index

This index is not the full contract. Do not implement from this file alone; follow the artifact paths below.

## Global artifacts
- `unit_graph.yaml` — joins all units, source anchors, exported signatures, and shared refs. Read this first to map assigned units and inter-unit edges.
- `migration_boundary.yaml` — identifies the smallest runtime-reachable boundary and the implementation scope (`must_rewrite`, `copy_as_is`, `legacy_allowed_to_remain`).
- `wire_contracts.yaml` — records external REST/Supabase/SDK contracts that must remain stable across a migration or rewrite.
- `shared_modules.yaml` — defines shared modules used by multiple units and their field subsets.
- `cross_unit_state.yaml` — captures implicit session and user-scoped state flows that must be preserved at runtime.
- `project-structure.md` — functional layout and project type.
- `tech-stack.md` — frameworks and runtime dependencies in the current app.
- `data-model.md` — entity inventory and the observed schema.

## Implementation Guide

### Unit: auth-splash
- external trigger: page (`/`)
- must read:
  - `units/auth-splash/behavior.yaml` — session-check behavior and unauthenticated/authenticated branch rules
  - `units/auth-splash/bindings.yaml` — route and auth-state registration requirements
  - `units/auth-splash/unit_decomposition.yaml` — optional split candidates for auth startup and route gating
- relevant global rows:
  - `unit_graph.yaml` rows for `auth-splash`
  - `cross_unit_state.yaml` flows including `auth-user-session` and `diagnosis-user-context`
- completion evidence: `artifacts_read`, `implemented_must_preserve`, `unresolved_or_deferred`, and runtime evidence that the session-check branch still routes correctly

### Unit: auth-login
- external trigger: page (`/login`)
- must read:
  - `units/auth-login/behavior.yaml` — email and Google login behavior, auth branches, and error semantics
  - `units/auth-login/bindings.yaml` — login route, provider wiring, and runtime config
  - `units/auth-login/unit_decomposition.yaml` — candidate split between provider-specific logic and UI flow
- relevant global rows:
  - `wire_contracts.yaml` rows for `supabase-google-auth`
  - `shared_modules.yaml` rows where `used_by_units` includes `auth-login`
- completion evidence: preserved auth success/failure semantics, secure OAuth config, and successful runtime auth validation

### Unit: auth-register
- external trigger: page (`/register`)
- must read:
  - `units/auth-register/behavior.yaml` — signup confirmation and validation behavior
  - `units/auth-register/bindings.yaml` — route and metadata contract
  - `units/auth-register/unit_decomposition.yaml` — candidate split between validation and post-sign-up confirmation logic
- completion evidence: signup metadata remains attached and confirmation flow remains intact

### Unit: home-dashboard
- external trigger: page (`/home`)
- must read:
  - `units/home-dashboard/behavior.yaml` — summary data load and empty-state behavior
  - `units/home-dashboard/bindings.yaml` — route and cubit registration
  - `units/home-dashboard/unit_decomposition.yaml` — split candidates for widget and summary composition
- relevant global rows:
  - `shared_modules.yaml` rows for `farm-remote-data-source` and `app-router`
  - `cross_unit_state.yaml` flows with `reader.unit == home-dashboard`
- completion evidence: dashboard loads from authenticated scope and preserves empty-state semantics

### Unit: farms-list
- external trigger: page (`/farms`)
- must read:
  - `units/farms-list/behavior.yaml` — farm list, create, and empty-state behavior
  - `units/farms-list/bindings.yaml` — route and data source injection
  - `units/farms-list/unit_decomposition.yaml` — candidate split between farm CRUD and nested child data queries
- relevant global rows:
  - `wire_contracts.yaml` rows for `supabase-farms-ownership-query`
- completion evidence: user-scoped farm ownership and row semantics remain unchanged

### Unit: farm-detail
- external trigger: page (`/farms/:farmId`)
- must read:
  - `units/farm-detail/behavior.yaml` — aggregated farm detail and empty-crop behavior
  - `units/farm-detail/bindings.yaml` — route and SQL contract
  - `units/farm-detail/unit_decomposition.yaml` — candidate split between farm metadata and nested child rows
- completion evidence: nested crop and plot aggregation remains valid and owner-scoped

### Unit: diagnosis
- external trigger: page (`/diagnose`)
- must read:
  - `units/diagnosis/behavior.yaml` — photo intake, backend upload, and diagnosis result rendering
  - `units/diagnosis/bindings.yaml` — route, use-case injection, and runtime config
  - `units/diagnosis/unit_decomposition.yaml` — candidate split between upload and fetch concerns
- relevant global rows:
  - `wire_contracts.yaml` rows for `fastapi-diagnosis-upload`
  - `shared_modules.yaml` rows for `fastapi-client` and `ai-backend-service`
- completion evidence: multipart upload and error-contract semantics are preserved and runtime results remain comparable

### Unit: history-list
- external trigger: page (`/history`)
- must read:
  - `units/history-list/behavior.yaml` — read-only list behavior and empty-state semantics
  - `units/history-list/bindings.yaml` — route and use-case registration
  - `units/history-list/unit_decomposition.yaml` — candidate split between list metadata and result rendering
- relevant global rows:
  - `wire_contracts.yaml` rows for `supabase-history-read`
- completion evidence: authenticated history queries and detail navigation remain consistent

### Unit: my-crops
- external trigger: page (`/crops/:cropId` and plot detail routes)
- must read:
  - `units/my-crops/behavior.yaml` — crop and plot detail behavior and record updates
  - `units/my-crops/bindings.yaml` — route and data source injection
  - `units/my-crops/unit_decomposition.yaml` — candidate split between crop and plot lifecycle logic
- completion evidence: crop and plot status, navigation, and backend calls remain in sync with ownership rules

### Unit: guide-crops
- external trigger: page (`/guide` and `/guide/:cropId`)
- must read:
  - `units/guide-crops/behavior.yaml` — list and detail browsing behavior
  - `units/guide-crops/bindings.yaml` — route mapping and helper wiring
  - `units/guide-crops/unit_decomposition.yaml` — split candidates for list and detail rendering
- completion evidence: crop browsing remains informational and route-specific without mutations

### Unit: profile-screen
- external trigger: page (`/profile`)
- must read:
  - `units/profile-screen/behavior.yaml` — personal data update and sign-out behavior
  - `units/profile-screen/bindings.yaml` — route and profile repository binding
  - `units/profile-screen/unit_decomposition.yaml` — candidate split between user settings and actions
- completion evidence: profile update and sign-out semantics remain secure and user-scoped

## Done conditions
Before marking implementation complete, the worker should confirm:
- the assigned unit’s `behavior.yaml` items are preserved in the target implementation
- relevant `wire_contracts.yaml` rows are not broken
- global `cross_unit_state.yaml` flows are still valid under the runtime contract
- `migration_boundary.yaml` scope is respected; do not expand to a full rewrite without a matching gate
- any unresolved contract remains explicitly noted as deferred rather than silently dropped
