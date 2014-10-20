MACRO( ADD_EXTERNAL_PROJECT 
    PROJECT_NAME
    PROJECT_FOLDER
    PROJECT_DEPENDS)

# additional args
	SET( PROJECT_CMAKE_ARGS ${ARGN} )
	LIST(APPEND PROJECT_CMAKE_ARGS
	    -DOPENCMISS_DEPENDENCIES_CONFIGS_DIR=${OPENCMISS_DEPENDENCIES_CONFIGS_DIR}
	    -DOPENCMISS_DEPENDENCIES_LIBRARIES=${OPENCMISS_DEPENDENCIES_LIBRARIES}
	)

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
	ExternalProject_Add( ${PROJECT_NAME}
		DEPENDS ${PROJECT_DEPENDS}
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
		
	UNSET( LOCAL_PLATFORM_BUILD_COMMAND )
	UNSET( LOCAL_PLATFORM_INSTALL_COMMAND )

ENDMACRO()