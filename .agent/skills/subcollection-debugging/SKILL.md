---
name: subcollection-debugging
description: Patterns and checklist for diagnosing and fixing Firestore subcollection read/write mismatches, field name inconsistencies, and reference resolution failures. Use when features that interact with Firestore subcollections (comments, purchases, episodes) are broken.
---

# Subcollection Debugging Skill

## When to Activate
Trigger this skill when:
- Data is written but doesn't appear in the UI
- Features using Firestore subcollections (comments, likes, purchases, episodes) are broken
- `StreamBuilder` shows empty but docs exist in Firestore
- User reports "não funciona" for interactive features

## Root Cause Categories

### 1. Path Mismatch (Most Critical)
**Symptom**: Data written doesn't appear in StreamBuilder.

**Root Cause**: Write path differs from read path. Extremely common when documents live in **nested subcollections** (e.g., `playlists/{id}/videos/{videoId}`).

```dart
// ❌ WRONG — hardcoded root path
final docRef = FirebaseFirestore.instance
    .collection('videos')
    .doc(currentVideo.reference.id)  // ← only the ID, loses parent path
    .collection('comments')
    .doc();

// ✅ CORRECT — uses the actual reference
final docRef = currentVideo.reference.collection('comments').doc();
```

**Why**: `currentVideo.reference.id` returns the same document ID regardless of where the video lives. But `FirebaseFirestore.instance.collection('videos').doc(id)` always points to the root `videos/` collection, not `playlists/{x}/videos/{id}`.

**Detection command**:
```bash
grep -rn "FirebaseFirestore.instance.collection(" lib/ --include="*.dart" | grep -v "collectionGroup"
```
Any result that manually constructs a subcollection path instead of using `.reference.collection()` is suspicious.

### 2. Field Name Mismatch
**Symptom**: Query returns empty results or crashes silently.

**Root Cause**: Dart model uses one field name, but query uses another.

```dart
// Model: snapshotData['createdAt']
// Query: .orderBy('created_time') ← WRONG field name

// Fix: Use the same name everywhere
.orderBy('createdAt', descending: true)
```

**Detection command**:
```bash
# Find all orderBy/where clauses and compare with model
grep -rn "orderBy\|where(" lib/ --include="*.dart" | grep "comment\|Comment"
grep -rn "snapshotData\[" lib/backend/schema/comments_record.dart
```

### 3. Unresolved References
**Symptom**: UI shows placeholder text (e.g., "Utilizador") instead of real data.

**Root Cause**: `DocumentReference` fields (like `userRef`) need to be fetched separately.

```dart
// ❌ WRONG — hardcoded placeholder
Text('Utilizador')

// ✅ CORRECT — resolve the reference
FutureBuilder<DocumentSnapshot>(
  future: comment.userRef?.get(),
  builder: (context, snapshot) {
    String name = 'Utilizador'; // fallback
    if (snapshot.hasData && snapshot.data!.exists) {
      final data = snapshot.data!.data() as Map<String, dynamic>;
      name = data['displayName'] ?? data['display_name'] ?? name;
    }
    return Text(name);
  },
)
```

### 4. Duplicate StreamBuilders
**Symptom**: Higher-than-expected Firestore reads, slow performance.

**Root Cause**: Multiple `StreamBuilder` widgets subscribing to the same collection independently.

```dart
// ❌ Two separate StreamBuilders for count and list
StreamBuilder(...) → count header
StreamBuilder(...) → comments list

// ✅ Single StreamBuilder that feeds both
StreamBuilder<List<CommentsRecord>>(
  stream: singleStream,
  builder: (context, snapshot) {
    final comments = snapshot.data ?? [];
    return Column(children: [
      Text('Comentários ${comments.length}'),
      // ... list ...
    ]);
  },
)
```

## Debugging Checklist
1. [ ] Identify ALL files that read/write to the subcollection
2. [ ] Verify READ path matches WRITE path exactly
3. [ ] Verify field names in queries match model's `_initializeFields()`
4. [ ] Verify `DocumentReference` fields are resolved in UI
5. [ ] Check for duplicate `StreamBuilder` subscriptions
6. [ ] Query Firestore via MCP to verify data location
7. [ ] Run `dart analyze` — 0 errors
8. [ ] Hot restart / relaunch and test

## Related Workflows
- `/debug-subcollection-features` — step-by-step execution workflow
