# Product Catalogue

iOS product catalogue (SwiftUI) backed by a Node.js/TypeScript API. Fake Store is used only on the server; the client never calls it. Enquiry email defaults to a console provider so reviewers need no paid accounts.

## Stack choice

| Layer | Choice | Why |
| --- | --- | --- |
| Client | **iOS (SwiftUI, Swift 6, iOS 17+)** | Matches a mobile PoC the entrepreneur can tap through on Simulator; `@Observable` view models and a `CatalogService` protocol keep UI and networking swappable. |
| Backend | **Node.js (TypeScript, Express)** | Fast to stand up, strong typing with zod, easy dependency injection for tests, and a natural path to AWS (Lambda/ECS later) without locking the client to Fake Store. |

Alternatives (React + Laravel, etc.) would also satisfy the brief; this pair optimises for a Simulator demo and clear ports for product data, email, and look-and-feel.

## Prerequisites

- **Node.js 20+**
- **Xcode 15+** (iOS Simulator)
- Network access so the backend can reach `https://fakestoreapi.com`

## Run locally (under 10 minutes)

### 1. Backend

```bash
cd backend
cp .env.example .env   # optional — defaults work for console email
npm install
npm run dev
```

API listens on **http://localhost:3000**. Health check: `GET /health`.

Enquiry emails print to the backend terminal when `EMAIL_PROVIDER=console` (default).

### 2. iOS app

1. Open `ios/Catalogue.xcodeproj` in Xcode.
2. Select an **iPhone simulator**.
3. Run (**⌘R**).

`ios/Config.xcconfig` sets `API_BASE_URL` to `http://localhost:3000`. To point elsewhere, edit that file (or copy from `Config.xcconfig.example`).

> Simulator → host machine: `localhost` reaches your Mac’s backend. Physical devices need your Mac’s LAN IP in `Config.xcconfig`.

### 3. Tests

```bash
cd backend && npm test
```

iOS: in Xcode, **Product → Test** (scheme `Catalogue`) — ViewModel tests use `StubCatalogService` (no network).

## API surface

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/health` | Liveness |
| GET | `/api/products/featured` | Top-rated products (`limit`, default 5) |
| GET | `/api/products` | List / search (`search`, `category`, `limit`, `offset`) |
| GET | `/api/products/:id` | Product detail |
| GET | `/api/categories` | Category list |
| GET | `/api/categories/:slug` | Top-rated + other products in category |
| POST | `/api/enquiries` | Submit enquiry (rate-limited) |

Public JSON uses our contract (`imageUrl`, `categorySlug`, …) — Fake Store field names are not exposed.

## Configuration

See [`backend/.env.example`](backend/.env.example) and [`ios/Config.xcconfig.example`](ios/Config.xcconfig.example). Do not commit real SMTP credentials.

| Variable | Role |
| --- | --- |
| `EMAIL_PROVIDER` | `console` (default) or `smtp` |
| `SALES_INBOX` | Destination address in the email payload |
| `FEATURED_LIMIT` / `CATEGORY_TOP_RATED_LIMIT` | Ranking cut-offs |
| `API_BASE_URL` (iOS) | Backend base URL |

## Docs

- [`DECISIONS.md`](DECISIONS.md) — assumptions, cuts, growth seams, next day
- [`AI_USAGE.md`](AI_USAGE.md) — tools, prompts, AI mistakes caught, **time spent**
- [`AGENTS.md`](AGENTS.md) — standing instructions for AI agents in this repo

## Time spent

About **3 hours** total — see the split in [`AI_USAGE.md`](AI_USAGE.md#time-spent).
