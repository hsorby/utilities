CMAKE_MINIMUM_REQUIRED(VERSION 3.0 FATAL_ERROR)
project(OpenCMISS_Utilities)

# Generate the wrappers (if not existing)
include(OCMUtilsGenerateFindXXXWrappers)

if(OCM_USE_MPI)
    # todo check for mpi and build if not found
endif()

# ... gtest, mpi, ..
