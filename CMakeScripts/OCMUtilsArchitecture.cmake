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
	ELSEIF( CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	    execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
	        RESULT_VARIABLE RES
	        OUTPUT_VARIABLE VERSION
	        OUTPUT_STRIP_TRAILING_WHITESPACE)
	    if (NOT RES EQUAL 0)
	        SET(VERSION "0.0")
	    endif()
	    SET(${VARNAME} gcc-${VERSION})
	    #if( CMAKE_COMPILER_IS_GNUCC )
	    #    SET(${VARNAME} gcc-${VERSION})
	    #else()
	    #    SET(${VARNAME} gxx-${VERSION})
	    #endif()
	ELSEIF( CYGWIN )
		SET(${VARNAME} "cygwin" )
	ENDIF()
ENDMACRO()

macro(GET_ARCHITECTURE_PATH VARNAME)
    SET(ARCHPATH )
    
    if(OCM_USE_ARCHITECTURE_PATH)
    
        # Architecture/System
        STRING(TOLOWER ${CMAKE_SYSTEM_NAME} CMAKE_SYSTEM_NAME_LOWER)
        SET(ARCHPATH ${CMAKE_SYSTEM_PROCESSOR}_${CMAKE_SYSTEM_NAME_LOWER})
        
        # MPI version information
        if(DEFINED MPI_C_COMPILER)
            SET(MPI_PART )
            if ("${MPI_C_INCLUDE_PATH}" MATCHES ".*mpich2.*")
                SET(MPI_PART mpich2)
            elseif("${MPI_C_INCLUDE_PATH}" MATCHES ".*openmpi.*")
                SET(MPI_PART openmpi)
            else()
                get_filename_component(COMP_NAME ${MPI_C_COMPILER} NAME)
                STRING(TOLOWER MPI_PART ${COMP_NAME})
            endif()
            if (MPI_PART)
                SET(ARCHPATH ${ARCHPATH}/${MPI_PART})
            endif()
        endif()
        
        # Compiler
        GET_COMPILER_NAME(COMPILER)
        SET(ARCHPATH ${ARCHPATH}/${COMPILER})
    
    endif()
    
    # Build type
    if (CMAKE_BUILD_TYPE)
        STRING(TOLOWER ${CMAKE_BUILD_TYPE} buildtype)
        SET(BUILDTYPEEXTRA ${buildtype})
    elseif (NOT CMAKE_CFG_INTDIR STREQUAL .)
        SET(BUILDTYPEEXTRA ${CMAKE_CFG_INTDIR})
    else()
        SET(BUILDTYPEEXTRA noconfig)
    endif()
    SET(ARCHPATH ${ARCHPATH}/${BUILDTYPEEXTRA})
    
    # Append to desired variable
    SET(${VARNAME} ${ARCHPATH})
endmacro()