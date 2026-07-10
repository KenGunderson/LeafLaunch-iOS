# Ubiquitous Components

_Generated: 2026-03-31T18:45:38-07:00_

## Scope

- **Workspace:** `/Users/sakohovaguimian/Desktop/Personal/Rune`
- **Output:** `/Users/sakohovaguimian/.codex/shared/ubiquitous-components/rune/UBIQUITOUS_COMPONENTS.md`
- **Global Rune Output:** `/Users/sakohovaguimian/.codex/shared/ubiquitous-components/rune/UBIQUITOUS_COMPONENTS.md`

### Source Roots

| Source | Kind | Root |
| --- | --- | --- |
| Rune | rune | `/Users/sakohovaguimian/Desktop/Personal/Rune/Sources/Rune` |

### Coverage Summary

| Source | Category | Declarations | APIs | Parameters |
| --- | --- | --- | --- | --- |
| Rune | Components | 155 | 185 | 735 |
| Rune | ViewModifiers | 74 | 73 | 198 |
| Rune | Services | 85 | 112 | 230 |
| Rune | Views | 67 | 78 | 314 |
| Rune | Extensions | 41 | 48 | 42 |

### Context Strategy

- This file is intentionally compact: one row per declaration with summarized entry points.
- Private/fileprivate declarations are excluded to focus on offered surface area.
- Use source file links (`File`) to inspect implementation details only where needed.
- For deep audits, regenerate with a custom script variant that emits full per-API parameter tables.

## Category: Components

### Source: Rune

