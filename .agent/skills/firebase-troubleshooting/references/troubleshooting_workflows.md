# Firebase Troubleshooting Workflows

## Workflow

### 1. Diagnose the Error
- **Analyze the Error Message:** Look for specific codes like `storage/unauthorized` (Storage) or `permission-denied` (Firestore).
- **Identify the Path:** For Storage, note the full path being accessed (e.g., `playlists/`, `thumbnails/`).
- **Check Local Rules:** Review `firebase/storage.rules` or `firebase/firestore.rules` to see if the path is explicitly allowed.

### 2. Verify CLI Connection & Active Project
Before deploying fixes, ensure the Firebase CLI is active and targeting the **correct project**.
```bash
firebase projects:list
```
*If this fails, the user may need to re-authenticate (`firebase login`), but you should ask first.*

> **CRITICAL:** Always run `/verify-firebase-mcp-project` workflow or use `firebase-mcp-project-guard` skill before ANY Firebase MCP operation. The MCP persists the active project across conversations and may point to the WRONG project.

### 3. Fixing Storage Permissions
If `storage/unauthorized` occurs for a valid path:
1.  **Edit `firebase/storage.rules`**:
    ```text
    match /your-path/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    ```
2.  **Deploy ONLY Storage Rules** (Safest approach):
    ```bash
    firebase deploy --only storage
    ```

### 4. Fixing Firestore Permissions
If `permission-denied` occurs:
1.  **Edit `firebase/firestore.rules`** to allow the collection/document access.
2.  **For collectionGroup queries**, add a wildcard rule:
    ```text
    match /{path=**}/videos/{document} {
      allow read: if true;
    }
    ```
3.  **Deploy ONLY Firestore Rules**:
    ```bash
    firebase deploy --only firestore:rules
    ```

### 5. Firestore Collection Structure Issues
When queries return empty despite data existing:

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| `orderBy('field')` returns empty | Field doesn't exist on most docs | Use a guaranteed field + client-side sort |
| Query returns empty | Data is in subcollections, not top-level | Use `collectionGroup` or iterate parent docs |
| `collectionGroup` gives `permission-denied` | Missing wildcard rule in firestore.rules | Add `match /{path=**}/collectionName/{doc}` rule |
| Query returns wrong data | MCP pointing to wrong Firebase project | Run `/verify-firebase-mcp-project` first |

**Alternative to `collectionGroup`** (avoids Firestore rules changes):
```dart
// 1. Fetch parent collection
final parents = await FirebaseFirestore.instance.collection('playlists').get();
// 2. For each parent, get subcollection docs
for (final parent in parents.docs) {
  final videos = await parent.reference.collection('videos').get();
  allVideos.addAll(videos.docs);
}
// 3. Sort client-side
allVideos.sort((a, b) => b['views'].compareTo(a['views']));
```

## Common Pitfalls
- **Missing Configuration**: Ensure `firebase.json` has the correct `storage` and `firestore` blocks pointing to your rule files.
- **Caching**: Local emulators or browsers might cache old rules. Deployment is the definitive fix.
- **Authentication**: `request.auth != null` only works if the client SDK is authenticated. Verify the user is logged in.
- **MCP Project Mismatch**: The Firebase MCP server persists the active project. ALWAYS verify before querying.
- **Top-level vs Subcollection**: `FirebaseFirestore.instance.collection('videos')` only queries `/videos`, NOT `/playlists/{id}/videos`.

## Best Practices
- **Granular Deploys**: Always use `--only <target>` to avoid overwriting other infrastructure components.
- **Least Privilege**: Only grant write access to authenticated users (`request.auth != null`).
- **Project Guard**: Always trigger `firebase-mcp-project-guard` skill before any Firestore/Auth/Storage MCP operation.
