# SkyUI SE Community Update (6.0+)

## Building

### Prerequisites

- [CMake 3.24+](https://cmake.org/download/)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) (or another CMake-supported generator)
- [JPEXS Free Flash Decompiler (windows installer)](https://github.com/jindrapetrik/jpexs-decompiler)
- A clean Skyrim Special Edition installation with:
  - The [Creation Kit](https://store.steampowered.com/app/1946180/Skyrim_Special_Edition_Creation_Kit/) installed and **run at least once** to unpack the base game script sources
  - The latest [SKSE64](https://skse.silverlock.org/) installed, including its script source files, overwriting the scripts included with the Creation Kit
  - No other mods or tools overwriting the base game or SKSE script sources

### Setup

Clone the repository with submodules:

```
git clone --recursive https://github.com/doodlum/SkyUI-Community.git
```

If you already cloned without `--recursive`, initialize the submodules with:

```
git submodule update --init
```

The build system expects Papyrus script sources at the following locations within your Skyrim SE game directory:

| Path | Contents |
|------|----------|
| `Data/Source/Scripts/` | Base game and Creation Kit script sources (`TESV_Papyrus_Flags.flg`, `Debug.psc`, `Form.psc`, etc.) |
| `Data/Scripts/Source/` | SKSE64 script sources (`UI.psc`, `StringUtil.psc`, `SKSE.psc`, etc.) |

### Building

The easiest way to build is to double-click `Build.bat`. It will automatically detect your Skyrim SE installation via the Steam registry. If auto-detection fails, it will prompt you to enter the path manually.

You can also set the `SkyrimSE_PATH` environment variable beforehand to skip the prompt:

```
set SkyrimSE_PATH=C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition
```

Alternatively, from the command line:

```
cmake --preset build
cmake --build build
```

### Output

The build produces `release/SkyUI_SE-<version>.zip` containing:

- `SkyUI_SE.esp` - Plugin file
- `SkyUI_SE.bsa` - Archive containing compiled Papyrus scripts and all interface files

## Contributing

Contributions are welcome! If you'd like to submit a bug fix or add new functionality, please follow these steps:

1. **Fork** the repository and create a new branch from `main`.
2. **Make your changes** — ensure they build successfully using the steps above.
3. **Test** your changes in-game to verify they work as expected.
4. **Open a pull request** against `main` with a clear description of what you changed and why.

### Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/). Each commit message should be structured as:

```
<type>: <description>
```

Common types used in this project:

| Type | Description |
|------|-------------|
| `fix` | A bug fix (correlates with a **patch** version bump) |
| `feat` | A new feature or addition (correlates with a **minor** version bump) |
| `build` | Changes to the build system or dependencies |
| `docs` | Documentation-only changes |
| `refactor` | Code changes that neither fix a bug nor add a feature |

A commit with a breaking change should append `!` after the type (e.g., `fix!: ...` or `feat!: ...`), which correlates with a **major** version bump.

### Versioning

This project follows [Semantic Versioning](https://semver.org/). The version is defined in `CMakeLists.txt` under the `VERSION` field (currently `6.0.0`).

When submitting a PR, update the version according to the type of change:

- **Patch** (`6.0.0` → `6.0.1`) — Bug fixes and minor corrections that don't change existing behavior.
- **Minor** (`6.0.0` → `6.1.0`) — New features or additions that are backward-compatible.
- **Major** (`6.0.0` → `7.0.0`) — Breaking changes that alter existing behavior or remove functionality.
