#.rst:
#
# Modifications for OpenCMISS build system:
# If MPI_HOME is set to the installation directory of mpi (containing /bin etc),
# the module will only look there for compilers and use them.
# The option 1) from below is still valid.
#
# FindMPI
# -------
#
# Find a Message Passing Interface (MPI) implementation
#
# The Message Passing Interface (MPI) is a library used to write
# high-performance distributed-memory parallel applications, and is
# typically deployed on a cluster.  MPI is a standard interface (defined
# by the MPI forum) for which many implementations are available.  All
# of them have somewhat different include paths, libraries to link
# against, etc., and this module tries to smooth out those differences.
#
# === Variables ===
#
# This module will set the following variables per language in your
# project, where <lang> is one of C, CXX, or Fortran:
#
# ::
#
#    MPI_<lang>_FOUND           TRUE if FindMPI found MPI flags for <lang>
#    MPI_<lang>_COMPILER        MPI Compiler wrapper for <lang>
#    MPI_<lang>_COMPILE_FLAGS   Compilation flags for MPI programs
#    MPI_<lang>_INCLUDE_PATH    Include path(s) for MPI header
#    MPI_<lang>_LINK_FLAGS      Linking flags for MPI programs
#    MPI_<lang>_LIBRARIES       All libraries to link MPI programs against
#
# Additionally, FindMPI sets the following variables for running MPI
# programs from the command line:
#
# ::
#
#    MPIEXEC                    Executable for running MPI programs
#    MPIEXEC_NUMPROC_FLAG       Flag to pass to MPIEXEC before giving
#                               it the number of processors to run on
#    MPIEXEC_PREFLAGS           Flags to pass to MPIEXEC directly
#                               before the executable to run.
#    MPIEXEC_POSTFLAGS          Flags to pass to MPIEXEC after other flags
#
# === Usage ===
#
# To use this module, simply call FindMPI from a CMakeLists.txt file, or
# run find_package(MPI), then run CMake.  If you are happy with the
# auto- detected configuration for your language, then you're done.  If
# not, you have two options:
#
# ::
#
#    1. Set MPI_<lang>_COMPILER to the MPI wrapper (mpicc, etc.) of your
#       choice and reconfigure.  FindMPI will attempt to determine all the
#       necessary variables using THAT compiler's compile and link flags.
#    2. If this fails, or if your MPI implementation does not come with
#       a compiler wrapper, then set both MPI_<lang>_LIBRARIES and
#       MPI_<lang>_INCLUDE_PATH.  You may also set any other variables
#       listed above, but these two are required.  This will circumvent
#       autodetection entirely.
#
# When configuration is successful, MPI_<lang>_COMPILER will be set to
# the compiler wrapper for <lang>, if it was found.  MPI_<lang>_FOUND
# and other variables above will be set if any MPI implementation was
# found for <lang>, regardless of whether a compiler was found.
#
# When using MPIEXEC to execute MPI applications, you should typically
# use all of the MPIEXEC flags as follows:
#
# ::
#
#    ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} PROCS
#      ${MPIEXEC_PREFLAGS} EXECUTABLE ${MPIEXEC_POSTFLAGS} ARGS
#
# where PROCS is the number of processors on which to execute the
# program, EXECUTABLE is the MPI program, and ARGS are the arguments to
# pass to the MPI program.
#
# === Backward Compatibility ===
#
# For backward compatibility with older versions of FindMPI, these
# variables are set, but deprecated:
#
# ::
#
#    MPI_FOUND           MPI_COMPILER        MPI_LIBRARY
#    MPI_COMPILE_FLAGS   MPI_INCLUDE_PATH    MPI_EXTRA_LIBRARY
#    MPI_LINK_FLAGS      MPI_LIBRARIES
#
# In new projects, please use the MPI_<lang>_XXX equivalents.

#=============================================================================
# Copyright 2001-2011 Kitware, Inc.
# Copyright 2010-2011 Todd Gamblin tgamblin@llnl.gov
# Copyright 2001-2009 Dave Partyka
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

# include this to handle the QUIETLY and REQUIRED arguments
include(FindPackageHandleStandardArgs)
#include(GetPrerequisites)

#
# This part detects MPI compilers, attempting to wade through the mess of compiler names in
# a sensible way.
#
# The compilers are detected in this order:
#
# 1. Try to find the most generic available MPI compiler, as this is usually set up by
#    cluster admins.  e.g., if plain old mpicc is available, we'll use it and assume it's
#    the right compiler.
#
# 2. If a generic mpicc is NOT found, then we attempt to find one that matches
#    CMAKE_<lang>_COMPILER_ID. e.g. if you are using XL compilers, we'll try to find mpixlc
#    and company, but not mpiicc.  This hopefully prevents toolchain mismatches.
#
# If you want to force a particular MPI compiler other than what we autodetect (e.g. if you
# want to compile regular stuff with GNU and parallel stuff with Intel), you can always set
# your favorite MPI_<lang>_COMPILER explicitly and this stuff will be ignored.
#

# Start out with the generic MPI compiler names, as these are most commonly used.
set(_MPI_C_COMPILER_NAMES                  mpicc    mpcc      mpicc_r mpcc_r)
set(_MPI_CXX_COMPILER_NAMES                mpicxx   mpiCC     mpcxx   mpCC    mpic++   mpc++
                                           mpicxx_r mpiCC_r   mpcxx_r mpCC_r  mpic++_r mpc++_r)
set(_MPI_Fortran_COMPILER_NAMES            mpif95   mpif95_r  mpf95   mpf95_r
                                           mpif90   mpif90_r  mpf90   mpf90_r
                                           mpif77   mpif77_r  mpf77   mpf77_r)

# GNU compiler names
set(_MPI_GNU_C_COMPILER_NAMES              mpigcc mpgcc mpigcc_r mpgcc_r)
set(_MPI_GNU_CXX_COMPILER_NAMES            mpig++ mpg++ mpig++_r mpg++_r)
set(_MPI_GNU_Fortran_COMPILER_NAMES        mpigfortran mpgfortran mpigfortran_r mpgfortran_r
                                           mpig77 mpig77_r mpg77 mpg77_r)

