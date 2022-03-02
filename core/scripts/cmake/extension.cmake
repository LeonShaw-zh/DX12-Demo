include(glob)
include(platform)

get_property(BIN_DIR
    TARGET lustice-engine
    PROPERTY RUNTIME_OUTPUT_DIRECTORY
)

add_library_glob_recurse(lustice-core.init STATIC ${CORE_ROOT}/source.init/core/*.cpp)
target_include_directories(lustice-core.init PUBLIC ${CORE_ROOT}/source.init)

# Search for extensions
set(EXTENSIONS)
set(BUILD_EXTENSIONS)
set(SOURCE_EXTENSIONS)
# set(RUNTIME_EXTENSIONS)
# set(LIBRARY_EXTENSIONS)

message("Discovering extensions in ${PROJECT_ROOT}")
file(GLOB EXTENSION_CANDIDATES RELATIVE ${PROJECT_ROOT} ${PROJECT_ROOT}/ext-*)
list(INSERT
    EXTENSION_CANDIDATES
    0
    core                                # core must be the first one
)

foreach (CANDIDATE ${EXTENSION_CANDIDATES})
    # Ensure extension names are in lower case
    string(TOLOWER "${CANDIDATE}" CANDIDATE_LOWER)
    if (NOT "${CANDIDATE_LOWER}" STREQUAL "${CANDIDATE}")
        file(RENAME "${CANDIDATE}" "${CANDIDATE_LOWER}")
        message(AUTHOR_WARNING
            "Extension names must be in all lower case.\n"
            "Renamed ${CANDIDATE} to ${CANDIDATE_LOWER} for you."
        )
        set(CANDIDATE "${CANDIDATE_LOWER}")
    endif ()

    set(provides "")

    if (IS_DIRECTORY ${PROJECT_ROOT}/${CANDIDATE}/source/${CANDIDATE})
        string(APPEND provides " source")
        list(APPEND SOURCE_EXTENSIONS ${CANDIDATE})
    endif ()

    if (EXISTS ${PROJECT_ROOT}/${CANDIDATE}/build.cmake)
        string(APPEND provides " build")
        list(APPEND BUILD_EXTENSIONS ${CANDIDATE})
    endif ()

    if ("${provides}" STREQUAL "")
        message("  Ignoring empty extension ${CANDIDATE}")
    else ()
        message("  Found extension ${CANDIDATE}:${provides}")
        list(APPEND EXTENSIONS ${CANDIDATE})
    endif ()
endforeach ()

# Prepare source extensions (Part 1)
foreach (EXT ${SOURCE_EXTENSIONS})
    set(SRC ${PROJECT_ROOT}/${EXT}/source)
    add_library_glob_recurse(lustice-${EXT} STATIC ${SRC}/${EXT}/*.cpp)

    add_library(lustice-${EXT}.include INTERFACE)
    target_include_directories(lustice-${EXT}.include INTERFACE ${SRC})

    if (NOT "${EXT}" STREQUAL "core")
        target_link_libraries(lustice-${EXT} lustice-core)
    endif ()
    target_link_libraries(lustice-${EXT} lustice-${EXT}.include)
endforeach ()

# Generate extension header for core to initialize extensions and more.
set(EXTENSIONS_INIT_DECL)
set(EXTENSIONS_INIT_CALL)
foreach (EXT ${SOURCE_EXTENSIONS})
    if (NOT "${EXT}" STREQUAL "core")
        string(REPLACE "-" "_" EXT_ID ${EXT})
        set(EXTENSIONS_INIT_DECL "${EXTENSIONS_INIT_DECL}namespace ${EXT_ID} { void init(); }\n")
        set(EXTENSIONS_INIT_CALL "${EXTENSIONS_INIT_CALL}lustice::${EXT_ID}::init();\n")
    endif ()
endforeach ()
set(EXTENSIONS_INIT_CONTENT "")
string(APPEND EXTENSIONS_INIT_CONTENT
    "namespace lustice\n"
    "{\n"
    "    ${EXTENSIONS_INIT_DECL}\n"
    "    namespace ext\n"
    "    {\n"
    "        void init()\n"
    "        {\n"
    "            ${EXTENSIONS_INIT_CALL}\n"
    "        }\n"
    "    }\n"
    "}\n"
)
file(GENERATE
    OUTPUT ${CMAKE_BINARY_DIR}/lustice-core.ext.init.cpp
    CONTENT "${EXTENSIONS_INIT_CONTENT}"
)
target_sources(lustice-core.init PRIVATE ${CMAKE_BINARY_DIR}/lustice-core.ext.init.cpp)

# Include build extensions
foreach (EXT ${BUILD_EXTENSIONS})
    include(${PROJECT_ROOT}/${EXT}/build.cmake)
endforeach ()

# Prepare source extensions (Part 2)
foreach (EXT ${SOURCE_EXTENSIONS})
    target_link_libraries(lustice-core.init lustice-${EXT})
endforeach ()