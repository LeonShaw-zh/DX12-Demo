function (add_library_glob_recurse name kind)
    file(GLOB_RECURSE "${name}-sources" CONFIGURE_DEPENDS ${ARGN})
    add_library("${name}" ${kind} ${${name}-sources})
endfunction ()

