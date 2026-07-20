# iOS Development Guide

How the app is wired **in this repo**. The portable SwiftUI rules — state ownership, primitive-first
leaves, never leaving a CTA silent — live in
[swiftui-best-practices.md](./swiftui-best-practices.md); this document is Bazar's implementation
of them.

## Tech stack

| Piece | Choice |
|-------|--------|
| Target | iOS 26.0, Swift 6, strict concurrency `complete` |
| Project | XcodeGen — `ios/project.yml` is the source of truth, `ios/Bazar.xcodeproj` is generated |
| Bundle id / team | `co.polyforms.bazar` / `46C337T7YN` |
| UI | SwiftUI, native iOS 26 components (Liquid Glass — no custom re-skins) |
| Data | Apollo iOS 1.18, generated into `ios/Bazar/Generated/GraphQL` |
| Auth / push | Firebase Auth (Sign in with Apple), Firebase Messaging |

Because the project is generated, **never add files through Xcode's UI**: create the file on disk
and, if a new folder appeared, re-run XcodeGen (`xcodegen generate` in `ios/`). Adding a source
path to `project.yml` is only needed for a new top-level group.

## Project structure

```
ios/Bazar/
├── BazarApp.swift              # @main — hands off to AuthRoot
├── ContentView.swift           # the TabView: Accueil, Objets, Scanner, Lieux
├── Features/{Feature}/
│   ├── {Feature}API.swift      # the mapping boundary: GraphQL → model types
│   ├── {Feature}ViewModel.swift
│   ├── {Feature}View.swift     # coordinator — navigation, sheets, .task
│   └── components/
│       ├── pages/              # pure presentation, data in / closures out
│       ├── organisms/
│       ├── molecules/
│       └── atoms/
├── Shared/
│   ├── GraphQLClient.swift     # ApolloClient + interceptor chain
│   ├── GraphQLHelpers.swift    # fetch/perform bridges, ISO8601, GraphQLNullable
│   ├── FirebaseTokenInterceptor.swift
│   ├── ModelTypes.swift        # the app's own model structs
│   ├── Components/atoms/       # cross-feature atoms
│   └── DebugGallery.swift      # #if DEBUG — render any page with fixtures
└── Generated/GraphQL/          # Apollo codegen output (committed)
```

Features: `Items`, `Locations`, `Scan`, `Search`, `Dashboard`, `Reminders`, `Notifications`,
`Auth`.

## Data fetching — GraphQL, not REST

### The client

`Shared/GraphQLClient.swift` builds the singleton `ApolloClient` against
`SharedConfig.serverURL + /graphql`, with two custom interceptors around Apollo's default chain:

1. `FirebaseTokenInterceptor` — injects `Authorization: Bearer <Firebase ID token>` on every
   request. There is no static API token in the app.
2. `GraphQLLoggingInterceptor` — logs the operation name and any GraphQL error code.

`SharedConfig.serverURL` defaults to the deployed Cloud Run URL and can be overridden through the
`serverURL` `UserDefaults` key to point at a local `bun run dev`.

### The async helpers

`GraphQLHelpers.fetch` / `.perform` bridge Apollo's callbacks to `async throws`, and — this is the
part that matters — **turn a non-empty `errors` array into a thrown `APIError.graphQL`**. A
GraphQL response with both data and errors is a failure, not a partial success.

`GraphQLHelpers.graphQLNullable(_:)` converts a Swift optional to Apollo's `GraphQLNullable`;
`parseISO8601(_:)` parses the `DateTime` scalar with or without fractional seconds.

### The feature API enum — the mapping boundary

`Features/{Feature}/{Feature}API.swift` is the **only** place generated Apollo types are allowed
to appear. It maps them to the app's own structs from `Shared/ModelTypes.swift` and back:

```swift
enum GraphQLItemsAPI {
    static func list(category: String? = nil, …) async throws -> ItemListPage {
        let data = try await GraphQLHelpers.fetch(client, query: BazarGraphQL.ItemListQuery(…))
        return ItemListPage(items: data.items.items.map(ItemListItem.init(from:)), …)
    }
}
```

Nothing above this boundary — no ViewModel, no view — imports `BazarGraphQL`. That is what keeps
a schema change from rippling into the UI, and what makes previews possible without a server.

The `.graphql` operation files live next to the feature (`Features/{Feature}/GraphQL/*.graphql`)
and are listed in `ios/apollo-codegen-config.json`. A new folder there means a new entry in that
config.

### Model types

The structs on the app side of that boundary live in `Shared/ModelTypes.swift`. They are
`Sendable` — Swift 6 strict concurrency crosses them between the API actor and the `@MainActor`
ViewModel — and `Identifiable` when a list renders them. They carry the shape the UI needs, not
the shape the schema returns: flattening (`locationFullPath`, `placeName`) and derived counts are
computed once during the mapping, never recomputed in a view body.

```swift
struct ItemListItem: Identifiable, Sendable {
    let id: String
    let name: String
    let category: ItemCategory
    let locationFullPath: String?   // flattened from the nested location payload
}
```

Optionality here mirrors GraphQL nullability, and stops there: an absent value is `nil`, and the
view decides what to show for it.

## Feature pattern

### ViewModel — `@MainActor @Observable`

One `@MainActor @Observable final class` per feature, holding the state the screens read and the
`load` / `loadMore` / mutation methods. Models it exposes are `Sendable` value types.

