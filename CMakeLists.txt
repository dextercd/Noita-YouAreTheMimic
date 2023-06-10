cmake_minimum_required(VERSION 3.24)

project(YouAreTheMimic
    VERSION 1.0.3
    DESCRIPTION "Noita mod where you play as a mimic"
    HOMEPAGE_URL "https://github.com/dextercd/Noita-YouAreTheMimic"
    LANGUAGES
)

install(DIRECTORY YouAreTheMimic
    DESTINATION .
    COMPONENT YouAreTheMimic
)


# Packaging

set(CPACK_VERBATIM_VARIABLES TRUE)
set(CPACK_GENERATOR ZIP)
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
include(CPack)
