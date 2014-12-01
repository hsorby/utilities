# ==============================
# Initial setup instructions
# ==============================
option(OCM_DEVELOPER_MODE "Handle the packages as proper submodules. DEVELOPERS ONLY." ON)

# ==============================
# Build configuration
# ==============================
option(BUILD_IRON "Build OpenCMISS-Iron" YES)
option(BUILD_ZINC "Build OpenCMISS-Zinc" NO)

# Use architecture information paths
SET(OCM_USE_ARCHITECTURE_PATH YES)

# Precision to build (if applicable)
# Valid choices are s,d,c,z and any combinations.
# s: Single / float precision
# d: Double precision
# c: Complex / float precision
# z: Complex / double precision
SET(BUILD_PRECISION sd)

# The integer types that can be used (if applicable)
# Used only by PASTIX yet
SET(INT_TYPE int32)

# Also build tests?
SET(BUILD_TESTS ON)

# Type of libraries to build
option(BUILD_SHARED_LIBS "Build shared libraries" NO)

# ==============================
# Compiler
# ==============================

# ==============================
# Multithreading
# This controls openmp/OpenAcc
# ==============================
option(OCM_USE_MT "Use multithreading in OpenCMISS (where applicable)" YES)

# ==============================
# MPI
# ==============================
# Global MPI flag
option(OCM_USE_MPI "Use MPI in OpenCMISS (not cared about eveywhere yet)!" YES)
# @@@ linux @@@
# mpich: gnu
# mpich2: gnu
# openmpi: gnu
# intel: needs I_MPI_ROOT
#  - also needs to know if GNU or INTEL compiler
# mvapich2: works only with MPI_INSTALL_DIR defined
# poe: not implemented
# cray: have special path
# @@@ aix @@@
# poe: 
# @@@ windows @@@
# mpich, mpich2: fixed directory
#SET(MPI mpich)
#SET(MPI mpich2)
#SET(MPI openmpi)
#SET(MPI intel)

# Enter a custom mpi root directory here for a different mpi implementation.
# Leave as-is to use default system mpi.
#SET(MPI_HOME ~/software/openmpi-1.8.3_install)

# Further, you can specify an explicit name of the compiler
# executable (no path, just the name).
# This will be used independently of (but possibly with) the MPI_HOME setting.
#SET(MPI_C_COMPILER mpicc)
#SET(MPI_CXX_COMPILER mpic++)
#SET(MPI_Fortran_COMPILER mpif77)

# Force to use all OpenCMISS dependencies - long compilation, but will work
SET(FORCE_OCM_ALLDEPS NO)

# To enforce use of the shipped package, set OCM_FORCE_<PACKAGE>=YES e.g.
#  SET(OCM_FORCE_BLAS YES)
# for BLAS libraries.

# Choose here which optional dependencies/packages will be built by cmake.
# The default is to build all

#SET(OCM_USE_BLAS NO)
#SET(OCM_USE_LAPACK NO)
#SET(OCM_USE_SCALAPACK NO)
#SET(OCM_USE_MUMPS NO)
#SET(OCM_USE_METIS NO)
#SET(OCM_USE_PLAPACK NO)
#SET(OCM_USE_PTSCOTCH NO)
#SET(OCM_USE_SCOTCH NO)
#SET(OCM_USE_SUITESPARSE NO)
#SET(OCM_USE_SUNDIALS NO)
#SET(OCM_USE_SUPERLU NO)
#SET(OCM_USE_SUPERLU_DIST NO)
#SET(OCM_USE_PARMETIS NO)
#SET(OCM_USE_PASTIX NO)
#SET(OCM_USE_HYPRE NO)
#SET(OCM_USE_PETSC NO)
#SET(OCM_USE_SLEPC NO)
#SET(OCM_USE_LIBCELLML NO)

SET(BLAS_VERSION 3.5.0)
SET(HYPRE_VERSION 2.9.0)
SET(LAPACK_VERSION 3.5.0)
SET(METIS_VERSION 5.1)
SET(MUMPS_VERSION 4.10.0)
SET(PASTIX_VERSION 5.2.2.16)
SET(PARMETIS_VERSION 4.0.3)
SET(PETSC_VERSION 3.5)
SET(PTSCOTCH_VERSION 6.0.3)
SET(SCALAPACK_VERSION 2.8)
SET(SCOTCH_VERSION 6.0.3)
SET(SLEPC_VERSION 3.5)
SET(SUITESPARSE_VERSION 4.4.0)
SET(SUNDIALS_VERSION 2.5)
SET(SUPERLU_VERSION 4.3)
SET(SUPERLU_DIST_VERSION 3.3)

# ==========================================================================================
# Single module configuration
#
# These flags only apply if the corresponding package is build
# by the OpenCMISS Dependencies system. The packages themselves will then search for the
# appropriate consumed packages. No checks are performed on whether the consumed packages
# will also be build by us or not, as they might be provided externally.
#
# To be safe: E.g. if you wanted to use MUMPS with SCOTCH, also set OCM_USE_SCOTCH=YES so that
# the build system ensures that SCOTCH will be available.
# ==========================================================================================
SET(MUMPS_WITH_SCOTCH NO)
SET(MUMPS_WITH_PTSCOTCH YES)
#SET(MUMPS_WITH_METIS YES)
#SET(MUMPS_WITH_PARMETIS NO)

SET(SUNDIALS_WITH_LAPACK YES)

SET(SCOTCH_USE_PTHREAD YES)
SET(SCOTCH_USE_GZ YES)

SET(SUPERLU_DIST_WITH_PARMETIS YES)

SET(PASTIX_USE_THREADS YES)
SET(PASTIX_USE_METIS YES)
SET(PASTIX_USE_PTSCOTCH YES)