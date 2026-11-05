# Agent instructions — Product Catalogue

Standing guidance for AI agents working in this repository.

## Goal

Ship a small product catalogue that can grow: iOS client + Node.js backend, Fake Store behind the backend only, enquiry email via a swappable provider.

## Stack

- **Client:** SwiftUI, iOS 17+, Swift 6, `@Observable` view models
- **Backend:** Node.js, TypeScript, Express, zod, vitest
- **Do not** call Fake Store (or any product upstream) from the iOS app

## Architecture rules

1. Keep boundaries clear: `ios/` talks only to our HTTP API; `backend/` owns Fake Store and email.
2. Preserve ports:
   - `ProductRepository` for catalogue data
   - `EmailProvider` for enquiry delivery
   - iOS `CatalogService` protocol for the app’s data access
3. Never leak Fake Store field names (`image`, etc.) in the public JSON — map to our contract (`imageUrl`, `categorySlug`, …).
4. Look-and-feel changes go through `DesignSystem/Theme` and shared components, not hardcoded styles in feature screens.
5. Inject dependencies into `createApp` / `AppContainer` so tests use fakes/stubs.

## Acceptance criteria to protect

- Home: 5 featured (top-rated) products
- Category: top-rated + additional products for that category
- Search: explicit search action; text match only
- Product detail from a tile
- Enquire → email to sales + Thank you UI

## Do not

- Commit secrets (use `.env.example` / `Config.xcconfig.example`)
- Add paid third-party services reviewers must sign up for
- Call Fake Store from the client
- Expand into auth, payments, or admin unless explicitly asked

## Docs to keep accurate

When behaviour or assumptions change, update `README.md`, `DECISIONS.md`, and `AI_USAGE.md` in the same change.
