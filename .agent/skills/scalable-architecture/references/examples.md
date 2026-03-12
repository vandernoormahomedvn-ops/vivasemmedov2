# Scalable Architecture: Good vs Bad Examples

## Example 1: Fetching Feed Content

### [BAD] (Direct UI Monolith)
Violates the Highlights Engine rule, mixes UI with data fetching, and relies directly on the UI framework for data logic.
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('videos').get(), // BAD: Querying videos directly, bypassing Highlights.
      builder: (context, snapshot) {
         // UI rendering mixed tightly with direct DB calls.
      }
    );
  }
}
```

### [GOOD] (Service Layer & Highlights Engine)
Separates concerns, utilizes the correct Highlights collection, and prepares data for the UI state manager.
```dart
// 1. Service Layer
class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Highlight>> getHomeFeed() async {
    // GOOD: Querying Highlights engine as dictated by architecture rules
    final snapshot = await _firestore.collection('highlights').orderBy('order').get();
    return snapshot.docs.map((doc) => Highlight.fromMap(doc.data())).toList();
  }
}

// 2. View Model / Provider (State Management)
class HomeViewModel extends ChangeNotifier {
   final ContentService _service;
   List<Highlight> feed = [];

   Future<void> loadFeed() async {
      feed = await _service.getHomeFeed();
      notifyListeners();
   }
}

// 3. Dumb UI
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final feed = context.watch<HomeViewModel>().feed;
    return ListView.builder(
       itemCount: feed.length,
       itemBuilder: (context, index) => HighlightCard(highlight: feed[index]),
    );
  }
}
```