| Symbol | Kind | Access | File | APIs | Params | Entry Points | What |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `AppBaseView` | `struct` | `public` | `Components/BaseViews/AppBaseView.swift`:10 | 1 | 4 | `init(alignment:horizontalPadding:backgroundStyle:content:)` | Reusable UI component for app base view. |
| `AppCardView` | `struct` | `public` | `Components/BaseViews/AppCardView.swift`:10 | 1 | 6 | `init(verticalPadding:horizontalPadding:backgroundStyle:cornerRadius:shadow:content:)` | Reusable UI component for app card view. |
| `AppHeaderScrollView` | `struct` | `public` | `Components/BaseViews/AppHeaderScrollView.swift`:10 | 1 | 6 | `init(alignment:horizontalPadding:backgroundStyle:scrollOffset:navBarContent:scrollViewContent:)` | Reusable UI component for app header scroll view. |
| `AppLoadingView` | `struct` | `public` | `Components/Animations/Loading/LoadingView.swift`:10 | 1 | 1 | `init(style:)` | Reusable UI component for app loading view. |
| `AppOutlineCardView` | `struct` | `public` | `Components/BaseViews/AppOutlineCardView.swift`:10 | 1 | 7 | `init(verticalPadding:horizontalPadding:backgroundStyle:outlineColor:outlineWidth:cornerRadius:content:)` | Reusable UI component for app outline card view. |
| `AppSideMenu` | `struct` | `public` | `Components/BaseViews/AppSideMenu.swift`:11 | 1 | 4 | `init(isSidebarVisible:direction:shouldDismissOnTapOutside:content:)` | Reusable UI component for app side menu. |
| `AssetOptions` | `enum` | `internal` | `Components/Selectable/CommonSelectionSheet.swift`:175 | 0 | 0 | - | Reusable UI component for asset options. |
| `AttributedText` | `struct` | `public` | `Components/AttributedText.swift`:19 | 1 | 1 | `init(content:)` | Reusable UI component for attributed text. |
| `AttributedTextBuilder` | `struct` | `public` | `Components/AttributedText.swift`:11 | 1 | 1 | `buildBlock(_:)` | Reusable UI component for attributed text builder. |
| `AvatarGroupView` | `struct` | `public` | `Components/Avatar/AvatarGroupView.swift`:15 | 1 | 6 | `init(avatars:interitemSpacing:strokeColor:strokeLineWidth:maxNumberOfAvatars:clipShape:)` | Reusable UI component for avatar group view. |
| `AvatarView` | `struct` | `public` | `Components/Avatar/AvatarView.swift`:10 | 1 | 4 | `init(style:foregroundColor:backgroundColor:clipShape:)` | Reusable UI component for avatar view. |
| `BackButton` | `struct` | `public` | `Components/CircularIconView.swift`:57 | 1 | 3 | `init(backgroundColor:size:backAction:)` | Reusable UI component for back button. |
| `BannerItem` | `struct` | `public` | `Components/Carousel/DynamicTextCarouselView.swift`:10 | 1 | 0 | `FAKE_MESSAGE_ITEMS()` | Reusable UI component for banner item. |
| `ButtonStyle` | `extension` | `public` | `Components/Button/CommonButton.swift`:180 | 1 | 7 | `commonButtonStyle(style:background:cornerRadius:isEnabled:verticalPadding:horizontalPadding:buttonBounceStyle:)` | Reusable UI component for button style. |
| `Carousel` | `struct` | `public` | `Components/Carousel/Carousel.swift`:36 | 1 | 5 | `init(activeIndex:style:interitemSpacing:safeAreaSpacing:content:)` | Reusable UI component for carousel. |
| `CarouselDemoItem` | `struct` | `public` | `Components/Carousel/Carousel.swift`:11 | 1 | 0 | `DUMMY_DATA()` | Reusable UI component for carousel demo item. |
| `CarouselStyle` | `enum` | `public` | `Components/Carousel/Carousel.swift`:29 | 0 | 0 | - | Reusable UI component for carousel style. |
| `CircleWaveView` | `struct` | `public` | `Components/LiquidView/CircleWaveView.swift`:10 | 1 | 3 | `init(percent:imageSource:colorSource:)` | Reusable UI component for circle wave view. |
| `CircularIconView` | `struct` | `public` | `Components/CircularIconView.swift`:10 | 1 | 5 | `init(foregroundColor:backgroundColor:imageSource:size:imageFillRatio:)` | Reusable UI component for circular icon view. |
| `CloseButton` | `struct` | `public` | `Components/CircularIconView.swift`:89 | 1 | 3 | `init(backgroundColor:size:backAction:)` | Reusable UI component for close button. |
| `CodeInputStyle` | `enum` | `public` | `Components/Fields/CommonCodeInputView.swift`:10 | 0 | 0 | - | Reusable UI component for code input style. |
| `CollapsableCardView` | `struct` | `public` | `Components/BaseViews/CollapsableCardView.swift`:10 | 1 | 12 | `init(isExpanded:verticalPadding:horizontalPadding:backgroundColor:cornerRadius:shadow:chevronColor:shouldShowChevron:animation:transition:collapsedView:expandedView:)` | Reusable UI component for collapsable card view. |
| `CollapsableView` | `struct` | `public` | `Components/BaseViews/CollapsableView.swift`:11 | 1 | 7 | `init(isExpanded:backgroundColor:shadow:animation:transition:collapsedView:expandedView:)` | Reusable UI component for collapsable view. |
| `CommonBadge` | `struct` | `public` | `Components/Badge/CommonBadge.swift`:10 | 1 | 6 | `init(contentStyle:placement:appearance:sizing:behavior:content:)` | Reusable UI component for common badge. |
| `CommonButton` | `struct` | `public` | `Components/Button/CommonButton.swift`:10 | 1 | 13 | `init(style:title:titleColor:titleFont:icon:iconAlignment:backgroundStyle:isEnabled:disabledOpacity:verticalPadding:horizontalPadding:buttonBounceStyle:action:)` | Reusable UI component for common button. |
| `CommonButtonStyle` | `struct` | `public` | `Components/Button/CommonButton.swift`:114 | 1 | 1 | `makeBody(configuration:)` | Reusable UI component for common button style. |
| `CommonCodeInputView` | `struct` | `public` | `Components/Fields/CommonCodeInputView.swift`:17 | 1 | 18 | `init(codeInput:maxCharacterCount:maxWidthPerCharacter:characterHeight:horizontalCharacterSpacing:inputStyle:clipShape:font:shadow:inputTextColor:unselectedBackgroundColor:selectedBackgroundColor:unselectedStrokeColor:selectedStrokeColor:placeholderColor:showBlinkingCursor:blinkingHorizontalPadding:isSecure:)` | Reusable UI component for common code input view. |
| `CommonDropDownMenu` | `struct` | `public` | `Components/Selectable/DropDown/CommonDropDownMenu.swift`:10 | 1 | 12 | `init(options:buttonHeight:maxItemDisplayed:foregroundStyle:backgroundStyle:cornerRadius:shadow:textHorizontalPadding:shouldPushContentDown:animation:selectedOption:showDropDown:)` | Reusable UI component for common drop down menu. |
| `CommonDropDownMultiSelectMenu` | `struct` | `public` | `Components/Selectable/DropDown/CommonMultiSelectDropDown.swift`:10 | 1 | 12 | `init(options:buttonHeight:maxItemDisplayed:foregroundStyle:backgroundStyle:cornerRadius:shadow:textHorizontalPadding:shouldPushContentDown:animation:selectedOptions:showDropDown:)` | Reusable UI component for common drop down multi select menu. |
| `CommonImageView` | `struct` | `public` | `Components/Image/CommonImageView.swift`:12 | 2 | 2 | `init(imageSource:)`, `init(style:)` | Reusable UI component for common image view. |
| `CommonMinimalStepper` | `struct` | `public` | `Components/Stepper/CommonMinimalStepper.swift`:10 | 1 | 8 | `init(value:in:step:tintColor:borderColor:height:horizontalPadding:clipShape:)` | Reusable UI component for common minimal stepper. |
| `CommonOutlinedStepper` | `struct` | `public` | `Components/Stepper/CommonOutlineStepper.swift`:10 | 1 | 8 | `init(value:in:step:tintColor:textColor:buttonSize:spacing:lineWidth:)` | Reusable UI component for common outlined stepper. |
| `CommonPillStepper` | `struct` | `public` | `Components/Stepper/CommonPillStepper.swift`:10 | 1 | 10 | `init(value:in:step:trackColor:innerButtonColor:iconColor:textColor:trackHeight:buttonPadding:clipShape:)` | Reusable UI component for common pill stepper. |
| `CommonSegmentedControl` | `struct` | `public` | `Components/Selectable/CommonSegmentedControl.swift`:10 | 1 | 10 | `init(selectedOption:options:titleFont:selectedTextColor:unselectedTextColor:foregroundStyle:backgroundStyle:outerCornerRadius:innerCornerRadius:shadow:)` | Reusable UI component for common segmented control. |
| `CommonSelectionSheet` | `struct` | `public` | `Components/Selectable/CommonSelectionSheet.swift`:10 | 1 | 6 | `init(options:headerTitle:headerSubtitle:selectionStyle:selectedOptions:selectionAction:)` | Reusable UI component for common selection sheet. |
| `CommonTextEditView` | `struct` | `public` | `Components/Fields/CommonTextEditView.swift`:10 | 1 | 14 | `init(text:placehoderText:isFocused:titleColor:titleFont:placeholderColor:unselectedBorderColor:selectedBorderColor:backgroundStyle:cornerRadius:shadow:lineLimit:verticalPadding:horizontalPadding:)` | Reusable UI component for common text edit view. |
| `CommonTextFieldPreview` | `struct` | `public` | `Components/Fields/CommonTextFieldPreview.swift`:10 | 0 | 0 | - | Reusable UI component for common text field preview. |
| `CommonTextFieldStyle` | `struct` | `public` | `Components/Fields/CommonTextFieldStyle.swift`:11 | 1 | 1 | `_body(configuration:)` | Reusable UI component for common text field style. |
| `CommonToggleGroup` | `struct` | `public` | `Components/Selectable/CommonToggleGroup.swift`:10 | 2 | 5 | `defaultToggleConfig()`, `init(options:selectionStyle:selectedOptions:toggleConfig:selectionAction:)` | Reusable UI component for common toggle group. |
| `CommonToggleStyle` | `struct` | `public` | `Components/Toggles/CommonToggleStyle.swift`:10 | 2 | 16 | `init(textColor:trackColor:trackFillColor:trackClipShape:thumbFillColor:thumbIcon:thumbIconTint:thumbClipShape:thumbWidthRatio:verticalThumbPadding:horizontalThumbPadding:interitemSpacing:toggleWidth:toggleHeight:animation:)`, `makeBody(configuration:)` | Reusable UI component for common toggle style. |
| `CommonTooltipAnchor` | `enum` | `public` | `Components/Tooltip/CommonTooltipAnchor.swift`:10 | 1 | 1 | `targetPoint(in:)` | Reusable UI component for common tooltip anchor. |
| `CommonTooltipContentContext` | `struct` | `public` | `Components/Tooltip/CommonTooltipCustomContent.swift`:10 | 1 | 6 | `init(step:style:indicator:onPrimaryAction:onSecondaryAction:onDismiss:)` | Reusable UI component for common tooltip content context. |
| `CommonTooltipScrollAlignment` | `enum` | `public` | `Components/Tooltip/CommonTooltipScrollAlignment.swift`:10 | 0 | 0 | - | Reusable UI component for common tooltip scroll alignment. |
| `CommonTooltipSequenceController` | `class` | `public` | `Components/Tooltip/CommonTooltipSequenceController.swift`:11 | 7 | 5 | `init(steps:startsPresented:)`, `start(at:)`, `next()`, (+4 more) | Reusable UI component for common tooltip sequence controller. |
| `CommonTooltipStep` | `extension` | `public` | `Components/Tooltip/CommonTooltipCustomContent.swift`:39 | 1 | 1 | `customContent(_:)` | Reusable UI component for common tooltip step. |
| `CommonTooltipStep` | `struct` | `public` | `Components/Tooltip/CommonTooltipStep.swift`:12 | 0 | 0 | - | Reusable UI component for common tooltip step. |
| `CommonTooltipStyle` | `struct` | `public` | `Components/Tooltip/CommonTooltipStyle.swift`:10 | 1 | 22 | `init(backgroundStyle:titleColor:messageColor:actionColor:titleFont:messageFont:indicatorFont:horizontalPadding:verticalPadding:contentSpacing:actionSpacing:cornerRadius:shadow:maxWidth:containerPadding:anchorSpacing:animation:showsArrow:arrowSize:spotlightOverlayColor:spotlightBorderColor:spotlightBorderWidth:)` | Reusable UI component for common tooltip style. |
| `CommonTooltipView` | `struct` | `internal` | `Components/Tooltip/CommonTooltipView.swift`:10 | 0 | 0 | - | Reusable UI component for common tooltip view. |
| `CommonWheelPicker` | `struct` | `public` | `Components/Selectable/Pickers/CommonWheelPicker.swift`:10 | 1 | 3 | `init(selectedOption:options:config:)` | Reusable UI component for common wheel picker. |
| `ConfettiConfig` | `struct` | `public` | `Components/Confetti/Models/ConfettiConfig.swift`:10 | 1 | 0 | `init()` | Reusable UI component for confetti config. |
| `ConfettiConfig` | `extension` | `internal` | `Components/Confetti/Models/ConfettiConfigDefaults.swift`:10 | 1 | 0 | `default()` | Reusable UI component for confetti config. |
| `ConfettiConfig` | `extension` | `internal` | `Components/Confetti/Models/ConfettiConfigDefaults.swift`:19 | 1 | 0 | `celebration()` | Reusable UI component for confetti config. |
| `ConfettiConfig` | `extension` | `internal` | `Components/Confetti/Models/ConfettiConfigDefaults.swift`:76 | 1 | 0 | `subtle()` | Reusable UI component for confetti config. |
| `ConfettiConfig` | `extension` | `internal` | `Components/Confetti/Models/ConfettiConfigDefaults.swift`:111 | 1 | 0 | `gold()` | Reusable UI component for confetti config. |
| `ConfettiConfig` | `extension` | `internal` | `Components/Confetti/Models/ConfettiConfigDefaults.swift`:137 | 1 | 0 | `rainbow()` | Reusable UI component for confetti config. |
| `ConfettiConfig` | `extension` | `internal` | `Components/Confetti/Models/ConfettiConfigDefaults.swift`:163 | 1 | 0 | `custom()` | Reusable UI component for confetti config. |
| `ConfettiParticle` | `struct` | `public` | `Components/Confetti/Models/ConfettiParticle.swift`:10 | 1 | 17 | `init(id:x:y:vx:vy:color:size:shape:mass:dragCoefficient:wobbleAmplitude:wobbleFrequency:wobbleDecay:rotationSpeedX:rotationSpeedY:rotationSpeedZ:settings:)` | Reusable UI component for confetti particle. |
| `ConfettiParticleView` | `struct` | `internal` | `Components/Confetti/ConfettiParticleView.swift`:10 | 1 | 2 | `init(particle:screenSize:)` | Reusable UI component for confetti particle view. |
| `ConfettiPreset` | `enum` | `public` | `Components/Confetti/ConfettiView.swift`:142 | 0 | 0 | - | Reusable UI component for confetti preset. |
| `ConfettiView` | `struct` | `public` | `Components/Confetti/ConfettiView.swift`:11 | 2 | 5 | `init(trigger:settings:colors:)`, `init(trigger:preset:)` | Reusable UI component for confetti view. |
| `CustomStaggeredTransition` | `struct` | `public` | `Components/Animations/StaggeredView/CustomStaggeredTransition.swift`:10 | 1 | 2 | `body(content:phase:)` | Reusable UI component for custom staggered transition. |
| `CustomToggleStyle` | `struct` | `public` | `Components/Toggles/CustomToggleStyle.swift`:10 | 2 | 2 | `init(config:)`, `makeBody(configuration:)` | Reusable UI component for custom toggle style. |
| `DebtOptions` | `enum` | `internal` | `Components/Selectable/CommonSelectionSheet.swift`:189 | 0 | 0 | - | Reusable UI component for debt options. |
| `DotsAnimationView` | `struct` | `public` | `Components/Animations/DotsLoadingView.swift`:10 | 1 | 1 | `animation(index:)` | Reusable UI component for dots animation view. |
| `DraggableProgressBar` | `struct` | `public` | `Components/Progress/DraggableProgressBar.swift`:10 | 1 | 5 | `init(currentValue:direction:foregroundColor:backgroundColor:clipShape:)` | Reusable UI component for draggable progress bar. |
| `FavoriteButton` | `struct` | `public` | `Components/CircularIconView.swift`:121 | 1 | 4 | `init(isFavorited:backgroundColor:size:favoriteAction:)` | Reusable UI component for favorite button. |
| `FiltersView` | `struct` | `public` | `Components/Selectable/FiltersView.swift`:11 | 0 | 0 | - | Reusable UI component for filters view. |
| `FiltersViewPreview` | `struct` | `public` | `Components/Selectable/FiltersView.swift`:165 | 1 | 8 | `init(filters:selectedFilter:selectedFilterColor:filterTextColor:filterSelectedText:backgroundColor:strokeStyle:strokeWidth:)` | Reusable UI component for filters view preview. |
| `FloatingLabelTextFieldPreview` | `struct` | `public` | `Components/Fields/FloatingLabelTextFieldPreview.swift`:10 | 0 | 0 | - | Reusable UI component for floating label text field preview. |
| `FloatingLabelTextFieldStyle` | `struct` | `public` | `Components/Fields/FloatingLabelTextFieldStyle.swift`:11 | 1 | 1 | `_body(configuration:)` | Reusable UI component for floating label text field style. |
| `FormattingTextViewPreview` | `struct` | `internal` | `Components/Fields/SanitizingTextField.swift`:68 | 0 | 0 | - | Reusable UI component for formatting text view preview. |
| `HalfCircleProgressView` | `struct` | `public` | `Components/Progress/HalfCircleProgressView.swift`:10 | 1 | 7 | `init(progress:lineWidth:title:titleFont:titleColor:fillColor:trackColor:)` | Reusable UI component for half circle progress view. |
| `HapticOption` | `enum` | `public` | `Components/Haptics/HapticOption.swift`:10 | 0 | 0 | - | Reusable UI component for haptic option. |
| `Haptics` | `class` | `public` | `Components/Haptics/Haptics.swift`:12 | 2 | 2 | `prepare(option:)`, `vibrate(option:)` | Reusable UI component for haptics. |
| `HapticViewModifier` | `struct` | `public` | `Components/Haptics/HapticViewModifier.swift`:12 | 1 | 1 | `body(content:)` | Reusable UI component for haptic view modifier. |
| `HeadlessStepper` | `struct` | `public` | `Components/Stepper/HeadlessStepper.swift`:23 | 1 | 6 | `init(value:in:step:onIncrement:onDecrement:content:)` | Reusable UI component for headless stepper. |
| `Heart` | `struct` | `public` | `Components/Shapes/Heart.swift`:10 | 1 | 1 | `path(in:)` | Reusable UI component for heart. |
| `HoldButtonView` | `struct` | `public` | `Components/Button/LongPressFillButtonView.swift`:10 | 2 | 2 | `init(style:holdButtonConfig:)`, `content()` | Reusable UI component for hold button view. |
| `HStackDots` | `struct` | `internal` | `Components/Progress/Progress/HStackDots.swift`:3 | 1 | 1 | `path(in:)` | Reusable UI component for hstack dots. |
| `HStackLines` | `struct` | `public` | `Components/Progress/Progress/HStackLines.swift`:3 | 2 | 5 | `init(diameter:centerInset:maxDots:inSet:)`, `path(in:)` | Reusable UI component for hstack lines. |
| `ImpactRatingView` | `struct` | `public` | `Components/Rating/ImpactRatingView.swift`:10 | 0 | 0 | - | Reusable UI component for impact rating view. |
| `InfoView` | `struct` | `public` | `Components/InfoView.swift`:10 | 1 | 8 | `init(title:titleFont:imageSource:foregroundStyle:clipShape:backgroundOpacity:appBorderConfig:action:)` | Reusable UI component for info view. |
| `InlineTransition` | `struct` | `public` | `Components/InlineView/InlineTransition.swift`:11 | 3 | 8 | `body(content:phase:)`, `offsetY(_:offsetAmount:phase:)`, `offsetX(_:offsetAmount:phase:)` | Reusable UI component for inline transition. |
| `InlineView` | `struct` | `public` | `Components/InlineView/InlineView.swift`:12 | 0 | 0 | - | Reusable UI component for inline view. |
| `InlineViewConfig` | `struct` | `public` | `Components/InlineView/InlineViewConfig.swift`:11 | 0 | 0 | - | Reusable UI component for inline view config. |
| `JSONPreviewView` | `struct` | `public` | `Components/JSONPreviewView.swift`:10 | 1 | 7 | `init(jsonData:backgroundColor:titleFont:subtitleFont:bodyFont:minHeight:maxHeight:)` | Reusable UI component for jsonpreview view. |
| `LinearGradient` | `extension` | `internal` | `Components/RelativeBarView.swift`:330 | 4 | 0 | `redColor()`, `blueColor()`, `greenColor()`, (+1 more) | Reusable UI component for linear gradient. |
| `LoadingCircleActivityView` | `struct` | `internal` | `Components/Animations/Loading/LoadingCircleActivityView.swift`:11 | 1 | 4 | `init(color:numberOfCircles:size:speed:)` | Reusable UI component for loading circle activity view. |
| `LoadingCircleBarsActivityView` | `struct` | `internal` | `Components/Animations/Loading/LoadingCircleBarsActivityView.swift`:11 | 1 | 5 | `init(color:numberOfBars:size:speed:unhighlightedOpacity:)` | Reusable UI component for loading circle bars activity view. |
| `LoadingCircleRunner` | `struct` | `internal` | `Components/Animations/Loading/LoadingCircleRunnerView.swift`:10 | 1 | 4 | `init(color:trimSubtractionScale:size:speed:)` | Reusable UI component for loading circle runner. |
| `LoadingDotsView` | `struct` | `internal` | `Components/Animations/Loading/LoadingDotsView.swift`:11 | 1 | 4 | `init(numberOfDots:selectedColor:unselectedColor:speed:)` | Reusable UI component for loading dots view. |
| `LoadingPulse` | `struct` | `internal` | `Components/Animations/Loading/LoadingPulseView.swift`:18 | 1 | 4 | `init(color:style:size:speed:)` | Reusable UI component for loading pulse. |
| `NavBarView` | `struct` | `public` | `Components/NavBarView.swift`:10 | 4 | 14 | `init(navBarStyle:backgroundStyle:)`, `init(title:subtitle:leftButtonView:rightButtonView:divider:navBackgroundStyle:)`, `calculateOpacity(currentOffset:threshold:)`, (+1 more) | Reusable UI component for nav bar view. |
| `OptimizedCollectionStack` | `struct` | `internal` | `Components/BaseViews/Optimized/OptimizedCollectionStack.swift`:11 | 3 | 3 | `makeCoordinator()`, `makeUIView(context:)`, `updateUIView(_:context:)` | Reusable UI component for optimized collection stack. |
| `OptimizedHStack` | `struct` | `public` | `Components/BaseViews/Optimized/OptimizedHStack.swift`:11 | 2 | 11 | `init(data:id:insertTransition:insertAnimation:showsHorizontalScrollIndicator:content:)`, `init(data:insertTransition:insertAnimation:showsHorizontalScrollIndicator:content:)` | A lightweight, diffable horizontal stack backed by `UICollectionView`. |
| `OptimizedStackAxis` | `enum` | `internal` | `Components/BaseViews/Optimized/OptimizedCollectionStack.swift`:209 | 1 | 0 | `makeLayout()` | Reusable UI component for optimized stack axis. |
| `OptimizedVStack` | `struct` | `public` | `Components/BaseViews/Optimized/OptimizedVStack.swift`:11 | 2 | 11 | `init(data:id:insertTransition:insertAnimation:showsVerticalScrollIndicator:content:)`, `init(data:insertTransition:insertAnimation:showsVerticalScrollIndicator:content:)` | A lightweight, diffable vertical stack backed by `UICollectionView`. |
| `PageControl` | `struct` | `public` | `Components/Carousel/PageControl.swift`:10 | 1 | 5 | `init(totalIndex:selectedIndex:unhighlightColor:highlightColor:height:)` | Reusable UI component for page control. |
| `PageIndicatorView` | `struct` | `public` | `Components/PageIndicatorView.swift`:11 | 0 | 0 | - | Reusable UI component for page indicator view. |
| `PinterestLayout` | `struct` | `public` | `Components/Layouts/PinterestLayout.swift`:10 | 4 | 11 | `init(numberOfColumns:horizontalSpacing:verticalSpacing:)`, `makeCache(subviews:)`, `sizeThatFits(proposal:subviews:cache:)`, (+1 more) | Reusable UI component for pinterest layout. |
| `Pokemon` | `enum` | `internal` | `Components/Selectable/CommonToggleGroup.swift`:108 | 0 | 0 | - | Reusable UI component for pokemon. |
| `ProgressBar` | `struct` | `public` | `Components/Progress/ProgressBar.swift`:10 | 1 | 5 | `init(value:trackColor:fillColor:clipShape:animation:)` | Reusable UI component for progress bar. |
| `ProgressCircle` | `struct` | `public` | `Components/Progress/ProgressCircle.swift`:10 | 1 | 4 | `init(progress:inactiveColor:activeColor:lineWidth:)` | Reusable UI component for progress circle. |
| `ProgressSlider` | `struct` | `public` | `Components/Progress/ProgressSlider.swift`:8 | 1 | 10 | `init(value:mode:hapticPolicy:trackStyle:trackHeight:tickerMarkScaleFactor:fillStyle:thumbStyle:thumbCircleStyle:thumbHeight:)` | Reusable UI component for progress slider. |
| `PulseLoadingStyle` | `enum` | `public` | `Components/Animations/Loading/LoadingPulseView.swift`:10 | 0 | 0 | - | Reusable UI component for pulse loading style. |
| `RadialLayout` | `struct` | `public` | `Components/Layouts/RadialLayout.swift`:11 | 2 | 7 | `sizeThatFits(proposal:subviews:cache:)`, `placeSubviews(in:proposal:subviews:cache:)` | Reusable UI component for radial layout. |
| `RangeProgressSlider` | `struct` | `public` | `Components/Progress/RangeProgressSlider.swift`:3 | 1 | 11 | `init(lowerValue:upperValue:bounds:minimumDistance:step:trackStyle:trackHeight:fillStyle:thumbStyle:thumbCircleStyle:thumbHeight:)` | Reusable UI component for range progress slider. |
| `RatingView` | `struct` | `public` | `Components/Rating/RatingView.swift`:10 | 1 | 5 | `init(rating:numberOfItems:selectedColor:unselectedColor:precision:)` | Reusable UI component for rating view. |
| `RelativeBarView` | `struct` | `public` | `Components/RelativeBarView.swift`:10 | 0 | 0 | - | Reusable UI component for relative bar view. |
| `RelativeBarViewMode` | `enum` | `public` | `Components/RelativeBarView.swift`:242 | 0 | 0 | - | Reusable UI component for relative bar view mode. |
| `RelativeBarViewSegment` | `struct` | `public` | `Components/RelativeBarView.swift`:249 | 0 | 0 | - | Reusable UI component for relative bar view segment. |
| `SanitizingTextField` | `struct` | `internal` | `Components/Fields/SanitizingTextField.swift`:10 | 1 | 3 | `init(_:text:transform:)` | Reusable UI component for sanitizing text field. |
| `ScrollBannerView` | `struct` | `public` | `Components/Carousel/DynamicTextCarouselView.swift`:33 | 1 | 7 | `init(items:currentIndex:foregroundColor:backgroundColor:pageingSelectedColor:pagingUnselectedColor:clipShape:)` | Reusable UI component for scroll banner view. |
| `SegmentedGauge` | `struct` | `public` | `Components/Progress/SegmentedGauge.swift`:10 | 2 | 5 | `init()`, `init(value:segmentCount:trackColor:fillColor:animation:)` | Reusable UI component for segmented gauge. |
| `Shimmer` | `struct` | `public` | `Components/Animations/Shimmer.swift`:10 | 2 | 5 | `init(animation:gradient:size:mode:)`, `body(content:)` | Reusable UI component for shimmer. |
| `StaggeredConfig` | `struct` | `public` | `Components/Animations/StaggeredView/StaggeredConfig.swift`:10 | 9 | 28 | `init(delay:maxDelay:blurRadius:offset:scale:scaleAnchor:animation:interitemSpacing:disappearInSameDirection:noDisappearAnimation:)`, `opacity(delay:)`, `slide(from:distance:delay:)`, (+6 more) | Reusable UI component for staggered config. |
| `StaggeredTestView` | `struct` | `internal` | `Components/Animations/StaggeredView/StaggeredView.swift`:44 | 0 | 0 | - | Reusable UI component for staggered test view. |
| `StaggeredView` | `struct` | `public` | `Components/Animations/StaggeredView/StaggeredView.swift`:10 | 1 | 2 | `init(config:content:)` | Reusable UI component for staggered view. |
| `Star` | `struct` | `public` | `Components/Shapes/Star.swift`:10 | 1 | 1 | `path(in:)` | Reusable UI component for star. |
| `StepperContext` | `struct` | `public` | `Components/Stepper/HeadlessStepper.swift`:10 | 0 | 0 | - | Reusable UI component for stepper context. |
| `TextProgressBar` | `struct` | `public` | `Components/Progress/TextProgressBar.swift`:10 | 1 | 7 | `init(value:text:textFont:textColor:trackColor:fillColor:cornerRadius:)` | Reusable UI component for text progress bar. |
| `ThumbRatingView` | `struct` | `public` | `Components/Rating/ThumbRatingView.swift`:10 | 0 | 0 | - | Reusable UI component for thumb rating view. |
| `TickerThumbAlignedFillMask` | `struct` | `internal` | `Components/Progress/Progress/TickerThumbAlignedFillMask.swift`:3 | 1 | 1 | `path(in:)` | Reusable UI component for ticker thumb aligned fill mask. |
| `TitleUnderlineTextFieldStyle` | `struct` | `public` | `Components/Fields/TitleUnderlineTextFieldStyle.swift`:11 | 1 | 1 | `_body(configuration:)` | Reusable UI component for title underline text field style. |
| `TitleUnderlineTextFieldStylePreview` | `struct` | `public` | `Components/Fields/TitleUnderlineTextFieldStylePreview.swift`:10 | 0 | 0 | - | Reusable UI component for title underline text field style preview. |
| `ToggleStyle` | `extension` | `internal` | `Components/Toggles/CommonToggleStyle.swift`:141 | 1 | 13 | `init(textColor:trackColor:trackFillColor:trackClipShape:thumbFillColor:thumbIcon:thumbIconTint:thumbClipShape:verticalThumbPadding:horizontalThumbPadding:interitemSpacing:toggleWidth:toggleHeight:)` | Reusable UI component for toggle style. |
| `ToggleStyle` | `extension` | `public` | `Components/Toggles/CustomToggleStyle.swift`:203 | 5 | 45 | `box(height:textColor:unselectedColor:selectedColor:fillRatio:horizontalSpacing:cornerRadius:animation:transition:)`, `checkmark(height:icon:textColor:unselectedColor:selectedColor:horizontalSpacing:cornerRadius:animation:transition:)`, `checkmarkFilled(height:icon:textColor:unselectedColor:selectedColor:horizontalSpacing:cornerRadius:animation:transition... | Reusable UI component for toggle style. |
| `TokenView` | `struct` | `public` | `Components/TokenView.swift`:10 | 1 | 8 | `init(text:titleFont:image:foregroundStyle:backgroundStyle:horizontalPadding:verticalPadding:clipShape:)` | Reusable UI component for token view. |
| `TooltipDemoView` | `struct` | `internal` | `Components/Tooltip/TooltipDemoView.swift`:10 | 1 | 0 | `init()` | Reusable UI component for tooltip demo view. |
| `TooltipSpotlightOverlay` | `struct` | `internal` | `Components/Tooltip/TooltipSpotlightOverlay.swift`:10 | 0 | 0 | - | Reusable UI component for tooltip spotlight overlay. |
| `TooltipTargetPreferenceKey` | `struct` | `internal` | `Components/Tooltip/ViewModifiers/TooltipTargetModifier.swift`:10 | 1 | 2 | `reduce(value:nextValue:)` | Reusable UI component for tooltip target preference key. |
| `View` | `extension` | `public` | `Components/Animations/Shimmer.swift`:161 | 1 | 5 | `shimmer(_:animation:gradient:size:mode:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/Badge/CommonBadge.swift`:469 | 1 | 5 | `init(contentStyle:placement:appearance:sizing:behavior:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/Fields/CommonTextFieldStyle.swift`:108 | 1 | 14 | `appTextFieldStyle(text:hint:icon:isFocused:borderColor:foregroundColor:backgroundColor:unselectedColor:textFieldFont:cornerRadius:shadow:leadingSpacing:iconTitleInteritemSpacing:centeredOverlay:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/Fields/FloatingLabelTextFieldStyle.swift`:167 | 1 | 20 | `floatingLabelTextFieldStyle(text:placeholder:leadingIcon:trailingIcon:isFocused:borderColor:foregroundColor:backgroundColor:unselectedColor:placeholderColor:floatingLabelColor:textFieldFont:placeholderFont:floatingLabelFont:cornerRadius:shadow:lineWidth:verticalPadding:horizontalPadding:iconTitleInteritemSpacing:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/Fields/TitleUnderlineTextFieldStyle.swift`:141 | 1 | 16 | `titleUnderlineTextFieldStyle(text:title:style:isFocused:borderColor:foregroundColor:backgroundColor:unselectedColor:unselectedIconColor:textFieldFont:titleFont:titleColor:shadow:leadingSpacing:iconTitleInteritemSpacing:centeredOverlay:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/Haptics/HapticViewModifier.swift`:34 | 1 | 2 | `withHaptic(option:onChangeOf:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/InlineView/InlineViewModifier.swift`:10 | 1 | 3 | `inlineView(config:viewContentAlignment:isPresented:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/Tooltip/ViewModifiers/TooltipPresenterModifier.swift`:435 | 2 | 4 | `tooltip(step:style:)`, `tooltipSequence(_:style:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/Tooltip/ViewModifiers/TooltipTargetModifier.swift`:49 | 1 | 1 | `tooltipTarget(_:)` | Reusable UI component for view. |
| `View` | `extension` | `public` | `Components/Tooltip/ViewModifiers/WindowTooltipOverlayModifier.swift`:10 | 1 | 0 | `withWindowTooltipOverlay()` | Reusable UI component for view. |
| `Wave` | `struct` | `public` | `Components/LiquidView/Wave.swift`:10 | 1 | 1 | `path(in:)` | Reusable UI component for wave. |
| `WaveLine` | `struct` | `internal` | `Components/Shapes/WaveLine.swift`:10 | 2 | 3 | `init(waveCount:amplitudeRatio:)`, `path(in:)` | Reusable UI component for wave line. |
| `WedgeShape` | `struct` | `public` | `Components/Shapes/Wedge.swift`:10 | 2 | 3 | `init(startAngle:endAngle:)`, `path(in:)` | Reusable UI component for wedge shape. |
| `WheelPickerConfig` | `struct` | `public` | `Components/Selectable/Pickers/Models/WheelPickerConfig.swift`:10 | 1 | 8 | `init(visibleRows:interitemSpacing:font:selectedOptionColor:unselectedOptionColor:overlayConfig:backgroundColor:cornerRadius:)` | Reusable UI component for wheel picker config. |
| `WheelPickerOverlayConfig` | `struct` | `public` | `Components/Selectable/Pickers/Models/WheelPickerOverlayConfig.swift`:10 | 1 | 4 | `init(strokeColor:strokeWidth:clipShape:horizontalPadding:)` | Reusable UI component for wheel picker overlay config. |
| `WheelPickerSizeStyle` | `enum` | `public` | `Components/Selectable/Pickers/Models/WheelPickerSizeStyle.swift`:10 | 0 | 0 | - | Reusable UI component for wheel picker size style. |
| `WheelPickerView` | `struct` | `public` | `Components/Selectable/Pickers/WheelPickerView.swift`:11 | 1 | 7 | `init(selectedOption:options:sizingStyle:visibleRows:interitemSpacing:overlayConfig:content:)` | Reusable UI component for wheel picker view. |
| `WheelTime` | `struct` | `public` | `Components/Selectable/Pickers/TimePickerView.swift`:10 | 2 | 4 | `init(hour:minute:period:)`, `setHour24(_:)` | Reusable UI component for wheel time. |
| `WheelTimeFormat` | `enum` | `public` | `Components/Selectable/Pickers/TimePickerView.swift`:3 | 0 | 0 | - | Reusable UI component for wheel time format. |
| `WheelTimePicker` | `struct` | `public` | `Components/Selectable/Pickers/TimePickerView.swift`:80 | 1 | 0 | `init()` | Reusable UI component for wheel time picker. |
| `WindowTooltipManager` | `class` | `public` | `Components/Tooltip/WindowTooltipManager.swift`:12 | 10 | 14 | `updateTargetFrame(_:frame:)`, `removeTargetFrame(_:)`, `present(step:style:)`, (+7 more) | Reusable UI component for window tooltip manager. |
| `WindowTooltipOverlayGroup` | `struct` | `internal` | `Components/Tooltip/WindowTooltipOverlayGroup.swift`:10 | 0 | 0 | - | Reusable UI component for window tooltip overlay group. |
| `WStack` | `struct` | `public` | `Components/Layouts/WStack.swift`:10 | 4 | 14 | `init(alignment:spacing:lineSpacing:lineLimit:hidesOverflowIndicator:horizontalPadding:)`, `makeCache(subviews:)`, `sizeThatFits(proposal:subviews:cache:)`, (+1 more) | Reusable UI component for wstack. |
| `ZigZag` | `struct` | `public` | `Components/Shapes/ZigZag.swift`:10 | 1 | 1 | `path(in:)` | Reusable UI component for zig zag. |

## Category: ViewModifiers

### Source: Rune

| Symbol | Kind | Access | File | APIs | Params | Entry Points | What |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `AnyFireworksShape` | `struct` | `public` | `ViewModifiers/Fireworks/Models/AnyFireworksShape.swift`:10 | 1 | 1 | `path(in:)` | View-modifier API related to any fireworks shape. |
| `AppBorderConfig` | `struct` | `public` | `ViewModifiers/AppBorder.swift`:10 | 1 | 4 | `init(cornerRadius:tintColor:lineWidth:outerBorder:)` | View-modifier API related to app border config. |
| `Array` | `extension` | `public` | `ViewModifiers/AppleIntellegenceGlow.swift`:112 | 1 | 1 | `customStyle(colors:)` | View-modifier API related to array. |
| `ButtonStyleViewModifier` | `struct` | `public` | `ViewModifiers/AsButton.swift`:10 | 1 | 1 | `makeBody(configuration:)` | View-modifier API related to button style view modifier. |
| `CenterIconStyle` | `struct` | `public` | `ViewModifiers/CenterIconStyle.swift`:10 | 1 | 1 | `makeBody(configuration:)` | View-modifier API related to center icon style. |
| `CustomSafeAreaPadding` | `struct` | `public` | `ViewModifiers/SafeAreaPadding.swift`:11 | 1 | 1 | `body(content:)` | View-modifier API related to custom safe area padding. |
| `FireworksConfiguration` | `struct` | `public` | `ViewModifiers/Fireworks/Models/FireworksConfig.swift`:10 | 1 | 12 | `init(particleCount:lifetime:maxParticleDelay:speed:gravity:velocityDampingPerSecond:size:particleSource:fadeOutFraction:twinkleStrength:fps:blendMode:)` | View-modifier API related to fireworks configuration. |
| `FireworksItem` | `extension` | `internal` | `ViewModifiers/Fireworks/FireworksPreview.swift`:127 | 0 | 0 | - | View-modifier API related to fireworks item. |
| `FireworksOrigin` | `enum` | `public` | `ViewModifiers/Fireworks/Models/FireworksOrigin.swift`:10 | 1 | 1 | `resolve(in:)` | View-modifier API related to fireworks origin. |
| `FireworksParticleAsset` | `enum` | `public` | `ViewModifiers/Fireworks/Models/FireworksParticleSource.swift`:37 | 0 | 0 | - | View-modifier API related to fireworks particle asset. |
| `FireworksParticleSource` | `enum` | `public` | `ViewModifiers/Fireworks/Models/FireworksParticleSource.swift`:10 | 0 | 0 | - | View-modifier API related to fireworks particle source. |
| `GradientBlurHeightStyle` | `enum` | `public` | `ViewModifiers/GradientBlurMask.swift`:20 | 0 | 0 | - | View-modifier API related to gradient blur height style. |
| `GradientBlurMask` | `enum` | `public` | `ViewModifiers/GradientBlurMask.swift`:10 | 0 | 0 | - | View-modifier API related to gradient blur mask. |
| `GradientBlurMaskPreset` | `enum` | `public` | `ViewModifiers/GradientBlurMask.swift`:34 | 0 | 0 | - | View-modifier API related to gradient blur mask preset. |
| `GradientDirection` | `enum` | `public` | `ViewModifiers/GradientBlurMask.swift`:27 | 0 | 0 | - | View-modifier API related to gradient direction. |
| `HorizontalView` | `struct` | `internal` | `ViewModifiers/Stretchy.swift`:68 | 0 | 0 | - | View-modifier API related to horizontal view. |
| `InsettableShape` | `extension` | `public` | `ViewModifiers/AppleIntellegenceGlow.swift`:34 | 1 | 0 | `intelligenceStroke()` | View-modifier API related to insettable shape. |
| `KeyboardInsetModifier` | `struct` | `public` | `ViewModifiers/KeyboardInset.swift`:11 | 1 | 1 | `body(content:)` | View-modifier API related to keyboard inset modifier. |
| `LabelStyle` | `extension` | `public` | `ViewModifiers/CenterIconStyle.swift`:23 | 0 | 0 | - | View-modifier API related to label style. |
| `OnColorSchemeChangeModifier` | `struct` | `internal` | `ViewModifiers/OnColorSchemeChange.swift`:10 | 1 | 1 | `body(content:)` | View-modifier API related to on color scheme change modifier. |
| `OrientationChangeModifier` | `struct` | `public` | `ViewModifiers/OrientationChange.swift`:13 | 1 | 1 | `body(content:)` | Always put this after `onAppear` View needs to be shown before this works. We can always call `onAppear()` like this even though it does nothing |
| `OutlineStrokeModifier` | `struct` | `internal` | `ViewModifiers/OutlineStroke.swift`:26 | 2 | 3 | `init(strokeSize:strokeColor:)`, `body(content:)` | View-modifier API related to outline stroke modifier. |
| `OverlayChannel` | `enum` | `public` | `ViewModifiers/AlwaysOnTop.swift`:12 | 0 | 0 | - | View-modifier API related to overlay channel. |
| `Particle` | `struct` | `internal` | `ViewModifiers/Particle.swift`:10 | 1 | 0 | `reset()` | View-modifier API related to particle. |
| `ParticleModifier` | `struct` | `public` | `ViewModifiers/Particle.swift`:29 | 1 | 1 | `body(content:)` | View-modifier API related to particle modifier. |
| `ParticlePreviewView` | `struct` | `internal` | `ViewModifiers/Particle.swift`:201 | 0 | 0 | - | View-modifier API related to particle preview view. |
| `PlainList` | `struct` | `public` | `ViewModifiers/PlainList.swift`:12 | 1 | 1 | `body(content:)` | View-modifier API related to plain list. |
| `PlainListRow` | `struct` | `internal` | `ViewModifiers/PlainList.swift`:33 | 1 | 1 | `body(content:)` | View-modifier API related to plain list row. |
| `PullToRefreshIndicatorContext` | `struct` | `public` | `ViewModifiers/PullToRefresh/PullToRefreshModifier.swift`:10 | 1 | 3 | `init(progress:offset:isRefreshing:)` | View-modifier API related to pull to refresh indicator context. |
| `PullToRefreshModifier` | `struct` | `public` | `ViewModifiers/PullToRefresh/PullToRefreshModifier.swift`:29 | 3 | 17 | `init(offset:isRefreshing:threshold:refreshIndicator:refreshStyle:autoCompleteRefresh:onRefresh:onRefreshCompleted:)`, `init(offset:isRefreshing:threshold:refreshStyle:autoCompleteRefresh:onRefresh:onRefreshCompleted:customIndicator:)`, `body(content:)` | View-modifier API related to pull to refresh modifier. |
| `RefreshArrowView` | `struct` | `internal` | `ViewModifiers/PullToRefresh/Views/ArrowView.swift`:10 | 0 | 0 | - | View-modifier API related to refresh arrow view. |
| `RefreshIndicatorType` | `enum` | `public` | `ViewModifiers/PullToRefresh/RefreshIndicatorType.swift`:10 | 1 | 3 | `view(progress:offset:isRefreshing:)` | View-modifier API related to refresh indicator type. |
| `RevealAnimationModifier` | `struct` | `public` | `ViewModifiers/RevealAnimation.swift`:10 | 1 | 1 | `body(content:)` | View-modifier API related to reveal animation modifier. |
| `ScenePhaseInstallModifier` | `struct` | `public` | `ViewModifiers/ScenePhaseInstall.swift`:10 | 1 | 1 | `body(content:)` | View-modifier API related to scene phase install modifier. |
| `SegmentedCirclePathView` | `struct` | `public` | `ViewModifiers/PullToRefresh/Views/SegmentedCirclePathView.swift`:11 | 1 | 3 | `init(items:lineWidth:rotationAngle:)` | View-modifier API related to segmented circle path view. |
| `Shape` | `extension` | `public` | `ViewModifiers/Fireworks/Models/AnyFireworksShape.swift`:28 | 1 | 0 | `asFireworksShape()` | View-modifier API related to shape. |
| `SimultaneousSwipeAxisLock` | `enum` | `public` | `ViewModifiers/SwipeGesture/onSimultaneousSwipe.swift`:72 | 0 | 0 | - | View-modifier API related to simultaneous swipe axis lock. |
| `StretchyHeaderViewModifier` | `struct` | `internal` | `ViewModifiers/StretchyHeader.swift`:10 | 2 | 5 | `init(startingHeight:coordinateSpace:shouldScaleOnStretch:maxOffset:)`, `body(content:)` | View-modifier API related to stretchy header view modifier. |
| `SwipeGestureConfiguration` | `struct` | `public` | `ViewModifiers/SwipeGesture/SwipeGestureConfiguration.swift`:10 | 1 | 7 | `init(direction:maxRevealWidth:openThreshold:rowHeight:additionalSwipeInset:interitemSpacing:animation:)` | View-modifier API related to swipe gesture configuration. |
| `SwipeGestureTestScreen` | `struct` | `public` | `ViewModifiers/SwipeGesture/SwipeGestureDemo.swift`:135 | 1 | 0 | `init()` | View-modifier API related to swipe gesture test screen. |
| `SwipeGestureTestScreen2` | `struct` | `public` | `ViewModifiers/SwipeGesture/SwipeGestureDemo.swift`:212 | 1 | 0 | `init()` | View-modifier API related to swipe gesture test screen2. |
| `SwipeGestureView` | `struct` | `public` | `ViewModifiers/SwipeGesture/SwipeGestureView.swift`:10 | 1 | 3 | `init(config:actions:content:)` | View-modifier API related to swipe gesture view. |
| `SwipeGestureViewModifier` | `struct` | `internal` | `ViewModifiers/SwipeGesture/SwipeGestureViewModifier.swift`:10 | 1 | 1 | `body(content:)` | View-modifier API related to swipe gesture view modifier. |
| `TextShimmerModifier` | `struct` | `public` | `ViewModifiers/TextShimmer.swift`:10 | 2 | 8 | `init(_:baseColor:glowColor:duration:bandWidth:blurRadius:direction:)`, `body(content:)` | View-modifier API related to text shimmer modifier. |
| `VerticalView` | `struct` | `internal` | `ViewModifiers/Stretchy.swift`:121 | 0 | 0 | - | View-modifier API related to vertical view. |
| `View` | `extension` | `public` | `ViewModifiers/AdaptiveMaxWidth.swift`:59 | 2 | 5 | `adaptiveMaxWidth(alignment:)`, `adaptiveMaxWidth(phone:ipad:mac:alignment:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/AdaptiveSheet.swift`:80 | 1 | 4 | `adaptiveSheet(isPresented:additionalDetens:backgroundStyle:content:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/AppBorder.swift`:31 | 2 | 5 | `appBorder(config:)`, `appBorder(cornerRadius:color:lineWidth:outerBorder:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/AppleIntellegenceGlow.swift`:11 | 2 | 2 | `intelligenceBackground(in:)`, `intelligenceOverlay(in:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/AsButton.swift`:26 | 2 | 7 | `asButton(scale:opacity:brightness:action:)`, `appOnTapGesture(count:hapticStyle:perform:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/Fireworks/Fireworks.swift`:31 | 2 | 7 | `init(trigger:configuration:origin:)`, `init(isTriggered:configuration:origin:resetDelay:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/FrameInfinity.swift`:11 | 1 | 1 | `frameInfinity(alignment:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/GradientBlurMask.swift`:42 | 1 | 7 | `gradientBlur(color:alignment:gradientDirection:mask:heightStyle:additionalHeightPadding:allowsHitTesting:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/Grain.swift`:12 | 1 | 3 | `grain(intensity:blendMode:tileSize:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/KeyboardInset.swift`:51 | 1 | 1 | `keyboardInset(_:)` | View-modifier API related to view. |
| `View` | `extension` | `internal` | `ViewModifiers/OnColorSchemeChange.swift`:32 | 1 | 1 | `onColorSchemeChange(_:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/OnFirstAppear.swift`:10 | 1 | 1 | `onFirstAppear(_:)` | View-modifier API related to view. |
| `View` | `extension` | `internal` | `ViewModifiers/OnFirstTask.swift`:10 | 0 | 0 | - | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/OrientationChange.swift`:29 | 1 | 1 | `detectRotation(change:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/OutlineStroke.swift`:10 | 1 | 2 | `outlineStroke(color:width:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/Particle.swift`:145 | 1 | 6 | `particleEffect(systemImage:font:status:activeColor:inActiveColor:largeDistance:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/PlainList.swift`:25 | 1 | 0 | `plainListStyle()` | View-modifier API related to view. |
| `View` | `extension` | `internal` | `ViewModifiers/PlainList.swift`:46 | 1 | 0 | `plainListRowStyle()` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/PullOffset.swift`:10 | 1 | 3 | `pullOffset(threshold:initialBuffer:zIndex:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/PullToRefresh/Ext+View/Ext+PullToRefresh.swift`:10 | 5 | 35 | `pullToRefresh(offset:isRefreshing:threshold:refreshIndicator:refreshStyle:autoCompleteRefresh:onRefresh:onRefreshCompleted:)`, `pullToRefreshAsync(offset:isRefreshing:threshold:refreshIndicator:refreshStyle:autoCompleteRefresh:onRefreshAsync:onRefreshCompleted:)`, `pullToRefreshCustom(offset:isRefreshing:threshold:refreshStyle:autoCompleteRefresh:onRefre... | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/RevealAnimation.swift`:59 | 1 | 3 | `revealAnimation(delay:direction:offset:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/ReversedMask.swift`:10 | 1 | 2 | `reversedMask(alignment:mask:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/SafeAreaPadding.swift`:53 | 1 | 3 | `customSafeAreaPadding(padding:for:shouldSupportKeyboardOffset:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/ScenePhaseInstall.swift`:47 | 1 | 1 | `onSceneActiveInstall(_:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/Stretchy.swift`:10 | 1 | 2 | `stretchy(axis:uniform:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/StretchyHeader.swift`:55 | 1 | 4 | `asStretchyHeader(startingHeight:shouldScaleOnStretch:coordinateSpace:maxOffset:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/SwipeGesture/SwipeGestureViewModifier.swift`:29 | 1 | 2 | `init(config:actions:)` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/SwipeGesture/onSimultaneousSwipe.swift`:10 | 1 | 0 | `onSimultaneousSwipe()` | View-modifier API related to view. |
| `View` | `extension` | `public` | `ViewModifiers/TextShimmer.swift`:189 | 1 | 7 | `textShimmer(_:baseColor:glowColor:duration:bandWidth:blurRadius:direction:)` | View-modifier API related to view. |

## Category: Services

### Source: Rune

| Symbol | Kind | Access | File | APIs | Params | Entry Points | What |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `AlertModifier` | `struct` | `public` | `Services/Alert/Models/Alerts/MultiAlertView.swift`:321 | 1 | 1 | `body(content:)` | Service-layer API handling alert modifier. |
| `AlertService` | `class` | `public` | `Services/Alert/AlertService.swift`:13 | 8 | 4 | `init()`, `showAlert(_:)`, `dismissAlert(_:)`, (+5 more) | Service-layer API handling alert service. |
| `AlertServiceProtocol` | `protocol` | `public` | `Services/Alert/AlertServiceProtocol.swift`:10 | 7 | 4 | `showAlert(_:)`, `dismissAlert(_:)`, `dismiss(_:)`, (+4 more) | Service-layer API handling alert service protocol. |
| `AlertStyle` | `enum` | `public` | `Services/Alert/Models/Alerts/AlertStyle.swift`:10 | 0 | 0 | - | Service-layer API handling alert style. |
| `AlertTextFieldView` | `struct` | `internal` | `Services/Alert/Models/Alerts/ConfigViews/AlertTextFieldView.swift`:10 | 4 | 11 | `init(alert:initialText:isPresented:action:dismissAction:)`, `init(alert:initialText:action:dismissAction:)`, `button(title:color:)`, (+1 more) | Service-layer API handling alert text field view. |
| `AlertViewModifier` | `struct` | `internal` | `Services/Alert/Models/Alerts/ViewModifiers/AlertViewModifier.swift`:10 | 2 | 4 | `init(isPresented:shouldDismissOnTouch:alertStyle:)`, `body(content:)` | Service-layer API handling alert view modifier. |
| `AppAlertCardView` | `struct` | `internal` | `Services/Alert/Models/Alerts/ConfigViews/AppAlertCardView.swift`:10 | 0 | 0 | - | Service-layer API handling app alert card view. |
| `AppAlertConfig` | `struct` | `public` | `Services/Alert/Models/Configs/AppAlertConfig.swift`:10 | 3 | 41 | `init(title:titleFont:titleColor:message:messageFont:messageColor:icon:iconTintColor:iconSize:primaryButtonTitle:primaryButtonAction:primaryButtonBackgroundColor:primaryButtonTextColor:secondaryButtonTitle:secondaryButtonAction:secondaryButtonBackgroundColor:secondaryButtonTextColor:)`, `init(title:titleFont:titleColor:message:messageFont:messageColor:ico... | Service-layer API handling app alert config. |
| `AppAlertView` | `struct` | `internal` | `Services/Alert/Models/Alerts/ConfigViews/AppAlertView.swift`:10 | 3 | 4 | `init(alert:isPresented:)`, `init(alert:dismissAction:)`, `buttonStackView()` | Service-layer API handling app alert view. |
| `AppCardConfig` | `struct` | `public` | `Services/Alert/Models/Configs/AppCardConfig.swift`:33 | 1 | 7 | `init(viewBuilder:cornerRadius:backgroundCardInset:contentCardInset:cardBackgroundColor:shouldDismissOnOutsideTouch:shouldDismissOnDrag:)` | Service-layer API handling app card config. |
| `AppCardConfig` | `extension` | `public` | `Services/Alert/Models/Configs/AppCardConfig.swift`:107 | 2 | 12 | `simpleCard(title:subtitle:imageResource:buttonTitle:buttonTitleColor:bottomPadding:)`, `actionSheet(title:message:options:cancelTitle:shouldDismissOnOutsideTouch:shouldDismissOnDrag:)` | Service-layer API handling app card config. |
| `AppFontViewModifier` | `struct` | `public` | `Services/DesignSystem/StyleExtensions/StyleFont.swift`:19 | 1 | 1 | `body(content:)` | Service-layer API handling app font view modifier. |
| `AppLoadingConfig` | `struct` | `public` | `Services/Alert/Models/Configs/AppLoadingConfig.swift`:10 | 1 | 1 | `init(loadStyle:)` | Service-layer API handling app loading config. |
| `ClipboardService` | `class` | `public` | `Services/ClipboardService.swift`:19 | 2 | 1 | `init()`, `set(text:)` | Service-layer API handling clipboard service. |
| `ClipboardServiceInterface` | `protocol` | `public` | `Services/ClipboardService.swift`:11 | 1 | 1 | `set(text:)` | Service-layer API handling clipboard service interface. |
| `ContentInset` | `struct` | `public` | `Services/Alert/Models/Configs/AppCardConfig.swift`:10 | 1 | 4 | `init(top:left:bottom:right:)` | Service-layer API handling content inset. |
| `DynamicIslandAlwaysOnTop` | `struct` | `public` | `Services/DynamicIsland/DynamicIslandPreview.swift`:12 | 1 | 0 | `init()` | Service-layer API handling dynamic island always on top. |
| `DynamicIslandBridgeView` | `struct` | `internal` | `Services/DynamicIsland/DynamicIslandBridgeView.swift`:11 | 0 | 0 | - | Service-layer API handling dynamic island bridge view. |
| `DynamicIslandManager` | `class` | `public` | `Services/DynamicIsland/DynamicIslandManager.swift`:12 | 4 | 2 | `present(_:)`, `present(_:)`, `dismiss()`, (+1 more) | Service-layer API handling dynamic island manager. |
| `DynamicIslandView` | `struct` | `public` | `Services/DynamicIsland/DynamicIslandView.swift`:14 | 1 | 5 | `init(isPresented:forceDynamicIsland:containerColor:animation:content:)` | Service-layer API handling dynamic island view. |
| `EdgeInsets` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleSpacing.swift`:27 | 4 | 7 | `init(top:left:bottom:right:)`, `init(spacing:)`, `init(verticalSpacing:)`, (+1 more) | Service-layer API handling edge insets. |
| `EnviornmentAlertViewConfig` | `struct` | `public` | `Services/Alert/Models/Alerts/ConfigViews/EnvironmentAlertView.swift`:10 | 1 | 10 | `init(title:titleColor:message:messageColor:image:imageColor:buttonTitle:buttonTitleColor:buttonColor:action:)` | Service-layer API handling enviornment alert view config. |
| `EnvironmentAlertView` | `struct` | `public` | `Services/Alert/Models/Alerts/ConfigViews/EnvironmentAlertView.swift`:49 | 1 | 1 | `init(config:)` | Service-layer API handling environment alert view. |
| `EnvironmentValues` | `extension` | `public` | `Services/DesignSystem/Style.swift`:10 | 0 | 0 | - | Service-layer API handling environment values. |
| `ErrorHandlerModifier` | `struct` | `internal` | `Services/Alert/Models/Alerts/ViewModifiers/ErrorHandlerModifier.swift`:10 | 1 | 1 | `body(content:)` | Service-layer API handling error handler modifier. |
| `Font` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleFont.swift`:10 | 1 | 1 | `appFont(_:)` | Service-layer API handling font. |
| `FontThemePreview` | `struct` | `public` | `Services/DesignSystem/FontThemePreview.swift`:10 | 1 | 0 | `init()` | Service-layer API handling font theme preview. |
| `KeyboardManager` | `class` | `public` | `Services/KeyboardManager.swift`:12 | 1 | 0 | `init()` | Service-layer API handling keyboard manager. |
| `Keychain` | `enum` | `public` | `Services/Keychain.swift`:11 | 0 | 0 | - | Service-layer API handling keychain. |
| `Keychain` | `extension` | `internal` | `Services/Keychain.swift`:13 | 0 | 0 | - | Service-layer API handling keychain. |
| `Keychain` | `extension` | `internal` | `Services/Keychain.swift`:50 | 0 | 0 | - | Service-layer API handling keychain. |
| `Keychain` | `extension` | `internal` | `Services/Keychain.swift`:77 | 0 | 0 | - | Service-layer API handling keychain. |
| `Keychain` | `extension` | `internal` | `Services/Keychain.swift`:123 | 0 | 0 | - | Service-layer API handling keychain. |
| `Label` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleFont.swift`:38 | 1 | 1 | `appFont(with:)` | Service-layer API handling label. |
| `MultiAlertShowcaseView` | `struct` | `internal` | `Services/Alert/Models/Alerts/MultiAlertShowcaseView.swift`:11 | 0 | 0 | - | Service-layer API handling multi alert showcase view. |
| `MultiAlertView` | `struct` | `public` | `Services/Alert/Models/Alerts/MultiAlertView.swift`:10 | 1 | 2 | `init(alertService:content:)` | Service-layer API handling multi alert view. |
| `ObservableAlertServiceWrapper` | `class` | `public` | `Services/Alert/ObservableAlertServiceWrapper.swift`:12 | 4 | 5 | `init(alertService:loggingEnabled:)`, `showAlert(_:)`, `dismissAlert(_:)`, (+1 more) | Service-layer API handling observable alert service wrapper. |
| `RNCacheConfiguration` | `struct` | `public` | `Services/ImageCache/RNCacheConfiguration.swift`:55 | 1 | 11 | `init(maxDiskAgeDays:maxMemoryCostLimitMB:requestTimeoutSeconds:maxConcurrentLoadTasks:maxInFlightTasks:failureRetryDelaySeconds:urlCacheMemoryCapacityMB:urlCacheDiskCapacityMB:maxHTTPConnectionsPerHost:previewMaxHTTPConnectionsPerHost:remoteImageBehavior:)` | Service-layer API handling rncache configuration. |
| `RNCachedImage` | `struct` | `public` | `Services/ImageCache/RNCachedImage.swift`:23 | 0 | 0 | - | Service-layer API handling rncached image. |
| `RNDiskImageCache` | `actor` | `internal` | `Services/ImageCache/RNDiskImageCache.swift`:12 | 3 | 3 | `readData(forKey:)`, `writeData(_:forKey:)`, `clearAll()` | Service-layer API handling rndisk image cache. |
| `RNImagePrefetcher` | `actor` | `internal` | `Services/ImageCache/RNImagePrefetcher.swift`:12 | 3 | 4 | `prefetch(urls:targetSize:scale:)`, `cancelPrefetching(for:)`, `cancelAll()` | Service-layer API handling rnimage prefetcher. |
| `RNRemoteImageBehavior` | `struct` | `public` | `Services/ImageCache/RNCacheConfiguration.swift`:40 | 1 | 2 | `init(retry:failureUI:)` | Service-layer API handling rnremote image behavior. |
| `RNRemoteImageFailureUIConfiguration` | `struct` | `public` | `Services/ImageCache/RNCacheConfiguration.swift`:28 | 1 | 1 | `init(showsRetryUIOnFailure:)` | Service-layer API handling rnremote image failure uiconfiguration. |
| `RNRemoteImagePipeline` | `actor` | `internal` | `Services/ImageCache/RNRemoteImagePipeline.swift`:114 | 2 | 6 | `image(for:targetSize:scale:)`, `imageResult(for:targetSize:scale:)` | Service-layer API handling rnremote image pipeline. |
| `RNRemoteImagePipelineError` | `enum` | `internal` | `Services/ImageCache/RNRemoteImagePipeline.swift`:85 | 0 | 0 | - | Service-layer API handling rnremote image pipeline error. |
| `RNRemoteImageRetryConfiguration` | `struct` | `public` | `Services/ImageCache/RNCacheConfiguration.swift`:10 | 1 | 3 | `init(autoRetryTemporarilyDeferredFailures:maxAutoRetryAttempts:autoRetryDelaySeconds:)` | Service-layer API handling rnremote image retry configuration. |
| `RuneAlert` | `struct` | `public` | `Services/Alert/Alert.swift`:10 | 1 | 2 | `init(_:id:)` | Service-layer API handling rune alert. |
| `Style` | `class` | `public` | `Services/DesignSystem/Style.swift`:15 | 8 | 8 | `updateTheme(_:)`, `foreground(_:)`, `background(_:)`, (+5 more) | Service-layer API handling style. |
| `StyleProtocol` | `protocol` | `public` | `Services/DesignSystem/StyleProtocol.swift`:10 | 8 | 8 | `updateTheme(_:)`, `foreground(_:)`, `background(_:)`, (+5 more) | Service-layer API handling style protocol. |
| `StyleSystemShadow` | `struct` | `public` | `Services/DesignSystem/StyleExtensions/StyleSystemShadow.swift`:10 | 1 | 1 | `body(content:)` | Service-layer API handling style system shadow. |
| `Text` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleFont.swift`:47 | 1 | 1 | `appFont(with:)` | Service-layer API handling text. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/CustomThemes/CoralTwilight.swift`:10 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/CustomThemes/EmeraldNoir.swift`:10 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/CustomThemes/GoldLight.swift`:10 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/CustomThemes/GoldNavy.swift`:10 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/CustomThemes/GoldNavy.swift`:50 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/CustomThemes/NeonNight.swift`:10 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/CustomThemes/SandstoneDusk.swift`:10 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/CustomThemes/TealCyanLight.swift`:10 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/Defaults.swift`:10 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/Defaults.swift`:24 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/Defaults.swift`:38 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/Defaults.swift`:54 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/Defaults.swift`:116 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/Defaults.swift`:164 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `extension` | `internal` | `Services/DesignSystem/StyleExtensions/Defaults.swift`:181 | 0 | 0 | - | Service-layer API handling theme. |
| `Theme` | `struct` | `public` | `Services/DesignSystem/Theme.swift`:10 | 1 | 10 | `init(id:foreground:background:textColor:spacing:radius:fonts:shadow:buttonBounceStyle:alertStyle:)` | Service-layer API handling theme. |
| `ThemeProtocol` | `protocol` | `public` | `Services/DesignSystem/ThemeProtocol.swift`:10 | 0 | 0 | - | Service-layer API handling theme protocol. |
| `ToastGroup` | `struct` | `public` | `Services/Toast/ToastListView.swift`:10 | 2 | 2 | `offsetY(_:)`, `scale(_:)` | Service-layer API handling toast group. |
| `ToastItem` | `struct` | `public` | `Services/Toast/Toast.swift`:10 | 2 | 18 | `init(title:titleColor:message:messageColor:backgroundColor:image:tint:clipShape:shadow:isUserInteractionEnabled:timing:direction:)`, `init(clipShape:shadow:isUserInteractionEnabled:timing:direction:content:)` | Service-layer API handling toast item. |
| `ToastManager` | `class` | `public` | `Services/Toast/ToastManager.swift`:12 | 1 | 1 | `present(toastItem:)` | Service-layer API handling toast manager. |
| `ToastOverlayModifier` | `struct` | `public` | `Services/Toast/ToastViewModifier.swift`:10 | 1 | 1 | `body(content:)` | Service-layer API handling toast overlay modifier. |
| `ToastView` | `struct` | `internal` | `Services/Toast/ToastView.swift`:10 | 1 | 0 | `removeToast()` | Service-layer API handling toast view. |
| `UIFont` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleFont.swift`:56 | 2 | 4 | `rounded(size:weight:)`, `serif(size:weight:)` | Service-layer API handling uifont. |
| `View` | `extension` | `public` | `Services/Alert/Models/Alerts/MultiAlertView.swift`:335 | 1 | 1 | `withAlertService(_:)` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/Alert/Models/Alerts/MultiAlertView.swift`:343 | 1 | 1 | `withWindowAlertService(_:)` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/Alert/Models/Alerts/ViewModifiers/AlertViewModifier.swift`:159 | 1 | 3 | `alertView(isPresented:shouldDismissOnTouch:alertStyle:)` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/Alert/Models/Alerts/ViewModifiers/ErrorHandlerModifier.swift`:40 | 1 | 2 | `errorHandler(error:alertStyle:)` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleCornerRadius.swift`:10 | 1 | 1 | `cornerRadius(_:)` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleFont.swift`:30 | 1 | 1 | `appFont(with:)` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleSpacing.swift`:10 | 2 | 3 | `padding(_:_:)`, `padding(_:)` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/DesignSystem/StyleExtensions/StyleSystemShadow.swift`:30 | 1 | 1 | `appShadow(_:)` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/DynamicIsland/DynamicIslandViewModifier.swift`:11 | 1 | 0 | `withWindowDynamicIslandService()` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/Toast/ToastViewModifier.swift`:25 | 1 | 0 | `withToastOverlay()` | Service-layer API handling view. |
| `View` | `extension` | `public` | `Services/Toast/ToastViewModifier.swift`:34 | 1 | 0 | `withWindowToastOverlay()` | Service-layer API handling view. |

## Category: Views

### Source: Rune

| Symbol | Kind | Access | File | APIs | Params | Entry Points | What |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `AppFlipView` | `struct` | `internal` | `Views/AppFlipView.swift`:10 | 3 | 5 | `init(isFlipped:duration:front:back:)`, `flipCard()`, `calculateInitialDegrees(isFlipped:)` | Standalone view for app flip view. |
| `BubblesPattern` | `struct` | `internal` | `Views/Patterns/Patterns/BubblesPattern.swift`:78 | 1 | 5 | `init(isAnimating:speed:scale:config:geo:)` | Standalone view for bubbles pattern. |
| `BubblesPatternConfig` | `struct` | `public` | `Views/Patterns/Patterns/BubblesPattern.swift`:45 | 1 | 1 | `init(items:)` | Standalone view for bubbles pattern config. |
| `BubblesPatternItemConfig` | `struct` | `public` | `Views/Patterns/Patterns/BubblesPattern.swift`:10 | 1 | 5 | `init(id:size:origin:delta:duration:)` | Standalone view for bubbles pattern item config. |
| `CalendarView` | `struct` | `public` | `Views/Calendar/Calendar.swift`:10 | 1 | 7 | `init(viewModel:backgroundStyle:clipShape:dayTextFont:dayTextColor:dayCornerRadius:daySelectionInset:)` | Standalone view for calendar view. |
| `CalendarViewModel` | `class` | `public` | `Views/Calendar/CalendarViewModel.swift`:11 | 5 | 8 | `setup(policy:enablesMonthToggling:selectionColor:selectionTextColor:selectionIconName:didTapDateAction:)`, `toggleDaySelection(_:)`, `goToNextMonth()`, (+2 more) | Standalone view for calendar view model. |
| `CameraPickerView` | `struct` | `internal` | `Views/Camera + Photos/CameraPickerView.swift`:12 | 4 | 6 | `init(sourceType:onImagePicked:onDismiss:)`, `makeUIViewController(context:)`, `updateUIViewController(_:context:)`, (+1 more) | Standalone view for camera picker view. |
| `CameraViewTestView` | `struct` | `internal` | `Views/Camera + Photos/CameraPickerView.swift`:86 | 0 | 0 | - | Standalone view for camera view test view. |
| `CardSwipeView` | `struct` | `public` | `Views/CardSwipeView.swift`:10 | 1 | 5 | `init(selected:items:config:onCompletionSwipeAction:cardContent:)` | Standalone view for card swipe view. |
| `CommonTimelineView` | `struct` | `public` | `Views/Timeline/CommonTimelineView.swift`:63 | 1 | 7 | `init(currentStepIndex:steps:direction:defaultAnimationStyle:shape:shapeSize:lineWidth:)` | Standalone view for common timeline view. |
| `CustomTimelineView` | `struct` | `public` | `Views/Timeline/CustomTimelineView.swift`:21 | 2 | 18 | `init(currentStepIndex:steps:defaultAnimationStyle:shape:shapeSize:lineWidth:stepSpacing:contentAlignment:content:)`, `init(currentStepIndex:steps:defaultAnimationStyle:shape:shapeSize:lineWidth:stepSpacing:contentAlignment:content:)` | Standalone view for custom timeline view. |
| `Day` | `struct` | `public` | `Views/Calendar/Models/Day.swift`:18 | 0 | 0 | - | Standalone view for day. |
| `DayContent` | `enum` | `public` | `Views/Calendar/Models/Day.swift`:10 | 0 | 0 | - | Standalone view for day content. |
| `DefaultHubView` | `struct` | `public` | `Views/SpinWheel/DefaultHubView.swift`:10 | 1 | 1 | `init(size:)` | Standalone view for default hub view. |
| `DiagonalsPattern` | `struct` | `internal` | `Views/Patterns/Patterns/DiagonalsPattern.swift`:29 | 1 | 5 | `init(isAnimating:speed:scale:config:geo:)` | Standalone view for diagonals pattern. |
| `DiagonalsPatternConfig` | `struct` | `public` | `Views/Patterns/Patterns/DiagonalsPattern.swift`:10 | 1 | 2 | `init(rotation:lineCount:)` | Standalone view for diagonals pattern config. |
| `Distribution` | `enum` | `public` | `Views/SpinWheel/Models/Distrbution.swift`:11 | 0 | 0 | - | Standalone view for distribution. |
| `DotPattern` | `struct` | `internal` | `Views/Patterns/Patterns/DotPattern.swift`:44 | 1 | 5 | `init(isAnimating:speed:scale:config:geo:)` | Standalone view for dot pattern. |
| `DotPatternConfig` | `struct` | `public` | `Views/Patterns/Patterns/DotPattern.swift`:10 | 1 | 7 | `init(spacing:dotSize:dotOpacity:rotation:yOffset:duration:columnDelay:)` | Standalone view for dot pattern config. |
| `EmailComposer` | `struct` | `public` | `Views/EmailComposer/Views/EmailComposer.swift`:10 | 2 | 5 | `init(isPresented:emailData:onDismiss:result:)`, `body(content:)` | Standalone view for email composer. |
| `EmailComposerData` | `struct` | `public` | `Views/EmailComposer/Models/EmailComposerData.swift`:10 | 1 | 5 | `init(subject:recipients:body:isHTML:attachments:)` | Standalone view for email composer data. |
| `EmailComposerResult` | `enum` | `public` | `Views/EmailComposer/Models/EmailComposerResult.swift`:8 | 0 | 0 | - | Standalone view for email composer result. |
| `EmailComposerView` | `struct` | `public` | `Views/EmailComposer/Views/EmailComposerView.swift`:11 | 5 | 5 | `init(emailData:result:)`, `makeUIViewController(context:)`, `updateUIViewController(_:context:)`, (+2 more) | Standalone view for email composer view. |
| `FloatingTabStyle` | `struct` | `public` | `Views/TabBars/Views/Styles/FloatingTabStyle.swift`:10 | 0 | 0 | - | Standalone view for floating tab style. |
| `FloatingTransitionAnimatedTitleStyle` | `struct` | `public` | `Views/TabBars/Views/Styles/FloatingTransitionAnimatedTitleStyle.swift`:10 | 0 | 0 | - | Standalone view for floating transition animated title style. |
| `FloatingTransitionTabStyle` | `struct` | `public` | `Views/TabBars/Views/Styles/FloatingTransitionTabStyle.swift`:10 | 0 | 0 | - | Standalone view for floating transition tab style. |
| `GalleryContainerView` | `struct` | `public` | `Views/GalleryContainerView.swift`:10 | 1 | 7 | `init(selectedItem:items:backgroundColor:cornerRadius:lineWidth:lineColor:height:)` | Standalone view for gallery container view. |
| `GridOverlay` | `struct` | `public` | `Views/GridOverlay.swift`:10 | 1 | 7 | `init(divisions:lineColor:lineOpacity:lineWidth:inset:showsOuterBorder:dash:)` | Standalone view for grid overlay. |
| `Marquee` | `struct` | `public` | `Views/Marquee.swift`:10 | 1 | 5 | `init(isActive:speed:interitemSpacing:autoReverse:content:)` | Standalone view for marquee. |
| `MovingGridPattern` | `struct` | `internal` | `Views/Patterns/Patterns/GridPattern.swift`:22 | 1 | 5 | `init(isAnimating:speed:scale:config:geo:)` | Standalone view for moving grid pattern. |
| `MovingGridPatternConfig` | `struct` | `public` | `Views/Patterns/Patterns/GridPattern.swift`:10 | 1 | 1 | `init(cellSize:)` | Standalone view for moving grid pattern config. |
| `MultiSelectionPolicy` | `struct` | `internal` | `Views/Calendar/Models/SelectionPolicy.swift`:94 | 2 | 7 | `init(maxSelections:minStartDate:maxEndDate:excludedDates:)`, `processTap(at:currentSelected:calendar:)` | Standalone view for multi selection policy. |
| `PassThroughWindow` | `class` | `public` | `Views/PassThroughWindow.swift`:3 | 1 | 2 | `hitTest(_:with:)` | Standalone view for pass through window. |
| `PatternCardType` | `enum` | `public` | `Views/Patterns/Models/PatternCardType.swift`:8 | 0 | 0 | - | Standalone view for pattern card type. |
| `PatternCardView` | `struct` | `public` | `Views/Patterns/PatternCardView.swift`:10 | 1 | 6 | `init(patternType:colors:isAnimating:speed:scale:content:)` | Standalone view for pattern card view. |
| `PhotoPickerView` | `struct` | `public` | `Views/Camera + Photos/PhotoPickerView.swift`:11 | 1 | 4 | `init(selectedImage:mediaType:content:onError:)` | Standalone view for photo picker view. |
| `PointerView` | `struct` | `internal` | `Views/SpinWheel/PointerView.swift`:10 | 1 | 8 | `init(rotation:pointerAngle:pointerRotationOffset:segments:distribution:defaultColor:shouldUpdateColor:liveSegment:)` | Standalone view for pointer view. |
| `RangeSelectionPolicy` | `struct` | `internal` | `Views/Calendar/Models/SelectionPolicy.swift`:143 | 2 | 8 | `init(minRange:maxRange:minStartDate:maxEndDate:excludedDates:)`, `processTap(at:currentSelected:calendar:)` | Standalone view for range selection policy. |
| `RipplesPattern` | `struct` | `internal` | `Views/Patterns/Patterns/RipplePattern.swift`:38 | 1 | 5 | `init(isAnimating:speed:scale:config:geo:)` | Standalone view for ripples pattern. |
| `RipplesPatternConfig` | `struct` | `public` | `Views/Patterns/Patterns/RipplePattern.swift`:10 | 1 | 5 | `init(ringCount:baseSpacing:lineWidth:baseOpacity:duration:)` | Standalone view for ripples pattern config. |
| `ScrollingTabHeaderItem` | `struct` | `public` | `Views/ScrollingTabView.swift`:10 | 1 | 6 | `init(title:icon:selectedColor:unselectedColor:selectedFont:unselectedFont:)` | Standalone view for scrolling tab header item. |
| `ScrollingTabView` | `struct` | `public` | `Views/ScrollingTabView.swift`:45 | 5 | 13 | `init(pageHeaders:pageHeaderStyle:pageHeaderDividerColor:pageHeaderDividerWidth:pageHeaderSelectedColor:pageHeaderItemToDividerVerticalSpacing:backgroundColor:pages:)`, `pages(size:)`, `contentScrollView(header:size:collection:)`, (+2 more) | Standalone view for scrolling tab view. |
| `ScrollingTabViewPreview` | `struct` | `internal` | `Views/ScrollingTabView.swift`:344 | 0 | 0 | - | Standalone view for scrolling tab view preview. |
| `Segment` | `struct` | `public` | `Views/SpinWheel/Models/Segment.swift`:11 | 1 | 4 | `init(name:value:color:backgroundImage:)` | Standalone view for segment. |
| `SelectionMode` | `enum` | `public` | `Views/Calendar/Models/SelectionPolicy.swift`:10 | 0 | 0 | - | Standalone view for selection mode. |
| `SelectionPolicy` | `protocol` | `public` | `Views/Calendar/Models/SelectionPolicy.swift`:18 | 1 | 3 | `processTap(at:currentSelected:calendar:)` | Standalone view for selection policy. |
| `SelectionPolicy` | `extension` | `internal` | `Views/Calendar/Models/SelectionPolicy.swift`:33 | 3 | 6 | `normalized(_:calendar:)`, `isWithinBounds(_:calendar:)`, `isExcludedDate(_:calendar:)` | Standalone view for selection policy. |
| `SineWavesPattern` | `struct` | `internal` | `Views/Patterns/Patterns/WaveShape.swift`:32 | 1 | 5 | `init(isAnimating:speed:scale:config:geo:)` | Standalone view for sine waves pattern. |
| `SineWavesPatternConfig` | `struct` | `public` | `Views/Patterns/Patterns/WaveShape.swift`:10 | 1 | 3 | `init(amplitude:frequency:waveSpacing:)` | Standalone view for sine waves pattern config. |
| `SingleSelectionPolicy` | `struct` | `internal` | `Views/Calendar/Models/SelectionPolicy.swift`:64 | 2 | 6 | `init(minStartDate:maxEndDate:excludedDates:)`, `processTap(at:currentSelected:calendar:)` | Standalone view for single selection policy. |
| `SliceView` | `struct` | `internal` | `Views/SpinWheel/SliceView.swift`:10 | 0 | 0 | - | Standalone view for slice view. |
| `SpinWheel` | `struct` | `public` | `Views/SpinWheel/SpinWheel.swift`:10 | 1 | 16 | `init(segments:distribution:size:pickerColor:segmentDividerColor:pointerAngle:pointerRotationOffset:spinAnimation:shouldChangeColorWhileSpinning:allowsDragging:enablePassiveSpin:spinTrigger:onSpinStart:onSpinEnd:sliceContent:hubContent:)` | Standalone view for spin wheel. |
| `SpinWheel` | `extension` | `internal` | `Views/SpinWheel/SpinWheel.swift`:292 | 1 | 13 | `init(segments:distribution:size:pickerColor:segmentDividerColor:pointerAngle:pointerRotationOffset:spinAnimation:shouldChangeColorWhileSpinning:allowsDragging:enablePassiveSpin:onSpinStart:onSpinEnd:)` | Standalone view for spin wheel. |
| `StandardTabBarStyle` | `struct` | `public` | `Views/TabBars/Views/Styles/StandardTabStyle.swift`:10 | 0 | 0 | - | Standalone view for standard tab bar style. |
| `StarfieldPattern` | `struct` | `internal` | `Views/Patterns/Patterns/StarPattern.swift`:69 | 1 | 5 | `init(isAnimating:speed:scale:config:geo:)` | Standalone view for starfield pattern. |
| `StarfieldPatternConfig` | `struct` | `public` | `Views/Patterns/Patterns/StarPattern.swift`:10 | 1 | 1 | `init(stars:)` | Standalone view for starfield pattern config. |
| `StarfieldPatternItemConfig` | `struct` | `public` | `Views/Patterns/Patterns/StarPattern.swift`:40 | 1 | 6 | `init(id:size:startX:startY:speedMultiplier:opacity:)` | Standalone view for starfield pattern item config. |
| `StepAnimationStyle` | `enum` | `public` | `Views/Timeline/CommonTimelineView.swift`:11 | 0 | 0 | - | Defines the style and animation behavior for a single step in the timeline. |
| `TabItem` | `struct` | `public` | `Views/TabBars/TabItem.swift`:10 | 2 | 6 | `hash(into:)`, `init(title:unselectedColor:unselectedIcon:selectedColor:selectedIcon:)` | Standalone view for tab item. |
| `TabItem` | `extension` | `internal` | `Views/TabBars/TabItem.swift`:51 | 1 | 0 | `DUMMY_DATA()` | Standalone view for tab item. |
| `TabItemView` | `struct` | `public` | `Views/TabBars/Views/TabItemView.swift`:10 | 1 | 7 | `init(tab:selectedTab:unselectedColor:unselectedIcon:selectedColor:selectedIcon:verticalSpacing:)` | Standalone view for tab item view. |
| `TickMarkSliderDecimalView` | `struct` | `public` | `Views/TickMarkSliderDecimalView.swift`:10 | 1 | 15 | `init(value:range:tickStep:stepWidth:showValueLabel:valueFont:measurementText:measurementFont:tickTitleColor:selectedTickColor:unselectedTickColor:majorTickInterval:majorTickHeight:minorTickHeight:velocitySensitivity:)` | Standalone view for tick mark slider decimal view. |
| `TickMarkSliderView` | `struct` | `public` | `Views/TickMarkSliderView.swift`:10 | 1 | 14 | `init(value:range:stepWidth:showValueLabel:valueFont:measurementText:measurementFont:tickTitleColor:selectedTickColor:unselectedTickColor:majorTickInterval:majorTickHeight:minorTickHeight:velocitySensitivity:)` | Standalone view for tick mark slider view. |
| `View` | `extension` | `public` | `Views/EmailComposer/Views/EmailComposer.swift`:58 | 1 | 4 | `emailComposer(isPresented:emailData:onDismiss:result:)` | Standalone view for view. |
| `WheelMath` | `struct` | `internal` | `Views/SpinWheel/Math/WheelMath.swift`:10 | 2 | 8 | `segment(for:pointerAngle:in:distribution:)`, `rotationToLand(on:currentRotation:pointerAngle:segments:)` | Standalone view for wheel math. |
| `WheelView` | `struct` | `internal` | `Views/SpinWheel/WheelView.swift`:10 | 0 | 0 | - | Standalone view for wheel view. |
| `ZoomView` | `struct` | `public` | `Views/ZoomView.swift`:10 | 1 | 1 | `init(content:)` | Standalone view for zoom view. |

## Category: Extensions

### Source: Rune

| Symbol | Kind | Access | File | APIs | Params | Entry Points | What |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Array` | `extension` | `public` | `Extensions/Ext+Array.swift`:8 | 0 | 0 | - | Extension API for array. |
| `Bool` | `extension` | `internal` | `Extensions/Ext+Primatives.swift`:18 | 0 | 0 | - | Extension API for bool. |
| `CGFloat` | `extension` | `internal` | `Extensions/Ext+Primatives.swift`:34 | 0 | 0 | - | Extension API for cgfloat. |
| `CGFloat` | `extension` | `internal` | `Extensions/Ext+Primatives.swift`:58 | 1 | 1 | `truncate(places:)` | Extension API for cgfloat. |
| `Color` | `extension` | `public` | `Extensions/Ext+Color.swift`:55 | 4 | 5 | `init(light:dark:)`, `init(hex:)`, `hexStringFromColor()`, (+1 more) | Extension API for color. |
| `Color` | `extension` | `internal` | `Extensions/Ext+Color.swift`:134 | 0 | 0 | - | Extension API for color. |
| `Data` | `extension` | `public` | `Extensions/Ext+Data.swift`:10 | 0 | 0 | - | Extension API for data. |
| `Dictionary` | `extension` | `public` | `Extensions/Ext+Dict.swift`:10 | 1 | 0 | `compact()` | Extension API for dictionary. |
| `Dictionary` | `extension` | `public` | `Extensions/Ext+Dict.swift`:18 | 1 | 0 | `compact()` | Extension API for dictionary. |
| `Double` | `extension` | `internal` | `Extensions/Ext+Primatives.swift`:50 | 0 | 0 | - | Extension API for double. |
| `Float` | `extension` | `internal` | `Extensions/Ext+Primatives.swift`:42 | 0 | 0 | - | Extension API for float. |
| `Int` | `extension` | `internal` | `Extensions/Ext+Primatives.swift`:26 | 0 | 0 | - | Extension API for int. |
| `OSLogType` | `extension` | `public` | `Extensions/Ext+OSLogType.swift`:11 | 4 | 0 | `allOptions()`, `displayName()`, `color()`, (+1 more) | Extension API for oslog type. |
| `ProcessInfo` | `extension` | `public` | `Extensions/Ext+ProcessInfo.swift`:14 | 1 | 0 | `isTestFlight()` | Extension API for process info. |
| `ProminentColorsView` | `struct` | `internal` | `Extensions/Ext+UIImage.swift`:315 | 1 | 0 | `extractColor()` | Extension API for prominent colors view. |
| `Publisher` | `extension` | `public` | `Extensions/Ext+Combine.swift`:22 | 1 | 1 | `value(or:)` | Extension API for publisher. |
| `Publisher` | `extension` | `public` | `Extensions/Ext+Combine.swift`:58 | 2 | 2 | `subscribeOnMain(options:)`, `receiveOnMain(options:)` | Extension API for publisher. |
| `Publisher` | `extension` | `public` | `Extensions/Ext+Combine.swift`:84 | 2 | 4 | `weakSink(capturing:receiveValue:)`, `weakAssign(to:on:)` | Extension API for publisher. |
| `Publisher` | `extension` | `public` | `Extensions/Ext+Combine.swift`:110 | 2 | 0 | `isTrue()`, `isFalse()` | Extension API for publisher. |
| `Sequence` | `extension` | `public` | `Extensions/Ext+Sequence.swift`:12 | 5 | 7 | `asyncForEach(_:)`, `asyncForEach(_:)`, `withThrowingForEach(_:)`, (+2 more) | Extension API for sequence. |
| `ShapeStyle` | `extension` | `public` | `Extensions/Ext+Color.swift`:42 | 0 | 0 | - | Extension API for shape style. |
| `String` | `extension` | `internal` | `Extensions/Ext+Primatives.swift`:10 | 0 | 0 | - | Extension API for string. |
| `String` | `extension` | `public` | `Extensions/Ext+String.swift`:12 | 0 | 0 | - | Extension API for string. |
| `String` | `extension` | `public` | `Extensions/Ext+String.swift`:81 | 0 | 0 | - | Extension API for string. |
| `String` | `extension` | `public` | `Extensions/Ext+String.swift`:95 | 1 | 0 | `trimmed()` | Extension API for string. |
| `Text` | `extension` | `public` | `Extensions/Ext+Text.swift`:10 | 1 | 2 | `init(_:configure:)` | Extension API for text. |
| `UIApplication` | `extension` | `public` | `Extensions/Ext+UIApplication.swift`:10 | 0 | 0 | - | Extension API for uiapplication. |
| `UIColor` | `extension` | `public` | `Extensions/Ext+Color.swift`:11 | 2 | 2 | `init(light:dark:)`, `random()` | Extension API for uicolor. |
| `UIDevice` | `extension` | `public` | `Extensions/Ext+Device.swift`:13 | 0 | 0 | - | Extension API for uidevice. |
| `UIDevice` | `extension` | `public` | `Extensions/Ext+UIApplication.swift`:54 | 0 | 0 | - | Extension API for uidevice. |
| `UIFont` | `extension` | `public` | `Extensions/Ext+UIFont.swift`:10 | 2 | 4 | `sfDisplay(size:weight:)`, `avenir(size:weight:)` | Extension API for uifont. |
| `UIImage` | `extension` | `public` | `Extensions/Ext+UIImage.swift`:11 | 1 | 1 | `scaleImage(scaleFactor:)` | Extension API for uiimage. |
| `UIImage` | `extension` | `public` | `Extensions/Ext+UIImage.swift`:28 | 1 | 2 | `extractColors(numberOfColors:sortByProminence:)` | Extension API for uiimage. |
| `UIImage` | `extension` | `public` | `Extensions/Ext+UIImage.swift`:278 | 1 | 1 | `compressedData(maxMegaBytes:)` | Extension API for uiimage. |
| `UINavigationController` | `extension` | `internal` | `Extensions/Ext+NavigationController.swift`:10 | 1 | 1 | `gestureRecognizerShouldBegin(_:)` | Extension API for uinavigation controller. |
| `UIPasteboard` | `extension` | `public` | `Extensions/Ext+String.swift`:117 | 2 | 1 | `pasteToClipboard(_:)`, `readFromClipboard()` | Extension API for uipasteboard. |
| `UIScreen` | `extension` | `public` | `Extensions/Ext+Window.swift`:30 | 0 | 0 | - | Extension API for uiscreen. |
| `UIWindow` | `extension` | `public` | `Extensions/Ext+Window.swift`:10 | 0 | 0 | - | Extension API for uiwindow. |
| `View` | `extension` | `public` | `Extensions/Ext+View.swift`:11 | 10 | 6 | `asAnyView()`, `centerHorizontally()`, `centerVertically()`, (+7 more) | Extension API for view. |
| `View` | `extension` | `public` | `Extensions/Ext+View.swift`:149 | 1 | 2 | `extract(_:completion:)` | Extension API for view. |
| `ViewExtractorDemoView` | `struct` | `internal` | `Extensions/Ext+View.swift`:247 | 0 | 0 | - | Extension API for view extractor demo view. |

---

## Verification

- Confirmed all discovered `Components`, `ViewModifiers`, `Services`, `Views`/`Screens`, and `Extensions` folders were scanned.
- Confirmed each declaration row includes access, file+line, API counts, parameter counts, and summarized entry points.
- Output excludes private/fileprivate declarations to keep focus on offered APIs.
- Review rows with `0` APIs to decide whether additional hand-written notes are needed.
