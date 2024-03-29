# #  -*- mode: cmake -*-

#
# ExternalProject_HDF5
#    Build the HDF5 project
#
#

# --- Setup

# Projects/targets dependent on HDF5 need this target
set(HDF5_BUILD_TARGET hdf5)

# Define the version and archive file
set(EP_HDF5_VERSION_MAJOR 1)
set(EP_HDF5_VERSION_MINOR 8)
set(EP_HDF5_VERSION_PATCH 11)
set(EP_HDF5_VERSION ${EP_HDF5_VERSION_MAJOR}.${EP_HDF5_VERSION_MINOR}.${EP_HDF5_VERSION_PATCH})
set(EP_HDF5_ARCHIVE_FILE   hdf5-${EP_HDF5_VERSION}.tar.gz)
set(EP_HDF5_MD5_SUM       1a4cc04f7dbe34e072ddcf3325717504)  

# Useful utility to build *FLAGS strings
include(BuildWhitespaceString)

# Make CMake files to run scripts and exit correctly 
include(MakeCMakeCommandFile)

# Construct library names
include(BuildLibraryName)

# ExternalProject directories, file and log settings
set(hdf5_url_file     ${TruchasExternal_ARCHIVE_DIR}/${EP_HDF5_ARCHIVE_FILE})
set(hdf5_prefix_dir   ${TruchasExternal_BINARY_DIR}/hdf5)
set(hdf5_source_dir   ${hdf5_prefix_dir}/hdf5-${EP_HDF5_VERSION}-source)
set(hdf5_stamp_dir    ${hdf5_prefix_dir}/hdf5-timestamps)
set(hdf5_tmp_dir      ${hdf5_prefix_dir}/hdf5-tmp)
set(hdf5_install_dir  ${TruchasExternal_INSTALL_PREFIX})
set(hdf5_download_dir ${TruchasExternal_ARCHIVE_DIR})

# --- Configure flags

# MPI
if(ENABLE_MPI)
  set(hdf5_parallel_opt --enable-parallel)
else()
  set(hdf5_parallel_opt --disable-parallel)
endif()

# ZLIB (Required)
set(zlib_library_dir)
set(zlib_inc_dir)
if ( NOT TARGET ${ZLIB_BUILD_TARGET} )
  include(Verify_ZLIB)

  if (NOT ZLIB_VERIFIED)
    include(ExternalProject_ZLIB)
  endif(NOT ZLIB_VERIFIED)  

endif(NOT TARGET ${ZLIB_BUILD_TARGET})

get_filename_component(zlib_library_dir ${ZLIB_LIBRARY} PATH)
set(zlib_inc_dir ${ZLIB_INCLUDE_DIR})
set(hdf5_zlib_opt --with-zlib=${zlib_inc_dir},${zlib_library_dir})


# --- Compile flags
string(TOUPPER "CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_FLAGS)
set(cflags ${CMAKE_C_FLAGS} ${${CMAKE_BUILD_TYPE_FLAGS}})
if (ENABLE_MPI)
  foreach(dir ${MPI_C_INCLUDE_PATH})  
    list(APPEND cflags -I${dir})
  endforeach()  
endif()
build_whitespace_string(hdf5_cflags ${cflags})

# --- Link flags
set(ldflags -L${zlib_install_dir}/lib)
if(ENABLE_MPI)
  list(APPEND ldflags ${MPI_C_LIBRARIES})
endif()
build_whitespace_string(hdf5_ldflags ${ldflags})

# --- Add the external project

ExternalProject_Add(${HDF5_BUILD_TARGET}
                    DEPENDS ${ZLIB_BUILD_TARGET}
                    # -- Project directories
                    PREFIX       ${hdf5_prefix_dir}   
                    TMP_DIR      ${hdf5_tmp_dir}     
                    STAMP_DIR    ${hdf5_stamp_dir}
                    SOURCE_DIR   ${hdf5_source_dir}
                    DOWNLOAD_DIR ${hdf5_download_dir}
		    #INSTALL_DIR ${hdf5_install_dir}
		    # -- Archive file definitions
                    URL          ${hdf5_url_file}
                    URL_MD5      ${EP_HDF5_MD5_SUM}   
                    # -- Configure
		    CONFIGURE_COMMAND
                        <SOURCE_DIR>/configure
                                          --prefix=${hdf5_install_dir}
                                          --enable-option-checking
					  --with-pic
                                          --disable-parallel
                                          --disable-fortran
                                          --disable-cxx
                                          --enable-largefile
                                          --enable-production
                                          --enable-hl
                                          ${hdf5_zlib_opt}
                                          ${TruchasExternal_SHARED_SWITCH}
					  CC=${CMAKE_C_COMPILER}
                                          CFLAGS=${hdf5_cflags}
                                          LDFLAGS=${hdf5_ldflags}
                    # -- Build					  
                    BUILD_COMMAND $(MAKE)
		    BUILD_IN_SOURCE True
                    # -- Output control
                    ${TruchasExternal_LOG_OPTS})

# --- Set the variables for other targets that need HDF5

# Version
set(HDF5_VERSION ${EP_HDF5_VERSION})

# Include directory
set(HDF5_INCLUDE_DIR ${hdf5_install_dir}/include)
set(HDF5_INCLUDE_DIRS ${HDF5_INCLUDE_DIR} ${ZLIB_INCLUDE_DIR})

# Library

# Debug or not, need to worry about this with CMake builds
#set(debug_suffix)
#string(TOLOWER "${CMAKE_BUILD_TYPE}" build_type_lc) 
#if ( "${build_type_lc}" STREQUAL "debug" )
#  set(debug_suffix _debug)
#endif()

build_library_name(hdf5_hl${debug_suffix}
                   HDF5_HL_LIBRARY 
                   APPEND_PATH ${hdf5_install_dir}/lib
                   ${lib_type})
set(HDF5_HL_LIBRARY ${HDF5_HL_LIBRARY})		 

build_library_name(hdf5${debug_suffix}
                   HDF5_C_LIBRARY
                   APPEND_PATH ${hdf5_install_dir}/lib
                   ${lib_type})
set(HDF5_C_LIBRARY ${HDF5_C_LIBRARY})		 

set(HDF5_LINK_LIBRARIES ${ZLIB_LIBRARIES})

set(HDF5_C_LIBRARIES 
           ${HDF5_HL_LIBRARY}
           ${HDF5_C_LIBRARY}
           ${HDF5_LINK_LIBRARIES})

