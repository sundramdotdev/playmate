# Contributing to PlayMate

Thank you for your interest in contributing to **PlayMate**! We are committed to building an open, welcoming, and high-quality offline game utility ecosystem.

---

## 🌿 Branching Strategy

We use a GitHub Flow-inspired branching workflow:

| Branch | Purpose | Protection Rules |
| :--- | :--- | :--- |
| `main` | Production-ready stable code. Matches latest release. | Protected. Requires 1 approving review and green CI checks. |
| `develop` | Active integration branch for upcoming releases. | Protected. All feature PRs merge here. |
| `feat/<name>` | New features or game utilities. | Created from `develop`. |
| `fix/<name>` | Bug fixes and UX corrections. | Created from `develop`. |
| `docs/<name>` | Documentation updates. | Created from `develop`. |
| `release/<vX.Y>`| Release stabilization and version bumps. | Created from `develop` and merged into `main` and `develop`. |

---

## 💬 Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```text
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Allowed Types:
- `feat`: A new user-facing feature or tool (e.g., `feat(dice): add D20 polyhedral option`).
- `fix`: A bug fix (e.g., `fix(cricket): prevent legal ball increment on wide balls`).
- `docs`: Documentation only changes (e.g., `docs(api): update analytics catalog`).
- `style`: Changes that do not affect code logic (formatting, missing semicolons).
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `perf`: A code change that improves performance or frame rate.
- `test`: Adding or correcting tests.
- `chore`: Maintenance tasks, dependency bumps, or build scripts.

---

## 🛠️ Local Development & Pre-Push Checklist

Before opening a pull request, run the following verification pipeline locally:

```bash
# 1. Format all Dart files
dart format --set-exit-if-changed lib test

# 2. Run static analysis
dart analyze --fatal-infos

# 3. Execute all unit and widget tests
flutter test

# 4. Ensure code generator files are up to date
dart run build_runner build --delete-conflicting-outputs
```

---

## 📥 Pull Request (PR) Workflow

1. **Fork & Branch:** Fork the repository and create your branch from `develop`.
2. **Atomic Commits:** Keep commits logically separated and well-described.
3. **Write Tests:** Accompany any new feature or bug fix with corresponding tests in `test/`.
4. **Open PR:** Submit your pull request targeting `develop`. Fill out the PR template:
   - What problem does this solve?
   - How was this tested?
   - Screenshots / Screen recordings (for any UI modifications).
5. **Code Review:** Address feedback promptly. Maintain a respectful, collaborative dialogue.

---

## 🐛 Reporting Issues

### Bug Reports
When filing an issue, please include:
- A clear, concise title.
- Device make, model, and OS version (e.g., Google Pixel 8, Android 14).
- Flutter version (`flutter --version`).
- Exact steps to reproduce the bug.
- Expected vs. actual behavior.
- Relevant logs or stack traces.

### Feature Requests
When requesting a new tool or expansion:
- Describe the physical game or real-world scenario where the tool is needed.
- Explain how the tool operates completely offline without internet dependencies.
- Outline proposed UI interactions.
