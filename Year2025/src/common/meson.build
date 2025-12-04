# src/common/meson.build

common_src = [
  'src/input.cpp',
  'src/grid.cpp',
  'src/util.cpp',
  # add more as you go
]

common_lib = static_library(
  'common',
  common_src,
  include_directories: include_directories('include'),
  cpp_args: ['-DAOC_BUILD'],
)

# This makes common_dep visible in parent scope (root)
common_dep = declare_dependency(
  link_with: common_lib,
  include_directories: include_directories('include'),
)