# Intel MPI compiler names
set(_MPI_Intel_C_COMPILER_NAMES            mpiicc)
set(_MPI_Intel_CXX_COMPILER_NAMES          mpiicpc  mpiicxx mpiic++ mpiiCC)
set(_MPI_Intel_Fortran_COMPILER_NAMES      mpiifort mpiif95 mpiif90 mpiif77)

# PGI compiler names
set(_MPI_PGI_C_COMPILER_NAMES              mpipgcc mppgcc)
set(_MPI_PGI_CXX_COMPILER_NAMES            mpipgCC mppgCC)
set(_MPI_PGI_Fortran_COMPILER_NAMES        mpipgf95 mpipgf90 mppgf95 mppgf90 mpipgf77 mppgf77)

# XLC MPI Compiler names
set(_MPI_XL_C_COMPILER_NAMES               mpxlc      mpxlc_r    mpixlc     mpixlc_r)
set(_MPI_XL_CXX_COMPILER_NAMES             mpixlcxx   mpixlC     mpixlc++   mpxlcxx   mpxlc++   mpixlc++   mpxlCC
                                           mpixlcxx_r mpixlC_r   mpixlc++_r mpxlcxx_r mpxlc++_r mpixlc++_r mpxlCC_r)
set(_MPI_XL_Fortran_COMPILER_NAMES         mpixlf95   mpixlf95_r mpxlf95 mpxlf95_r
                                           mpixlf90   mpixlf90_r mpxlf90 mpxlf90_r
                                           mpixlf77   mpixlf77_r mpxlf77 mpxlf77_r
                                           mpixlf     mpixlf_r   mpxlf   mpxlf_r)
                                           
set(_MPI_PREFIX_PATH )

# For 64bit environments, look in bin64 folders first!
SET(_BIN_SUFFIX bin)
if (${CMAKE_SYSTEM_PROCESSOR} MATCHES 64)
    LIST(INSERT _BIN_SUFFIX 0 bin64)
endif()

# Check if a mpi mnemonic is given
# Standard local paths will be added below later
if(MPI)
    if (MPI STREQUAL mpich)
        #LIST(APPEND _MPI_PREFIX_PATH /usr/lib/mpich /usr/lib64/mpich /usr/local/lib/mpich /usr/local/lib64/mpich)
        LIST(APPEND _MPI_PREFIX_PATH mpich)
        if(WIN32)
            LIST(APPEND _MPI_PREFIX_PATH "C:/Program\ Files/MPICH" "C:/Program\ Files/mpich")
        endif()
    elseif(MPI STREQUAL mpich2)
        #LIST(APPEND _MPI_PREFIX_PATH /usr/lib/mpich2 /usr/lib64/mpich2 /usr/local/lib/mpich2 /usr/local/lib64/mpich2)
        LIST(APPEND _MPI_PREFIX_PATH mpich2)
        if(WIN32)
            LIST(APPEND _MPI_PREFIX_PATH "C:/Program\ Files/MPICH2" "C:/Program\ Files/mpich2")
        endif()
    elseif(MPI STREQUAL intel)
        LIST(APPEND _MPI_PREFIX_PATH /opt/intel/impi/latest)
    elseif(MPI STREQUAL openmpi)
        #LIST(APPEND _MPI_PREFIX_PATH /usr/lib64/compat-openmpi /usr/lib/compat-openmpi
        #    /usr/lib64/openmpi /usr/lib/openmpi
        #    /usr/local/openmpi /usr/local/lib/openmpi)
        LIST(APPEND _MPI_PREFIX_PATH compat-openmpi openmpi)
    elseif(MPI STREQUAL mvapich2)
        if(NOT MPI_HOME)
            message(WARNING "mvapich2 requested but not MPI_HOME is set")
        endif()
    elseif(MPI STREQUAL poe)
        LIST(APPEND _MPI_PREFIX_PATH /usr/lpp/ppe.poe)
    elseif(MPI STREQUAL cray)
        LIST(APPEND _MPI_PREFIX_PATH /opt/cray/mpt/4.1.1/xt/seastar/mpich2-gnu)
    endif()
    message(STATUS "FindMPI: MPI=${MPI}")
endif()

# append vendor-specific compilers to the list if we either don't know the compiler id,
# or if we know it matches the regular compiler.
foreach (lang C CXX Fortran)
  foreach (id GNU Intel PGI XL)
    if (NOT CMAKE_${lang}_COMPILER_ID OR "${CMAKE_${lang}_COMPILER_ID}" STREQUAL "${id}")
      list(INSERT _MPI_${lang}_COMPILER_NAMES 0 ${_MPI_${id}_${lang}_COMPILER_NAMES})
    endif()
    unset(_MPI_${id}_${lang}_COMPILER_NAMES)    # clean up the namespace here
  endforeach()
  #if (NOT MPI) # dont display twice if we're still adding stuff below
  #    message(STATUS "FindMPI: MPI_${lang}_COMPILER_NAMES=${_MPI_${lang}_COMPILER_NAMES}")
  #endif()
endforeach()

# Names to try for MPI exec
set(_MPI_EXEC_NAMES mpiexec mpirun lamexec srun)

# For systems with "alternatives" management: prepend the mnemonic name to the executable names
# (they match, by coincidence/common sence, but hey, they match at least for mpich2/openmpi).
if(MPI)
    foreach (lang C CXX Fortran)
        foreach(compname ${_MPI_${lang}_COMPILER_NAMES})
            # Insert to have it looked up first
            LIST(INSERT _MPI_${lang}_COMPILER_NAMES 0 ${compname}.${MPI})
        endforeach()
        foreach(exename ${_MPI_EXEC_NAMES})
            # Insert to have it looked up first
            LIST(INSERT _MPI_EXEC_NAMES 0 ${exename}.${MPI})
        endforeach()
    endforeach()
    #message(STATUS "FindMPI: MPI_EXEC_NAMES=${_MPI_EXEC_NAMES}, MPI_${lang}_COMPILER_NAMES=${_MPI_${lang}_COMPILER_NAMES}")
