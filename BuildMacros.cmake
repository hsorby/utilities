MACRO( ADD_EXTERNAL_PROJECT 
    PROJECT_NAME
    PROJECT_FOLDER)

    # additional args
	SET( PROJECT_CMAKE_ARGS "")
	LIST(APPEND PROJECT_CMAKE_ARGS
	    -DOPENCMISS_DEPENDENCIES_CONFIGS_DIR=${OPENCMISS_DEPENDENCIES_CONFIGS_DIR}
	    -DOPENCMISS_DEPENDENCIES_LIBRARIES=${OPENCMISS_DEPENDENCIES_LIBRARIES}
	)
	# Forward any other variables
    foreach(extra_var ${ARGN})
        LIST(APPEND PROJECT_CMAKE_ARGS -D${extra_var}=${${extra_var}})
        message(STATUS "Appending extra definition -D${extra_var}=${${extra_var}}")
    endforeach()

	#SET( PATCH_COMMAND_STRING )
	#STRING( LENGTH "${PROJECT_PATCH_FILE}" PATCH_LENGTH )
	#IF( PATCH_LENGTH GREATER 0 )
	#	SET( PATCH_COMMAND_STRING "PATCH_COMMAND;${DEPENDENCIES_PATCH_EXECUTABLE};-p1;-i;${PROJECT_FOLDER}/download/${PROJECT_NAME}-${PROJECT_VERSION}.patch" )
	#ENDIF( PATCH_LENGTH GREATER 0 )
	# If we are builiding using devenv or msbuild we need to add the name of the solution file to the build and install command
	SET( LOCAL_PLATFORM_BUILD_COMMAND ${PLATFORM_BUILD_COMMAND} )
	SET( LOCAL_PLATFORM_INSTALL_COMMAND ${PLATFORM_INSTALL_COMMAND} )
	IF( GENERATOR_MATCH_VISUAL_STUDIO )
		# Some solution names differ from their project name so we change those here
		SET( SOLUTION_NAME ${PROJECT_NAME} )
		IF( ${PROJECT_NAME} STREQUAL "InsightToolkit" )
			SET( SOLUTION_NAME itk )
		ENDIF()
		LIST(INSERT LOCAL_PLATFORM_BUILD_COMMAND 1 ${SOLUTION_NAME}.sln )
		IF( DEPENDENCIES_DEVENV_EXECUTABLE )
			LIST(INSERT LOCAL_PLATFORM_INSTALL_COMMAND 1 ${SOLUTION_NAME}.sln )
		ENDIF( DEPENDENCIES_DEVENV_EXECUTABLE )			
	ENDIF( GENERATOR_MATCH_VISUAL_STUDIO )
	
#	IF( ${CMAKE_BUILD_TYPE} STREQUAL "Debug" )
#		SET( PROJECT_DEBUG_SUFFIX d )
#	ENDIF()
	#IF( NOT EXISTS "${PROJECT_FOLDER}/src/${PROJECT_NAME}-${PROJECT_VERSION}/CMakeLists.txt" )
