# Copilot Instructions for ShadowFlowRepo

## Project Overview

ShadowFlow is an iOS jailbreak tweak supporting multiple jailbreak environments:
- **Rootful** (unc0ver, checkra1n) - Traditional jailbreaks with full root access
- **Rootless** (Dopamine, palera1n) - Modern jailbreaks with `/var/jb` prefix
- **Roothide** - Hidden root jailbreaks with additional security

## Architecture

```
ShadowFlowRepo/
├── control/                 # DEBIAN control files
│   ├── control             # Rootful package metadata
│   └── control-rootless    # Rootless/Roothide metadata
├── layout/                  # Tweak files structure
│   └── Library/MobileSubstrate/DynamicLibraries/
│       ├── ShadowFlow.dylib    # Compiled tweak
│       └── ShadowFlow.plist    # Substrate filter
├── scripts/
│   └── build-deb.sh        # Build script for all architectures
└── .github/workflows/
    └── release.yml         # Auto-release on tag push
```

## Development Workflow

### Building Packages
```bash
chmod +x scripts/build-deb.sh
./scripts/build-deb.sh 1.0.0   # Pass version as argument
```

### Creating a Release
```bash
git tag v1.0.0
git push origin v1.0.0
# GitHub Actions will automatically build and create release
```

### Manual Release via GitHub UI
1. Go to Actions → "Build & Release"
2. Click "Run workflow"
3. Enter version number
4. Release will be created automatically

## Package Architecture

| Architecture | Jailbreak Type | Install Path |
|-------------|----------------|--------------|
| `iphoneos-arm` | Rootful | `/Library/MobileSubstrate/DynamicLibraries/` |
| `iphoneos-arm64` | Rootless | `/var/jb/Library/MobileSubstrate/DynamicLibraries/` |
| `iphoneos-arm64` + Tag: roothide | Roothide | `/var/jb/Library/MobileSubstrate/DynamicLibraries/` |

## Key Files

- [control/control](control/control) - Package metadata (name, version, dependencies)
- [scripts/build-deb.sh](scripts/build-deb.sh) - Multi-architecture build script
- [.github/workflows/release.yml](.github/workflows/release.yml) - CI/CD pipeline

