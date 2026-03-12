# Firebase Authentication Core Concepts

Firebase Authentication provides backend services, easy-to-use SDKs, and ready-made UI libraries to authenticate users to your app.

### Users

A user is an entity that can sign in to your app. Each user is identified by a unique ID (`uid`) which is guaranteed to be unique across all providers.
User properties include:
- `uid`: Unique identifier.
- `email`: User's email address (if available).
- `displayName`: User's display name (if available).
- `photoURL`: URL to user's photo (if available).
- `emailVerified`: Boolean indicating if the email is verified.

### Identity Providers

Firebase Auth supports multiple ways to sign in:
- **Email/Password**: Basic email and password authentication.
- **Federated Identity Providers**: Google, Facebook, Twitter, GitHub, Microsoft, Apple, etc.
- **Phone Number**: SMS-based authentication.
- **Anonymous**: Temporary guest accounts that can be linked to permanent accounts later.
- **Custom Auth**: Integrate with your existing auth system.

Google Sign In is recommended as a good and secure default provider.

### Tokens

When a user signs in, they receive an ID Token (JWT). This token is used to identify the user when making requests to Firebase services (Realtime Database, Cloud Storage, Firestore) or your own backend.
- **ID Token**: Short-lived (1 hour), verifies identity.
- **Refresh Token**: Long-lived, used to get new ID tokens.
