cmake_minimum_required(VERSION 2.8.3)
project(wayland-build)

include(CMakeParseArguments)

set(time_stamp "${PROJECT_BINARY_DIR}/build.stamp")
add_custom_target(refresh
  COMMAND "${CMAKE_COMMAND}" -E touch "${time_stamp}"
  COMMAND "${CMAKE_COMMAND}" -E echo "Time Stamp Touched.")
add_custom_command(OUTPUT "${time_stamp}"
  COMMAND "${CMAKE_COMMAND}" -E touch "${time_stamp}"
  COMMAND "${CMAKE_COMMAND}" -E echo "Time Stamp Touched.")

function(make_and_install name)
  set(options)
  set(one_value_args)
  set(multi_value_args DEPENDS)
  cmake_parse_arguments(MAKE_AND_INSTALL
    "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  set(DEPEND_PKGS)
  foreach(pkg ${MAKE_AND_INSTALL_DEPENDS})
    set(DEPEND_PKGS ${DEPEND_PKGS} "${pkg}.pkg")
  endforeach()
  set(pkg_dir "${PROJECT_SOURCE_DIR}/${name}")
  set(pkg_stamp "${PROJECT_BINARY_DIR}/${name}.pkg.stamp")
  add_custom_command(OUTPUT "${pkg_stamp}"
    COMMAND "${PROJECT_SOURCE_DIR}/make_install.sh" "${name}"
    COMMAND "${CMAKE_COMMAND}" -E touch "${pkg_stamp}"
    WORKING_DIRECTORY "${pkg_dir}"
    DEPENDS ${DEPEND_PKGS} "${time_stamp}")
  add_custom_target("${name}.pkg" ALL DEPENDS "${pkg_stamp}")
  add_custom_target("${name}" ALL DEPENDS "${name}.pkg")
endfunction()

make_and_install(fontconfig-git
  DEPENDS)
make_and_install(weston-git
  DEPENDS libxkbcommon-git wayland-git mesa-full cairo-gl-git libglu-git)
make_and_install(wayland-git
  DEPENDS)
make_and_install(pango-git
  DEPENDS glib2-git cairo-gl-git harfbuzz-git fontconfig-git)
make_and_install(mesa-full
  DEPENDS wayland-git)
make_and_install(libxkbcommon-git
  DEPENDS)
make_and_install(libglu-git
  DEPENDS mesa-full)
make_and_install(harfbuzz-git
  DEPENDS cairo-gl-git)
make_and_install(gdk-pixbuf2-git
  DEPENDS glib2-git gobject-introspection-git)
make_and_install(gtk3-ubuntu-git
  DEPENDS glib2-git atk-git cairo-gl-git pango-git at-spi2-atk-git
  libxkbcommon-git gdk-pixbuf2-git)
make_and_install(gobject-introspection-git
  DEPENDS glib2-git)
make_and_install(glib2-git
  DEPENDS)
make_and_install(cairo-gl-git
  DEPENDS mesa-full fontconfig-git)
make_and_install(at-spi2-atk-git
  DEPENDS atk-git at-spi2-core-git)
make_and_install(atk-git
  DEPENDS glib2-git)
make_and_install(at-spi2-core-git
  DEPENDS gobject-introspection-git glib2-git)
make_and_install(vala-git
  DEPENDS gobject-introspection-git glib2-git)
make_and_install(valadoc-git
  DEPENDS vala-git)
