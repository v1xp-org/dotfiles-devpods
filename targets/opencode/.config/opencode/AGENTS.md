# Global Agent Rules

## Context-First Approach

Before making any changes to a codebase, ALWAYS:

1. Check if `graphify-out/GRAPH_REPORT.md` exists in the project root
   - If yes: read it first to understand the codebase structure
   - If no: run `graphify .` to generate the knowledge graph, then read the report
2. Use `graphify query` to explore specific parts of the codebase before editing
3. Read relevant files directly only after graphify has oriented you

## Graph Query Patterns

When exploring a codebase, use these graphify queries in order:

```
graphify query "show the main entry points" --graph graphify-out/graph.json
graphify query "show the architecture and module relationships" --graph graphify-out/graph.json
graphify query "show the data flow for [feature]" --graph graphify-out/graph.json
```

## Code Quality Standards

- Write tests BEFORE implementation (TDD)
- Keep functions small and focused (< 50 lines)
- Use meaningful variable and function names
- Never leave commented-out code in commits
- Run tests before considering any task complete

## Security

- Never commit secrets, API keys, or credentials
- Never log sensitive data
- Use environment variables for configuration
- Validate all user inputs

## Communication

- Be concise in responses
- Explain WHY you made changes, not just WHAT
- When uncertain, ask before proceeding
- Report errors clearly with context

## Git Conventions

- Use conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Keep commits atomic and focused
- Write meaningful commit messages