endif()

# Grab the path to MPI from the registry if we're on windows.
if(WIN32)
  list(APPEND _MPI_PREFIX_PATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MPICH\\SMPD;binary]/..")
  list(APPEND _MPI_PREFIX_PATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MPICH2;Path]")
  list(APPEND _MPI_PREFIX_PATH "$ENV{ProgramW6432}/MPICH2/")
endif()

# Build a list of prefixes to search for MPI.
SET(_MPI_PREFIX_PATH_COPY ${_MPI_PREFIX_PATH})
foreach(SystemPrefixDir 
    ${CMAKE_SYSTEM_PREFIX_PATH}
    # Add some more paths
    /usr/lib /usr/lib64
    /usr/local/lib /usr/local/lib64)
  foreach(MpiPackageDir ${_MPI_PREFIX_PATH_COPY})
    #message(STATUS "FindMPI: Trying path ${SystemPrefixDir}/${MpiPackageDir}")
    if(EXISTS ${SystemPrefixDir}/${MpiPackageDir})
      #message(STATUS "FindMPI: Path added")
      list(APPEND _MPI_PREFIX_PATH "${SystemPrefixDir}/${MpiPackageDir}")
    endif()
  endforeach()
endforeach()
unset(_MPI_PREFIX_PATH_COPY)

if (MPI_HOME)
    list(INSERT _MPI_PREFIX_PATH 0 ${MPI_HOME})
endif()
if (_MPI_PREFIX_PATH)
    message(STATUS "FindMPI: MPI_PREFIX_PATH=${_MPI_PREFIX_PATH}")
endif()

