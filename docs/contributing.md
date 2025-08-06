# Contributing Guide

Thank you for your interest in contributing 🎉

## Setup

1. Clone the repo
2. Create a virtual environment
3. Run `make setup`
4. Start the dev server with `make runserver`

## Branching

- Create a feature branch for your work:
  ```bash
  git checkout -b feature/my-feature

````

## Testing

* Run all tests with:

  ```bash
  make test
  ```
* For faster iteration without coverage:

  ```bash
  make test-fast
  ```

## Code Style

* Pre-commit hooks enforce:

    * `black` for formatting
    * `isort` for import sorting
    * `flake8` for linting

Run manually:

```bash
make lint
```

## Releasing

* Bump version and push with:

  ```bash
  make ship
  ```
