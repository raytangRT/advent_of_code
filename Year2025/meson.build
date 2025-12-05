# meson.build
project('aoc-2025', 'cpp',
  default_options : [
    'cpp_std=c++23', 'warning_level=3',
    'werror=true',
    'optimization=3',
    'b_lto=true',
  ]
)

# --------------------------------------------------
# GoogleTest (automatically downloaded first run)
# --------------------------------------------------
gtest_proj = subproject('gtest')
gtest_dep      = gtest_proj.get_variable('gtest_dep')
gmock_dep      = gtest_proj.get_variable('gmock_dep')  # Add this line

fmt = subproject('fmt')
fmt_dep = fmt.get_variable('fmt_dep')

spdlog_proj = subproject('spdlog')
spdlog_dep = spdlog_proj.get_variable('spdlog_dep')

# --------------------------------------------------
# Common code (optional but recommended)
# --------------------------------------------------
subdir('src/common')   # must expose variable: common_dep
# If you have no common code yet, just comment the line above and use dependency([])
# --------------------------------------------------
# Days 01–25 — only test.cpp is required
# --------------------------------------------------

fs = import('fs')
# Add this temporarily to see what Meson sees
message('Source root: ' + meson.source_root())
message('Input exists: ' + fs.exists('input').to_string())
message('Input path: ' + (meson.source_root() / 'input'))

# Symlink input/ to build dir (faster than copying)
input_symlink = ''
if fs.exists('input')
  input_symlink = custom_target('symlink-input',
    output: 'input',
    command: ['ln', '-sfn', meson.source_root() / 'input', '@OUTDIR@/input'],
    build_by_default: true,
    console: true,
  )
endif

foreach i : range(1, 26)
  day_num  = i.to_string(fill: 2)
  day_name = 'day' + day_num

  if fs.exists('src'/ day_name / 'test.cpp')
    test_exe = executable(
      day_name + '_test',
      'src'/day_name/'test.cpp',
      input_symlink,
      dependencies : [common_dep, gtest_dep, fmt_dep, spdlog_dep, gmock_dep],
      override_options : ['cpp_std=c++23'],
    )

    # This makes "ninja day01" run the tests for day 01
    alias_target(day_name, test_exe)

    # This registers it with "ninja test"
    test(day_name, test_exe, suite : 'aoc2025')
  endif
endforeach

