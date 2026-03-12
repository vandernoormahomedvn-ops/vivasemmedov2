# Firebase Basics: Setup and Workflow

### Prerequisites: Node.js and npm
To use the Firebase CLI, you need Node.js (version 20+ required) and npm (which comes with Node.js).
**Recommended: Use a Node Version Manager (nvm)**
This avoids permission issues when installing global packages.

1.  **Install nvm:**
    - Mac/Linux: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash`
    - Windows: Download [nvm-windows](https://github.com/coreybutler/nvm-windows/releases)
2.  **Install Node.js:**
    ```bash
    nvm install 24
    nvm use 24
    ```

**Alternative: Official Installer**
Download and install the LTS version from [nodejs.org](https://nodejs.org/).

## Core Workflow

### 1. Installation
Install the Firebase CLI globally via npm:
```bash
npm install -g firebase-tools
```
Verify installation:
```bash
firebase --version
```

### 2. Authentication
Log in to Firebase:
```bash
firebase login
```
- This opens a browser for authentication.
- For environments where localhost is not available (e.g., remote shell), use `firebase login --no-localhost`.

### 3. Creating a Project
To create a new Firebase project from the CLI:
```bash
firebase projects:create
```
You will be prompted to:
1. Enter a Project ID (must be unique globally).
2. Enter a display name.

### 4. Initialization
Initialize Firebase services in your project directory:
```bash
mkdir my-project
cd my-project
firebase init
```
The CLI will guide you through:
- Selecting features (Firestore, Functions, Hosting, etc.).
- Associating with an existing project or creating a new one.
- Configuring files (firebase.json, .firebaserc).

## Exploring Commands
The Firebase CLI documents itself. Instruct the user to use help commands to discover functionality.
- **Global Help**: List all available commands and categories. `firebase --help`
- **Command Help**: Get detailed usage for a specific command. `firebase deploy --help`

## Common Issues
- **Permission Denied (EACCES)**: If `npm install -g` fails, suggest using a node version manager (nvm) or `sudo` (caution advised).
- **Login Issues**: If the browser doesn't open, try `firebase login --no-localhost`.
