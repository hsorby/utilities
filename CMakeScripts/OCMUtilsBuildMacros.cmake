include(ExternalProject)

macro(GET_BUILD_COMMANDS BUILD_CMD_VAR INSTALL_CMD_VAR DIR PARALLEL)
    STRING(REGEX MATCH "^Visual Studio" GENERATOR_MATCH_VISUAL_STUDIO ${CMAKE_GENERATOR})
    STRING(REGEX MATCH "^NMake Makefiles$" GENERATOR_MATCH_NMAKE ${CMAKE_GENERATOR})
    STRING(REGEX MATCH "^Unix Makefiles$" GENERATOR_MATCH_MAKE ${CMAKE_GENERATOR})
#    IF( GENERATOR_MATCH_NMAKE )
#    	SET( PLATFORM_BUILD_COMMAND nmake ${NUMPROCS} )
#    	SET( PLATFORM_INSTALL_COMMAND nmake ${NUMPROCS} install )
#    	SET( THIRD_PARTY_PATCH_EXECUTABLE ${THIRD_PARTY_PATCH_EXECUTABLE} --binary )
#    ELSEIF( GENERATOR_MATCH_VISUAL_STUDIO )
#    	IF( MSVC10 )
#    		GET_FILENAME_COMPONENT( VISUAL_STUDIO_DIR [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\10.0\\Setup\\VS;ProductDir] REALPATH CACHE )
#    	ELSEIF( MSVC90 )
#    		GET_FILENAME_COMPONENT( VISUAL_STUDIO_DIR [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\9.0\\Setup\\VS;ProductDir] REALPATH CACHE )
#    	ELSEIF( MSVC80 )
#    		GET_FILENAME_COMPONENT( VISUAL_STUDIO_DIR [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\8.0\\Setup\\VS;ProductDir] REALPATH CACHE )
#    	ENDIF()
#    	FIND_PROGRAM(THIRD_PARTY_DEVENV_EXECUTABLE devenv.exe HINTS "${VISUAL_STUDIO_DIR}/Common7/IDE" )
#    	FIND_PROGRAM(THIRD_PARTY_MSBUILD_EXECUTABLE msbuild.exe )
#    	IF( THIRD_PARTY_DEVENV_EXECUTABLE )
#    		SET( PLATFORM_BUILD_COMMAND "${THIRD_PARTY_DEVENV_EXECUTABLE}" /Build ${CMAKE_BUILD_TYPE} /Project all_build )
#    		SET( PLATFORM_INSTALL_COMMAND "${THIRD_PARTY_DEVENV_EXECUTABLE}" /Build ${CMAKE_BUILD_TYPE} /Project install )
#    	ELSEIF( THIRD_PARTY_MSBUILD_EXECUTABLE )
#    		SET( PLATFORM_BUILD_COMMAND "${THIRD_PARTY_MSBUILD_EXECUTABLE}" /t:build /p:Configuration=${CMAKE_BUILD_TYPE} /m )
#    		SET( PLATFORM_INSTALL_COMMAND "${THIRD_PARTY_MSBUILD_EXECUTABLE}" install.vcxproj /t:build /p:Configuration=${CMAKE_BUILD_TYPE} /m)
#    	ELSE()
#    		MESSAGE( FATAL_ERROR "Failed to find either devenv.exe or msbuild.exe for Visual Studio generator." )
#    	ENDIF()
#    	SET( THIRD_PARTY_PATCH_EXECUTABLE ${THIRD_PARTY_PATCH_EXECUTABLE} --binary )
#    	
    	# Some solution names differ from their project name so we change those here
#		SET( SOLUTION_NAME ${PROJECT_NAME} )
#		IF( ${PROJECT_NAME} STREQUAL "InsightToolkit" )
#			SET( SOLUTION_NAME itk )
#		ENDIF()
#		LIST(INSERT PLATFORM_BUILD_COMMAND 1 ${SOLUTION_NAME}.sln )
#		IF( DEPENDENCIES_DEVENV_EXECUTABLE )
#			LIST(INSERT PLATFORM_INSTALL_COMMAND 1 ${SOLUTION_NAME}.sln )
#		ENDIF()
#    ELSEIF(GENERATOR_MATCH_MAKE)
#    	SET( PLATFORM_BUILD_COMMAND make ${NUMPROCS})
#    	SET( PLATFORM_INSTALL_COMMAND make ${NUMPROCS} install )
#    ELSE()
    SET( PLATFORM_BUILD_COMMAND ${CMAKE_COMMAND} --build ${DIR})
    SET( PLATFORM_INSTALL_COMMAND ${CMAKE_COMMAND} --build ${DIR} --target install)    
