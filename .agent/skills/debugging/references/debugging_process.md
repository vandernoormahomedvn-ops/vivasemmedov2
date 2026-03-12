# Debugging Workflow & Process

## Workflow

1.  **Capture Context**: Get the error message, stack trace, and recent code changes.
2.  **Reproduction**: Identification of steps to reproduce the issue.
3.  **Isolation**: Locate the specific failure point.
4.  **Fix**: Implement the minimal fix to resolve the core issue.
5.  **Verification**: Verify the solution works and doesn't introduce regressions.

## Debugging Process

- **Analyze**: Read error messages and logs carefully.
- **Check Changes**: Review recent commits or edits.
- **Hypothesize**: Form a theory about why it failed.
- **Log**: Add strategic debug logging if needed.
- **Inspect**: Check variable states and flow. Use `mcp_dart-mcp-server_analyze_files` for project-wide structural analysis.

## Common Bug Patterns

### 1. "Feature Not Working" — Missing Logic in Secondary Screens
When a feature (e.g., view count, like, save) works on some screens but not others:
- **Trace the full navigation path**: Home → Details → Player. Each screen is a separate widget with its own lifecycle.
- **Check if the logic exists in ALL screens** where the feature should work, not just the first one you find.
- **Example**: `_incrementViewCount()` existed only in `VideoPlayerWidget` but NOT in `VideoDetailsScreen` → views were never counted when users opened video details.

### 2. Firestore Data in Wrong Collection
When queries return empty despite data existing:
- **Check top-level vs subcollections**: Data might be in `playlists/{id}/videos` (subcollection) but the query targets `videos` (top-level).
- **`collectionGroup` needs Firestore rules**: `match /{path=**}/videos/{document}` rule is required.
- **Alternative**: Query parent collection first, then iterate subcollections.

### 3. Video Player Fullscreen Issues (Web)
- **Chewie on web uses Route-based fullscreen** → triggers `didPushNext` which can pause video.
- **`lazyLoad: true` skips `initialize()`** → causes black screen after exiting fullscreen.
- **`autoPlay: true` races with `seekTo()`** → video restarts instead of resuming.
- **`postFrameCallback` can run on disposed views** → use `Future.delayed` + `mounted` checks instead.

### 4. Firebase MCP Project Mismatch
- **MCP persists active project across conversations** → always verify with `firebase_get_environment` before any Firestore operation.
- **Use `/verify-firebase-mcp-project` workflow** before any Firebase MCP query.

## Output Requirements

For each issue, provide:
- **Root Cause**: Explanation of *why* it happened.
- **Evidence**: Logs or code snippets supporting the diagnosis.
- **Fix**: The specific code change.
- **Test**: How you verified the fix.
- **Prevention**: Recommendations to prevent recurrence.

> Focus on fixing the underlying issue, not just symptoms.