#
# interrogate_mpi_compiler(lang try_libs)
#
# Attempts to extract compiler and linker args from an MPI compiler. The arguments set
# by this function are:
#
#   MPI_<lang>_INCLUDE_PATH    MPI_<lang>_LINK_FLAGS     MPI_<lang>_FOUND
#   MPI_<lang>_COMPILE_FLAGS   MPI_<lang>_LIBRARIES
#
# MPI_<lang>_COMPILER must be set beforehand to the absolute path to an MPI compiler for
# <lang>.  Additionally, MPI_<lang>_INCLUDE_PATH and MPI_<lang>_LIBRARIES may be set
# to skip autodetection.
#
# If try_libs is TRUE, this will also attempt to find plain MPI libraries in the usual
# way.  In general, this is not as effective as interrogating the compilers, as it
# ignores language-specific flags and libraries.  However, some MPI implementations
# (Windows implementations) do not have compiler wrappers, so this approach must be used.
#
function (interrogate_mpi_compiler lang try_libs)
  # MPI_${lang}_NO_INTERROGATE will be set to a compiler name when the *regular* compiler was
  # discovered to be the MPI compiler.  This happens on machines like the Cray XE6 that use
  # modules to set cc, CC, and ftn to the MPI compilers.  If the user force-sets another MPI
  # compiler, MPI_${lang}_COMPILER won't be equal to MPI_${lang}_NO_INTERROGATE, and we'll
  # inspect that compiler anew.  This allows users to set new compilers w/o rm'ing cache.
  string(COMPARE NOTEQUAL "${MPI_${lang}_NO_INTERROGATE}" "${MPI_${lang}_COMPILER}" interrogate)
  #message("Interrogate MPI_${lang}_COMPILER: ${MPI_${lang}_COMPILER}")
  # If MPI is set already in the cache, don't bother with interrogating the compiler.
  if (interrogate AND ((NOT MPI_${lang}_INCLUDE_PATH) OR (NOT MPI_${lang}_LIBRARIES)))
    if (MPI_${lang}_COMPILER)
      # Check whether the -showme:compile option works. This indicates that we have either OpenMPI
      # or a newer version of LAM-MPI, and implies that -showme:link will also work.
      execute_process(
        COMMAND ${MPI_${lang}_COMPILER} -showme:compile
        OUTPUT_VARIABLE  MPI_COMPILE_CMDLINE OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE   MPI_COMPILE_CMDLINE ERROR_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE  MPI_COMPILER_RETURN)

      if (MPI_COMPILER_RETURN EQUAL 0)
        # If we appear to have -showme:compile, then we should
        # also have -showme:link. Try it.
        execute_process(
          COMMAND ${MPI_${lang}_COMPILER} -showme:link
          OUTPUT_VARIABLE  MPI_LINK_CMDLINE OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_VARIABLE   MPI_LINK_CMDLINE ERROR_STRIP_TRAILING_WHITESPACE
          RESULT_VARIABLE  MPI_COMPILER_RETURN)

        if (MPI_COMPILER_RETURN EQUAL 0)
          # We probably have -showme:incdirs and -showme:libdirs as well,
          # so grab that while we're at it.
          execute_process(
            COMMAND ${MPI_${lang}_COMPILER} -showme:incdirs
            OUTPUT_VARIABLE  MPI_INCDIRS OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE   MPI_INCDIRS ERROR_STRIP_TRAILING_WHITESPACE)

          execute_process(
            COMMAND ${MPI_${lang}_COMPILER} -showme:libdirs
            OUTPUT_VARIABLE  MPI_LIBDIRS OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE   MPI_LIBDIRS ERROR_STRIP_TRAILING_WHITESPACE)

        else()
          # reset things here if something went wrong.
          set(MPI_COMPILE_CMDLINE)
          set(MPI_LINK_CMDLINE)
        endif()
      endif ()

      # Older versions of LAM-MPI have "-showme". Try to find that.
      if (NOT MPI_COMPILER_RETURN EQUAL 0)
        execute_process(
          COMMAND ${MPI_${lang}_COMPILER} -showme
          OUTPUT_VARIABLE  MPI_COMPILE_CMDLINE OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_VARIABLE   MPI_COMPILE_CMDLINE ERROR_STRIP_TRAILING_WHITESPACE
          RESULT_VARIABLE  MPI_COMPILER_RETURN)
      endif()

      # MVAPICH uses -compile-info and -link-info.  Try them.
      if (NOT MPI_COMPILER_RETURN EQUAL 0)
        execute_process(
          COMMAND ${MPI_${lang}_COMPILER} -compile-info
          OUTPUT_VARIABLE  MPI_COMPILE_CMDLINE OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_VARIABLE   MPI_COMPILE_CMDLINE ERROR_STRIP_TRAILING_WHITESPACE
          RESULT_VARIABLE  MPI_COMPILER_RETURN)

        # If we have compile-info, also have link-info.
        if (MPI_COMPILER_RETURN EQUAL 0)
          execute_process(
            COMMAND ${MPI_${lang}_COMPILER} -link-info
            OUTPUT_VARIABLE  MPI_LINK_CMDLINE OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE   MPI_LINK_CMDLINE ERROR_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE  MPI_COMPILER_RETURN)
        endif()

        # make sure we got compile and link.  Reset vars if something's wrong.
        if (NOT MPI_COMPILER_RETURN EQUAL 0)
          set(MPI_COMPILE_CMDLINE)
          set(MPI_LINK_CMDLINE)
        endif()
      endif()

      # MPICH just uses "-show". Try it.
      if (NOT MPI_COMPILER_RETURN EQUAL 0)
        execute_process(
          COMMAND ${MPI_${lang}_COMPILER} -show
          OUTPUT_VARIABLE  MPI_COMPILE_CMDLINE OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_VARIABLE   MPI_COMPILE_CMDLINE ERROR_STRIP_TRAILING_WHITESPACE
          RESULT_VARIABLE  MPI_COMPILER_RETURN)
      endif()

      if (MPI_COMPILER_RETURN EQUAL 0)
        # We have our command lines, but we might need to copy MPI_COMPILE_CMDLINE
        # into MPI_LINK_CMDLINE, if we didn't find the link line.
        if (NOT MPI_LINK_CMDLINE)
          set(MPI_LINK_CMDLINE ${MPI_COMPILE_CMDLINE})
        endif()
      else()
        message(STATUS "Unable to determine MPI from MPI driver ${MPI_${lang}_COMPILER}")
        set(MPI_COMPILE_CMDLINE)
        set(MPI_LINK_CMDLINE)
      endif()

      # Here, we're done with the interrogation part, and we'll try to extract args we care
      # about from what we learned from the compiler wrapper scripts.

      # If interrogation came back with something, extract our variable from the MPI command line
      if (MPI_COMPILE_CMDLINE OR MPI_LINK_CMDLINE)
        # Extract compile flags from the compile command line.
        string(REGEX MATCHALL "(^| )-[Df]([^\" ]+|\"[^\"]+\")" MPI_ALL_COMPILE_FLAGS "${MPI_COMPILE_CMDLINE}")
        set(MPI_COMPILE_FLAGS_WORK)

        foreach(FLAG ${MPI_ALL_COMPILE_FLAGS})
          if (MPI_COMPILE_FLAGS_WORK)
            set(MPI_COMPILE_FLAGS_WORK "${MPI_COMPILE_FLAGS_WORK} ${FLAG}")
          else()
            set(MPI_COMPILE_FLAGS_WORK ${FLAG})
          endif()
        endforeach()

        # Extract include paths from compile command line
        string(REGEX MATCHALL "(^| )-I([^\" ]+|\"[^\"]+\")" MPI_ALL_INCLUDE_PATHS "${MPI_COMPILE_CMDLINE}")
        foreach(IPATH ${MPI_ALL_INCLUDE_PATHS})
          string(REGEX REPLACE "^ ?-I" "" IPATH ${IPATH})
          string(REGEX REPLACE "//" "/" IPATH ${IPATH})
          list(APPEND MPI_INCLUDE_PATH_WORK ${IPATH})
        endforeach()

        # try using showme:incdirs if extracting didn't work.
        if (NOT MPI_INCLUDE_PATH_WORK)
          set(MPI_INCLUDE_PATH_WORK ${MPI_INCDIRS})
          separate_arguments(MPI_INCLUDE_PATH_WORK)
        endif()

        # If all else fails, just search for mpi.h in the normal include paths.
        if (NOT MPI_INCLUDE_PATH_WORK)
          set(MPI_HEADER_PATH "MPI_HEADER_PATH-NOTFOUND" CACHE FILEPATH "Cleared" FORCE)
          find_path(MPI_HEADER_PATH mpi.h
            HINTS ${_MPI_BASE_DIR} ${_MPI_PREFIX_PATH}
            PATH_SUFFIXES include)
          set(MPI_INCLUDE_PATH_WORK ${MPI_HEADER_PATH})
        endif()

        # Extract linker paths from the link command line
        string(REGEX MATCHALL "(^| |-Wl,)-L([^\" ]+|\"[^\"]+\")" MPI_ALL_LINK_PATHS "${MPI_LINK_CMDLINE}")
        set(MPI_LINK_PATH)
        foreach(LPATH ${MPI_ALL_LINK_PATHS})
          string(REGEX REPLACE "^(| |-Wl,)-L" "" LPATH ${LPATH})
          string(REGEX REPLACE "//" "/" LPATH ${LPATH})
          list(APPEND MPI_LINK_PATH ${LPATH})
        endforeach()

        # try using showme:libdirs if extracting didn't work.
        if (NOT MPI_LINK_PATH)
          set(MPI_LINK_PATH ${MPI_LIBDIRS})
          separate_arguments(MPI_LINK_PATH)
        endif()

        # Extract linker flags from the link command line
        string(REGEX MATCHALL "(^| )-Wl,([^\" ]+|\"[^\"]+\")" MPI_ALL_LINK_FLAGS "${MPI_LINK_CMDLINE}")
        set(MPI_LINK_FLAGS_WORK)
        foreach(FLAG ${MPI_ALL_LINK_FLAGS})
          if (MPI_LINK_FLAGS_WORK)
            set(MPI_LINK_FLAGS_WORK "${MPI_LINK_FLAGS_WORK} ${FLAG}")
          else()
            set(MPI_LINK_FLAGS_WORK ${FLAG})
          endif()
        endforeach()

        # Extract the set of libraries to link against from the link command
        # line
        string(REGEX MATCHALL "(^| )-l([^\" ]+|\"[^\"]+\")" MPI_LIBNAMES "${MPI_LINK_CMDLINE}")
        # add the compiler implicit directories because some compilers
        # such as the intel compiler have libraries that show up
        # in the showme list that can only be found in the implicit
        # link directories of the compiler. Do this for C++ and C
        # compilers if the implicit link directories are defined.
        if (DEFINED CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES)
          set(MPI_LINK_PATH
            "${MPI_LINK_PATH};${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES}")
        endif ()

        if (DEFINED CMAKE_C_IMPLICIT_LINK_DIRECTORIES)
          set(MPI_LINK_PATH
            "${MPI_LINK_PATH};${CMAKE_C_IMPLICIT_LINK_DIRECTORIES}")
        endif ()

        # Determine full path names for all of the libraries that one needs
        # to link against in an MPI program
        foreach(LIB ${MPI_LIBNAMES})
          string(REGEX REPLACE "^ ?-l" "" LIB ${LIB})
          # MPI_LIB is cached by find_library, but we don't want that.  Clear it first.
          set(MPI_LIB "MPI_LIB-NOTFOUND" CACHE FILEPATH "Cleared" FORCE)
          find_library(MPI_LIB NAMES ${LIB} HINTS ${MPI_LINK_PATH})

          if (MPI_LIB)
            list(APPEND MPI_LIBRARIES_WORK ${MPI_LIB})
          elseif (NOT MPI_FIND_QUIETLY)
            message(WARNING "Unable to find MPI library ${LIB}")
          endif()
        endforeach()

        # Sanity check MPI_LIBRARIES to make sure there are enough libraries
        list(LENGTH MPI_LIBRARIES_WORK MPI_NUMLIBS)
        list(LENGTH MPI_LIBNAMES MPI_NUMLIBS_EXPECTED)
        if (NOT MPI_NUMLIBS EQUAL MPI_NUMLIBS_EXPECTED)
          set(MPI_LIBRARIES_WORK "MPI_${lang}_LIBRARIES-NOTFOUND")
        endif()
      endif()

    elseif(try_libs)
      # If we didn't have an MPI compiler script to interrogate, attempt to find everything
      # with plain old find functions.  This is nasty because MPI implementations have LOTS of
      # different library names, so this section isn't going to be very generic.  We need to
      # make sure it works for MS MPI, though, since there are no compiler wrappers for that.
      find_path(MPI_HEADER_PATH mpi.h
        HINTS ${_MPI_BASE_DIR} ${_MPI_PREFIX_PATH}
        PATH_SUFFIXES include Inc)
      set(MPI_INCLUDE_PATH_WORK ${MPI_HEADER_PATH})

      # Decide between 32-bit and 64-bit libraries for Microsoft's MPI
      if("${CMAKE_SIZEOF_VOID_P}" EQUAL 8)
        set(MS_MPI_ARCH_DIR amd64)
      else()
        set(MS_MPI_ARCH_DIR i386)
      endif()

      set(MPI_LIB "MPI_LIB-NOTFOUND" CACHE FILEPATH "Cleared" FORCE)
      find_library(MPI_LIB
        NAMES         mpi mpich mpich2 msmpi
        HINTS         ${_MPI_BASE_DIR} ${_MPI_PREFIX_PATH}
        PATH_SUFFIXES lib lib/${MS_MPI_ARCH_DIR} Lib Lib/${MS_MPI_ARCH_DIR})
      set(MPI_LIBRARIES_WORK ${MPI_LIB})

      # Right now, we only know about the extra libs for C++.
      # We could add Fortran here (as there is usually libfmpich, etc.), but
      # this really only has to work with MS MPI on Windows.
      # Assume that other MPI's are covered by the compiler wrappers.
      if (${lang} STREQUAL CXX)
        set(MPI_LIB "MPI_LIB-NOTFOUND" CACHE FILEPATH "Cleared" FORCE)
        find_library(MPI_LIB
          NAMES         mpi++ mpicxx cxx mpi_cxx
          HINTS         ${_MPI_BASE_DIR} ${_MPI_PREFIX_PATH}
          PATH_SUFFIXES lib)
        if (MPI_LIBRARIES_WORK AND MPI_LIB)
          list(APPEND MPI_LIBRARIES_WORK ${MPI_LIB})
        endif()
      endif()

      if (NOT MPI_LIBRARIES_WORK)
        set(MPI_LIBRARIES_WORK "MPI_${lang}_LIBRARIES-NOTFOUND")
      endif()
    endif()

    # If we found MPI, set up all of the appropriate cache entries
    set(MPI_${lang}_COMPILE_FLAGS ${MPI_COMPILE_FLAGS_WORK} CACHE STRING "MPI ${lang} compilation flags"         FORCE)
    set(MPI_${lang}_INCLUDE_PATH  ${MPI_INCLUDE_PATH_WORK}  CACHE STRING "MPI ${lang} include path"              FORCE)
    set(MPI_${lang}_LINK_FLAGS    ${MPI_LINK_FLAGS_WORK}    CACHE STRING "MPI ${lang} linking flags"             FORCE)
    set(MPI_${lang}_LIBRARIES     ${MPI_LIBRARIES_WORK}     CACHE STRING "MPI ${lang} libraries to link against" FORCE)
    mark_as_advanced(MPI_${lang}_COMPILE_FLAGS MPI_${lang}_INCLUDE_PATH MPI_${lang}_LINK_FLAGS MPI_${lang}_LIBRARIES)

    # clear out our temporary lib/header detectionv variable here.
    set(MPI_LIB         "MPI_LIB-NOTFOUND"         CACHE INTERNAL "Scratch variable for MPI lib detection"    FORCE)
    set(MPI_HEADER_PATH "MPI_HEADER_PATH-NOTFOUND" CACHE INTERNAL "Scratch variable for MPI header detection" FORCE)
  endif()

  # finally set a found variable for each MPI language
  if (MPI_${lang}_INCLUDE_PATH AND MPI_${lang}_LIBRARIES)
    set(MPI_${lang}_FOUND TRUE PARENT_SCOPE)
  else()
    set(MPI_${lang}_FOUND FALSE PARENT_SCOPE)
  endif()
