# SkyUI SE Community Update (6.0+)

## Building

### Prerequisites

- [CMake 4.2+](https://cmake.org/download/)
- [Visual Studio 2026](https://visualstudio.microsoft.com/) (or another CMake-supported generator; on Linux, the default make generator is used)
- [Java](https://www.java.com/en/download/) (required by the bundled ffdec-cli)
- [Python 3](https://www.python.org/downloads/) (required by the FPS patch, which is on by default; see below)
- [Proton](https://github.com/ValveSoftware/Proton) *(Linux only)* — auto-detected from your Steam installation. Skyrim SE must have been launched via Steam at least once to create the Proton prefix.
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
For convenient debugging, use `MOD_DEBUG_PATH`. `.swf` and `.pex` files will be placed in the specified path. If you only modify the `.swf`, you can test them without exiting the game. Skyrim's interface features "hot reloading." If you are already sitting in the modified menu, open it again to see the changes.
```
set MOD_DEBUG_PATH="C:\Users\user\AppData\Local\ModOrganizer\Skyrim Special Edition\mods\SkyUI_Test"
```

Alternatively, from the command line:

```
cmake --preset debug
cmake --build --preset debug
```

### Building on Linux

The easiest way to build is to run `./build.sh`. It will automatically detect your Skyrim SE installation from your Steam library. If auto-detection fails, it will prompt you to enter the path manually.

You can also set the `SkyrimSE_PATH` environment variable beforehand to skip the prompt:

```bash
export SkyrimSE_PATH="$HOME/.local/share/Steam/steamapps/common/Skyrim Special Edition"
```

For convenient debugging, use `MOD_DEBUG_PATH`:

```bash
export MOD_DEBUG_PATH="$HOME/.local/share/ModOrganizer/Skyrim Special Edition/mods/SkyUI-dev"
```

Alternatively, from the command line (ensure `SkyrimSE_PATH` is exported first):

```bash
cmake --preset debug
cmake --build --preset debug
```

### FPS patch (smoother menu animations)

By default the build raises each SWF's frame rate as far as it can while keeping animations at their original
speed down to 30 game fps (`ENABLE_FPS_PATCH=ON`, cap set by `FPS_PATCH_TARGET`, default 90). Scaleform advances
a movie by at most 3 frames per rendered game frame, so a SWF at N fps keeps real time only while the game renders
at least N / 3 fps. Each SWF is stretched by the largest whole factor that stays at or below the cap: with the
default 90, 24 fps menus (HUD, stats) become 72 fps (x3), 30 fps menus 90 fps (x3), and 60 fps menus (the item
menus, favorites, map) stay at 60. `-DFPS_PATCH_TARGET=120` converts everything to 120 (correct from 40 game fps),
`240` to 240 (from 80). Every timeline with more than one frame is stretched by the SWF's factor so animations keep
their real-time length, tweens are interpolated, and the compiled ActionScript is rewritten to keep using original
frame numbers (`tools/xml_fps_patcher.py`, runtime side in `source/actionscript/Common/skyui/util/FpsScale.as`).
Which SWFs are converted is listed in `tools/fps_patch_plan.json`.

- The configure log prints `[Build] FPS patch : ON` or `OFF`; the presets set it ON. A build folder configured
  by hand keeps whatever value is in its `CMakeCache.txt`, so pass `-DENABLE_FPS_PATCH=ON` (or `OFF`) when
  reusing one. With the patch OFF the SWFs keep their original frame rates.
- Measured in game at ~55 fps: the stats menu opening takes ~0.55 s on main, ~0.57 s at 120 fps and ~0.84 s at
  240 fps (above the 3-frames-per-frame limit).
- Libraries other SWFs import (`itemcard`, `bottombar`, `configpanel`) play at the importing menu's rate; the plan
  gives them `played_at` and the checker verifies every importer. Every exported symbol carries its own scale
  marker, so art libraries picked by frame number (key icons, map markers) stay correct inside converted menus.
- Other mods: SWFs loaded into a converted menu (SkyUI widgets from other mods, moreHUD, Infinity UI patches)
  keep playing at their own frame rate. Mods that read SkyUI's raw frame numbers need those timelines left
  unstretched; `FPS_PATCH_COMPAT` (default `morehud_inventory`) selects profiles from the plan's `"compat"`
  section. `morehud_inventory` keeps the item card's own 221-frame timeline for moreHUD Inventory Edition (only
  relevant when the cap stretches the item menus, i.e. 120 or more). Set `-DFPS_PATCH_COMPAT=` for none.
- Always kept for native HUD mods: the HUD's "Compass Marker" icon atlas keeps its original frame layout (Map
  Marker Framework, DbSkseFunctions, ShowUnlooted and SkyBuild read and extend it from SKSE), and
  `gotoAndPlay(n)` with the clip's raw current frame resumes from that frame (SKSE code such as Blood Magic's
  `Health.PlayForward(Health._currentFrame)`). Known limitation: SkyUI-Navbar's stats-menu intro skip checks
  `_totalframes == 31` and switches itself off on a patched statsmenu.swf.
- Verify a patched build with `cmake --build --preset debug --target check_fps_patch` (or
  `python tools/check_fps_patch.py --build build/debug --ffdec <path to ffdec-cli> --fps 90 --compat morehud_inventory`,
  matching the build's options). It proves for every SWF that each timeline keeps its duration in seconds and
  that every frame-number reference in the bytecode was rescaled, and fails otherwise.

### Output

The build produces `build/release/SkyUI_SE-<version>.zip` containing:

- `SkyUI_SE.esp` - Plugin file
- `SkyUI_SE.bsa` - Archive containing compiled Papyrus scripts and all interface files

For release use the following command lines:

```
cmake --preset release
cmake --build --preset release
```

## Contributing

Contributions are welcome! If you'd like to submit a bug fix or add new functionality, please follow these steps:

1. **Fork** the repository and create a new branch from `main`.
2. **Make your changes** — ensure they build successfully using the steps above.
3. **Test** your changes in-game to verify they work as expected.
4. **Open a pull request** against `main` with a clear description of what you changed and why.

### Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

## Credits

- [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler) by Jindra Petřík — used for ActionScript and XML compilation into SWF files