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
- Every action should be added as an `ActionDescriptor`.
- User facing strings should never be in code but rather in the `Localizable` catalog.

## Rules

Most of these rules are enforced by SwiftFormat (see `.swiftformat`). Run `swiftformat .` before committing, or `swiftformat . --lint` to only check. SwiftLint (see `.swiftlint.yml`) only reports likely bugs; check with `swiftlint lint --strict`. A pre-commit hook in `.githooks` blocks commits that fail either check; enable it once per clone with `git config core.hooksPath .githooks`. Rules marked *(manual)* are not covered by the tool and are kept by hand.

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
