# Decisions and assumptions

## Assumptions (where the acceptance criteria were unclear)

1. **"5 products chosen to be top rated"**  
   Not hand-curated. Computed from Fake Store ratings: sort by `rating.rate` desc, then `rating.count` desc, then `id` asc. Limit defaults to 5 (`FEATURED_LIMIT`). A curated override list is the natural next step once merchandising exists.

2. **Category page sections**  
   “Top rated for that category” = top 3 by the same ranking (`CATEGORY_TOP_RATED_LIMIT`). Remaining products in the category are returned as `others` so the UI can render two sections. Fake Store only has ~5 products per category, so “others” is often empty — the API shape still supports growth.

3. **Search**  
   Case-insensitive substring match over **title, description, and category**, executed on the backend. Triggered by an explicit Search button (and keyboard submit), matching the acceptance criteria rather than live-as-you-type.

4. **Enquiry email**  
   Default provider is **console** (prints to the backend stdout). That satisfies “sales inbox will receive an email” for a reviewer with zero accounts. `EMAIL_PROVIDER=smtp` switches to nodemailer. The customer sees an in-app “Thank you” screen with a reference UUID.

5. **Category URLs**  
   Fake Store categories contain spaces/apostrophes (`men's clothing`). They are slugified to `mens-clothing` for API paths; the display name stays the original string.

6. **Currency**  
   Fake Store prices are treated as USD in the UI.

7. **Auth / accounts**  
   Out of scope for the MVP. Enquiries are anonymous contact forms.

## Requirements dropped or simplified

| Item | Decision | Why |
| --- | --- | --- |
| Docker / AWS deploy | Not included | Mobile brief only requires a local backend + Simulator. Docker would be untested overhead here. |
| Real email / SES | Console default; SMTP optional; SES not built | Paid/account-gated services are disallowed for reviewers. SES is documented as the AWS path for later. |
| Pagination UI | API supports `limit`/`offset`; UI loads full small sets | Fake Store has 20 products — pagination UI would be speculative. |
| Offline / persistence | None | PoC focus is the critical browse → enquire path. |
| Custom branding / design system polish | Tokenised Theme only | Look-and-feel is expected to change; tokens are the seam, not a finished brand. |
| Hand-curated featured list | Computed ranking | No merchandising tool yet; ranking is transparent and testable. |

## How the design grows beyond the PoC

The brief calls out three things that will change. Each has an explicit seam:

```
iOS views  →  CatalogService protocol  →  RemoteCatalogService
                                            StubCatalogService (tests)

HTTP routes → CatalogService / EnquiryService
                 ↓                    ↓
         ProductRepository      EmailProvider
                 ↓                    ↓
     FakeStoreProductRepository   ConsoleEmailProvider
     (future: DB / CMS)           SmtpEmailProvider
                                  (future: SesEmailProvider)
```

- **Product data source** — swap `FakeStoreProductRepository` for a DB/CMS adapter. The HTTP JSON contract (`imageUrl`, `categorySlug`, etc.) stays stable; Fake Store’s `image` field never leaks to clients.
- **Look and feel** — iOS screens compose `Theme` tokens and shared components (`ProductTile`, `RemoteImage`). A redesign replaces tokens/components without rewriting feature view models.
- **Email provider** — implement `EmailProvider` (e.g. AWS SES). `EnquiryService` and the route stay unchanged.
- **Backend testability** — `createApp({ catalogService, enquiryService })` injects dependencies; vitest uses in-memory fakes, not Fake Store.

## What I would do with another day

1. Wire a curated featured-product override (config or admin list) on top of ranking.
2. Add an AWS SES `EmailProvider` and a minimal CDK/CloudFormation sketch for API deploy.
3. Add snapshot/UI tests for critical screens and a contract test that pins the OpenAPI-shaped responses.
4. Replace in-memory full-catalogue cache with paginated upstream calls once a real catalogue API exists.
5. Polish empty/error states and Dynamic Type / VoiceOver passes.
