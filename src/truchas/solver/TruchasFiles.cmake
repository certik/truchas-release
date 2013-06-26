# Truchas files in directory
#   solver

# List of files to  process
set(SOLVER_FILES)

# List of files to add to the Truchas library
set(SOLVER_SOURCE_FILES)

# Process target name
set(SOLVER_TARGET_NAME ProcessTruchasSolverFiles)


set(SOLVER_FILES
          solver/fhypre.F90
          solver/hypre_pcg_type.F90
          solver/linear_solution.F90
          solver/nonlinear_solution.F90
          solver/ortho_matvec.F90
          solver/preconditioners.F90
          solver/ridders_type.F90)

set(SOLVER_FPP_FLAGS 
        -I${TruchasExe_SOURCE_DIR}/utilities
        -I${TruchasExe_SOURCE_DIR}/solver
	${Truchas_FPP_FLAGS})

# Process files
fortran_preprocess_files(SOLVER_SOURCE_FILES
                         FILES ${SOLVER_FILES}
			 FPP_EXECUTABLE ${Truchas_PREPROCESSOR}
			 FPP_FLAGS ${SOLVER_FPP_FLAGS}
			 PROCESS_TARGET ${SOLVER_TARGET_NAME})
set(SOLVER_COMPILE_FLAGS "-I${PGSLib_MODULE_DIR} -I${UbikSolve_MODULE_DIR}")		       
set_source_files_properties(${SOLVER_SOURCE_FILES} PROPERTIES
                            COMPILE_FLAGS ${SOLVER_COMPILE_FLAGS})

list(APPEND SOLVER_SOURCE_FILES solver/fhypre_c.c)
set(fhypre_cflags "-I${Truchas_FCIface_INCLUDE_DIR}")
foreach (dir ${HYPRE_INCLUDE_DIRS})
  set(fhypre_cflags "${fhypre_cflags} -I${dir}")
endforeach()
if (ENABLE_MPI)
  set(fhypre_cflags "${fhypre_cflags} -I${MPI_C_INCLUDE_PATH}")
endif() 
print_variable(fhypre_cflags)
set_source_files_properties(solver/fhypre_c.c PROPERTIES
                            COMPILE_FLAGS ${fhypre_cflags})



list(APPEND Truchas_LIBRARY_SOURCE_FILES ${SOLVER_SOURCE_FILES})		       
list(APPEND Truchas_PROCESS_TARGETS ${SOLVER_TARGET_NAME})

