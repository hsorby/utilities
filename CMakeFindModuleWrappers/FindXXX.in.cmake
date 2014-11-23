macro(GET_BUILD_TYPE VARNAME)
    if (NOT CMAKE_CFG_INTDIR STREQUAL .)
        STRING(TOUPPER ${VARNAME} ${CMAKE_CFG_INTDIR})
    elseif(DEFINED CMAKE_BUILD_TYPE)
        SET(${VARNAME} ${CMAKE_BUILD_TYPE})
    else()
        SET(${VARNAME} NOCONFIG)
    endif()
endmacro()

macro(MODULE_TO_TARGETS LIBS INCS)
    message(STATUS "Converting found module to imported targets for package @PACKAGE_NAME@:\n"
        "Libraries: ${LIBS}\nIncludes: ${INCS}")
    GET_BUILD_TYPE(CURRENT_BUILD_TYPE)
    SET(DONE_LIBS )
    foreach(TARGET @PACKAGE_TARGETS@)
        #message(STATUS "Trying target ${TARGET}")
        SET(CURTARGET_DONE FALSE)
        # Try different patterns to guess/recognize the already installed packages
        SET(PATTERNS "^(lib)?${TARGET}.[a|so|lib|dll]$"
            "^(lib)?${TARGET}[-|_]${@PACKAGE_NAME@_FIND_VERSION}.[a|so|lib|dll]$"
            "^(lib)?${TARGET}[-|_]${@PACKAGE_NAME@_FIND_VERSION}[^.]*"
            "^(lib)?${TARGET}[^.]*")
        foreach(LIB ${LIBS})
            #message(STATUS "Trying library ${LIB}")
            get_filename_component(LIBFILE ${LIB} NAME)
            foreach(PATTERN ${PATTERNS})
                if (LIBFILE MATCHES ${PATTERN})
                    message(STATUS "Matched target ${TARGET} to library '${LIB}' (${LIBFILE} MATCHES ${PATTERN})")
                    add_library(${TARGET} UNKNOWN IMPORTED)
                    set_property(TARGET ${TARGET} APPEND PROPERTY IMPORTED_CONFIGURATIONS CURRENT_BUILD_TYPE)
                    set_target_properties(${TARGET} PROPERTIES 
                        IMPORTED_LOCATION_${CURRENT_BUILD_TYPE} ${LIB})
                    # Simply add the m and rt libraries on unix
                    if(UNIX)
                        set_target_properties(${TARGET} PROPERTIES
                            INTERFACE_LINK_LIBRARIES "m;rt")
                    endif()
                    if (INCS)
                        set_target_properties(${TARGET} PROPERTIES 
                            INTERFACE_INCLUDE_DIRECTORIES "${INCS}")
                    endif()
                    SET(CURTARGET_DONE TRUE)
                    LIST(APPEND DONE_LIBS ${LIB})
                    break()
                endif()
            endforeach()
            if (CURTARGET_DONE)
                break()
            endif()
        endforeach()
    endforeach()
    # Add non-matched libraries as link libraries so nothing gets forgotten
    foreach(LIB ${LIBS})
        LIST(FIND DONE_LIBS ${LIB} POSITION)
        if (POSITION EQUAL -1)
            message(STATUS "Adding not-associated library ${LIB} to link interface of targets '@PACKAGE_TARGETS@'")
            foreach(TARGET @PACKAGE_TARGETS@)
                set_target_properties(${TARGET} PROPERTIES
                    INTERFACE_LINK_LIBRARIES "${LIB}")
            endforeach()
        endif()
    endforeach()
endmacro()

#message(STATUS "OpenCMISS Find@PACKAGE_NAME@ wrapper called.")
SET(FOUND @PACKAGE_NAME@_FOUND)
# Default: Not found
SET(${FOUND} NO)
    
if (OCM_FORCE_@PACKAGE_NAME@)
    message(STATUS "OpenCMISS version of @PACKAGE_NAME@ forced:\nLooking for @PACKAGE_NAME@ ${@PACKAGE_NAME@_FIND_VERSION} exclusively in '${CMAKE_PREFIX_PATH}'")
    find_package(@PACKAGE_NAME@ ${@PACKAGE_NAME@_FIND_VERSION} CONFIG
        PATHS ${CMAKE_PREFIX_PATH}
        QUIET
        NO_DEFAULT_PATH)
else()        

    # Remove all paths resolving to this one here so that recursive calls wont search here again
    SET(_MODPATHCOPY ${CMAKE_MODULE_PATH})
    SET(_READDME )
    foreach(_ENTRY ${_MODPATHCOPY})
        if(_ENTRY MATCHES ".*/CMakeFindModuleWrappers$")
            LIST(REMOVE_ITEM CMAKE_MODULE_PATH ${_ENTRY})
            LIST(APPEND _READDME ${_ENTRY})
        endif()
    endforeach()
    
    # Make "native" call to find_package in MODULE mode first
    message(STATUS "Trying to find @PACKAGE_NAME@ ${@PACKAGE_NAME@_FIND_VERSION} in MODULE mode")
    #message(STATUS "(CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH})")
    
    # Temporarily disable the required flag (if set from outside)
    SET(_PKG_REQ_OLD ${@PACKAGE_NAME@_FIND_REQUIRED})
    UNSET(@PACKAGE_NAME@_FIND_REQUIRED)
    find_package(@PACKAGE_NAME@ ${@PACKAGE_NAME@_FIND_VERSION} MODULE QUIET)
    SET(@PACKAGE_NAME@_FIND_REQUIRED ${_PKG_REQ_OLD})
    
    if (@PACKAGE_NAME@_FOUND)
        message(STATUS "Found package @PACKAGE_NAME@: ${@PACKAGE_NAME@_LIBRARIES}")
        SET(INCS )
        foreach(DIRSUFF _INCLUDE_DIRS _INCLUDES _INCLUDE_PATH _INCLUDE_DIR)
            #message(STATUS "Trying @PACKAGE_NAME@${DIRSUFF}..")
            if (DEFINED @PACKAGE_NAME@${DIRSUFF})
                SET(INCS ${@PACKAGE_NAME@${DIRSUFF}})
                break()
            endif()
        endforeach()
        
        MODULE_TO_TARGETS("${@PACKAGE_NAME@_LIBRARIES}" "${INCS}")
    else()
        message(STATUS "Trying to find @PACKAGE_NAME@ ${@PACKAGE_NAME@_FIND_VERSION} in CONFIG mode")
        #message(STATUS "(CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH})")
        find_package(@PACKAGE_NAME@ ${@PACKAGE_NAME@_FIND_VERSION} CONFIG QUIET)
    endif()
    
    # Restore the current module path
    # Sloppy as all are added to the front.. this will bite someone somewhere sometime :-p
    foreach(_ENTRY ${_READDME})
        LIST(INSERT CMAKE_MODULE_PATH 0 ${_ENTRY})
    endforeach()
endif()

if (@PACKAGE_NAME@_FIND_REQUIRED AND NOT @PACKAGE_NAME@_FOUND)
    message(FATAL_ERROR "Could not find @PACKAGE_NAME@ with either MODULE or CONFIG mode.\nCMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}\nCMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
endif()