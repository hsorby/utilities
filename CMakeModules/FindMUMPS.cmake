# - Try to find MUMPS
#

find_path (MUMPS_DIR include/mumps_compat.h HINTS ENV MUMPS_DIR PATHS $ENV{HOME}/mumps DOC "Mumps Directory")

IF(EXISTS ${MUMPS_DIR}/include/mumps_compat.h)
  SET(MUMPS_FOUND YES)
  SET(MUMPS_INCLUDES ${MUMPS_DIR})
  find_path (MUMPS_INCLUDE_DIR mumps_compat.h HINTS "${MUMPS_DIR}" PATH_SUFFIXES include NO_DEFAULT_PATH)
  list(APPEND MUMPS_INCLUDES ${MUMPS_INCLUDE_DIR})
  FILE(GLOB MUMPS_LIBRARIES "${MUMPS_DIR}/lib/libmumps*.a" "${MUMPS_DIR}/lib/lib*mumps*.a" "${MUMPS_DIR}/lib/lib*pord*.a")
ELSE()
  SET(MUMPS_FOUND NO)
ENDIF()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MUMPS DEFAULT_MSG MUMPS_LIBRARIES MUMPS_INCLUDES)