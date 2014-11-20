CMAKE_MINIMUM_REQUIRED(VERSION 2.4 FATAL_ERROR)
project(OpenCMISS_Utilities)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts)
#SET(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/install)

# Check if cmake is up-to-date (and build if required)
include(CMakeCheck)

# Generate the wrappers (if not existing)
include(OCMUtilsGenerateFindXXXWrappers)

# Now we know we have external project available


# ... gtest, mpi, ..
