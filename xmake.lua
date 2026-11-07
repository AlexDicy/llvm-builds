-- Builds the LLVM packages Ens links against, with the configuration Ens uses, so the results drop
-- into its package cache unchanged. The requires below are copied from Ens's xmake.lua
-- (main @ 95625f24) and ens-repository/ is a copy of its scripts/repository, where libllvm's build
-- lives. When Ens changes either, change them here too.

add_rules("mode.release")
add_repositories("ens ens-repository")

add_requires("llvm 21.1.0")
add_requires("libllvm 21.1.0", { configs = { lld = true, clang = false, target_x86 = true, target_aarch64 = true,
                                             libcxx = is_plat("linux") or nil,
                                             cxflags = is_plat("macosx") and "--target=arm64-apple-macos15.0" or nil } })

target("packages")
    set_kind("phony")
    add_packages("llvm", "libllvm")
