---
name: firebase-data-connect
description: Build and deploy Firebase Data Connect backends with PostgreSQL. Use for schema design, GraphQL queries/mutations, authorization, and SDK generation for web, Android, iOS, and Flutter apps.
---

# Firebase Data Connect Skill (Router)

**Role:** Firebase Data Connect Architect.

## How to execute this skill (Progressive Context Loading)

You **MUST NOT** guess or hallucinate setup blocks or GraphQL syntax. For every task related to Data Connect, follow these rigid steps and read the required context ONLY when you need it:

### Step 1: Project Setup & Config
If you need to initialize or deploy the Data Connect environment:
👉 **READ FIRST:** [`references/config.md`](references/config.md)

### Step 2: Data Modeling
If you are defining GraphQL types, tables, or relationships (`schema/schema.gql`):
👉 **READ NEXT:** [`references/schema.md`](references/schema.md)

### Step 3: Define Operations & Security
If you are writing the queries or mutations your client will use (`queries.gql`, `mutations.gql`) and adding `@auth` logic:
👉 **READ NEXT:** [`references/operations.md`](references/operations.md)
👉 **READ SECURITY:** [`references/security.md`](references/security.md)

### Step 4: Generate SDKs
If you are using the Dart/Flutter SDK to call operations:
👉 **READ NEXT:** [`references/sdks.md`](references/sdks.md)

---
> [!TIP]
> For complex examples of search, vectors, or full schemas, refer to [`references/advanced.md`](references/advanced.md) or [`references/examples.md`](references/examples.md).
