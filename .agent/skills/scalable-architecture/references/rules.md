# Scalable Architecture Rules & Constraints

## Core Architecture Pattern (2025/2026)
We enforce **Clean Architecture** combined with a **Modular Feature-Based Structure**. Never build monolithic `/screens` or `/models` folders. Always isolate by feature (e.g., `features/delivery/`).

## Intentional State Management & Layers
### 1. Presentation Layer (UI & State)
- **UI Components**: Keep them "dumb" whenever possible. Hand over logic to state managers.
- **State Management**: Use Provider/Riverpod or BLoC explicitly for all business logic. Never scatter `setState` for global app states.

### 2. Domain & Service Layer
- **Centralized Services**: Abstract data fetching into services (e.g., `ContentService`).
- **Repositories**: Create repositories to sit between the Service and the raw Firebase/API calls.

## Yentelelo Data Structure Constraints

### Categories Hierarchy
- **Main Categories**: STRICTLY only `Yentelelo News` and `Y Training Academy`.
- **Subcategories**: All other categories must have `parent_ref` pointing to one of the Main Categories.
- **Fetching Strategy**:
  - Root Level: Query `categories` where `is_main == true`.
  - Drill Down: Query `categories` where `parent_ref == [SelectedCategoryRef]`.

### Content Organization
- **Series (Playlists)** (`playlists` collection): 
  - Must have `is_series: true` and a `category_ref`.
- **Episodes (Videos)** (`videos` collection): 
  - Must have `series_ref` pointing to Playlist and an `episode_number`.
- **Single Videos**: 
  - `series_ref` is NULL; directly linked to a `category_ref`.

### The Highlights Engine (Home Screen)
- The Home Screen feed is driven exclusively by the `highlights` collection.
- **NEVER** query `videos` directly to populate the main feed.
- Content must be mapped: `highlights` -> `video_ref` OR `associated_content_ref` (Series), ordered by `order`.

### Access Control
- Always verify `is_public` boolean. If false, check `allowed_plans` against user's active subscription before showing.
