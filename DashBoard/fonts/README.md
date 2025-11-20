# 🎨 Fonts Directory

## 📁 Required Font Files

To use the **DEv-Index.html** dashboard with the Samarkan font, you need to add the font file to this directory.

### Required File:
- `samarkan-normal.ttf` - The Samarkan font file

## 📥 How to Add the Font

### Option 1: Download the Font
1. Download **Samarkan** font from a font repository
2. Save the `.ttf` file as `samarkan-normal.ttf`
3. Place it in this `DashBoard/fonts/` directory

### Option 2: Use Your Own Font
If you have a different font you'd like to use:
1. Place the font file (`.ttf`, `.otf`, `.woff`, `.woff2`) in this directory
2. Update `samarkan.css` to reference your font file
3. Update the font name if needed

## 📂 Expected Structure

```
DashBoard/
├── fonts/
│   ├── samarkan-normal.ttf    ← Place your font file here
│   ├── samarkan.css           ← Font CSS definition
│   └── README.md              ← This file
├── DEv-Index.html             ← Dashboard with Samarkan font
├── index.html                 ← Dashboard with Inter font
└── dashboard.js
```

## 🎯 Usage

### For Standard Dashboard (Inter Font)
Open `index.html` - Uses Google Fonts Inter (no font file needed)

### For DEv Dashboard (Samarkan Font)
Open `DEv-Index.html` - Requires samarkan-normal.ttf in this folder

## ⚙️ Font Configuration

The font is configured in `samarkan.css`:

```css
@font-face {
    font-family: 'Samarkan';
    src: url('samarkan-normal.ttf') format('truetype');
    font-weight: normal;
    font-style: normal;
}
```

### Font Application Strategy

**Samarkan Font Applied To:**
- All headings (h1, h2, h3, h4, h5, h6)
- Main title text
- Large display text
- Button text
- Section titles

**Inter Font Applied To:**
- Small text (text-xs, text-sm)
- Keyboard shortcuts (kbd)
- Monospace elements
- Body paragraphs
- Long-form content

This ensures:
- ✅ Beautiful decorative font for headings
- ✅ Readable font for body text
- ✅ Best of both worlds

## 🔧 Customization

### To Change Font Size for Samarkan:
Edit `DEv-Index.html` and adjust the letter-spacing or font-size in the style section.

### To Use Different Font Weights:
Add more `@font-face` declarations in `samarkan.css`:

```css
@font-face {
    font-family: 'Samarkan';
    src: url('samarkan-bold.ttf') format('truetype');
    font-weight: bold;
    font-style: normal;
}
```

### To Change Fallback Fonts:
Update the font-family chain in `samarkan.css`:

```css
body.samarkan-font {
    font-family: 'Samarkan', 'YourFallback', 'Inter', system-ui, sans-serif;
}
```

## 📝 Font File Formats Supported

- `.ttf` - TrueType Font (recommended)
- `.otf` - OpenType Font
- `.woff` - Web Open Font Format
- `.woff2` - Web Open Font Format 2 (best compression)

### Multiple Format Support:
For better browser compatibility, use multiple formats:

```css
@font-face {
    font-family: 'Samarkan';
    src: url('samarkan-normal.woff2') format('woff2'),
         url('samarkan-normal.woff') format('woff'),
         url('samarkan-normal.ttf') format('truetype');
}
```

## ⚠️ Important Notes

1. **Font License**: Make sure you have the right to use the font
2. **File Size**: Large font files may slow down page load
3. **Browser Compatibility**: Modern browsers support all formats
4. **Fallback**: Always include fallback fonts for reliability

## 🚀 Quick Start

1. Place `samarkan-normal.ttf` in this folder
2. Open `DEv-Index.html` in your browser
3. Enjoy the custom font dashboard!

---

**Need Help?**
If the font doesn't load, check:
- ✅ Font file is named correctly
- ✅ Font file is in the correct directory
- ✅ Browser console for errors (F12)
- ✅ File path in samarkan.css is correct

---

*Last Updated: October 21, 2025*

