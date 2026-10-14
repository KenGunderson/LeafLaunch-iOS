# Customer workflow contract

The user brief, [AGENTS.md](AGENTS.md), and [implementation guide](docs/IMPLEMENTATION_BEST_PRACTICES.md) govern this mobile milestone. Backend contracts are the sibling API's `storeAppConfiguration`, `storeLocation`, `locationProductListing`, `promotion`, `event`, `customerAccount`, and `customerLocationMembership` modules. Web transport models corroborate the wire format; owner/portal permissions do not apply to customers.

| Capability | Canonical owner | Behavior |
| --- | --- | --- |
| Launch | RootStartupService and StoreSessionService | Resolve optional existing auth, refresh public bootstrap, validate location, and apply theme before dismissing splash. Show recoverable configuration/failure states. |
| Target identity | BusinessConfig and target xcconfig | A dedicated target selects one business, public app key, logo, and bundle. No customer tenant picker. |
| Theme | UserDefaultsService and StoreThemeBuilder | Restore a valid tenant-specific Codable theme definition before splash. Refresh branding from bootstrap; corruption falls back to built-in Rune styling. |
| Location navigation | StoreSessionService | Validate cached location through the public API and current bootstrap list. A failed cached selection returns to the list. One available location without a cached selection bypasses the list. |
| Age modal | AgeVerificationScreen and StoreSessionService | Required gate blocks store content and cannot be dismissed. Affirmation is persisted per identity and state. Guest approval never approves another account. |
| Store tabs | TabBarNavigationService and StoreDetailsScreen | Store overview, Shop, Favorites, Account. Each owns its navigation path; location changes reset paths and create fresh feature ViewModels. |
| Search/filter | StoreShopViewModel | Search and parent/subcategory selections replace results, cancel superseded work, and reset pagination. Search offers clear and submit controls. |
| Catalog paging/sort | StoreShopViewModel | Featured products use explicit load-more and server metadata. Sorting loads all matching pages before applying a client menu order because the API has no sorting parameter. |
| Favorites | UserDefaultsService | Local, tenant-specific product IDs; shared publisher keeps feed, details, and favorites consistent for guests and signed-in customers. |
| Account | AuthService and StoreAccountViewModel | Browsing stays available without registration. Firebase auth bridges to actual CustomerAccount endpoints. Loyalty reads require an authenticated account and location membership. |
| Forms and Select/Listbox | Native SwiftUI controls | Native TextField, SecureField, Picker, Button, and Link behavior. Existing app components cover actions. |
| Loading/errors | Owning ViewModel and injected AlertService | Focused ViewModel helpers present errors directly; no `.errorHandler`. Async tasks show/dismiss their own unique Rune loading alert. Loading, empty, failure, and retry are explicit; cancellation cannot present an error or stale result. |
| Scrollbar and Date | Native SwiftUI/Foundation | Platform scrolling indicators and date controls; no custom browser scrollbar or date implementation. |

Approvals retain the requested `[userId: [state]]` shape. The API currently supplies business-wide `age_gate_required`, `minimum_age`, and `age_gate_version`, without a state policy. It cannot express a new per-state rule or invalidate a previously approved state without an additional policy contract.

The public bootstrap also omits the full Store/business object and radius tokens. Screens show the provided public business name and actual location details; they do not call protected owner endpoints or synthesize missing business records. See [customer architecture](docs/CUSTOMER_ARCHITECTURE.md) for target configuration, endpoint mappings, and remaining backend work.

Verification for this milestone is source inspection, Swift syntax parsing, Foundation model typechecking, plist validation, explicit target membership, and whitespace checks. Builds, tests, simulator interaction, and finished visual review require a later authorized validation pass.
