include(ExternalProject)

macro(GET_BUILD_COMMANDS BUILD_CMD_VAR INSTALL_CMD_VAR DIR)
# If we are builiding using devenv or msbuild we need to add the name of the solution file to the build and install command
	#SET( LOCAL_PLATFORM_BUILD_COMMAND ${PLATFORM_BUILD_COMMAND} )
	SET( LOCAL_PLATFORM_BUILD_COMMAND ${CMAKE_COMMAND} --build ${DIR})
	#SET( LOCAL_PLATFORM_INSTALL_COMMAND ${PLATFORM_INSTALL_COMMAND} )
	SET( LOCAL_PLATFORM_INSTALL_COMMAND ${CMAKE_COMMAND} --build ${DIR} --target install)
	IF( GENERATOR_MATCH_VISUAL_STUDIO )
		# Some solution names differ from their project name so we change those here
		SET( SOLUTION_NAME ${PROJECT_NAME} )
		IF( ${PROJECT_NAME} STREQUAL "InsightToolkit" )
			SET( SOLUTION_NAME itk )
		ENDIF()
		LIST(INSERT LOCAL_PLATFORM_BUILD_COMMAND 1 ${SOLUTION_NAME}.sln )
		IF( DEPENDENCIES_DEVENV_EXECUTABLE )
			LIST(INSERT LOCAL_PLATFORM_INSTALL_COMMAND 1 ${SOLUTION_NAME}.sln )
		ENDIF()			
	ENDIF()
	SET(${BUILD_CMD_VAR} ${LOCAL_PLATFORM_BUILD_COMMAND})
	SET(${INSTALL_CMD_VAR} ${LOCAL_PLATFORM_INSTALL_COMMAND})
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
    execute_process(COMMAND git submodule status ${MODULE_PATH}
        OUTPUT_VARIABLE RES
        WORKING_DIRECTORY ${REPO_DIR})
    string(SUBSTRING ${RES} 0 1 ${STATUS_VAR})
    string(SUBSTRING ${RES} 1 40 ${REV_VAR})
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