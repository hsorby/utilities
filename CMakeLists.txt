CMAKE_MINIMUM_REQUIRED(VERSION 2.4 FATAL_ERROR)
project(OpenCMISS_Utilities)
LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts)

# Check if cmake is up-to-date (and build if required)
include(CMakeCheck)

# Now we're talking
CMAKE_MINIMUM_REQUIRED(VERSION 3.0 FATAL_ERROR)

# Generate the wrappers (if not existing)
include(OCMUtilsGenerateFindXXXWrappers)

# Now we know we have external project available
include(OpenCMISSLocalConfig)
if(OCM_USE_MPI)
    # todo check for mpi and build if not found
endif()

# ... gtest, mpi, ..
