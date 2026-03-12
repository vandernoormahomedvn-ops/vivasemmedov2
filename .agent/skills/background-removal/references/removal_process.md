# Background Removal Process & Integration

## Method: Pillow Color-Key Removal

This technique replaces a target background color (e.g., white) with transparency.

### Script Location
Use the script at `.agent/skills/background-removal/scripts/remove_bg.py`.

### Usage
```bash
python3 .agent/skills/background-removal/scripts/remove_bg.py \
  --input path/to/logo.jpg \
  --output path/to/logo_transparent.png \
  --threshold 240 \
  --feather 2
```

### Parameters
| Parameter   | Default | Description |
|-------------|---------|-------------|
| `--input`   | required | Source image path |
| `--output`  | required | Output PNG path |
| `--threshold` | 240 | Brightness threshold (0-255). Pixels above this are removed. Lower = more aggressive. |
| `--feather` | 2 | Edge feathering in pixels for smooth transitions. |

### Best Practices
1. **Start conservative** with threshold 240 and increase if background remnants remain.
2. **Check edges** — logos with soft shadows may need threshold 230 or lower.
3. **Always output PNG** — JPEG does not support transparency.
4. **Verify** the result by viewing the output file before using it in the app.

## Integration with Flutter
After creating transparent PNGs:
- Place them in `assets/images/` or the appropriate subdirectory.
- Register the directory in `pubspec.yaml` under `flutter > assets`.
- Use `Image.asset()` instead of `CachedNetworkImage()`.
