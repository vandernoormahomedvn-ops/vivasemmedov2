# Firebase AI Logic Setup & Initialization

### Prerequisites

- Before starting, ensure you have **Node.js 16+** and npm installed. Install them if they aren’t already available. 
- Identify the platform the user is interested in building on prior to starting: Android, iOS, Flutter or Web.
- If their platform is unsupported, Direct the user to Firebase Docs to learn how to set up AI Logic for their application (share this link with the user https://firebase.google.com/docs/ai-logic/get-started)

### Installation

The library is part of the standard Firebase Web SDK.

`npm install -g firebase@latest`

If you're in a firebase directory (with a firebase.json) the currently selected project will be marked with "current" using this command:  

`firebase projects:list`

Ensure there's at least one app associated with the current project 

`firebase apps:list`

Initialize AI logic SDK with the init command

`firebase init # Choose AI logic`

This will automatically enable the Gemini Developer API in the Firebase console.

More info in [Firebase AI Logic Getting Started](https://firebase.google.com/docs/ai-logic/get-started.md.txt)

## Initialization Code References

| Language, Framework, Platform | Gemini API provider | Context URL |
| :---- | :---- | :---- |
| Web Modular API | Gemini Developer API (Developer API) | firebase://docs/ai-logic/get-started  |

**Always use gemini-2.5-flash or gemini-3-flash-preview unless another model is requested by the docs or the user. DO NOT USE gemini 1.5 flash**
