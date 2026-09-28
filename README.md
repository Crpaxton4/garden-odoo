# garden-odoo

Odoo 19.0 implementation and customization to run a market garden from seed to sale — fresh produce and derivative goods.

Built for a two-person operation. The priority is automation: the system tells users what to do and when, minimizing manual steps. This is a human-in-the-loop solution, not a traditional ERP interface.

## Status

**Pre-development / planning.** No modules have been released yet.

The first module, `garden_product_seasonality` (planting windows, growing time, sun/water/soil requirements), installs on Odoo 19 but is not released.

## Scope

This solution will cover the following business domains:

| Domain                        | Description                                                 |
| ----------------------------- | ----------------------------------------------------------- |
| Crop Planning                 | Seed selection, planting schedules, field/bed allocation    |
| Growth Tracking & Forecasting | Growth stage monitoring, yield predictions                  |
| Inventory & Resupply          | Stock levels, reorder rules for inputs and finished goods   |
| Lot/Serial Tracking           | Traceability for perishable goods from harvest through sale |
| Quality                       | Inspection and grading workflows                            |
| Processing / Value-Add        | Transforming raw produce into derivative products (PLM)     |
| Costing                       | Full cost tracking including labor for N employees          |
| Ecommerce                     | Online storefront for direct-to-consumer sales              |
| Farmers Market Sales          | POS and order management for market-day operations          |
| Shipping                      | Delivery scheduling and fulfillment                         |
| CRM                           | Customer relationships, leads, and retention                |
| Accounting                    | Financial management and reporting                          |
| Marketing                     | Email, SMS, social marketing, and automation                |
| Blog                          | Content publishing                                          |
| Surveys                       | Customer and operational feedback                           |
| Appointments                  | Scheduling for farm visits, pickups, consultations          |
| Planning                      | Resource and task scheduling                                |
| Document Management           | Centralized file storage and organization                   |

## Tech Stack

- **Odoo** 19.0
- **Python** 3.12
- **License** AGPL-3.0

## Layout

- `src/` — Odoo modules; this is the container's `addons_path`
- `devops/` — devcontainer lifecycle hooks, the Bash tooling test suite (`devops/tests/run_all.sh`) and the mutation-testing wrapper (`devops/ray_gun.sh`)
- `.devcontainer/` — Dockerfile, Compose file and Odoo config for the dev environment
- `.github/workflows/` — CI: code quality, CodeQL, devcontainer image build

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (Docker Desktop or Docker Engine)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Setup

1. Clone this repository.
2. Open the repo in VS Code.
3. When prompted, click **Reopen in Container** — or run the command palette action `Dev Containers: Reopen in Container`.
4. Wait for the container build and lifecycle hooks to complete. This installs all dev dependencies and initializes the Odoo database.

The container provides:

- **Odoo 19.0** (community) on port `8069`
- **PostgreSQL 17** database
- Python virtualenv with dev tools (black, isort, pylint, coverage, cosmic-ray)
- Node.js with JS tooling (eslint, prettier, stylelint)
- Pre-configured launch configs for Python debugging, OWL debugging, and Odoo shell

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming, PR rules, and testing requirements.

## Links

- [Contributing](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [License](LICENSE)
