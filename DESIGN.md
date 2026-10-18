---
version: alpha
omitted:
  - section: colors
    reason: Store branding and Rune runtime themes own color values.
  - section: typography
    reason: Rune font roles preserve each store's configured font family.
  - section: spacing
    reason: LeafLaunchThemeTokens and the environment Rune style own spacing.
  - section: rounded
    reason: Validated store radius definitions and Rune own radius values.
  - section: components
    reason: Native SwiftUI and Rune component contracts are documented below.
---

# LeafLaunch customer storefront

## Overview

LeafLaunch is a native SwiftUI commerce app for the business assigned to its target. The design makes products, real prices, saved favorites, and store information easy to browse. Its signature interaction is a horizontal category pill rail with a second subcategory rail that reveals or replaces through a blur transition.

The skin is a construction system, not a fixed brand. Each store owns its appearance through Rune. Preserve the store's configured colors, fonts, radius roles, logo, and existing theme persistence. Product familiarity and clear actions take priority over decorative layouts.

## Colors

Rune is the only runtime styling authority. Production views read `@Environment(\.style)`; semantic Rune color sources and modifiers resolve that same environment. Outside the explicit promotion-caption, membership-card, and Store Info treatments below, do not introduce feature palettes, literal colors, gradients, `Style.shared` reads, or a second theme engine. Pass the environment style explicitly when an API such as `source(style:)` or `resolvedColor(style:)` requires color resolution.

The mapping remains:

`StoreAppBranding -> validated cached definition / StoreThemeBuilder -> Rune Theme -> environment style -> shared components`

[LeafLaunchLightTheme](LeafLaunch/Services/DesignSystem/LeafLaunchLightTheme.swift), [LeafLaunchDarkTheme](LeafLaunch/Services/DesignSystem/LeafLaunchDarkTheme.swift), [LeafLaunchThemeTokens](LeafLaunch/Services/DesignSystem/LeafLaunchThemeTokens.swift), and [LeafLaunchFonts](LeafLaunch/Services/DesignSystem/LeafLaunchFonts.swift) remain canonical fallback sources. This document defines composition, without duplicating their values. Cached branding restores synchronously before splash creation; the supported remote radius and font contracts remain intact.

