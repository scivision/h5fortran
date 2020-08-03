program scalar_test

use, intrinsic :: iso_fortran_env, only: real32, real64, int32, stderr=>error_unit
use hdf5, only: HSIZE_T
use h5fortran, only: hdf5_file

implicit none (type, external)

type(hdf5_file) :: h
real(real32), allocatable :: rr1(:)
real(real32) :: rt, r1(4)
integer(int32) :: it, i1(4)
integer(int32), allocatable :: i1t(:)
integer(HSIZE_T), allocatable :: dims(:)
integer :: i
character(*), parameter :: fn = 'test_scalar.h5'

do i = 1,size(i1)
  i1(i) = i
enddo

r1 = i1

!> write
call h%initialize(fn, status='replace')
!! scalar tests
call h%write('/scalar_int', 42_int32)
call h%write('/scalar_real', -1._real32)
call h%write('/scalar_real', 42._real32)
call h%write('/1d_real', r1)
call h%write('/1d_int', i1)
!! test rewrite
call h%write('scalar_real', 42.)
call h%write('scalar_int', 42)
call h%finalize()

!> read

call h%initialize(fn, status='old', action='r')

call h%read('/scalar_int', it)
call h%read('/scalar_real', rt)
if (.not.(rt==it .and. it==42)) then
  write(stderr,*) it,'/=',rt
  error stop 'scalar real / int: not equal 42'
endif

call h%shape('/1d_real',dims)
allocate(rr1(dims(1)))
call h%read('/1d_real',rr1)
if (.not.all(r1 == rr1)) error stop 'real 1-D: read does not match write'

call h%shape('/1d_int',dims)
allocate(i1t(dims(1)))
call h%read('/1d_int',i1t)
if (.not.all(i1==i1t)) error stop 'integer 1-D: read does not match write'

if (.not. h%filename == fn) then
  write(stderr,*) h%filename // ' mismatch filename'
  error stop
endif

call h%finalize()

end program
