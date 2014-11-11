CMAKE_MINIMUM_REQUIRED(VERSION 2.4 FATAL_ERROR)
project(OPENCMISS_UTILS)

SET(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/install)
if (CMAKE_MAJOR_VERSION LESS 4)
    if (WIN32)
        message(WARNING "Your CMake version is ${CMAKE_VERSION}, but at least version 3.x.x is required for OpenCMISS. Please download & install from http://www.cmake.org/download/")
    else()
        message(WARNING "Your CMake version is ${CMAKE_VERSION}, but at least version 3.x.x is required for OpenCMISS. Setting up cmake target..")
        execute_process(
            COMMAND git submodule update --init cmake
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
        add_subdirectory(cmake)
        #execute_process(
        #    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/cmake/build)
        #add_custom_target(cmake
        #    COMMAND ${CMAKE_COMMAND} ..
        #    COMMAND ${CMAKE_MAKE_PROGRAM}
        #    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/cmake/build
        #)
    endif()     
endif()
