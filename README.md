# SkyUI SE Community Update (6.0+)

## Building

### Prerequisites

- [CMake 3.24+](https://cmake.org/download/)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) (or another CMake-supported generator)
- [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler) (windows installer)
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

## Known Issues

### `Common/skyui/components/list/BasicListEntry.as`

This file has been intentionally excluded from all SWF build targets. Including it causes the Mod Configuration Menu to break. It is present in the source tree for reference only and should not be added back to any `.cmake` source list.

## Contributing

Contributions are welcome! If you'd like to submit a bug fix or add new functionality, please follow these steps:

1. **Fork** the repository and create a new branch from `main`.
2. **Make your changes** — ensure they build successfully using the steps above.
3. **Test** your changes in-game to verify they work as expected.
4. **Open a pull request** against `main` with a clear description of what you changed and why.

### Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/).