endfunction()


# This function attempts to compile with the regular compiler, to see if MPI programs
# work with it.  This is a last ditch attempt after we've tried interrogating mpicc and
# friends, and after we've tried to find generic libraries.  Works on machines like
# Cray XE6, where the modules environment changes what MPI version cc, CC, and ftn use.
function(try_regular_compiler lang success)
  set(scratch_directory ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
  if (${lang} STREQUAL Fortran)
    set(test_file ${scratch_directory}/cmake_mpi_test.f90)
    file(WRITE ${test_file}
      "program hello\n"
      "include 'mpif.h'\n"
      "integer ierror\n"
      "call MPI_INIT(ierror)\n"
      "call MPI_FINALIZE(ierror)\n"
      "end\n")
  else()
    if (${lang} STREQUAL CXX)
      set(test_file ${scratch_directory}/cmake_mpi_test.cpp)
    else()
      set(test_file ${scratch_directory}/cmake_mpi_test.c)
    endif()
    file(WRITE ${test_file}
      "#include <mpi.h>\n"
      "int main(int argc, char **argv) {\n"
      "  MPI_Init(&argc, &argv);\n"
      "  MPI_Finalize();\n"
      "}\n")
  endif()
  try_compile(compiler_has_mpi ${scratch_directory} ${test_file})
  if (compiler_has_mpi)
    set(MPI_${lang}_NO_INTERROGATE ${CMAKE_${lang}_COMPILER} CACHE STRING "Whether to interrogate MPI ${lang} compiler" FORCE)
    set(MPI_${lang}_COMPILER       ${CMAKE_${lang}_COMPILER} CACHE STRING "MPI ${lang} compiler"                        FORCE)
    set(MPI_${lang}_COMPILE_FLAGS  ""                        CACHE STRING "MPI ${lang} compilation flags"               FORCE)
    set(MPI_${lang}_INCLUDE_PATH   ""                        CACHE STRING "MPI ${lang} include path"                    FORCE)
    set(MPI_${lang}_LINK_FLAGS     ""                        CACHE STRING "MPI ${lang} linking flags"                   FORCE)
    set(MPI_${lang}_LIBRARIES      ""                        CACHE STRING "MPI ${lang} libraries to link against"       FORCE)
  endif()
  set(${success} ${compiler_has_mpi} PARENT_SCOPE)
  unset(compiler_has_mpi CACHE)
endfunction()

# This function has been added here from GetPrerequisites.
# It has been modified to resolve symlinks on linux so that the "file"
function(is_file_executable file result_var)
  #
  # A file is not executable until proven otherwise:
  #
  set(${result_var} 0 PARENT_SCOPE)

  get_filename_component(file_full "${file}" ABSOLUTE)
  string(TOLOWER "${file_full}" file_full_lower)
  #message(STATUS "file_full='${file_full}'")

  # If file name ends in .exe on Windows, *assume* executable:
  #
  if(WIN32 AND NOT UNIX)
    if("${file_full_lower}" MATCHES "\\.exe$")
      set(${result_var} 1 PARENT_SCOPE)
      return()
    endif()

    # A clause could be added here that uses output or return value of dumpbin
    # to determine ${result_var}. In 99%+? practical cases, the exe name
    # match will be sufficient...
    #
  endif()

  # Use the information returned from the Unix shell command "file" to
  # determine if ${file_full} should be considered an executable file...
  #
  # If the file command's output contains "executable" and does *not* contain
  # "text" then it is likely an executable suitable for prerequisite analysis
  # via the get_prerequisites macro.
  #
  if(UNIX)
    if(NOT file_cmd)
      find_program(file_cmd "file")
      mark_as_advanced(file_cmd)
    endif()

    if(file_cmd)
      execute_process(COMMAND "${file_cmd}" "${file_full}"
        OUTPUT_VARIABLE file_ov
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )

      # Replace the name of the file in the output with a placeholder token
      # (the string " _file_full_ ") so that just in case the path name of
      # the file contains the word "text" or "executable" we are not fooled
      # into thinking "the wrong thing" because the file name matches the
      # other 'file' command output we are looking for...
      #
      string(REPLACE "${file_full}" " _file_full_ " file_ov "${file_ov}")
      string(TOLOWER "${file_ov}" file_ov)

      #message(STATUS "file_ov='${file_ov}'")
      if("${file_ov}" MATCHES "symbolic link")
        #message(STATUS "symlink!")
        if(NOT readlink_cmd)
          find_program(readlink_cmd "readlink")
          mark_as_advanced(readlink_cmd)
        endif()
        if (readlink_cmd)
            execute_process(COMMAND "${readlink_cmd}" -e -n "${file_full}"
              OUTPUT_VARIABLE resolved_link
              OUTPUT_STRIP_TRAILING_WHITESPACE
              )
            #message(STATUS "recursive call: is_exec(${resolved_link} recursive_result)")
            is_file_executable(${resolved_link} recursive_result)
            #message(STATUS "recursive result: ${recursive_result}")
            set(${result_var} ${recursive_result} PARENT_SCOPE)
        else()
            message(WARNING "No 'readlink' command, cant resolve symlink '${file_full}'")
        endif()
      elseif("${file_ov}" MATCHES "executable")
        #message(STATUS "executable!")
        #if("${file_ov}" MATCHES "text")
        #  message(STATUS "but text, so *not* a binary executable!")
        #else()
          set(${result_var} 1 PARENT_SCOPE)
          return()
        #endif()
      endif()

      # Also detect position independent executables on Linux,
      # where "file" gives "shared object ... (uses shared libraries)"
      if("${file_ov}" MATCHES "shared object.*\(uses shared libs\)")
        set(${result_var} 1 PARENT_SCOPE)
        return()
      endif()

    else()
      message(WARNING "warning: No 'file' command, skipping execute_process...")
    endif()
  endif()
endfunction()

# End definitions, commence real work here.

SET(PATHOPT )
if (MPI_HOME)
    SET(PATHOPT NO_DEFAULT_PATH)
endif()
# Most mpi distros have some form of mpiexec which gives us something we can reliably look for.
find_program(MPIEXEC
  NAMES ${_MPI_EXEC_NAMES}
  HINTS ${_MPI_PREFIX_PATH} 
  PATH_SUFFIXES ${_BIN_SUFFIX}
  ${PATHOPT}
  DOC "Executable for running MPI programs.")
message("Found MPI executable: ${MPIEXEC}")

# call get_filename_component twice to remove mpiexec and the directory it exists in (typically bin).
# This gives us a fairly reliable base directory to search for /bin /lib and /include from.
get_filename_component(_MPI_BASE_DIR "${MPIEXEC}" PATH)
get_filename_component(_MPI_BASE_DIR "${_MPI_BASE_DIR}" PATH)

set(MPIEXEC_NUMPROC_FLAG "-np" CACHE STRING "Flag used by MPI to specify the number of processes for MPIEXEC; the next option will be the number of processes.")
set(MPIEXEC_PREFLAGS     ""    CACHE STRING "These flags will be directly before the executable that is being run by MPIEXEC.")
set(MPIEXEC_POSTFLAGS    ""    CACHE STRING "These flags will come after all flags given to MPIEXEC.")
set(MPIEXEC_MAX_NUMPROCS "2"   CACHE STRING "Maximum number of processors available to run MPI applications.")
mark_as_advanced(MPIEXEC MPIEXEC_NUMPROC_FLAG MPIEXEC_PREFLAGS MPIEXEC_POSTFLAGS MPIEXEC_MAX_NUMPROCS)


#=============================================================================
# Backward compatibility input hacks.  Propagate the FindMPI hints to C and
# CXX if the respective new versions are not defined.  Translate the old
# MPI_LIBRARY and MPI_EXTRA_LIBRARY to respective MPI_${lang}_LIBRARIES.
#
# Once we find the new variables, we translate them back into their old
# equivalents below.
foreach (lang C CXX)
  # Old input variables.
  set(_MPI_OLD_INPUT_VARS COMPILER COMPILE_FLAGS INCLUDE_PATH LINK_FLAGS)

  # Set new vars based on their old equivalents, if the new versions are not already set.
  foreach (var ${_MPI_OLD_INPUT_VARS})
    if (NOT MPI_${lang}_${var} AND MPI_${var})
      set(MPI_${lang}_${var} "${MPI_${var}}")
    endif()
  endforeach()

  # Special handling for MPI_LIBRARY and MPI_EXTRA_LIBRARY, which we nixed in the
  # new FindMPI.  These need to be merged into MPI_<lang>_LIBRARIES
  if (NOT MPI_${lang}_LIBRARIES AND (MPI_LIBRARY OR MPI_EXTRA_LIBRARY))
    set(MPI_${lang}_LIBRARIES ${MPI_LIBRARY} ${MPI_EXTRA_LIBRARY})
  endif()
endforeach()
#=============================================================================


# This loop finds the compilers and sends them off for interrogation.
foreach (lang C CXX Fortran)
  #message(STATUS "MPI_${lang}_COMPILER '${MPI_${lang}_COMPILER}': CMAKE_${lang}_COMPILER_WORKS=${CMAKE_${lang}_COMPILER_WORKS}")
  if (CMAKE_${lang}_COMPILER_WORKS)
    set(try_libs TRUE)
    # If the user supplies a compiler *name* instead of an absolute path, assume that we need to find THAT compiler.
    if (MPI_${lang}_COMPILER)
      message(STATUS "Using given MPI_${lang}_COMPILER '${MPI_${lang}_COMPILER}'")
      # If the user specifies a compiler, we don't want to try to search libraries either.
      set(try_libs FALSE)  
      is_file_executable(${MPI_${lang}_COMPILER} MPI_COMPILER_IS_EXECUTABLE)
      if (NOT MPI_COMPILER_IS_EXECUTABLE)
        message("User-defined MPI_${lang}_COMPILER is NOT an executable, looking for matching executable")
        # Get rid of our default list of names and just search for the name the user wants.
        set(_MPI_${lang}_COMPILER_NAMES ${MPI_${lang}_COMPILER})
        set(MPI_${lang}_COMPILER "MPI_${lang}_COMPILER-NOTFOUND" CACHE FILEPATH "Cleared" FORCE)
      endif()
    else()
      set(try_libs TRUE)
    endif()

    #message(STATUS "Looking for MPI_${lang}_COMPILER with names ${_MPI_${lang}_COMPILER_NAMES} at ${_MPI_PREFIX_PATH} + environment PATH")
    find_program(MPI_${lang}_COMPILER
      NAMES  ${_MPI_${lang}_COMPILER_NAMES}
      # Look for our locations first then on environment path
      HINTS  ${_MPI_PREFIX_PATH} ${MPI_HOME} $ENV{MPI_HOME}
      PATH_SUFFIXES ${_BIN_SUFFIX}
      ${PATHOPT})
    message(STATUS "Using MPI_${lang}_COMPILER '${MPI_${lang}_COMPILER}'")
    interrogate_mpi_compiler(${lang} ${try_libs})
    mark_as_advanced(MPI_${lang}_COMPILER)

    # last ditch try -- if nothing works so far, just try running the regular compiler and
    # see if we can create an MPI executable.
    set(regular_compiler_worked 0)
    if (NOT MPI_${lang}_LIBRARIES OR NOT MPI_${lang}_INCLUDE_PATH)
      try_regular_compiler(${lang} regular_compiler_worked)
    endif()

    set(MPI_${lang}_FIND_QUIETLY ${MPI_FIND_QUIETLY})
    set(MPI_${lang}_FIND_REQUIRED ${MPI_FIND_REQUIRED})
    set(MPI_${lang}_FIND_VERSION ${MPI_FIND_VERSION})
    set(MPI_${lang}_FIND_VERSION_EXACT ${MPI_FIND_VERSION_EXACT})
    
    # Check if the found version matches with the desired one
    # (Applies only if MPI variable is set!)
    if(MPI)
        SET(MNEMONICS mpich mpich2 openmpi intel)
        # Patterns to match the include path
        SET(PATTERNS ".*mpich([/|-].*|$)" ".*mpich2([/|-].*|$)" ".*openmpi([/|-].*|$)" ".*(intel|impi)[/|-].*")
        foreach(IDX RANGE 3)
            LIST(GET MNEMONICS ${IDX} MNEMONIC)
            LIST(GET PATTERNS ${IDX} PATTERN)
            if (MPI STREQUAL ${MNEMONIC} AND NOT MPI_${lang}_INCLUDE_PATH MATCHES ${PATTERN})
                message(STATUS "An MPI_${lang} compiler '${MPI_${lang}_COMPILER}' was found but the MPI_${lang}_INCLUDE_PATH")
                message(STATUS "'${MPI_${lang}_INCLUDE_PATH}' does not match the requested MPI implementation '${MPI}'.")
                message(STATUS "Check your include paths (searched in that order with suffixes '${_BIN_SUFFIX}'):")
                message(STATUS "PATH1 (CMAKE_PREFIX_PATH): ${CMAKE_PREFIX_PATH}")
                message(STATUS "PATH2 (MPI_HOME + OWN GUESS/HINTS): ${_MPI_PREFIX_PATH} ${MPI_HOME} $ENV{MPI_HOME}")
                message(STATUS "PATH3 (ENVIRONMENT PATH): $ENV{PATH}")
                message(STATUS "PATH4 (CMAKE_SYSTEM_PREFIX_PATH): ${CMAKE_SYSTEM_PREFIX_PATH}")
                message(FATAL_ERROR "Wrong MPI implementation found.\nCheck your MPI_HOME [or provide an absolute path to MPI_${lang}_COMPILER in] OpenCMISSLocalConfig.")
                UNSET(MPI_${lang}_INCLUDE_PATH CACHE)
                UNSET(MPI_${lang}_LIBRARIES CACHE)
            endif()
        endforeach()
    endif()

    if (regular_compiler_worked)
      find_package_handle_standard_args(MPI_${lang} DEFAULT_MSG MPI_${lang}_COMPILER)
    else()
      find_package_handle_standard_args(MPI_${lang} DEFAULT_MSG MPI_${lang}_LIBRARIES MPI_${lang}_INCLUDE_PATH)
    endif()
  endif()
endforeach()


#=============================================================================
# More backward compatibility stuff
#
# Bare MPI sans ${lang} vars are set to CXX then C, depending on what was found.
# This mimics the behavior of the old language-oblivious FindMPI.
set(_MPI_OLD_VARS FOUND COMPILER INCLUDE_PATH COMPILE_FLAGS LINK_FLAGS LIBRARIES)
if (MPI_CXX_FOUND)
  foreach (var ${_MPI_OLD_VARS})
    set(MPI_${var} ${MPI_CXX_${var}})
  endforeach()
elseif (MPI_C_FOUND)
  foreach (var ${_MPI_OLD_VARS})
    set(MPI_${var} ${MPI_C_${var}})
  endforeach()
else()
  # Note that we might still have found Fortran, but you'll need to use MPI_Fortran_FOUND
  set(MPI_FOUND FALSE)
endif()

# Chop MPI_LIBRARIES into the old-style MPI_LIBRARY and MPI_EXTRA_LIBRARY, and set them in cache.
if (MPI_LIBRARIES)
  list(GET MPI_LIBRARIES 0 MPI_LIBRARY_WORK)
  set(MPI_LIBRARY ${MPI_LIBRARY_WORK} CACHE FILEPATH "MPI library to link against" FORCE)
else()
  set(MPI_LIBRARY "MPI_LIBRARY-NOTFOUND" CACHE FILEPATH "MPI library to link against" FORCE)
endif()

list(LENGTH MPI_LIBRARIES MPI_NUMLIBS)
if (MPI_NUMLIBS GREATER 1)
  set(MPI_EXTRA_LIBRARY_WORK ${MPI_LIBRARIES})
  list(REMOVE_AT MPI_EXTRA_LIBRARY_WORK 0)
  set(MPI_EXTRA_LIBRARY ${MPI_EXTRA_LIBRARY_WORK} CACHE STRING "Extra MPI libraries to link against" FORCE)
else()
  set(MPI_EXTRA_LIBRARY "MPI_EXTRA_LIBRARY-NOTFOUND" CACHE STRING "Extra MPI libraries to link against" FORCE)
endif()
#=============================================================================

# unset these vars to cleanup namespace
unset(_MPI_OLD_VARS)
unset(_MPI_PREFIX_PATH)
unset(_MPI_BASE_DIR)
foreach (lang C CXX Fortran)
  unset(_MPI_${lang}_COMPILER_NAMES)
endforeach()