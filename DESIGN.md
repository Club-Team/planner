# Dayline Planner UI Design Notes

This document summarizes the design tokens and component theming added to align the app’s UI with a cohesive visual language.

## Color System
- Primary: #559390 (light) / #4DD0E1 (dark)
- Secondary (accent): #5A8282 (light) / #26C6DA (dark)
- Background: #F7F0E6 (light) / #121212 (dark)
- Surface: Subtle, warm cards with low elevation and no surface tint.

## Material 3
- `useMaterial3: true` enabled.
- Rich `ColorScheme` defined for both light and dark themes.

## Typography
- Family: Rubik
- Titles use `titleMedium` with bolder weight for stronger hierarchy.

## Components
- Card: 16px radius, low elevation, consistent margins.
- Buttons: Unified padding, rounded corners (14px), flat elevation.
- Inputs: Filled background, 14px radius, focused 2px primary outline.
- Switches/Sliders: Colors and ripple tuned to primary.

## Spacing and Radii
- Default radii: 14–16px on interactive surfaces.
- Comfortable vertical spacing (8–24px) in layouts.

## Edit Sections Screen
- Cards now use Material with ripple, left accent bar reflecting the primary color, improved time display, and tighter spacing.
- Bottom sheet editor includes drag handle, icon preview, labeled range slider, and upgraded icon picker chips.

## Next Suggestions
- Adopt reusable spacing/radius constants (e.g., `AppSpacing`, `AppRadius`).
- Wrap common patterns (e.g., accent card) into shared widgets.
- Expand component themes (Chips, Dialogs, SegmentedButton) as needed.
