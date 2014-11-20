# This file sets all the targets any (external) dependency package provides
SET(PACKAGES_WITH_TARGETS BLAS HYPRE LAPACK METIS
    MUMPS PARMETIS PASTIX PETSC PLAPACK PTSCOTCH SCALAPACK 
    SCOTCH SUITESPARSE SUNDIALS SUPERLU SUPERLU_DIST)
    
SET(BLAS_TARGETS blas)
SET(HYPRE_TARGETS hypre)
SET(LAPACK_TARGETS lapack)
SET(METIS_TARGETS metis)
SET(MUMPS_TARGETS mumps)
SET(PARMETIS_TARGETS parmetis metis)
SET(PASTIX_TARGETS pastix pastix-matrix-driver)
SET(PETSC_TARGETS petsc)
SET(PLAPACK_TARGETS plapack)
SET(PTSCOTCH_TARGETS scotch ptscotch esmumps ptesmumps)
SET(SCALAPACK_TARGETS scalapack)
SET(SCOTCH_TARGETS scotch esmumps)
SET(SUITESPARSE_TARGETS suitesparseconfig amd btf camd cholmod colamd ccolamd klu umfpack)
SET(SUNDIALS_TARGETS sundials_cvode sundials_fcvode sundials_cvodes
    sundials_ida sundials_fida sundials_idas
    sundials_kinsol sundials_fkinsol
    sundials_nvecparallel sundials_nvecserial
    )
SET(SUPERLU_TARGETS superlu)
SET(SUPERLU_DIST_TARGETS superlu_dist)
SET(SLEPC_TARGETS slepc)