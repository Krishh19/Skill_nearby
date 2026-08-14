# Contributing to SkillNearby

Thank you for your interest in contributing to SkillNearby! 🎉

SkillNearby is an open-source neighbourhood skill-sharing platform that helps people discover, exchange, and share skills with people nearby.

We welcome contributions of all kinds — code, documentation, bug reports, feature ideas, testing, UI/UX improvements, and feedback.

## Table of Contents

* [Before You Start](#before-you-start)
* [Ways to Contribute](#ways-to-contribute)
* [Development Setup](#development-setup)
* [Project Structure](#project-structure)
* [Making Changes](#making-changes)
* [Code Quality](#code-quality)
* [Testing](#testing)
* [Commit Messages](#commit-messages)
* [Pull Requests](#pull-requests)
* [Issues](#issues)
* [Code of Conduct](#code-of-conduct)
* [Questions](#questions)

## Before You Start

Before making a contribution:

1. Check the existing issues and pull requests to see whether the work is already being discussed.
2. For larger changes, open an issue first so the proposed approach can be discussed.
3. Keep changes focused. A pull request should ideally address one problem or feature.
4. Make sure your changes do not expose secrets, API keys, credentials, or private configuration.

## Ways to Contribute

You can contribute to SkillNearby in many ways:

* Fix bugs
* Add new features
* Improve existing features
* Improve UI/UX
* Improve accessibility
* Add or improve tests
* Improve documentation
* Fix typos or broken links
* Improve performance
* Review pull requests
* Report bugs
* Suggest new ideas
* Improve developer tooling and automation

You do not need to be an expert to contribute.

## Development Setup

### Prerequisites

Before starting development, make sure you have:

* Flutter SDK installed
* Dart SDK compatible with the project
* Git installed
* Android Studio or another suitable Flutter development environment
* A Supabase project for backend development

### Clone the Repository

```bash
git clone https://github.com/Krishh19/Skill_nearby.git
cd Skill_nearby
```

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

Connect an Android device or start an Android emulator and run:

```bash
flutter run
```

### Analyze the Project

Before submitting changes, run:

```bash
flutter analyze
```

Fix any analyzer errors introduced by your changes.

## Project Structure

SkillNearby is organized around a feature-oriented Flutter architecture.

When adding a new feature:

* Keep feature-specific code within the appropriate feature/module.
* Reuse existing services and utilities where possible.
* Avoid introducing duplicate implementations.
* Keep UI, state management, data access, and business logic appropriately separated.

Before making architectural changes, please open an issue to discuss the proposed approach.

## Making Changes

Create a new branch for your work.

For example:

```bash
git checkout -b fix/profile-loading
```

or:

```bash
git checkout -b feature/skill-search
```

Use descriptive branch names such as:

* `feature/<description>`
* `fix/<description>`
* `docs/<description>`
* `refactor/<description>`
* `test/<description>`

Avoid making changes directly on the `main` branch.

## Code Quality

Please follow the existing coding conventions in the project.

In particular:

* Write clear and maintainable Dart code.
* Prefer small, focused functions and widgets.
* Reuse existing components when appropriate.
* Avoid unnecessary dependencies.
* Handle loading, error, and empty states appropriately.
* Avoid hard-coded credentials or secrets.
* Do not commit `.env` files or private keys.
* Keep user data and authentication information secure.

Before submitting a pull request, run:

```bash
flutter analyze
```

and:

```bash
flutter test
```

when applicable.

## Testing

New features and bug fixes should include tests where practical.

When fixing a bug, consider adding a regression test that prevents the issue from returning.

At minimum, verify that:

* The application builds successfully.
* Existing functionality continues to work.
* The changed feature works as expected.
* `flutter analyze` passes.
* Relevant tests pass.

## Commit Messages

Use clear and descriptive commit messages.

Examples:

```text
feat: add skill search filters
fix: resolve profile loading error
docs: improve contribution guide
test: add swap request tests
refactor: simplify authentication service
```

Keep commits focused on a single logical change whenever possible.

## Pull Requests

When your changes are ready:

1. Push your branch to your fork or repository.
2. Open a pull request against the `main` branch.
3. Clearly describe what you changed.
4. Explain why the change is needed.
5. Include screenshots or screen recordings for UI changes when useful.
6. Mention relevant issues using GitHub issue references such as `Closes #123`.
7. Make sure required checks pass before requesting review.

### Pull Request Checklist

Before submitting a pull request, verify:

* [ ] The change is focused and necessary.
* [ ] The code follows the existing project conventions.
* [ ] I have tested my changes locally.
* [ ] `flutter analyze` passes.
* [ ] Relevant tests pass.
* [ ] I have not committed secrets or credentials.
* [ ] Documentation has been updated if necessary.
* [ ] Screenshots or recordings are included for significant UI changes.

Maintainers may request changes before a pull request can be merged.

## Issues

Before opening an issue, search existing issues to make sure the problem or suggestion has not already been reported.

### Bug Reports

A useful bug report should include:

* A clear description of the problem.
* Steps to reproduce it.
* Expected behaviour.
* Actual behaviour.
* Flutter/Dart version when relevant.
* Device or emulator information when relevant.
* Relevant logs or screenshots.

Please remove private information, API keys, tokens, and other sensitive data before posting logs.

### Feature Requests

Feature requests should explain:

* What problem the feature solves.
* Who would benefit from it.
* How the proposed feature could work.
* Any alternatives you considered.

Not every feature request will necessarily be accepted. The project aims to keep SkillNearby focused on its core purpose.

## Code of Conduct

By participating in SkillNearby, you agree to follow the project's [Code of Conduct](CODE_OF_CONDUCT.md).

Please be respectful, constructive, and considerate when communicating with other contributors.

## Questions

If you are unsure about something, open a GitHub issue or discussion rather than making a large change based on assumptions.

Thank you for helping make SkillNearby better! ❤️
