# AI usage notes

## Tools and models

- **Cursor** (Agent mode) with Composer for planning and implementation
- **XcodeBuildMCP** available in the environment (not used to build/run — local build/test done by the author)
- No separate Claude Code / Copilot session for this submission

## Agent instruction files

Committed to the repo:

- [`AGENTS.md`](AGENTS.md) — standing instructions for agents working in this repository (stack, seams, do-nots)

## Plan / spec

A written plan was produced before implementation covering:

- Stack choice (SwiftUI iOS + Node.js/TypeScript)
- Ports-and-adapters architecture for product source, look-and-feel, and email
- Stable API contract (so Fake Store shape never reaches the client)
- Assumptions on ranking, search, category split, and console email
- File layout for `backend/` and `ios/`
- Test strategy (vitest + Swift Testing against stubs)

## Key prompts / moments that shaped the solution

1. **“Implement the assignment; choose stack and record assumptions.”**  
   Drove the plan: iOS + Node, computed top-rated, console email, no Docker.

2. **“Do not call Fake Store from the client; foundation must grow.”**  
   Locked in `ProductRepository` / `EmailProvider` ports and a mapper that renames `image` → `imageUrl`.

3. **“Don’t try running or building — I will build and test.”**  
   Scoped agent work to writing code and docs only; verification left to the author.

4. **“MD files should not say the code is unbuilt/untested.”**  
   README / DECISIONS written as the finished submission narrative.

5. **“Code only — no git remote / PR setup.”**  
   Agent left repository hosting and the open PR to the author.

## Where the AI got something wrong (and how it was caught)

1. **URL construction in `APIClient`**  
   An early draft mixed `appendingPathComponent` with a discarded `URLComponents` assignment. Caught on static review; rewritten to join base path + endpoint path via `URLComponents` only.

2. **Config.xcconfig location**  
   First draft put `Config.xcconfig` inside the synchronized `Catalogue/` group *and* referenced it from the project root, which would confuse membership. Caught while writing the project file; config now lives next to the `.xcodeproj`, with Info.plist still inside the app folder.

3. **Nested `navigationDestination` recursion**  
   An early `RootView` recursively attached destinations per pushed screen. Simplified to one destination closure per `NavigationStack` so category → product → enquire pushes stay on the same stack.

4. **Over-claiming verification in docs**  
   A draft plan note would have put “unbuilt / untested” into README. Corrected before docs were written so the submission matches the author’s build/test pass.
