include(glob)

add_library_glob_recurse(lustice-core.main STATIC ${CORE_ROOT}/source.main/core/*.cpp)
target_include_directories(lustice-core.main PUBLIC ${CORE_ROOT}/source.main)

target_link_libraries(
    lustice-core.main
    lustice-default-flags
    lustice-core.init
)

target_link_libraries(
    lustice-core
    lustice-default-flags
)

file(GENERATE
    OUTPUT ${CMAKE_BINARY_DIR}/lustice-core.entry.cpp
    CONTENT "#include <core/engine.hpp>\nint main(int argc, char* argv[]) { lustice::engine_main_with_args(argc, argv); }\n"
)
add_library(lustice-core.entry STATIC ${CMAKE_BINARY_DIR}/lustice-core.entry.cpp)
target_link_libraries(
    lustice-core.entry
    lustice-default-flags
    lustice-core.main
)
target_link_libraries(
    lustice-engine
    lustice-core.entry
)