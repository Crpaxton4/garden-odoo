# Contributing

Both internal and external contributors are welcome. All contribution happens through GitHub issues and pull requests.

For what this project is and what it covers, see [README.md](README.md).

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
- **Reviews:** 1 approving review required; code-owner approval required
- **Threads:** all review threads must be resolved
- **Stale reviews:** dismissed automatically on new push
- **Last push:** must be approved before merge
- **Commits:** must be signed (GPG or SSH)

---

## Dev Environment

This project uses a [devcontainer](https://containers.dev/) for a consistent development environment.

### Quick start

1. Install [Docker](https://docs.docker.com/get-docker/) and [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Open the repo in VS Code and select **Reopen in Container**.
3. The container provides Odoo 19.0, PostgreSQL 17, and all dev tooling pre-installed.

See [README.md](README.md) for full details.

---

## Testing

Every PR must include tests appropriate to its change:

| Type                      | When to use                                                        |
| ------------------------- | ------------------------------------------------------------------ |
| Python unit tests         | Model logic, ORM behavior, business rules                          |
| JS OWL unit tests         | OWL component behavior                                             |
| JS tour integration tests | End-to-end user flows                                              |
| Bash tooling tests        | Devcontainer tool availability, config correctness, service health |

---

## Code Quality & Security

PRs are gated on automated checks. Do not attempt to bypass them.

- **CodeQL** — blocked on high-or-higher security alerts and scanning errors
- **Code quality** — blocked on code quality errors
- **PostToolUse hooks** — automatically lint changed files and validate configuration consistency after every AI-assisted edit (see `.github/hooks/post-edit.json`)
