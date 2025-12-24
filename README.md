<p align="center">
  <img src="https://img.shields.io/badge/iOS-14.0+-blue?style=for-the-badge&logo=apple" alt="iOS">
  <img src="https://img.shields.io/badge/Sileo-Compatible-purple?style=for-the-badge" alt="Sileo">
  <img src="https://img.shields.io/badge/Cydia-Compatible-brown?style=for-the-badge" alt="Cydia">
  <img src="https://img.shields.io/badge/Zebra-Compatible-orange?style=for-the-badge" alt="Zebra">
</p>

<h1 align="center">🌑 ShadowFlow Repository</h1>

<p align="center">
  <b>Cydia/Sileo repository for iOS tweaks</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Rootful-✓-success?style=flat-square" alt="Rootful">
  <img src="https://img.shields.io/badge/Rootless-✓-success?style=flat-square" alt="Rootless">
  <img src="https://img.shields.io/badge/Roothide-✓-success?style=flat-square" alt="Roothide">
</p>

---

## 📦 Add Repository

### Repo URL
```
https://YOUR_USERNAME.github.io/ShadowFlowRepo/
```

### Quick Add
- **Sileo**: [Click to Add](sileo://source/https://YOUR_USERNAME.github.io/ShadowFlowRepo/)
- **Zebra**: [Click to Add](zbra://sources/add/https://YOUR_USERNAME.github.io/ShadowFlowRepo/)
- **Cydia**: Add manually via Sources → Edit → Add

---

## 📁 Repository Structure

```
ShadowFlowRepo/
├── debs/           # Place your .deb files here
├── Packages        # Auto-generated package index
├── Packages.bz2    # Compressed (auto-generated)
├── Packages.xz     # Compressed (auto-generated)
├── Release         # Repository metadata
└── index.html      # Beautiful repo webpage
```

---

## 🚀 How to Use

### 1. Enable GitHub Pages
1. Go to **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: **main** / **(root)**
4. Save

### 2. Add Your .deb Files
Simply copy your `.deb` files into the `debs/` folder and push:
```bash
cp your-tweak.deb debs/
git add debs/
git commit -m "Add new tweak"
git push
```

### 3. Automatic Update
GitHub Actions will automatically:
- ✅ Scan all `.deb` files in `debs/`
- ✅ Generate `Packages` file
- ✅ Create compressed versions (`.bz2`, `.xz`, `.gz`)
- ✅ Commit and push changes

---

## 📱 Compatibility

| Jailbreak | Architecture | Package Manager |
|-----------|--------------|-----------------|
| Rootful (unc0ver, checkra1n) | `iphoneos-arm` | Cydia, Zebra, Sileo |
| Rootless (Dopamine, palera1n) | `iphoneos-arm64` | Sileo, Zebra |
| Roothide | `iphoneos-arm64` | Sileo |

---

## ⭐ Support

If you find this useful, please give this repo a star!

---

<p align="center">Made with ❤️ for the jailbreak community</p>

