# Security Workflows & Best Practices

## Workflows

### 1. Firebase Rules Validation
- **Inspect**: Use `mcp_firebase-mcp-server_firebase_get_security_rules` to retrieve live rules.
- **Validate**: Use `mcp_firebase-mcp-server_firebase_validate_security_rules` before deploying new rules.
- **Deny by Default**: Ensure rules follow a "deny all" pattern unless explicitly allowed.
    - *Poor*: `allow read, write: if true;`
    - *Better*: `allow read: if request.auth != null;`

### 2. Secret Management
- **Protection**: Never commit API keys directly to public repositories.
- **Environment Variables**: Use `.env` files or platform-specific secret management (e.g., Firebase Remote Config or GCP Secrets).
- **Censorship**: Proactively check for hardcoded secrets in code audits.

### 3. Data Integrity
- **Validation**: Ensure all write operations are validated on the backend/Firestore rules, not just the frontend.
- **Privacy**: Implement data masking for sensitive fields in user profiles.

## Best Practices
- **Audit Regularly**: Periodically review Firestore rules to ensure no "leaks" were introduced.
- **Use Multi-Factor**: Encourage the use of SMS or Email MFA where appropriate via Firebase Auth.
- **Least Privilege**: Grant users and services only the permissions they absolutely need.

> [!CAUTION]
> Open security rules (e.g., those allowing public writes) are a critical vulnerability and must be addressed immediately.
