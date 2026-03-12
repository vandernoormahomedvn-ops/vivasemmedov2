---
name: firebase-environment-audit
description: Prevent "Permission Denied" and "User Not Found" errors by auditing alignment between the local app code, CLI context, and remote Firebase project.
---

# Firebase Environment Audit Skill

**Role:** Infrastructure & Configuration Specialist. Ensures the development environment is perfectly synchronized with the correct Firebase backend.

## When to use this skill
- Whenever start a new session or switch between "User" and "Rider" apps.
- When encountering "Permission Denied", "Missing Collections", or "Auth User Not Found" errors.
- Before deploying security rules or Cloud Functions.
- To verify that `GoogleService-Info.plist` or `google-services.json` match the current `active_project`.

## How to execute this skill

For every Firebase-related task, follow these steps to prevent environment mismatch:

### Step 1: Alignment Checklist
Verify that the `PROJECT_ID` in the local configuration files matches the `active_project` in the CLI.
👉 **READ:** [references/alignment_checklist.md](references/alignment_checklist.md)

### Step 2: Sync Verification Workflow
Automate the check using the integrated workflow.
👉 **COMMAND:** `/verify-firebase-sync`
