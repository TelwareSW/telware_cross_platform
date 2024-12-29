# Coding Guidelines

To ensure consistency and maintainability across the project, please follow these coding standards:

## General Guidelines

- Write clean and readable code.
- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.
- Avoid hardcoding values; use constants or configuration files.
- Ensure all code changes are tested before committing.

## File and Folder Organization

- Group related files together (e.g., components, screens, services).
- Keep files small and focused; a single file should ideally handle one responsibility.
- Use descriptive and consistent file and folder names in `snake_case`.

## Naming Conventions

- **Classes**: Use `PascalCase` (e.g., `UserModel`, `MainScreen`).
- **Variables**: Use `camelCase` (e.g., `userName`, `isLoggedIn`).
- **Constants**: Use `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`).

## Code Comments

- Write meaningful comments explaining the “why” behind the logic, not the “what.”
- Document all public methods and classes using DartDoc.
  ```dart
  /// Calculates the total price of items in the cart.
  double calculateTotalPrice(List<Item> items) {
    ...
  }
  ```

## Flutter-Specific Guidelines
- Use widgets efficiently; prefer `const` constructors where possible.
- Separate business logic from UI using patterns like Provider, or Riverpod.
- Avoid nesting widgets deeply; extract them into reusable components.

## Git Commit Guidelines
- Use descriptive commit messages (e.g., `feat: add login functionality`).
- Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

## Code Reviews
- All pull requests must be reviewed and approved before merging.
- Address all comments from reviewers before marking a PR as ready.

By adhering to these guidelines, we ensure a high standard of quality and a codebase that's easier to maintain and scale.