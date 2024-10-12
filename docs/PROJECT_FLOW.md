# Project Flow Documentation

This document describes the branching strategy, commit message conventions, and linear history maintenance for this project to ensure consistency and clarity across all contributions.

---

## :open_file_folder: Branching Strategy

The project follows a **branch-based workflow** to organize features, fixes, and releases efficiently. Below is the branching strategy to be followed:

### Branch Types

- **`main`**  
  - Contains the latest stable release code.
  - Only merged after review and passing tests.
  - No direct commits allowed.

- **`develop`**  
  - Tracks ongoing development work.
  - Feature branches are merged here after approval.
  - Regularly rebased from `main` to keep it up-to-date.

- **`feature/{feature-name}`**  
  - Used for working on individual features.
  - Branch naming convention: `feature/login-ui` or `feature/integration-x-api`.

- **`bugfix/{issue-number}-{description}`**  
  - Dedicated for bug fixes.
  - Example: `bugfix/42-login-issue`.

- **`release/{version}`**  
  - Tracks release preparation (e.g., `release/1.0.0`).
  - Bug fixes and last-minute adjustments merged here.

- **`hotfix/{issue-number}-{description}`**  
  - Used for critical, time-sensitive patches to the `main` branch.
  - Example: `hotfix/99-crash-on-launch`.

---

### :card_index_dividers: Difference Between `develop` and `main`

The **`develop`** and **`main`** branches serve distinct roles in the project:

- **`main` Branch:**  
  - **Purpose:** Holds the latest **stable, production-ready code**.  
  - **Usage:** Reflects the **live version** of the project. Only tested changes are merged here, typically via release branches or hotfixes. Direct commits are not allowed.

- **`develop` Branch:**  
  - **Purpose:** Acts as the **integration branch** for new features and fixes.  
  - **Usage:** Aggregates work from feature branches and may contain unstable code. Code is tested here before being merged into `main`.

### Key Differences

| Aspect                | `main`                                  | `develop`                                 |
|-----------------------|-----------------------------------------|-------------------------------------------|
| **Purpose**           | Production-ready code                   | Ongoing development and integration       |
| **Stability**         | Always stable and deployable            | May contain unstable or incomplete code   |
| **Direct Commits**    | Not allowed (except hotfixes)           | Allowed but discouraged                   |

This strategy helps maintain a **stable production environment** while allowing flexibility for development.

---

## :bookmark_tabs: Commit Message Conventions

Consistent commit messages help with clear versioning and history tracking. The following format ensures that every commit is meaningful.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>  # Optional but recommended
<footers>  # Optional: references issues or breaking changes
```

#### **Examples:**
- `feat(auth): add login page UI`
- `fix(api): correct endpoint URL for orders`
- `docs(readme): update installation instructions`

### **Commit Types:**
- **feat:** A new feature
- **fix:** A bug fix
- **docs:** Documentation changes only
- **style:** Code style improvements (e.g., formatting)
- **refactor:** Code changes that neither fix a bug nor add a feature
- **test:** Adding or improving tests
- **chore:** Routine tasks like dependency updates

### **Scope:**  
Optional but recommended. Indicates the area of the codebase affected (e.g., `auth`, `ui`, `api`).

### **Subject:**  
A short summary (imperative form, present tense) describing the change.

---

## :arrows_counterclockwise: Linear History and Merge Strategy

### **Linear History:**
To maintain a clean and linear Git history, we use **rebasing** rather than merging for feature branches. This ensures that all commits are orderly and follow a chronological sequence.

1. **Always rebase your branch** on the latest `develop` or `main` branch:
   ```
   git checkout feature/my-new-feature
   git fetch origin
   git rebase origin/develop
   ```

2. **Resolve conflicts** if any appear during the rebase:
   ```
   # After resolving conflicts
   git add .
   git rebase --continue
   ```

3. **Force push** to update your branch (because history is rewritten):
   ```
   git push --force
   ```

---

## :rocket: Pull Requests and Merging Process

1. **Open a Pull Request (PR)**  
   - Target: `develop` for feature/bugfix branches  
   - Target: `main` for hotfixes

2. **Review Process:**  
   - At least one team member must review your PR.
   - Ensure all tests pass before requesting a review.

3. **Rebase if needed:**  
   If `develop` has progressed since you started your feature, **rebase** your branch before merging.

4. **Squash and Merge:**  
   Use **squash and merge** to ensure a linear history on the `develop` and `main` branches.

5. **Tagging Releases:**  
   For releases, the maintainer will tag the `main` branch:
   ```
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

---

## :hammer_and_wrench: Commands Summary

- **Create a branch:**
  ```
  git checkout -b feature/login-ui
  ```
  
- **Rebase your branch:**
  ```
  git rebase origin/develop
  ```

- **Squash commits:**
  ```
  git rebase -i HEAD~<n>
  ```

- **Push force after rebasing:**
  ```
  git push --force
  ```

---

## :clipboard: Best Practices

- **Commit frequently:** Make small, incremental commits with meaningful messages.
- **Keep PRs focused:** Avoid working on multiple issues in a single branch.
- **Update branches regularly:** Rebase frequently to avoid large merge conflicts.
- **Avoid direct commits to `main` or `develop`.** All changes should go through pull requests.
