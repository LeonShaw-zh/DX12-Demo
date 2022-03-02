get_filename_component(PROJECT_ROOT .. ABSOLUTE BASE_DIR ${CORE_ROOT})
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
include(platform)

add_library(lustice-default-flags INTERFACE)
target_compile_options(
    lustice-default-flags INTERFACE
    -DUMMY_FLAG=1
)

file(GENERATE
    OUTPUT ${CMAKE_BINARY_DIR}/dummy.engine.cpp
    CONTENT ""
)
add_executable(lustice-engine ${CMAKE_BINARY_DIR}/dummy.engine.cpp)

set_property(
    TARGET lustice-engine
    PROPERTY RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

target_link_libraries(
    lustice-engine
    lustice-default-flags
)

target_compile_features(lustice-default-flags INTERFACE cxx_std_14)
set(CMAKE_CXX_EXTENSIONS OFF)

target_compile_options(
    lustice-default-flags INTERFACE
    -utf-8
    -bigobj
    -D_SCL_SECURE_NO_WARNINGS   # Remove Microsoft-only deprecation warnings
    -D_CRT_SECURE_NO_WARNINGS   # Remove Microsoft-only deprecation warnings
    -wd4297                     # No warnings when throwing in dtor
    -FC                         # Output full path in diagnostics
    -Zm2000                     # Increase PCH memory limits to 1500MB to avoid C1060 error
)
if (WARNINGS_AS_ERRORS)
    target_compile_options(
        lustice-default-flags INTERFACE
        -WX
    )
endif ()

# No warnings when there are duplicated link libraries
string(APPEND CMAKE_STATIC_LINKER_FLAGS " -ignore:4221")

include(extension)