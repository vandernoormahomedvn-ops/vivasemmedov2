---
name: firebase-mcp-project-guard
description: Prevents Firebase MCP operations on the wrong project. MUST be triggered before any Firestore/Auth/Storage MCP operation. Validates and auto-corrects the active project.
---

# Firebase MCP Project Guard

## Purpose
The Firebase MCP server **persists** its active project across conversations and workspaces. This means switching from one project workspace (e.g., Flexpress) to another (e.g., Yentelelo) does NOT automatically update the MCP's active project. This leads to:
- Silent data mismatches (queries returning empty because the project has no such data)
- Dangerous writes to the wrong project
- Hours of wasted debugging

## When to Activate
> [!CAUTION]
> **ALWAYS** run this check before any `mcp_firebase-mcp-server_firestore_*`, `mcp_firebase-mcp-server_auth_*`, or `mcp_firebase-mcp-server_storage_*` tool call.

## Steps

### 1. Check Current Environment
Call `mcp_firebase-mcp-server_firebase_get_environment` and compare:
- `Active Project ID` vs. the workspace's actual Firebase project ID
- `Project Directory` vs. the current workspace path

### 2. Find the Correct Project ID
The Firebase project ID is in one of these locations:
| Platform | File | Field |
|----------|------|-------|
| Flutter | `lib/backend/firebase/firebase_config.dart` | `projectId:` |
| Flutter | `lib/firebase_options.dart` | `projectId:` |
| Android | `android/app/google-services.json` | `project_id` |
| iOS | `ios/Runner/GoogleService-Info.plist` | `PROJECT_ID` |
| Web | `web/index.html` or `firebase_config.dart` | `projectId` |

### 3. Auto-Correct if Mismatched
If the active project doesn't match, immediately call:
```
mcp_firebase-mcp-server_firebase_update_environment(
  active_project: "<correct_project_id>",
  project_dir: "<current_workspace_path>"
)
```

### 4. Confirm
Re-check with `mcp_firebase-mcp-server_firebase_get_environment` to verify the correction.

## Red Flags (Indicators of Wrong Project)
- Firestore query returns `[]` when data should exist
- Auth operations fail with "user not found"
- Storage downloads return 404
- MCP shows a different `Project Directory` than your workspace

## Known Project IDs

| Workspace | Project ID | Directory |
|-----------|-----------|-----------|
| Yentelelo | `yentelelo-el9qvy` | `/Users/vanderdfsnoormahomed/Downloads/yentelelo` |
| Flexpress | `flexpress-delivery-pro` | Flexpress workspace path |

## Extended Troubleshooting

### Data Still Empty After Project Correction?
If the project is correct but queries still return empty:

1. **Check collection path**: Data may be in subcollections (`playlists/{id}/videos`) not top-level (`videos`).
2. **Check field existence**: `orderBy('views')` only returns docs WITH the `views` field. Use `orderBy('createdAt')` + client-side sort as fallback.
3. **Check `collectionGroup` rules**: Need `match /{path=**}/collection/{doc}` rule in `firestore.rules`.

### Feature Not Working? (View Count, Likes, etc.)
When a Firestore-writing feature works inconsistently:

1. **Trace the FULL navigation path**: Home → Details → Player. Each screen is independent.
2. **Verify the logic exists in ALL relevant screens**, not just the one where you first found it.
3. **Check `currentUserReference`**: If null, the user is not authenticated → Firestore writes silently skip.
4. **Check debug output in terminal**: If no debug logs appear, the function was never called.