#		SET( EXTRACT_STEP "EXTRACT_ARCHIVE;${PROJECT_FOLDER}/download/${PROJECT_NAME}-${PROJECT_VERSION}/${PROJECT_NAME}-${PROJECT_VERSION}.${PROJECT_ARCHIVE_SUFFIX}" )
#		SET( PATCH_STEP "PATCH_COMMAND;${DEPENDENCIES_PATCH_EXECUTABLE};-p1;-i;${PROJECT_FOLDER}/download/${PROJECT_NAME}-${PROJECT_VERSION}/${PROJECT_NAME}-${PROJECT_VERSION}.patch" )
#	ELSE()
#		SET( EXTRACT_STEP )
#		SET( PATCH_STEP )
#	ENDIF()
    
    # We use the project folder name as module name
    SET(MODULE_NAME ${PROJECT_FOLDER})
    # get current revision ID
    execute_process(COMMAND git submodule ${MODULE_NAME} OUTPUT_VARIABLE RES)
    string(SUBSTRING ${RES} 1 40 REV_ID)
    message(STATUS "GIT submodule ${MODULE_NAME} revision: ${REV_ID}")
    
    if (OCM_DEVELOPER_MODE)
        execute_process(COMMAND git submodule init ${PROJECT_FOLDER})
    	ExternalProject_Add( ${PROJECT_NAME}
    		DEPENDS ${${PROJECT_NAME}_DEPS}
    		PREFIX ${PROJECT_FOLDER}
    		#DOWNLOAD_DIR ${PROJECT_FOLDER}/download/${PROJECT_NAME}-${PROJECT_VERSION}
    		SOURCE_DIR ../${PROJECT_FOLDER}
    		BINARY_DIR ${PROJECT_FOLDER}/build
    		#${PROJECT_NAME}${PROJECT_DEBUG_SUFFIX}-${PROJECT_VERSION}
    		#--Download step--------------
    		#SVN_REPOSITORY ${PROJECT_REPOSITORY}/${PROJECT_NAME}/${PROJECT_VERSION}
    		#SVN_REVISION -r ${PROJECT_REVISION}
    		#--Extract step---------------
    		#EXTRACT_ARCHIVE ${PROJECT_FOLDER}/download/${PROJECT_NAME}-${PROJECT_VERSION}/${PROJECT_NAME}-${PROJECT_VERSION}.${PROJECT_ARCHIVE_SUFFIX}
    		#${EXTRACT_STEP}
    		#--Update/Patch step----------
    		#PATCH_COMMAND "${DEPENDENCIES_PATCH_EXECUTABLE};-p1;-i;${PROJECT_FOLDER}/download/${PROJECT_NAME}-${PROJECT_VERSION}/${PROJECT_NAME}-${PROJECT_VERSION}.patch"
    		#${PATCH_STEP}
    		#--Configure step-------------
    		CMAKE_ARGS ${PROJECT_CMAKE_ARGS}
    		#--Build step-----------------
    		BUILD_COMMAND ${LOCAL_PLATFORM_BUILD_COMMAND}
    		#--Install step---------------
    		INSTALL_COMMAND "" #${LOCAL_PLATFORM_INSTALL_COMMAND}
    		)
    else()
            ExternalProject_Add( ${PROJECT_NAME}
    		DEPENDS ${${PROJECT_NAME}_DEPS}
    		PREFIX ${PROJECT_FOLDER}
    		#--Download step--------------
    		DOWNLOAD_DIR ../${PROJECT_FOLDER}
    		URL git@github.com:rondiplomatico/${MODULE_NAME}/archive/${REV_ID}.zip
    		#--Extract step---------------
    		SOURCE_DIR ../${PROJECT_FOLDER}
    		BINARY_DIR ${PROJECT_FOLDER}/build
    		#EXTRACT_ARCHIVE ${PROJECT_FOLDER}/download/${PROJECT_NAME}-${PROJECT_VERSION}/${PROJECT_NAME}-${PROJECT_VERSION}.${PROJECT_ARCHIVE_SUFFIX}
    		#${EXTRACT_STEP}
    		#--Configure step-------------
    		CMAKE_ARGS ${PROJECT_CMAKE_ARGS}
    		#--Build step-----------------
    		BUILD_COMMAND ${LOCAL_PLATFORM_BUILD_COMMAND}
    		#--Install step---------------
    		INSTALL_COMMAND "" #${LOCAL_PLATFORM_INSTALL_COMMAND}
    		)
    endif()
		
	UNSET( LOCAL_PLATFORM_BUILD_COMMAND )
	UNSET( LOCAL_PLATFORM_INSTALL_COMMAND )
	
	ADD_DOWNSTREAM_DEPS(${PROJECT_NAME})
    message(STATUS "Dependencies of ${PROJECT_NAME}: ${${PROJECT_NAME}_DEPS}")
    
ENDMACRO()

MACRO(ADD_DOWNSTREAM_DEPS PACKAGE)
    if (${PACKAGE}_FWD_DEPS)
        #message(STATUS "Package ${PACKAGE} has forward dependencies: ${${PACKAGE}_FWD_DEPS}")
        foreach(FWD_DEP ${${PACKAGE}_FWD_DEPS})
            #message(STATUS "adding ${PACKAGE} to fwd-dep ${FWD_DEP}_DEPS")  
            LIST(APPEND ${FWD_DEP}_DEPS ${PACKAGE})
        endforeach()
    endif()
ENDMACRO()

MACRO(EXTRACT_PKG_CONFIG PACKAGE_NAME)
    string(TOUPPER ${PACKAGE_NAME} PACKAGE_NAME_UPPER)
    SET(PKG_LIB ${PACKAGE_NAME_UPPER}_LIBRARIES)
    SET(PKG_INCDIR ${PACKAGE_NAME_UPPER}_INCLUDE_DIRS)
    get_target_property(${PKG_LIB} ${PACKAGE_NAME} LOCATION)
    if (NOT ${PKG_LIB})
        get_target_property(${PKG_LIB} ${PACKAGE_NAME} IMPORTED_LOCATION)
    endif()
    if (NOT ${PKG_LIB})
        get_target_property(${PKG_LIB} ${PACKAGE_NAME} IMPORTED_LOCATION_NOCONFIG)
    endif()
    get_target_property(${PKG_INCDIR} ${PACKAGE_NAME} INCLUDE_DIRECTORIES)
    
    message(STATUS "Extracted package information for ${PACKAGE_NAME}: ${PKG_LIB}=${${PKG_LIB}}, ${PKG_INCDIR}=${${PKG_INCDIR}}")
ENDMACRO()

FUNCTION(PRINT_VARS)
    get_cmake_property(_variableNames VARIABLES)
    foreach (_variableName ${_variableNames})
        message(STATUS "VARDUMP -- ${_variableName}=${${_variableName}}")
    endforeach()
ENDFUNCTION()