- **Single-flight**: guard re-entrancy (`guard !isLoading`) so a `.task` plus a `.refreshable`
  don't fire twice.
- **Stale responses**: when a filter can change mid-flight, bump a `generation` token and drop
  responses that don't match it.
- **Errors are a `String?`** rendered by the view, produced by `reportError(_:)`. Never a silent
  `try?`.

### Coordinator (`{Feature}View.swift`) vs page (`…Page.swift`)

The **coordinator** owns the `NavigationStack`, the sheets, `.task` / `.refreshable`, the
ViewModel, and every network call. The **page** is pure: data in, closures out — no networking, no
navigation state, no ViewModel.

```swift
struct ItemsView: View {                       // coordinator
    @State private var model = ItemsViewModel()
    var body: some View {
        NavigationStack {
            ItemsPage(groups: model.groupedItems, isLoading: model.isLoading,
                      onLoadMore: { await model.loadMore() })
                .task { await model.load() }
                .refreshable { await model.load() }
        }
    }
}
```

## Atomic design

| Layer | Location | Receives |
|-------|----------|----------|
| **Atoms** | `Shared/Components/atoms/` | Primitives — cross-feature (`AsyncToolbarButton`) |
| **Molecules** | `Features/{F}/components/molecules/` | Primitives (`ItemRow`, `ReminderRow`) |
| **Organisms** | `Features/{F}/components/organisms/` | Primitives, or one model struct at the mapping boundary |
| **Pages** | `Features/{F}/components/pages/` | Data + closures |

Promote a molecule used by two features up into `Shared/Components/`.

### Primitive-first leaf views

A leaf view takes `String`, `Int`, `Bool`, `Date?`, a logic-free enum (`ItemCategory`) or a
closure — **never** a generated Apollo type, and not a whole model struct when it reads three
fields. When a component needs five or more parameters, give it a nested `Item` struct and do the
mapping in the page:

```swift
struct StatRow: View {
    struct Item: Identifiable {
        let id = UUID()
        let label: String
        let count: Int
        var highlighted: Bool = false
    }
    let items: [Item]
}
```

The struct is nested inside the view on purpose: it is that component's input shape, not a shared
model, and nesting keeps it from drifting into `ModelTypes.swift`.

## CTA + network — never a silent wait

The rule is in
[swiftui-best-practices.md](./swiftui-best-practices.md#a-cta-that-fires-a-network-call-never-waits-in-silence).
In this app:

| Shape | Here |
|-------|------|
| Inline spinner in a toolbar button | `Shared/Components/atoms/AsyncToolbarButton.swift` — owns its `isInProgress`, ignores re-taps |
| Optimistic + background | Item deletion: the sheet closes at once, the mutation follows, a failure surfaces on the next reload |

`.disabled(…)` alone is never enough: a disabled button with no spinner reads as a broken app.

## Sheet toolbar CTAs — icons, never text

A sheet's toolbar actions always use an SF Symbol with an `.accessibilityLabel`, never a text
label: `xmark` to close, `checkmark` to confirm. Pushed pages and tab roots keep the platform's
standard text actions.

## Hide empty sections

A `Section` with no data is not rendered at all — no empty-state text, no placeholder. An empty
section reads as broken.

## Previews as a storybook + DebugGallery

Every component below page level **must** preview without a running server, fed by shared
fixtures. `Shared/DebugGallery.swift` (wrapped in `#if DEBUG`) renders any page with those
fixtures, no server and no auth, and `BazarApp` branches into it when the `-gallery <screen>`
launch argument is set.

**After finishing any iOS task, launch the result in the simulator on your own** — never ask
first. Build, install, then launch straight into the affected screen and screenshot it before
reporting:

```bash
xcrun simctl launch booted co.polyforms.bazar -gallery items
```

If the touched screen has no `switch` case in `DebugGallery.swift` yet, add one. This is distinct
from installing on the physical iPhone, which always requires an explicit yes.

## Language

Identifiers, file names, comments and accessibility **identifiers** are English. French is for
what the user reads: labels, titles, accessibility *labels*, preview names. See
[code-style.md](./code-style.md#language).

## Auth — Firebase + Sign in with Apple

`Features/Auth/` owns the whole flow: `AuthRoot` gates the app on a signed-in user, `LoginView`
runs Sign in with Apple, `AppleNonce` generates the nonce Firebase requires, `AuthSession` holds
the session. Every GraphQL request then carries the Firebase ID token through the interceptor.
Portal-side setup: [apple-sign-in.md](./apple-sign-in.md).

## Push notifications

`Shared/NotificationManager.swift` requests authorisation and surfaces the FCM token;
`NotificationSubscriber.swift` sends it to the backend (`subscribeToNotifications`) and
unsubscribes on sign-out. The only push today is the low-stock crossing — see
[business-rules.md](./business-rules.md#quantity-low-stock-and-the-crossing).

## Apollo codegen

```
bun run generate:graphql   # backend → shared/schema.graphql
bun run generate:ios       # schema + .graphql operations → Generated/GraphQL
```

Both outputs are committed. Never hand-edit anything under `Generated/`.

## Build

```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project ios/Bazar.xcodeproj -scheme Bazar \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
```

`DEVELOPER_DIR` is required because `xcode-select` points at the Command Line Tools.
