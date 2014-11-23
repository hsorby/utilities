# - Try to find SUNDIALS
#

# Test script
#SET(SUNDIALS_FOUND TRUE)
#SET(SUNDIALS_LIBRARIES libsundials_cvode.a
#    libsundials_fcvode.a libsundials_cvodes.a
#    libsundials_ida.a libsundials_fida.a libsundials_idas.a
#    libsundials_kinsol.a libsundials_fkinsol.a
#    libsundials_nvecserial.a
#    nonexistent.a) #libsundials_nvecparallel.a
#return()

find_path (SUNDIALS_DIR include/sundials/sundials_config.h HINTS ENV SUNDIALS_DIR PATHS $ENV{HOME}/sundials DOC "Sundials Directory")

IF(EXISTS ${SUNDIALS_DIR}/include/sundials/sundials_config.h)
  SET(SUNDIALS_FOUND YES)
  SET(SUNDIALS_INCLUDES ${SUNDIALS_DIR})
  find_path (SUNDIALS_INCLUDE_DIR sundials_config.h HINTS "${SUNDIALS_DIR}" PATH_SUFFIXES include/sundials NO_DEFAULT_PATH)
  list(APPEND SUNDIALS_INCLUDES ${SUNDIALS_INCLUDE_DIR})
  FILE(GLOB SUNDIALS_LIBRARIES RELATIVE "${SUNDIALS_DIR}/lib" "${SUNDIALS_DIR}/lib/libsundials*.a")
ELSE()
  SET(SUNDIALS_FOUND NO)
  if (NOT SUNDIALS_FIND_QUIETLY)
      message(FATAL_ERROR "Cannot find SUNDIALS!")
  endif()
ENDIF()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SUNDIALS DEFAULT_MSG SUNDIALS_LIBRARIES SUNDIALS_INCLUDES)