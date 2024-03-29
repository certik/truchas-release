!!
!! ADDGAPS
!!
!! An Exodus mesh utility program that adds gap elements to a mesh.
!!
!! Neil N. Carlson <nnc@lanl.gov>
!! 30 Oct 2005
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
!! Copyright (c) Los Alamos National Security, LLC.  This file is part of the
!! Truchas code (LA-CC-15-097) and is subject to the revised BSD license terms
!! in the LICENSE file found in the top-level directory of this distribution.
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program addgaps

  use exodus_mesh_type
  use exodus_mesh_io
  use command_line
  use addgaps_proc
  implicit none

  character(len=512) :: infile, outfile
  type(exodus_mesh)  :: inmesh, outmesh
  integer, pointer   :: ssid(:) => null()

  character(len=8), parameter :: CREATOR = 'addgaps', VERSION = '2.0'

  call parse_command_line (infile, outfile, ssid)
  call read_exodus_mesh (infile, inmesh)
  call add_gap_elements (inmesh, ssid, outmesh)
  call write_exodus_mesh (outfile, outmesh, CREATOR, VERSION)

end program addgaps
