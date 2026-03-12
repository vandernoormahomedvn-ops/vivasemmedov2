# Project Maintenance & Cleanup Workflows

## Workflows

### 1. Log and Temporary File Cleanup
- **Identify**: Locate files with extensions like `.log`, `.tmp`, or `.bak`.
- **Remove**: Use `run_command` with `rm` to delete unnecessary files from the root.
    - Example: `rm *.log` (After verification).
- **Automate**: Ensure automated build logs are directed to a specific `logs/` directory (ignored by git) rather than the root.

### 2. Dependency Hygiene
- **Check**: Run `dart pub outdated` via MCP to find stale dependencies.
- **Prune**: Use `dart pub remove` for packages no longer used in the project.

### 3. File System Organization
- **Structure**: Ensure new code follows the established directory structure (e.g., `lib/core`, `lib/screens`).
- **Nomenclature**: Fix inconsistent file naming (e.g., mixing camelCase and snake_case in file names).

## Best Practices
- **Verify before Delete**: Always list files before running a bulk delete command.
- **Git Awareness**: Ensure critical configuration files are not accidentally deleted or ignored.
- **Consistency**: Keep the root directory clean. Only essential configuration files (e.g., `pubspec.yaml`, `firebase.json`) should reside there.

> [!WARNING]
> Be extremely careful when using recursive delete commands. Always target specific extensions or directories.
