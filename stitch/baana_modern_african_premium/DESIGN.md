---
name: Baana Modern African Premium
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
  secondary: '#8c4f00'
  on-secondary: '#ffffff'
  secondary-container: '#ffac5b'
  on-secondary-container: '#744000'
  tertiary: '#9d4300'
  on-tertiary: '#ffffff'
  tertiary-container: '#ff7e2d'
  on-tertiary-container: '#622700'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#ffdcc0'
  secondary-fixed-dim: '#ffb875'
  on-secondary-fixed: '#2d1600'
  on-secondary-fixed-variant: '#6b3b00'
  tertiary-fixed: '#ffdbca'
  tertiary-fixed-dim: '#ffb690'
  on-tertiary-fixed: '#341100'
  on-tertiary-fixed-variant: '#783200'
  background: '#f7faf8'
  on-background: '#181c1c'
  surface-variant: '#e0e3e1'
  quasi-black: '#2C3E36'
  text-secondary: '#6B7D75'
  surface-input: '#EDF2EF'
  border-muted: '#D4DDD8'
  error-warm: '#E05252'
  info-warm: '#3B9EC4'
  success-light: oklch(92% 0.04 160)
  warning-light: oklch(94% 0.03 55)
  error-light: oklch(94% 0.03 25)
typography:
  headline-lg:
    fontFamily: Comfortaa
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Comfortaa
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  subtitle:
    fontFamily: Nunito
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-reg:
    fontFamily: Nunito
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-bold:
    fontFamily: Nunito
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  price-display:
    fontFamily: Comfortaa
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 32px
  label-caps:
    fontFamily: Nunito
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.1em
  caption:
    fontFamily: Nunito
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 14px
  button-text:
    fontFamily: Comfortaa
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 20px
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
  gutter-h: 12px
  gutter-v: 16px
  section-gap: 32px
  element-gap: 24px
  stack-sm: 8px
---

## Brand & Style

The design system embodies a "Modern African Premium" aesthetic, specifically tailored for Senegalese merchants. It balances the warmth and abundance of local entrepreneurship with the precision of a high-end subscription service. The visual narrative is built on organic growth, represented by clover-inspired shapes and a vibrant, life-affirming palette.

The style avoids generic "SaaS" tropes by embracing **asymmetry, brutalist typographic hierarchy, and a strict rejection of pure grays**. It is a tactile yet flat design, prioritizing high-contrast legibility for users who may be less tech-savvy. The interface should feel welcoming, professional, and distinctively local through the use of emerald-tinted neutrals and soft, rounded geometry.

## Colors

The palette is strictly emerald-tinted to ensure visual warmth and brand cohesion. **Pure grays, blacks, and whites are prohibited.**

- **Primary (Emerald):** Used for main actions, active states, and brand presence.
- **Accent (Baana Orange):** Reserved for promotions, badges, and soft alerts.
- **CTA Orange (Urgent):** High-impact orange for critical conversion points like "Start" or "Recommended."
- **Neutrals:** All neutral surfaces use an OKLCH-derived tint (hue 160) to maintain a lush, organic feel. 
- **Functional:** Error and Info states use warm-leaning tints to avoid clinical, generic software appearances.

## Typography

This design system employs a **brutal hierarchy**, creating stark contrast between headlines and body copy to guide the eye effectively.

- **Headlines:** Comfortaa Bold provides a soft, organic character. Use H1 for main greetings and H2 for page titles.
- **Body:** Nunito Sans ensures high legibility on mobile screens while maintaining the rounded aesthetic of the brand.
- **Price Display:** Prices, especially "Pro" prices, should be treated as display elements using Comfortaa to emphasize value.
- **Scale Rule:** Maintain a minimum 14pt difference between the H1 and standard body text to ensure a premium, non-generic layout.

## Layout & Spacing

The layout philosophy centers on **Asymmetrical Dynamics**. By utilizing uneven left (20px) and right (28px) margins, the design system avoids the "stiff" look of standard templates and feels more handcrafted and energetic.

- **Grid:** Use a fluid column structure, but always adhere to the asymmetrical outer margins.
- **Vertical Rhythm:** Large 32px gaps between major sections provide breathing room. Use 24px between headers and content blocks.
- **Mobile-First:** Elements are designed for thumb-friendly interaction, specifically focusing on the bottom-right quadrant for reachability.

## Elevation & Depth

To maintain a modern, crisp aesthetic, the design system **replaces drop shadows with tonal layering and high-contrast borders**.

- **Tonal Layers:** Depth is created by placing `surface-input` elements or `white-tinted` cards directly onto the `background-tint` base.
- **Zero Shadows:** Do not use CSS box-shadows. Define elevation through color shifts. 
- **State Changes:** For pressed states, apply a 10% brightness reduction to the background color rather than adding a shadow or glow.
- **Flat Borders:** Use `border-muted` for structural separation when tonal contrast is insufficient.

## Shapes

The shape language is organic and varied, inspired by the clover logo. Avoid uniformity in corner radii to maintain the "Modern African" feel.

- **Primary Radius:** 12px (0.75rem) for inputs, cards, and primary buttons.
- **Large Radius:** 16px (1rem) for banners and promotional blocks.
- **Container Radius:** 24px for bottom-edge product images or sheet headers.
- **Pill Shapes:** Used exclusively for tags like "Pro" or "Member Pro" to distinguish them from actionable buttons.
- **Asymmetric Accents:** "PROMO" badges must feature a **-3° rotation** to break the grid.

## Components

### Buttons
- **Primary/CTA:** Minimum height of 52px. Full-width on mobile. Use Comfortaa Bold.
- **Urgent CTA:** 56px height in CTA Orange (#F97316). Use for high-intent actions only.
- **Secondary:** 2px Emerald border, transparent background.

### Inputs
- **Style:** 52px height, `surface-input` background, 12px radius. 
- **Focus:** 2px Emerald border. No shadows.

### Cards
- **Product Cards:** A single surface direct on the background. **No cards-inside-cards.**
- **Images:** 1:1 ratio with 12px rounded corners.

### Navigation
- **Bottom Bar:** 56px height. Separation from content via a subtle tonal shift or a very thin emerald-tinted border at the top. Use **Phosphor Icons** in "Regular" for inactive and "Fill" for active states.

### Badges
- **Promo:** Orange background, -3° rotation, 6px corners.
- **Status Tags:** Pill-shaped with low-opacity background tints (e.g., success-light for "In Stock").

### Icons
- Use **Phosphor** or **Lucide** exclusively. 24px for navigation, 20px for inline text elements. Never use Material Icons.