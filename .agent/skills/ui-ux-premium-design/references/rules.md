# Premium UI/UX Design Rules

## Core Pillars of Yentelelo Design
We pursue visual excellence and state-of-the-art user experiences combining custom Glassmorphism with Google's Material 3 capabilities.

### 1. Visual Hierarchy & Typography (Material 3)
- **Modern Fonts**: Use Google Fonts like *Inter*, *Roboto*, or *Outfit*. Avoid default system fonts.
- **M3 Integration**: Leverage Material 3's typography scaling consistency, applying it dynamically. Contrast is paramount: distinct headers and legible body text.

### 2. Glassmorphism & Depth
Glassmorphism implies transparency, blurred backgrounds, and soft, highlighted edges.
- **Blur Effects**: Use `BackdropFilter` with `ImageFilter.blur` (sigmaX/Y between 10-20). Limit the repaint area with `ClipRRect`.
- **Subtle Borders**: Apply thin, semi-transparent white borders (width: 0.5 - 1.0) to simulate a "glass" edge reflecting light.
- **Gradients**: Use highly transparent linear or radial gradients (e.g., Cyan to Blue or White) to tint the glass.
- **Opacity Method**: Always use `.withValues(alpha: ...)` for colors in Flutter 3+.

### 3. Material 3 Elevation & Depth Strategy
- The natural sense of depth in Glassmorphism pairs beautifully with M3's elevation system.
- Utilize M3's `surface tint color` or subtle shadow overlays on foundational components to create contrast beneath the floating glass layers.

### 4. Micro-Animations & Interactivity
- **Hover/Tap Effects**: All interactive elements (buttons, cards) must register interaction through color-shifts, opacity changes, or scale animations.
- **Transitions**: Ensure logical and fluid transitions between screens using M3's expressive motion principles (Slide, Fade Through).

### 5. Layout & Spacing
- **Generous Padding**: Treat space as a fundamental design element. Avoid cramped UI.
- **Dynamic Sizing**: Utilize `LayoutBuilder` and constraints to maintain proportions across viewports.

## Aesthetic Mandates
- **Avoid Generic Colors**: Use the brand's HSL-curated palettes. Never use uncalibrated `Colors.red` or `Colors.blue`.
- **Performance**: High blur radii are computationally severe. Use `RepaintBoundary` around intense visual effects over static areas.

## Image Generation & Dashboard Aesthetics
When replacing heavy, realistic photos on dashboards (which clash with Glassmorphism), follow this process to generate clean alternatives:

1. **Option 1: Stylized 3D (Recommended for Fintech)**
   - *Prompt Style*: "A high-quality 3D stylized render of [subject]. Minimalist, premium clean aesthetic like a Fintech app. Colors: [Brand Colors]. Soft studio lighting, smooth glossy reflections. Isometric angle. Isolated on a pure white background. No humans."
2. **Option 2: Abstract/Floating Elements**
   - *Prompt Style*: "A high-quality 3D stylized render of [abstract objects related to task] floating gently in mid-air. Minimalist, clean aesthetic. Colors: [Brand Colors]. Soft studio lighting. Isolated on pure white background."
3. **Option 3: Minimalist 2D Vector**
   - *Prompt Style*: "A clean, minimalist 2D flat vector illustration of [subject]. Fintech app aesthetic. Transparent background style (pure white for removal). Colors: [Brand Colors]. Abstract motion lines. Simple geometric shapes."

**Integration Workflow:**
1. Generate the image using the `generate_image` tool.
2. Remove the white background using the `background-removal` skill (`python3 .agent/skills/background-removal/scripts/remove_bg.py --input <path> --output <path> --threshold 230`).
3. Replace the `.png` asset in the `lib/` codebase and Hot Restart the app.
