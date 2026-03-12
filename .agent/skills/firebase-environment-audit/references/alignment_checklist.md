# Firebase Alignment Checklist

Follow this checklist to ensure your environment is healthy and synchronized.

## 1. App Code vs. CLI Sync
Always verify that the `PROJECT_ID` inside your app's configuration matches the current Firebase CLI project.

- **Check iOS**: View `ios/Runner/GoogleService-Info.plist` -> Look for `<key>PROJECT_ID</key>`.
- **Check Android**: View `android/app/google-services.json` -> Look for `"project_id"`.
- **Check CLI**: Run `firebase_get_environment` and check `active_project`.

> [!IMPORTANT]
> If these do not match, any rules you deploy will go to the WRONG project, and any Auth/Firestore calls from the app will fail on the RIGHT project.

## 2. Rule Deployment Validation
Before deploying rules:
1. Run `firebase use <correct-project-id>`.
2. Check that `firebase.json` is in the current directory and points to the right `firestore.rules`.
3. Use the MCP tool `firebase_get_security_rules` to see what is *already* live.

## 3. Auth & Firestore Consistency
If Auth works but Firestore fails:
- Check if the ID token is synchronized: `credential.user!.getIdToken(true)` in Flutter.
- Verify the collection name exists in the Rules: If the rule mentions `match /users/{id}` but you write to `/user/{id}`, it will be denied.

## 4. Common Mismatch Scenarios
- **The "Legacy" Trap**: You are accidentalyl deploying rules from an old project (e.g., Yentelelo) to a new project (e.g., Flexpress). Always check `firebase.json`.
- **The "Multi-Project" Trap**: You have access to many Firebase projects. Verify `active_project` every time you restart work.
