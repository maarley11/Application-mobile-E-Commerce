---
name: Baana Luxury Mobile
colors:
  surface: '#f7faf8'
  surface-dim: '#d7dbd9'
  surface-bright: '#f7faf8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f4f2'
  surface-container: '#ebefed'
  surface-container-high: '#e6e9e7'
  surface-container-highest: '#e0e3e1'
  on-surface: '#181c1c'
  on-surface-variant: '#3c4a42'
  inverse-surface: '#2d3130'
  inverse-on-surface: '#eef1ef'
  outline: '#6c7a71'
  outline-variant: '#bbcabf'
  surface-tint: '#006c49'
  primary: '#006c49'
  on-primary: '#ffffff'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#4edea3'
  secondary: '#9d4300'
  on-secondary: '#ffffff'
  secondary-container: '#fd761a'
  on-secondary-container: '#5c2400'
  tertiary: '#51625b'
  on-tertiary: '#ffffff'
  tertiary-container: '#94a79e'
  on-tertiary-container: '#2c3c36'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#ffdbca'
  secondary-fixed-dim: '#ffb690'
  on-secondary-fixed: '#341100'
  on-secondary-fixed-variant: '#783200'
  tertiary-fixed: '#d4e7dd'
  tertiary-fixed-dim: '#b8cbc2'
  on-tertiary-fixed: '#0e1f19'
  on-tertiary-fixed-variant: '#394a43'
  background: '#f7faf8'
  on-background: '#181c1c'
  surface-variant: '#e0e3e1'
typography:
  headline-xl:
    fontFamily: Comfortaa
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Comfortaa
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Comfortaa
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Nunito Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Nunito Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Nunito Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-left: 20px
  margin-right: 28px
  gutter: 16px
  stack-sm: 8px
  stack-md: 24px
  stack-lg: 48px
---

## Brand & Style
This design system embodies a high-end Senegalese e-commerce experience that bridges traditional vibrancy with contemporary luxury. The brand personality is "Luxe-Eclat"—sophisticated, intentional, and radiant. It targets a discerning audience that values curated quality and seamless digital craftsmanship.

The aesthetic follows a **Modern Minimalist** approach with a unique twist: **Controlled Asymmetry**. By avoiding perfectly symmetrical gutters, the UI feels more like a bespoke editorial magazine than a standard template. The visual language is clean and breathable, using white space not just as a separator, but as a luxury element itself. Every interaction should feel deliberate, quiet, and premium.

## Colors
The palette is rooted in a refined naturalism, avoiding the harshness of digital extremes. 
- **Primary:** Emerald Green (#10B981) represents growth and prosperity, used for key actions and brand presence.
- **Accent:** Vibrant Orange (#F97316) provides a high-energy contrast for notifications and special highlights.
- **Base:** The background is a soft, tinted white (#F7FAF8), providing a warm, organic feel compared to clinical pure white.
- **Strict Constraint:** No pure blacks (#000000), pure whites (#FFFFFF), or neutral grays are permitted. All "grays" must be tinted with green or slate tones to maintain the cohesive high-end atmosphere.

## Typography
The typographic hierarchy relies on the contrast between the geometric, friendly boldness of **Comfortaa** and the clean, humanist legibility of **Nunito Sans**.

- **Headlines:** Always use Comfortaa in Bold. This provides a distinctive, approachable character to the interface.
- **Body & Labels:** Use Nunito Sans for all reading and functional text. It ensures clarity even at small sizes.
- **Styling:** For luxury product titles, use `headline-lg` with generous top margin. For secondary information, use `body-sm` with the secondary text color (#6B7D75).

## Layout & Spacing
This design system utilizes a **Fixed Asymmetrical Grid** to break the monotony of traditional e-commerce apps.

- **Asymmetry:** Standard mobile views use a 20px left margin and a 28px right margin. This subtle shift creates a more dynamic visual flow, drawing the eye across the content in a less predictable pattern.
- **Vertical Rhythm:** Spacing is managed in increments of 8px. Use `stack-lg` to separate distinct product sections and `stack-md` for internal card groupings.
- **Mobile-First:** The layout is optimized for single-column scrolling with "peek" horizontal carousels that reveal 15% of the next item to encourage exploration.

## Elevation & Depth
In alignment with the high-end, flat-modern aesthetic, **shadows are strictly prohibited**. Depth is created through:

1.  **Tonal Layering:** Using subtle variations of the tinted background (#F7FAF8) and very thin, low-contrast borders (1px) in the secondary text color at low opacity.
2.  **Color Blocking:** Large areas of the Primary Emerald Green are used to "lift" specific modules off the page.
3.  **Containment:** Cards do not float with shadows; they are defined by their 12px rounded corners and slight color shifts against the main background.

## Shapes
The shape language is "Soft-Modern." Elements use a consistent 12px (0.75rem) corner radius to strike a balance between geometric precision and organic friendliness. 

- **Standard Elements:** Buttons, input fields, and small cards use the base 12px radius.
- **Large Containers:** Bottom sheets and full-width banners use a 24px (1.5rem) radius on the top corners to emphasize a "nesting" feel.

## Components
### Buttons
- **Primary:** 52px height, Emerald Green (#10B981) background, Bold Nunito Sans text in the tinted white (#F7FAF8). Corners must be exactly 12px. No shadows.
- **Secondary:** 52px height, 1.5px border in Emerald Green, transparent background.

### Input Fields
- Height of 52px to match buttons.
- Background: A slightly darker tint of the neutral background or a 1px border of #6B7D75 at 30% opacity.
- Text: Nunito Sans 16px.

### Cards
- Used for products. Should use the asymmetrical margin rules (e.g., if two cards are side-by-side, they may have slightly different widths to maintain the overall page asymmetry).
- Padding should be generous (min 16px).

### Selection Controls
- **Checkboxes/Radios:** Use the Emerald Green for the active state. Avoid sharp corners; use a 4px radius for checkboxes to match the brand softness.

### Chips/Filters
- Small, pill-shaped elements (height 32px) using a very light tint of the primary color with Emerald Green text.