#    ENDIF()
    if(PARALLEL OR PARALLEL STREQUAL TRUE)
        include(ProcessorCount)
        ProcessorCount(NUM_PROCESSORS)
        if (NUM_PROCESSORS EQUAL 0)
            SET(NUM_PROCESSORS 1)
        #else()
        #    MATH(EXPR NUM_PROCESSORS ${NUM_PROCESSORS}+4)
        endif()
        if(GENERATOR_MATCH_MAKE OR GENERATOR_MATCH_NMAKE)
            LIST(APPEND PLATFORM_BUILD_COMMAND -- -j${NUM_PROCESSORS})
            LIST(APPEND PLATFORM_INSTALL_COMMAND -- -j${NUM_PROCESSORS})
        elseif(GENERATOR_MATCH_VISUAL_STUDIO)
            LIST(APPEND PLATFORM_BUILD_COMMAND -- /MP)
            LIST(APPEND PLATFORM_INSTALL_COMMAND -- /MP)
        endif()
    endif()
    #message(STATUS "Build command: ${PLATFORM_BUILD_COMMAND}, install: ${PLATFORM_INSTALL_COMMAND}")
	SET(${BUILD_CMD_VAR} ${PLATFORM_BUILD_COMMAND})
	SET(${INSTALL_CMD_VAR} ${PLATFORM_INSTALL_COMMAND})
endmacro()

# Gets the revison of a submodule
#
# See http://git-scm.com/docs/git-submodule#status
#
# STATUS_VAR: Variable name to store the submodule status flag (-,+, ), see git-submodule
# REV_VAR: Variable name to store the revision
# REPO_DIR: Repo directory that contains the submodule
# MODULE_PATH: Path to the submodule relative to REPO_DIR
macro(GET_SUBMODULE_STATUS STATUS_VAR REV_VAR REPO_DIR MODULE_PATH)
    if(WIN32)
        SET(_cmd cmd /c)
    endif()
    execute_process(COMMAND ${_cmd} git submodule status ${MODULE_PATH}
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE RES
        ERROR_VARIABLE RES_ERR
        WORKING_DIRECTORY ${REPO_DIR}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT RES_VAR EQUAL 0)
        message(FATAL_ERROR "Process returned nonzero result: ${RES_VAR}. Additional error: ${RES_ERR}")
    endif()
    string(SUBSTRING ${RES} 0 1 ${STATUS_VAR})
    string(SUBSTRING ${RES} 1 40 ${REV_VAR})
    unset(RES_VAR)
    unset(RES)
    unset(RES_ERR)
    unset(_cmd)
endmacro()

# Recursively inits and updates a submodule and switches to a specified branch, if given. 
macro(OCM_DEVELOPER_SUBMODULE_CHECKOUT REPO_ROOT MODULE_PATH BRANCH)
#macro(ADD_SUBMODULE_CHECKOUT_STEPS PROJECT REPO_ROOT MODULE_PATH BRANCH)
    #
    #ExternalProject_Add_Step(${PROJECT} gitinit
	#        COMMAND git submodule update --init --recursive ${MODULE_PATH}
	#        COMMENT "Initializing git submodule ${MODULE_PATH}.."
	#        DEPENDERS configure
	#        WORKING_DIRECTORY ${REPO_ROOT})
	#if (BRANCH)
    # 	ExternalProject_Add_Step(${PROJECT} gitcheckout
    # 	        COMMAND git checkout ${BRANCH}
    #	        COMMENT "Checking out branch ${BRANCH} of ${MODULE_PATH}.."
    # 	        DEPENDEES gitinit
    #	        DEPENDERS configure
    # 	        WORKING_DIRECTORY ${REPO_ROOT}/${MODULE_PATH}
    #	)
	#endif()
	
    message(STATUS "Initializing git submodule ${MODULE_PATH}..")
    execute_process(COMMAND git submodule update --init --recursive ${MODULE_PATH}
        RESULT_VARIABLE RETCODE
        ERROR_VARIABLE UPDATE_CMD_ERR
        WORKING_DIRECTORY ${REPO_ROOT})
    if (NOT RETCODE EQUAL 0)
        message(FATAL_ERROR "Error updating submodule '${MODULE_PATH}' (code: ${RETCODE}): ${UPDATE_CMD_ERR}")
    endif()
    if (BRANCH)
       # Check out opencmiss branch
       execute_process(COMMAND git checkout ${BRANCH}
           WORKING_DIRECTORY ${REPO_ROOT}/${MODULE_PATH}
           RESULT_VARIABLE RETCODE
           ERROR_VARIABLE CHECKOUT_CMD_ERR
       )
       if (NOT RETCODE EQUAL 0)
           message(FATAL_ERROR "Error checking out submodule '${MODULE_PATH}' (code: ${RETCODE}): ${CHECKOUT_CMD_ERR}")
       endif()
    endif()
endmacro()