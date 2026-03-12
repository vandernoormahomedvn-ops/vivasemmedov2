# Dart 3 & Flutter Performance Optimizations

## General Workflow & Best Practices
- **Analyze before Fixing**: Run `analyze_files` to grasp the scope before using `dart_fix`. Address high-severity Build Errors before styling lints.
- **Leverage DTD**: When the app is running, use DTD-connected tools (`get_widget_tree`, `get_runtime_errors`) for real-time debugging.
- **Check Dependencies**: Always keep packages updated and verify alignment using `pub` subcommands.

## Dart 3 Specific Guidelines
1. **Strong Typing & Avoid `dynamic`**: Strong typing aids the compiler. Avoiding `dynamic` in hot paths prevents runtime overhead and enables function inlining.
2. **Immutability FIRST**: 
   - Use `const` variables and constructors religiously. This reduces memory allocation and relieves garbage collection.
   - Use `final` where `const` isn't possible.
3. **Minimize Object Creation**: Avoid recreating objects inside `build()` methods or loops. Reuse objects or cache them.
4. **Asynchronous Efficiency**: Offload heavy CPU work from the main UI isolate using `compute` or `Isolate.run()`.

## Flutter Performance Best Practices
1. **Widget Rebuilds**:
   - Extract complex UI parts into smaller `StatelessWidget` classes instead of helper methods. This localizes `setState` updates.
   - Prefer `ValueNotifier` or provider selectors to update specific widgets instead of calling `setState` on the whole screen.
2. **Layout & Painting**:
   - Use `SizedBox` instead of `Container` for simple padding to skip unnecessary painting passes.
   - For heavily animating UI elements (like a continuously updating loading bar), wrap them in a `RepaintBoundary` to prevent the rest of the screen from repainting.
3. **List Rendering**:
   - Always use `ListView.builder` or `SliverList` for long data arrays. Never use a `Column` with `map()` for large datasets.
