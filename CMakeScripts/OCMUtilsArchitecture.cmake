MACRO(GET_COMPILER_NAME VARNAME)
	# Get the compiler name
	IF( MINGW )
		SET(${VARNAME} "mingw" )
	ELSEIF( MSYS )
		SET(${VARNAME} "msys" )
	ELSEIF( BORLAND )
		SET(${VARNAME} "borland" )
	ELSEIF( WATCOM )
		SET(${VARNAME} "watcom" )
	ELSEIF( MSVC OR MSVC_IDE OR MSVC60 OR MSVC70 OR MSVC71 OR MSVC80 OR CMAKE_COMPILER_2005 OR MSVC90 )
		SET(${VARNAME} "msvc" )
	ELSEIF( CMAKE_COMPILER_IS_GNUCC )
		SET(${VARNAME} "gcc" )
	ELSEIF( CMAKE_COMPILER_IS_GNUCXX )
		SET(${VARNAME} "gxx" )
	ELSEIF( CYGWIN )
		SET(${VARNAME} "cygwin" )
	ENDIF()
ENDMACRO()

macro(APPEND_ARCHITECTURE_PATH VARNAME)
    SET(ARCHPATH )
    
    # Architecture/System
    SET(ARCHPATH ${CMAKE_SYSTEM_PROCESSOR}_${CMAKE_SYSTEM_NAME})
    
    # Compiler
    GET_COMPILER_NAME(COMPILER)
    SET(ARCHPATH ${ARCHPATH}/${COMPILER})
    
    # MPI Compiler information
    SET(COMP_NAME )
    if(MPI_C_COMPILER)
        get_filename_component(C_COMP_NAME ${MPI_C_COMPILER} NAME)
        SET(COMP_NAME ${C_COMP_NAME})
    endif()
    if(MPI_Fortran_COMPILER)
        get_filename_component(F_COMP_NAME ${MPI_Fortran_COMPILER} NAME)
        SET(COMP_NAME "${COMP_NAME}_${F_COMP_NAME}")
    endif()
    if (COMP_NAME)
        SET(ARCHPATH ${ARCHPATH}/${COMP_NAME})
    endif()
    
    # Append to desired variable
    SET(${VARNAME} ${${VARNAME}}/${ARCHPATH})
endmacro()

# Appends the currently selected build type to a path.
# So far works on unix only
macro(APPEND_BUILDTYPE_PATH VARNAME)
    if (CMAKE_BUILD_TYPE)
        STRING(TOLOWER ${CMAKE_BUILD_TYPE} buildtype)
        SET(BUILDTYPEEXTRA ${buildtype})
    elseif (NOT CMAKE_CFG_INTDIR STREQUAL .)
        SET(BUILDTYPEEXTRA ${CMAKE_CFG_INTDIR})
    endif()
    SET(${VARNAME} ${${VARNAME}}/${BUILDTYPEEXTRA})
endmacro()