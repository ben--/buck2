# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is dual-licensed under either the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree or the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree. You may select, at your option, one of the
# above-listed licenses.

load("@prelude//cfg/exec_platform:marker.bzl", "get_exec_platform_marker")

def _execution_platform_impl(ctx: AnalysisContext) -> list[Provider]:
    constraints = dict()
    constraints.update(ctx.attrs.cpu_configuration[ConfigurationInfo].constraints)
    constraints.update(ctx.attrs.os_configuration[ConfigurationInfo].constraints)
    cfg = ConfigurationInfo(constraints = constraints, values = {})

    name = ctx.label.raw_target()
    platform = ExecutionPlatformInfo(
        label = name,
        configuration = cfg,
        executor_config = CommandExecutorConfig(
            local_enabled = True,
            remote_enabled = False,
            use_windows_path_separators = ctx.attrs.use_windows_path_separators,
        ),
    )

    return [
        DefaultInfo(),
        platform,
        PlatformInfo(label = str(name), configuration = cfg),
        ExecutionPlatformRegistrationInfo(
            platforms = [platform],
            exec_marker_constraint = get_exec_platform_marker(),
        ),
    ]

execution_platform = rule(
    impl = _execution_platform_impl,
    attrs = {
        "cpu_configuration": attrs.dep(providers = [ConfigurationInfo]),
        "os_configuration": attrs.dep(providers = [ConfigurationInfo]),
        "use_windows_path_separators": attrs.bool(),
    },
)

def _host_cpu_configuration() -> str:
    arch = host_info().arch
    if arch.is_aarch64:
        return "prelude//cpu:arm64"
    elif arch.is_arm:
        return "prelude//cpu:arm32"
    elif arch.is_i386:
        return "prelude//cpu:x86_32"
    elif arch.is_riscv64:
        return "prelude//cpu:riscv64"
    else:
        return "prelude//cpu:x86_64"

def _host_os_configuration() -> str:
    os = host_info().os
    if os.is_macos:
        return "prelude//os:macos"
    elif os.is_windows:
        return "prelude//os:windows"
    else:
        return "prelude//os:linux"

# <<<<<<< conflict 1 of 1
# +++++++ llrsumtk a0b24148 "fix(oss): add runtime/constraints:anywhere-linux" (rebase destination)
# %%%%%%% diff from: llrsumtk 949e53ae "fix(oss): add runtime/constraints:anywhere-linux" (parents of rebased revision)
# \\\\\\\        to: lnmyxqtv 1b8d9dd2 "fix(oss): Use libc++ for clang targets on both macos and linux" (rebased revision)
#  def _host_cpp_stdlib_configuration() -> str:
#      os = host_info().os
# -    # macOS defaults to libc++
# -    if os.is_macos:
# +
# +    if os.is_macos or os.is_linux:
# +        # macOS and Linux default to libc++ (works better with clang)
#          return "prelude//cpp:libc++"
# -    # For other platforms, default to libstdc++
# -    # (Windows and Linux both default to libstdc++ - on Windows this represents
# -    # the general C++ stdlib concept, on Linux it's typically the actual libstdc++)
#      else:
# +        # Windows defaults to libstdc++ (represents the general C++ stdlib concept)
#          return "prelude//cpp:libstdc++"
#
#  def _host_distro_configuration() -> str | None:
#      # Check if running in a conda environment
#      if read_root_config("env", "CONDA_PREFIX"):
#          return "prelude//distro:conda"
#      return None
#
#  def _host_compiler_configuration() -> str:
#      os = host_info().os
#      if os.is_windows:
#          return "prelude//compiler:msvc"
#      else:
#          # macOS and Linux default to clang
#          return "prelude//compiler:clang"
#
#  def _host_abi_configuration() -> str:
#      os = host_info().os
#      if os.is_windows:
#          return "prelude//abi:msvc"
#      else:
#          # macOS and Linux default to gnu ABI
#          return "prelude//abi:gnu"
#
# >>>>>>> conflict 1 of 1 ends
host_configuration = struct(
    cpu = _host_cpu_configuration(),
    os = _host_os_configuration(),
)
