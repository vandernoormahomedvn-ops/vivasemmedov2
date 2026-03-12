# Deploying to App Hosting from Source

This is the recommended flow for most users. 
1. Configure `firebase.json` with an `apphosting` block.
    ```json
    {
      "apphosting": {
        "backendId": "my-app-id",
        "rootDir": "/",
        "ignore": [
          "node_modules",
          ".git",
          "firebase-debug.log",
          "firebase-debug.*.log",
          "functions"
        ]
      }
    }
    ```
2. Create or edit `apphosting.yaml`- see `references/configuration.md` for more information on how to do so.
3. If the app needs safe access to sensitive keys, use `firebase apphosting:secrets` commands to set and grant access to secrets.
4. Run `firebase deploy` when you are ready to deploy.
