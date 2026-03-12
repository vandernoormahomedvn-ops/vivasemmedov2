# Visual Guidelines & Dark Glass Theme

## Dark Glass Theme (Yentelelo Signature)
For all content-heavy or immersive screens (Video Player, Dashboard, Explore), strictly follow these composition rules:

### Colors
- **Background:** `#0F1113` (Deep Dark) - Do NOT use standard black or lighter grays.
- **Surface:** `#1D2126` (For cards/tiles without glass effect).
- **Primary Accent:** `#0DD7F2` (Cyan/Teal) - Use for active states, icons, and highlights.
- **Text Primary:** `#FFFFFF` (White).
- **Text Secondary:** `Colors.white70` (White with 70% opacity) or `#94A3B8`.

### Glassmorphism ("Liquid Glass")
Use this effect for overlays, action bars, and floating inputs.
- **Color:** `Colors.white.withOpacity(0.08)`
- **Border:** `Colors.white.withOpacity(0.1)` (1px width)
- **Blur:** `BackdropFilter` with `sigmaX: 10, sigmaY: 10`
- **Border Radius:** `16.0` to `24.0` typically.

### Typography
- **Family:** `Outfit` (Google Fonts).
- **Headings:** Bold/SemiBold.
- **Body:** Regular/Light.

## AI Image Generation (Nano Banana 2)
For all marketing and UI placeholders, use the **Nano Banana 2** (Gemini 3.1 Flash) model with the following constraints:
- **Resolution:** Always target 2K or 4K.
- **Branding:** Ensure the 'FLEXPRESS' text is correctly rendered on vehicles, uniforms, or packages.
- **Aesthetic:** High-contrast, cinematic lighting, deep blacks (#0F1113), and cyan accents (#0DD7F2).
