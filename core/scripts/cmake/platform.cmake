if ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(TARGET_SYSTEM windows)
    if (CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(TARGET_CPU amd64)
    else ()
        set(TARGET_CPU x86)
    endif ()
endif ()