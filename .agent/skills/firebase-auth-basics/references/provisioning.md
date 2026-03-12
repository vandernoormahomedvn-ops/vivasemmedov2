# Firebase Authentication Provisioning

### Prerequisites

- **Firebase Project**: Created via `firebase projects:create` (see `firebase-basics`).
- **Firebase CLI**: Installed and logged in (see `firebase-basics`).

### Option 1. Enabling Authentication via CLI

Only Google Sign In, anonymous auth, and email/password auth can be enabled via CLI. For other providers, use the Firebase Console.

Configure Firebase Authentication in `firebase.json` by adding an 'auth' block:

```json
{
  "auth": {
    "providers": {
      "anonymous": true,
      "emailPassword": true,
      "googleSignIn": {
        "oAuthBrandDisplayName": "Your Brand Name",
        "supportEmail": "support@example.com",
        "authorizedRedirectUris": ["https://example.com"]
      }
    }
  }
}
```

### Option 2. Enabling Authentication in Console

Enable other providers in the Firebase Console.

1.  Go to the https://console.firebase.google.com/project/_/authentication/providers
2.  Select your project.
3.  Enable the desired Sign-in providers (e.g., Email/Password, Google).
