program main

!*****************************************************************************80
!
!! MAIN is the main program for ZERO_RC_PRB.
!
!  Discussion:
!
!    ZERO_RC_PRB tests the ZERO_RC library.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    21 January 2013
!
!  Author:
!
!    John Burkardt
!
  implicit none

  call timestamp ( )
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'ZERO_RC_PRB:'
  write ( *, '(a)' ) '  FORTRAN90 version'
  write ( *, '(a)' ) '  Test the ZERO_RC library.'

  call test01 ( )
  call test02 ( )
!
!  Terminate.
!
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'ZERO_RC_PRB:'
  write ( *, '(a)' ) '  Normal end of execution.'
  write ( *, '(a)' ) ' '
  call timestamp ( )

  stop
end
subroutine test01 ( )

!*****************************************************************************80
!
!! TEST01 tests ROOT_RC.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    21 January 2013
!
!  Author:
!
!    John Burkardt
!
  implicit none

  real ( kind = 8 ) ferr
  real ( kind = 8 ) fx
  integer ( kind = 4 ) i
  integer ( kind = 4 ) it
  integer ( kind = 4 ) it_max
  real ( kind = 8 ) q(9)
  real ( kind = 8 ) root_rc
  real ( kind = 8 ) x
  real ( kind = 8 ) xerr

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'TEST01'
  write ( *, '(a)' ) '  Test ROOT_RC, which searches for an'
  write ( *, '(a)' ) '  approximate solution of F(X) = 0.'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '       X              XERR            FX              FERR'
  write ( *, '(a)' ) ' '
!
!  Initialization.
!
  it = 0
  it_max = 30
  q(1:9) = 0.0D+00
  x = - 2.1D+00
!
!  Each call takes one more step of improvement.
!
  do

    fx = cos ( x ) - x

    if ( it == 0 ) then 
      write ( *, '(2x,g14.6,2x,14x,2x,g14.6))' ) x, fx
    else
      write ( *, '(4(2x,g14.6))' ) x, xerr, fx, ferr
    end if

    x = root_rc ( x, fx, ferr, xerr, q )

    if ( ferr < 1.0D-08 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Uncertainty in F(X) less than tolerance'
      exit
    end if

    if ( xerr < 1.0D-08 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Width of X interal less than tolerance.'
      exit
    end if

    if ( it_max < it ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Too many iterations!'
      exit
    end if

    it = it + 1
        
  end do

  return
end
subroutine test02 ( )

!*****************************************************************************80
!
!! TEST02 tests ROOTS_RC.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    21 January 2013
!
!  Author:
!
!    John Burkardt
!
  implicit none

  integer ( kind = 4 ), parameter :: n = 4

  real ( kind = 8 ) ferr
  real ( kind = 8 ) fx(n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) it
  integer ( kind = 4 ), parameter :: it_max = 30
  integer ( kind = 4 ) j
  real ( kind = 8 ) q(2*n+2,n+2)
  real ( kind = 8 ) x(n)
  real ( kind = 8 ) xnew(n)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'TEST02'
  write ( *, '(a)' ) '  Test ROOTS_RC, which seeks a solution of'
  write ( *, '(a)' ) '  the N-dimensional nonlinear system F(X) = 0.'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '       FERR          X'
  write ( *, '(a)' ) ' '
!
!  Initialization.
!
  q(1:2*n+2,1:n+2) = 0.0D+00

  xnew(1) = 1.2D+00
  xnew(2:n) = 1.0D+00

  it = 0

  do

    x(1:n) = xnew(1:n)

    fx(1) = 1.0D+00 - x(1)
    fx(2:n) = 10.0D+00 * ( x(2:n) - x(1:n-1)**2 )

    if ( it == 0 ) then
      write ( *, '(2x,14x,5(2x,g14.6))' ) x(1:n)
    else
      write ( *, '(2x,g14.6,5(2x,g14.6))' ) ferr, x(1:n)
    end if

    call roots_rc ( n, x, fx, ferr, xnew, q )

    if ( ferr < 1.0D-07 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Sum of |f(x)| less than tolerance.'
      exit
    end if

    if ( it_max < it ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Too many iterations!'
      exit
    end if

    it = it + 1

  end do

  return
end

