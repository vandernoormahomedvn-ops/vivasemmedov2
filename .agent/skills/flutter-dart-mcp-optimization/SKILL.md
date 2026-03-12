---
name: flutter-dart-mcp-optimization
description: Specialized workflows for auditing, fixing, and optimizing Flutter and Dart projects using the Dart MCP server.
---

# Flutter & Dart MCP Optimization Skill (Router)

**Role:** Expert Flutter/Dart Performance Engineer & Code Auditor.

## How to execute this skill (Progressive Context Loading)

You **MUST NOT** guess or hallucinate performance rules or Dart 3 features. For every task related to optimizing, fixing, or auditing Flutter code, follow these rigid steps and read the required context ONLY when you need it:

### Step 1: Automated Analysis & Baseline
1.  Use `analyze_files` to get a project-wide baseline of errors/warnings.
2.  Run `dart_fix` for quick, safe syntax updates (e.g., adding `const`).
3.  For dependency issues, use the `pub` tool (`outdated`, `upgrade`).

### Step 2: Deep Optimization & Dart 3 Features
If you are refactoring widgets for performance, modernizing code to Dart 3, or addressing complex architectural bottlenecks identified in Step 1:
👉 **READ NEXT:** [`references/dart3_optimizations.md`](references/dart3_optimizations.md)

---
> [!TIP]
> Always verify optimizations by running the app (`launch_app`) and using DTD tools (`get_runtime_errors`, `get_widget_tree`, `get_app_logs`) to ensure you haven't introduced regressions.

> [!WARNING]
> COMPULSORY RULE / REGRA OBRIGATÓRIA: Sempre que escrever ou modificar código Flutter ou Dart, DEVE obrigatoriamente utilizar as `mcp_dart-mcp-server` tools disponíveis (como `mcp_dart-mcp-server_analyze_files`, `mcp_dart-mcp-server_dart_fix`, `mcp_dart-mcp-server_dart_format`) para validar a sintaxe e evitar erros antes de considerar a tarefa finalizada.

> [!IMPORTANT]
> Always verify that the Flutter SDK is on the correct channel (e.g., beta for latest features) if MCP tools encounter environment issues.
