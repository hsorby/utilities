CMAKE_MINIMUM_REQUIRED(VERSION 2.4 FATAL_ERROR)

if (CMAKE_MAJOR_VERSION LESS 3)
    if (WIN32)
        message(WARNING "Your CMake version is ${CMAKE_VERSION}, but at least version 3.x.x is required for OpenCMISS. Please download & install from http://www.cmake.org/download/")
    else()
        execute_process(
            COMMAND git submodule update --init cmake)
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E make_directory build
            WORKING_DIRECTORY git)
        execute_process(
            COMMAND ${CMAKE_COMMAND} ..
            COMMAND ${CMAKE_MAKE_PROGRAM}
            WORKING_DIRECTORY git/build)            
    endif() 
endif()