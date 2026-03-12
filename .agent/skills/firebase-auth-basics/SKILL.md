---
name: firebase-auth-basics
description: Guide for setting up and using Firebase Authentication. Use this skill when the user's app requires user sign-in, user management, or secure data access using auth rules.
compatibility: This skill is best used with the Firebase CLI, but does not require it. Install it by running `npm install -g firebase-tools`.
---

# Firebase Authentication Skill (Router)

**Role:** Firebase Authentication Specialist.

## How to execute this skill (Progressive Context Loading)

You **MUST NOT** guess or hallucinate setup blocks or SDK APIs. For every task related to Authentication, follow these rigid steps and read the required context ONLY when you need it:

### Step 1: Core Concepts & Setup
If you need to understand how Firebase Auth handles users, tokens, and identity providers, or if you need to provision/setup Auth via rules and CLI:
👉 **READ FIRST:** [`references/core_concepts.md`](references/core_concepts.md)
👉 **THEN READ:** [`references/provisioning.md`](references/provisioning.md)

### Step 2: Client Integration (Web)
If you are implementing the login UI, sign-up flows, or checking auth state in a web application:
👉 **READ NEXT:** [`references/client_sdk_web.md`](references/client_sdk_web.md)

### Step 3: Security
To protect your Firestore or Storage data based on the authenticated user:
👉 **READ FINALLY:** [`references/security_rules.md`](references/security_rules.md)
