#!/usr/bin/env python3
"""
Remove white/solid backgrounds from images, producing transparent PNGs.
Designed for brand logos that need to be used on dark-themed UIs.

Usage:
    python3 remove_bg.py --input logo.jpg --output logo.png --threshold 240 --feather 2
"""

import argparse
import sys

try:
    from PIL import Image, ImageFilter
except ImportError:
    print("ERROR: Pillow is required. Install with: pip3 install Pillow")
    sys.exit(1)


def remove_background(input_path: str, output_path: str, threshold: int = 240, feather: int = 2):
    """
    Remove near-white background from an image and save as transparent PNG.
    
    Args:
        input_path: Path to source image
        output_path: Path to output PNG
        threshold: Brightness threshold (0-255). Pixels with R, G, B all above this become transparent.
        feather: Edge feathering radius in pixels for smooth edges.
    """
    img = Image.open(input_path).convert("RGBA")
    data = img.getdata()
    
    new_data = []
    for item in data:
        r, g, b, a = item
        # If pixel is close to white, make it transparent
        if r > threshold and g > threshold and b > threshold:
            new_data.append((r, g, b, 0))
        else:
            new_data.append(item)
    
    img.putdata(new_data)
    
    # Optional edge feathering for smoother transitions
    if feather > 0:
        # Extract alpha channel, blur it slightly, then re-apply
        alpha = img.split()[3]
        # Use a slight blur to feather edges
        alpha = alpha.filter(ImageFilter.GaussianBlur(radius=feather))
        img.putalpha(alpha)
    
    img.save(output_path, "PNG")
    print(f"✅ Background removed: {output_path}")
    print(f"   Threshold: {threshold}, Feather: {feather}px")
    
    # Report stats
    total = len(data)
    transparent = sum(1 for p in img.getdata() if p[3] < 10)
    pct = (transparent / total) * 100
    print(f"   Transparent pixels: {transparent}/{total} ({pct:.1f}%)")


def main():
    parser = argparse.ArgumentParser(description="Remove solid backgrounds from images")
    parser.add_argument("--input", "-i", required=True, help="Input image path")
    parser.add_argument("--output", "-o", required=True, help="Output PNG path")
    parser.add_argument("--threshold", "-t", type=int, default=240,
                        help="Brightness threshold (0-255). Default: 240")
    parser.add_argument("--feather", "-f", type=int, default=2,
                        help="Edge feathering radius in pixels. Default: 2")
    
    args = parser.parse_args()
    remove_background(args.input, args.output, args.threshold, args.feather)


if __name__ == "__main__":
    main()
