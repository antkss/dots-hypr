project('simple-bar', 'vala', 'c')

bindir = get_option('prefix') / get_option('bindir')
libdir = get_option('prefix') / get_option('libdir')

pkgconfig_deps = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gtk+-3.0'),
  dependency('libnm'),
  dependency('astal-3.0'),
  dependency('astal-io-0.1'),
  dependency('astal-battery-0.1'),
  dependency('astal-wireplumber-0.1'),
  dependency('astal-network-0.1'),
  dependency('astal-tray-0.1'),
  dependency('astal-mpris-0.1'),
  dependency('astal-hyprland-0.1'),
  dependency('astal-notifd-0.1'),
]
# add_project_arguments(['-static'], language: 'vala')
deps = pkgconfig_deps + meson.get_compiler('c').find_library('m')

sources = files(
  'bar.vala',
  'app.in.vala'
)

executable(
  'mbar',
  [sources],
  dependencies: deps,
  install: true,
  vala_args: ['--pkg', 'posix'],
  install_dir: bindir,
)

