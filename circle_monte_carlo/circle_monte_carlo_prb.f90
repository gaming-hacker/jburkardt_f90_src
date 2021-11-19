program main

!*****************************************************************************80
!
!! MAIN is the main program for CIRCLE_MONTE_CARLO_PRB.
!
!  Discussion:
!
!    CIRCLE_MONTE_CARLO_PRB tests the CIRCLE_MONTE_CARLO library.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    11 January 2014
!
!  Author:
!
!    John Burkardt
!
  implicit none

  call timestamp ( )
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'CIRCLE_MONTE_CARLO_PRB'
  write ( *, '(a)' ) '  FORTRAN90 version'
  write ( *, '(a)' ) '  Test the CIRCLE_MONTE_CARLO library.'

  call test01 ( )
!
!  Terminate.
!
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'CIRCLE_MONTE_CARLO_PRB'
  write ( *, '(a)' ) '  Normal end of execution.'
  write ( *, '(a)' ) ' '
  call timestamp ( )

  stop
end
subroutine test01 ( )

!*****************************************************************************80
!
!! TEST01 uses CIRCLE01_SAMPLE with an increasing number of points.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    11 January 2014
!
!  Author:
!
!    John Burkardt
!
  implicit none

  real ( kind = 8 ) circle01_length
  integer ( kind = 4 ) e(2)
  integer ( kind = 4 ) :: e_test(2,7) = reshape ( (/ &
    0, 0, &
    2, 0, &
    0, 2, &
    4, 0, &
    2, 2, &
    0, 4, &
    6, 0 /), (/ 2, 7 /) )
  real ( kind = 8 ) error
  real ( kind = 8 ) exact
  integer ( kind = 4 ) j
  integer ( kind = 4 ) n
  real ( kind = 8 ) result(7)
  integer ( kind = 4 ) seed
  real ( kind = 8 ), allocatable :: value(:)
  real ( kind = 8 ), allocatable :: x(:,:)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'TEST01'
  write ( *, '(a)' ) '  Use CIRCLE01_SAMPLE to estimate integrals '
  write ( *, '(a)' ) '  along the length of the unit circle in 2D.'

  seed = 123456789

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '         N        1              X^2             Y^2' // &
    '             X^4           X^2Y^2             Y^4           X^6'
  write ( *, '(a)' ) ' '

  n = 1

  do while ( n <= 65536 )

    allocate ( value(1:n) )
    allocate ( x(1:2,1:n) )

    call circle01_sample ( n, seed, x )

    do j = 1, 7

      e(1:2) = e_test(1:2,j)

      call monomial_value ( 2, n, e, x, value )

      result(j) = circle01_length ( ) * sum ( value(1:n) ) &
        / real ( n, kind = 8 )

    end do

    write ( *, '(2x,i8,7(2x,g14.6))' ) n, result(1:7)

    deallocate ( value )
    deallocate ( x )

    n = 2 * n

  end do

  write ( *, '(a)' ) ' '

  do j = 1, 7

    e(1:2) = e_test(1:2,j)

    call circle01_monomial_integral ( e, result(j) )

  end do

  write ( *, '(2x,a8,7(2x,g14.6))' ) '   Exact', result(1:7)

  return
end
