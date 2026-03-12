# Firebase MCP Productivity & Scalability Workflows

## Workflows

### 1. Rapid Project Context & Inspection (Productivity)
Use these tools to instantly understand the environment:
- **`firebase_get_environment`**: Check the active user, project directory, and current project context.
- **`firebase_get_project`**: Retrieve detailed metadata about the active project (ID, name, resources).
- **`firebase_list_apps`**: List all registered apps (Web, Android, iOS) to ensure alignment with your codebase.
- **`read_resource`**: Access live config or data using `firebase://` URIs. 
    - Example: `read_resource(uri="firebase://projects/YOUR_PROJECT_ID/databases/(default)/documents/users/USER_ID")` to read Firestore data directly.

### 2. Scalable App Management
When adding new platforms or scaling the application:
- **Create Apps via MCP**: Instead of using the console, use `firebase_create_app`.
    - Example: `firebase_create_app(platform="android", android_config={"package_name": "com.example.app"})`
    - This ensures the app is registered correctly and you get the App ID immediately for config.
- **Fetch SDK Config**: Use `firebase_get_sdk_config` to get the exact configuration object needed for your frontend (web) or mobile app (google-services.json/plist content).
    - This avoids copy-paste errors from the console.

### 3. Troubleshooting & Error Resolution
When deployment fails or permissions are denied:
- **Inspect Live Rules**: Use `firebase_get_security_rules` to see what is *actually* deployed, not just what's in your local file.
    - Compare local `firestore.rules` with the output of `firebase_get_security_rules(type="firestore")`.
- **Verify Init Status**: If features are missing, use `firebase_init` to enable services (Firestore, Storage, Hosting) directly in the workspace.
- **Check Resource State**: Use `read_resource` to verify if a specific document or storage path exists and is accessible.

## Best Practices
- **Always verify environment first**: Run `firebase_get_environment` before making changes to ensure you are targeting the correct project.
- **Use `firebase_init` for new features**: It sets up the correct local configuration files (`firebase.json`, `.firebaserc`) automatically.
- **Leverage `firebase_get_sdk_config`**: This is the source of truth for connecting your app. Never hardcode API keys if you can fetch them dynamically or verify them with this tool.
- **Full-Stack Alignment**: Use the `flutter-dart-mcp-optimization` skill to ensure your Flutter frontend is optimized and correctly implementing the Firebase SDK patterns identified here.
