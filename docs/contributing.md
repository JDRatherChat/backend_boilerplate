# Contributing

Thank you for your interest in contributing.

## Getting Started

- Fork the repository and create a feature branch from `main`.
- Ensure your development environment is set up (see `docs/dev_setup.md`).
- Install pre-commit hooks:
  ```bash
  pre-commit install
  pre-commit run --all-files
  ```

## Branching and Commits

- Use short-lived feature branches: `feature/<short-description>`, `fix/<short-description>`.
- Write clear commit messages following the pattern:
  ```
  <type>(<scope>): <summary>

  <body>
  ```
  Examples of `<type>`: feat, fix, docs, style, refactor, test, chore.

## Code Style and Quality

- Format code with Black and isort.
- Lint with Flake8 and Ruff.
- Add or update tests for any change in behavior.
- Run the full test suite before opening a PR:
  ```bash
  pytest -q
  ```

## Pull Requests

- Keep PRs focused and small where possible.
- Describe the problem, the solution, and any alternatives considered.
- Include screenshots or logs when relevant.
- Ensure CI checks pass.

## Security

- Do not include secrets in code or commit history.
- Report security concerns privately to the maintainers.
