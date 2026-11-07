# llvm-builds

The LLVM packages `ens` links against, built from source per platform and published as release
assets, so no machine builds LLVM itself and none pays a link-time LTO cost.

## What it builds

Two xmake packages per platform, with the configuration Ens declares, copied from Ens's `xmake.lua`
(`main` @ `95625f24`):

- `llvm 21.1.0` - the toolchain Ens compiles with
- `libllvm 21.1.0` - the libraries Ens merges into `ens-llvm`, with `lld = true`, `clang = false`,
  `target_x86 = true`, `target_aarch64 = true`, plus the macOS deployment target

`ens-repository/` is a copy of Ens's `scripts/repository`, which is where `libllvm`'s source build
lives. When Ens changes its LLVM version, its configs, or that build, mirror it here.

## Running it

Actions -> build -> Run workflow, tick the platforms, give a release tag (`llvm-21.1.0`). Each
ticked platform is its own job and they run in parallel; the release job publishes the archives.

| input | runner | assets |
|---|---|---|
| linux_x64 | ubuntu-22.04 | `llvm-21.1.0-linux-x64-{llvm,libllvm}.tar.xz` |
| linux_arm64 | ubuntu-22.04-arm | `llvm-21.1.0-linux-arm64-{llvm,libllvm}.tar.xz` |
| macos_arm64 | macos-15 | `llvm-21.1.0-macos-arm64-{llvm,libllvm}.tar.xz` |
| windows_x64 | windows-2022 | `llvm-21.1.0-windows-x64-{llvm,libllvm}.tar.xz` |
| windows_arm64 | windows-11-arm | `llvm-21.1.0-windows-arm64-{llvm,libllvm}.tar.xz` |

`SHA256SUMS.txt` carries the digests; Ens pins them by hash in its package definitions.

Published releases are immutable, so a build stages its assets as a draft and publishes them in one
go, and only when every selected platform is present. Give each build an unused tag (`llvm-21.1.0-1`,
then `-2` for a rebuild); a partial build leaves a draft behind instead of a release that can never
be completed.

## What the archives have to be

- The contents of the installed package prefix, not a build directory: `include/`, `lib/`,
  `lib/<triple>/`, `lib/clang/<major>/lib/<triple>/`, `bin/`.
- Native objects with `LLVM_ENABLE_LTO=OFF`, so linking them is a plain link.
- For Linux, built on ubuntu-22.04, so the objects stay inside the glibc floor Ens declares in
  `selfhost/bundled/symbols/linux-x64.symbols` (`glibc 2.34`). A newer glibc bakes in `arc4random`
  and the `__isoc23_strto*` family, which that floor does not carry and cannot.

## Notes

- No cache step on purpose: a build is a once-per-release cost, and a cache would only speed reruns.
- `windows-11-arm` and `ubuntu-22.04-arm` runners are free only on public repositories, which is why
  this repository is public.
- Linux needs `binutils-dev`: LLVM's gold plugin target compiles against its `plugin-api.h`.