The approved home reference has two fixed presentation treatments: promotion captions use white text over a black gradient fading from 85% opacity at the bottom to transparent at the top, and Store Info uses a full-width white background with black copy and pale gray icons (#CACFD2). Keep these local to their feature components; store branding and the surrounding UI continue to use Rune.

Use background.primary for the canvas, secondary for content surfaces, tertiary/quinary for media placeholders and quiet grouping, and border for outlines. Title/body roles carry content hierarchy. Foreground.primary pairs with text.button for filled selection and primary actions; accent/link, icon, and button roles stay independent. Semantic error and destructive roles retain their meaning. The same construction must work in light, dark, and store-defined themes.

## Typography

Use Rune `appFont(with:)` and the active store's font roles. Section titles use TITLE_6, screen headers use HEADER_3 (Account and Points Activity use HEADER_5 to match the approved account reference), product names use TITLE_3, and prices use TITLE_5. Supporting copy uses BODY_1/BODY_2 or NOTE_1. Do not set a new font family or fixed custom type scale in a feature.

App-owned titles, section names, and important callouts use Title Case. Preserve the supplied spelling and casing of store and product names.

Let descriptive text wrap naturally outside product cards. Product cards reserve one category line and two name lines, limit price/availability text to two lines, and use a fixed details area so their heights stay equal. Product grids retain two equal-width columns. Keep native control behavior; app-owned components, views, and screens do not add accessibility modifiers or read `accessibilityReduceMotion`.

## Layout

Compose screens from short, named view builders and focused feature components. Keep models and ViewModels in their established feature ownership. Use environment spacing tokens: medium for content padding, small/small2 for related content, and large/large2 between sections.

Menu and Favorite Products share a two-column, image-first product grid. The grid owns cell widths without per-card container-relative calculations. Every card is 360 points tall: a 180-point image area and a 180-point details area including padding, aligned to the top. Loading, placeholder, unavailable, and loaded images render inside the image area without affecting layout. ProductImageView owns a background-sized, clipped overlay so remote images can use fill without expanding their layout bounds. Detail galleries reserve square pages and 64-point thumbnails independently. Each card presents category, name, available minimum price, and a separate favorite action. Opening the card shows product details; the heart never opens the product. Do not add cart, checkout, stock claims, or fake discount information that the domain does not supply.

Product details give the gallery primary space, with paging and the existing selectable thumbnails directly beneath the selected image. Omit gallery captions and image-count copy. The selected-image box and its empty placeholder share a large-radius Rune border. The standard bubbly Back and heart actions live in the navigation header. A compact padded surface groups a transparent category image to the left of the product title, category copy, a horizontal outlined pricing rail, and the description. Pricing options retain real display prices, availability, and missing-price states; the rail uses horizontal safe-area padding within the panel and small vertical padding to keep its outlines visible. Currency amounts stay on one line and can scale down within their option cells. Attributes follow as clean divided label/value rows. Interested? Hit Us Up! pairs with compact 32-point circular Maps and phone actions inside 44-point touch targets. Recommended products use the existing product cards in a full-width horizontal rail with horizontal safe-area padding.

Store overview places the location name and a vertically centered downward chevron together in the branded navigation header; tapping them opens the existing location sheet. Preserve the original four-point title/subtitle spacing without adding row height. There is no separate location card. The page uses a full-width Rune header/scroll host, with section-title insets and horizontal safe-area padding on all three carousels so scrolling media can reach the screen edges. Empty Promotions and Events sections, including their headings, are hidden. Populated sections appear with a blur-replace transition and value-scoped bouncy animation. Sections are sixteen points apart, their headings sit twelve points above content, and Store Info begins eight points after the storefront sections.

Promotions are equal-sized 1.9:1 image banners with a single-line title (0.5 minimum scale factor) and an optional two-line subtitle over a soft black gradient. Missing descriptions shrink the caption without reserving subtitle space. Images fill and clip to the measured banner bounds, centered, including bundled fallbacks. Centered page dots sit six points below the banner, with no paging arrows. The carousel advances every five seconds with 0.65-second ease-in-out motion, resets to the first item without an animated rewind, and pauses during scrolling or while the app is inactive. Promotions and events have distinct bundled fallback photographs through StoreMarketingImage. Event images fill the card width inside a fixed 160-point-high, clipped media area, so loading or differently shaped assets cannot change card sizing. Event captions have eight-point outer padding and four points between title and schedule, without reserved blank lines. Home requests the first ten events; an accent-colored, semibold View More action pushes the paginated Events screen. Featured Products uses a lazy horizontal row of the existing ProductCardView cells, retaining favorites and navigation and the first six listings from the existing server-side featured order.

GENERAL promotion banners remain plain display content. SALE, NEW_PRODUCT, and LINK use the existing Rune button treatment. Several linked products push a native list using CommerceSurface rows with product names and navigation chevrons; unavailable products retain their row, show availability copy and an information icon, and explain the reason when selected. The existing navigation header and Back behavior preserve the overview and list. A single available product opens the existing product details directly; LINK opens the default external browser.

Store Info follows the reference as a flat, full-width white module with sixteen-point top padding, a Store Info heading, and pale gray icons beside Address, Store Hours, Phone Number, and Email. Row titles and content share a consistent leading column. Hours remain expanded Monday through Sunday with times in a trailing column, retaining split intervals without a next-day annotation. Special Hours uses the same tight rows, groups intervals by date, and places any reason beneath the date as a compact note. Contact values come from the public store projection; there is no contact disclosure or full-menu action. The white surface includes the custom tab-bar content clearance. Event cards in both the overview and Events screen push native details with their full description, location address, directions, and optional website.

Account follows the approved membership reference: a larger Account heading with the existing settings action, compact initials/profile row, prominent business membership pass, Member Since beneath it, one recent points transaction with View All, and a divided Saved Products / Your Store group. The pass uses the business accent through Rune palette.link, darkened by a 78-percent black overlay, with white copy and restrained diagonal accent/white planes; this treatment stays local to StoreAccountMembershipCard and remains dark in both themes. Its badge uses Rune titleInverted for contrast on the accent. The business name, account status, grouped points balance, member code, and join date come from CustomerAccount. BILLBOARD_3 gives the balance emphasis without changing the global font scale. View Membership opens read-only account/location details in a native sheet. Activity rows pair a circular accent-tinted transaction icon with the actual reason, optional reward, date/time, and signed points; debits use the destructive role. View All pushes the dedicated Points Activity screen on the Account navigation stack. That screen uses the same larger header, accent transaction icons, rounded history rows, and explicit paged Load More action; Back restores Account. Account itself keeps a single-entry preview. Keep guest registration, location enrollment, retry, and sign-out controls available.

Location selection retains the leading store-logo header with safe-area top padding, city/ZIP search beside Use My Location, and a single outlined group of divided store rows. Rows pair a circular storefront icon with the store name, city/region, street/postal address, and server open/closed status without opening-hour ranges. Store names use TITLE_3; address, search, and selection-summary copy use BODY_1 for breathing room. The selected row uses the business accent (branding.accentColor through Rune palette.link) at eight-percent opacity over the group surface, with an accent storefront icon and filled checkmark, and no selected-row outline. A bottom safe-area footer names the pending selection and offers Continue with a trailing chevron; tapping a row only changes that pending choice. Search controls stack when space is limited. Reopening the picker from an active store adds the standard Close action to the branded header and permits native swipe dismissal, both retaining the committed location. First selection stays mandatory. Age consent shares the leading store-logo header with safe-area top padding and retains its compact age badge, selected location's full address, and existing approval behavior.

Store Details retains JobLens iOS's `BubbleTabBarView` over the root `TabView`, with one navigation stack per tab, the system bar hidden, 42pt top corners, and its existing keyboard-independent overlay. `tabFlowContentSpacing()` keeps content above that bar. Keep the three Store, Menu, and Account navigation tabs. A filled heart in Menu pushes Favorite Products on the Menu navigation stack.

## Elevation & Depth

Use `LLAppCardView` for app-owned card composition. It wraps Rune `AppCardView` with shadow disabled and applies Rune `.appBorder` with a 1.5-point line width and its default color. The wrapper owns these defaults; spacing, background, and corner radius remain configurable Rune roles. `CommerceSurface` supplies the recurring padded surface with theme large radius. Image-led promotion and event cards use unpadded `LLAppCardView` composition. Do not nest cards just to divide text; prefer spacing or a disclosure within the owning surface.

## Shapes

Surfaces, Settings cards, and media use theme large radius, inputs use medium2, and primary actions retain LeafLaunchButton's theme medium radius. Categories and sort controls are capsules because they form scrolling selection rails. The tab bar keeps its documented shape. All other radius choices come from the active Rune theme.

## Components

| Responsibility | Owner |
| --- | --- |
| Primary actions | LeafLaunchButton using Rune CommonButton; enabled state and leading/trailing icon alignment remain owned by this wrapper |
| Header and scroll composition | LLAppHeaderScrollView owns the shared medium content inset; Home retains its intentional large inset; Store Overview and Product Details use the Rune host without a page-wide inset and apply horizontal safe-area padding to their carousels; Menu uses Rune AppHeaderScrollView with the same medium inset and its custom refresh configuration |
| Branded store headers | StoreNavHeader uses NavHeader with the store icon/logo and a target-logo fallback; its optional location action adds a chevron beside the subtitle and its optional dismissal action adds the standard Close control; the image fills its clipped square using aspect fill, with no inner padding |
| Titled authentication fields | llTextFieldStyle owns the Rune field treatment and medium2 input radius; callers own focus, secure entry, keyboard, and submission |
| Modal alert content | AppCardConfig factories and BaseAppCardConfigView; InvitationAlertView reads the active style |
| Cards | LLAppCardView using Rune AppCardView and appBorder |
| Padded commerce surfaces | CommerceSurface using LLAppCardView |
| Section title and optional supporting text | CommerceSectionHeader using SectionView |
| Contextual empty/error content | CommerceEmptyState; screen-wide overlays retain EmptyStateView |
| Catalog category selection | Search and rails are grouped with theme small spacing, and category/subcategory rails use extraSmall spacing. CatalogCategoryFilters and CatalogFilterPill; both rails use medium horizontal safe-area padding with full-width scrolling viewports; category URL images lead the title without an image background or selection checkmarks; the first category and first subcategory are selected by default, with no All pills |
| Category imagery | ProductCategoryImageView renders remote category URLs through Rune and bundled mock file URLs through UIImage; both preserve transparency without adding an image background |
| Menu refresh | Rune AppHeaderScrollView refresh configuration owns the gesture, haptics, and async completion; CatalogRefreshIndicator groups its progress icon and center-aligned status copy together in an HStack, centered with Rune centerHorizontally() through pull, armed, loading, and success/error/neutral feedback |
| Product grid and cards | ProductGridView and ProductCardView |
| Price, media, and saved state | ProductPriceView, ProductImageView, and ProductFavoriteButton |
| Product gallery and details | ProductGalleryView, ProductDetailsSummaryView, ProductOptionsView, and ProductAttributesView |
| Promotions, events, and Store Info | StorePromotionsCarousel owns timed promotion paging; PromotionProductsScreen and PromotionProductsViewModel own the linked-product list; StoreMarketingImage loads distinct promotion/event fallbacks; StoreEventsScreen and StoreEventsViewModel own the paginated events list; StoreInfoView owns the white information module and StoreHoursView renders expanded hours |
| Profile, membership, and activity | StoreAccountProfileView, StoreAccountMembershipView, StoreAccountMembershipCard, StoreAccountMembershipDetailsView, StoreAccountHistoryView, StoreAccountHistoryRow, and StoreAccountLinksView under StoreDetails/Account/Views |
| Location selection and age consent | LocationSelectionCard, LocationSearchControls, and LocationSelectionFooter compose the store picker; AgeVerificationConsentView owns age consent |
| Launch identity | SplashScreenView and SplashBrandMarkView |

Native SwiftUI owns scrolling, focus, menus, pickers, disclosures, and safe areas. Rune `ImageSource` owns media loading and caching. Public product responses include each active image’s `url`; cards and galleries load those URLs directly. Categories provide `image_url`, bootstrap branding provides `logo_url`/`icon_url`/`splash_url`, and promotion/event images provide `url`. Customer models contain no storage keys or MIME metadata, and screens make no separate media URL requests. Keep loading, unavailable-media, empty, and failure/retry states truthful.

Modal information uses its natural height when it fits and scrolls when needed, with the primary dismissal action outside the scrolling content. Use themed presentation spacing rather than a fixed gap that can consume the available height on short screens.

Apply `.animation(.bouncy, value:)` to meaningful selection, favorite feedback, disclosures, and splash entrance. Category changes replace the subcategory group with `.blurReplace`; changing the parent selects its first child. Category headings and sort labels use animated numeric text content transitions. Favorite actions show ProductFavoriteToastView through Rune's custom-content toast initializer, naming the product and whether it was added or removed. The toast view spans the current screen width minus 32 points, leaving sixteen-point side insets. Use Rune `.asButton` for ordinary custom actions; retain native role-bearing buttons where the modifier cannot preserve that role. Keep LeafLaunchButton and Rune CommonButton for primary action styling. Do not add perpetual decorative animation or delays to the startup callback.

## Do's and Don'ts

- Keep store branding and all visual tokens in Rune; improve hierarchy through construction.
- Use actual model imagery, prices, schedules, availability, balances, and ledger strings.
- Keep icon actions at least 44pt touch targets.
- Keep search, filtering, server sorting, pagination, local favorites, legal copy, and lifecycle ownership consistent with [UX-CONTRACT](UX-CONTRACT.md).
- Check changed call sites and both app targets. Follow the repository's restriction on Xcode builds and tests.
