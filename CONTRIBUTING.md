#  Contributing

## Guidelines

The following guidelines form the basis of every contributed code:

- **Simplicity**: Code should only be as complex as necessary while being as simple as possible. Prefer maintainable solutions over clever ones.
- **Maintainability**: Maintainability and code cleanliness should be the top priority for any contributed code.
- **Consistency**: Code should be consistent with existing code in terms of patterns and style.
- **Canonicality**: Prefer canonical, recommended or industry-standard solutions over highly specific, custom ones.

## Hints

What follows are less important hints for contributed code:

- Every UI view should have at least one sensible preview.
- Every action should be added as an `Action`.
- User facing strings should never be in code but rather in their target's `Localizable` catalog (see Structure).

## Rules

Most of these rules are enforced by SwiftFormat (see `.swiftformat`). Run `swiftformat .` before committing, or `swiftformat . --lint` to only check. SwiftLint (see `.swiftlint.yml`) only reports likely bugs; check with `swiftlint lint --strict`. A pre-commit hook in `.githooks` blocks commits that fail either check; enable it once per clone with `git config core.hooksPath .githooks`. Rules marked *(manual)* are not covered by the tool and are kept by hand.

### Structure

The app and its extensions share one local package, `Modules`, with two libraries. The dependencies only point one way: the app and the extensions depend on both libraries, `FormworkUI` on `FormworkKit`, and `FormworkKit` on neither. *(manual)*

- `FormworkKit` holds everything that isn't a view: models, statistics, storage and the parts of features the app and extensions share, like intents.
- `FormworkUI` holds the design system: views and styles that know nothing about exercises, workouts or statistics, and `Action`.
- The app holds everything that knows the domain and is shown on screen.

Code lives where its narrowest user is. A view used by one feature stays in that feature and moves to `Components` once a second feature uses it, not before. *(manual)*

| Folder | Holds |
| --- | --- |
| `Formwork/Features/<Feature>` | Screens (`…Screen`), forms (`…Form`) and the views only they use. A feature is a tab or a flow, and a screen belongs to the feature of what it shows. |
| `Formwork/Components/<Topic>` | Views used by several features, grouped by domain, e.g. `Exercise` or `Statistics`. |
| `Formwork/Support` | App-wide plumbing that isn't a feature: navigation, haptics, debug tools, extensions. |
| `FormworkKit/Models/<Model>` | SwiftData models and the value types they're made of. |
| `FormworkKit/Statistics` | Everything worked out from models: histories, statistics and trends. Statistics are sorted by the protocol they conform to: `Charts/` (`Statistic`), `Indicators/` and `Metrics/`. |
| `FormworkKit/Formats` | Format styles that turn models and values into text, for any view to apply. |
| `FormworkKit/Features/<Feature>` | The non-view parts of a feature that several targets need. |
| `FormworkKit/Support` | Infrastructure: storage, schema, samples, constants, extensions. |
| `FormworkUI/Components/<Kind>` | Domain-agnostic building blocks: content, input, layout, navigation, styles. |
| `FormworkUI/Support` | Environment values and view extensions. |

- Folders that collect several things are plural (`Features/Workouts`); a model's own folder is singular (`Models/Workout`). The same name means the same thing in every target. *(manual)*
- Each target has its own `Localizable` catalog. `FormworkKit`'s names concepts, like kinds, categories and statistics; words that only exist because of a screen, like actions or headings, go into `FormworkUI`'s or the app's. *(manual)*

### Declarations

- The type body describes the shape of a type only: enum cases, nested types, stored properties and the designated initializer.
- Behaviour goes into extensions: computed properties, convenience initializers, functions, and every conformance whose members are written by hand (`Identifiable`, `Comparable`, …) gets its own `extension Type: Protocol`. *(manual)*
- Synthesized conformances (`Codable`, `Hashable`, `Sendable`, `CaseIterable`, raw values) stay on the declaration, and so does `View`. *(manual)*
- Access control is written on each member, never on an extension. A `public extension` makes every new member public by default; file-local helpers use `fileprivate` on each member.
- A nested type that grows substantial logic moves into its own file named `Parent+Child.swift`. *(manual)*

### Ordering

Members of a class, struct or enum are declared in the following order. The order applies separately to the type body and to each extension, so extensions can still group members by topic.

```
Enum cases
Nested types and type aliases

// Stored properties
public static let
public static var
internal static let
internal static var
private static let
private static var

public let
public var
internal let
internal var
private let
private var

// Initializers
public init
internal init
private init

// Computed properties
public static var
internal static var
private static var

public var            // view-building properties (body, some View) first
internal var
private var

// Functions
public static func
internal static func
private static func

public func           // functions returning some View first
internal func
private func
```

- Static members precede instance members within each group, since they belong to the type rather than to an instance.
- Among instance computed properties and instance functions, the ones that build views come first, so a view reads from `body` down to its helpers.
- Property-wrapped properties (`@State`, `@Environment`, `@Query`, …) are stored properties and follow the same order, so a view's inputs precede its state.
- `let` precedes `var` within the same group. *(manual)*
- Within the same group, SwiftUI property wrappers go from what the view reads to what it owns: `@Environment` and `@ScaledMetric`, then `@Query`, then `@AppStorage`, then `@State`, then `@FocusState` and `@Namespace`. Other attributes, such as `@Relationship`, are not ordered. *(manual)*
- `fileprivate` members count as `private`.
- Subscripts count as functions.

### Formatting

- The body of a `guard` always goes on its own line, never `guard … else { return }` on one line.
- Every member is surrounded by a blank line, properties included. Enum cases are the exception and stay without blank lines between them. *(manual)*
- Every attribute goes on its own line, stacked when there are several:

```swift
@Environment(\.dismiss)
private var dismiss: DismissAction

@MainActor
@Observable
final class Foo {}
```

### Layout

- Screens put their content in `ScrollView { ContentStack { … } }`. `ContentStack` gives every child the screen margin, and only content that has to reach the screen edges, like a swipeable list, opts out with `.edgeToEdge()`. Views never add the screen margin themselves. *(manual)*
- `SectionView` applies the margin to its header and content itself, so a list inside a section can use `.edgeToEdge()` too.
- Every vertical `ScrollView` keeps its last content clear of the tab bar and bottom bars with `.contentMargins(.bottom, .sections, for: .scrollContent)`. Sheets without a toolbar use `.vertical` instead, since no navigation bar leaves room at the top. *(manual)*
- Structural spacing uses the named values: `.sections` (32) between sections, `.groups` (16) between groups inside a card and between the sections of a compact sheet, `.items` (8) between sibling cards or tiles and below a header. Spacing inside a single component stays a literal. *(manual)*
- Styles like `.groupBoxStyle(.card)` and `.labeledContentStyle(.row)` are set by the view that creates the styled views, on the smallest container around them, never once at the app root. That way every view and its preview look right on their own. *(manual)*
