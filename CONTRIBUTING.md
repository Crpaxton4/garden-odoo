# Contributing

Both internal and external contributors are welcome. All contribution happens through GitHub issues and pull requests.

For what this project is, how the repo is laid out and how to set up the dev environment, see [README.md](README.md).

---

## Communication

All discussion happens through GitHub issues. There is no mailing list, chat, or direct contact channel.

- **Bug reports** — open an issue with steps to reproduce
- **Feature requests** — open an issue describing the use case and expected behavior
- **Questions** — open an issue

---

## Branch Naming

Branches must use one of these prefixes. Any other name is rejected by the repository ruleset.

| Prefix      | Use for                                    |
| ----------- | ------------------------------------------ |
| `feature/`  | New functionality                          |
| `bugfix/`   | Bug fixes                                  |
| `docs/`     | Documentation changes                      |
| `test/`     | Test additions or changes                  |
| `refactor/` | Code restructuring with no behavior change |

---

## Pull Requests

All changes go through a PR targeting `main`. Direct pushes are blocked.

- **Merge method:** squash only
- **Reviews:** none required; the sole maintainer merges their own work
- **Threads:** all review threads must be resolved
- **Checks:** CodeQL and Code Quality must pass
- **Commits:** must be signed (GPG or SSH)

---

## Testing

Every PR must include tests appropriate to its change:

| Type                      | When to use                                                        |
| ------------------------- | ------------------------------------------------------------------ |
| Python unit tests         | Model logic, ORM behavior, business rules                          |
| JS OWL unit tests         | OWL component behavior                                             |
| JS tour integration tests | End-to-end user flows                                              |
| Bash tooling tests        | Devcontainer tool availability, config correctness, service health |

Run the Bash tooling tests with `bash devops/tests/run_all.sh` (add `--ci` to skip the service checks).

---

## Code Quality & Security

PRs are gated on automated checks. Do not attempt to bypass them.

- **CodeQL** — blocked on high-or-higher security alerts and scanning errors
- **Code Quality** — black, isort, ESLint, Prettier, Stylelint and markdownlint must pass
- **Devcontainer Image** — the image must build and the Bash tooling tests must pass when `.devcontainer/`, `devops/` or the dependency files change
