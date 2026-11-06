# Data Model

## Entity inventory
The application model is mostly *feature-local* and is backed by Supabase and FastAPI payloads rather than a single centralized ORM. The main persistent and domain entities observed in the code are:

- `AppUser` — authenticated user record returned after sign-in or sign-up; includes profile and role fields
- `SignUpParams` — collection of registration metadata for email/signup flows
- `Farm` — owner-scoped farm entity, with area, description, department, municipality, and address fields
- `FarmDetails` — aggregate object that combines farm metadata with child crop rows
- `FarmCrop` — crop entity attached to a farm, including planting and harvest dates
- `FarmPlot` — plot entity attached to a crop, with area, plant count, status, and last sampled date
- `DiagnosisRecord` — previous diagnosis object stored by the user and read from the history backend
- `CropDiagnosis` — domain result returned from the AI diagnosis pipeline, including disease name, scientific name, confidence, and recommendations
- `HomeDashboard` — summary object used to present the authenticated user’s dashboard and related farm data
- `UpdateProfileParams` — profile update payload used in the personal data flow

## Relationships
- Users own many farms (`owner_id` relationship in the `farms` table)
- Farms own many crops (`farm_id` relationship in the `crops` table)
- Crops own many plots (`crop_id` relationship in the `plots` table)
- Diagnosis records are associated with user-level history and may optionally map to a plot or crop context

## Database schema hints
The data source code references tables such as:
- `farms`
- `crops`
- `crop_types`
- `plots`
- `profiles`
- `diagnoses`

Specific key fields visible in the code include `owner_id`, `farm_id`, `crop_type_id`, `plot_id`, `area_ha`, `plant_count`, `created_at`, `updated_at`, and `last_sampled_at`.

## Key-entity summary
1. `AppUser` — active authenticated profile used to gate access and personalize the app.
2. `Farm` — primary farm record used for ownership and summary screens.
3. `FarmCrop` — selected crop within a farm and a container for crop metadata and plots.
4. `FarmPlot` — plot-level record, the main operational unit for monitoring and sampling.
5. `CropDiagnosis` — AI result returned from the backend with disease classification and recommendations.
6. `DiagnosisRecord` — persisted history item used by the history feature and details screen.

This file documents the current schema and persistence conventions as implemented in code; it does not propose a target redesign.
