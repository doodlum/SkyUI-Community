# SkyUI SE Community Update (6.0+)

## Building

### Prerequisites

- [CMake 3.24+](https://cmake.org/download/)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) (or another CMake-supported generator)
- Skyrim Special Edition with the Creation Kit installed (for the Papyrus compiler and base script sources)
- [SKSE64](https://skse.silverlock.org/) script sources installed into the game's Data folder

### Setup

Clone the repository with submodules:

```
git clone --recursive https://github.com/AceVenturi/SkyUI-Community.git
```

If you already cloned without `--recursive`, initialize the submodules with:

```
git submodule update --init
```

Set the `SkyrimSE_PATH` environment variable to your Skyrim SE installation directory:

```
set SkyrimSE_PATH=C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition
```

The build system expects Papyrus script sources at the following locations within your game directory:

| Path | Contents |
|------|----------|
| `Data/Source/Scripts/` | Base game and Creation Kit script sources (`TESV_Papyrus_Flags.flg`, `Debug.psc`, `Form.psc`, etc.) |
| `Data/Scripts/Source/` | SKSE64 script sources (`UI.psc`, `StringUtil.psc`, `SKSE.psc`, etc.) |

### Building

The easiest way to build is to double-click `Build.bat` after setting the environment variable.

Alternatively, from the command line:

```
cmake --preset build
cmake --build build
```

### Output

The build produces `release/SkyUI_SE-<version>.zip` containing:

- `SkyUI_SE.esp` - Plugin file
- `SkyUI_SE.bsa` - Archive containing compiled Papyrus scripts and all interface files
