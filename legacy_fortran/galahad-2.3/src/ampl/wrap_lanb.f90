! THIS VERSION: GALAHAD 2.1 - 22/03/2007 AT 09:00 GMT.
!! Implements an F90 wrapper around the solvers implemented in the
!!
!!            G  A  L  A  H  A  D
!!
!! optimization library, to make functions within Fortran 90 modules
!! visible to the linker when linking with a C object file.
!!
!! Grants access to
!!
!! [5] LANCELOT-B
!!     Augmented Lagrangian code for General Nonlinear Programs.
!!
!! D. Orban@ECE                                   Chicago, March 2003
!!
!! Thanks to the f2py project      http://cens.ioc.ee/projects/f2py2e
!!===================================================================

!! ===============================
!! Main wrapper around USE_LANB( )
!! ===============================

Subroutine Wrap_Use_Lanb( setup_use_lanb )

  Use GALAHAD_USELANB_double      ! Main LANB driver module
  External setup_use_lanb         ! Declared in galahad.c

  ! Pass pointer to subroutine USE_LANB to calling function
  Call setup_use_lanb( USE_LANB )

  Return

End Subroutine Wrap_Use_Lanb

!!=================================
!! End of wrapper
!! ================================
