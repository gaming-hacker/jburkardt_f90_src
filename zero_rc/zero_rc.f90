function root_rc ( x, fx, ferr, xerr, q )

!*****************************************************************************80
!
!! ROOT_RC solves a single nonlinear equation using reverse communication.
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
!    Original FORTRAN77 version by Gaston Gonnet.
!    FORTRAN90 version by John Burkardt.
!
!  Reference:
!     
!    Gaston Gonnet,
!    On the Structure of Zero Finders,
!    BIT Numerical Mathematics,
!    Volume 17, Number 2, June 1977, pages 170-183.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) X, an estimate for the root.  On the first
!    call, this must be a value chosen by the user.  Thereafter, it may
!    be a value chosen by the user, or the value of ROOT returned on the
!    previous call to the function.
!
!    Input, real ( kind = 8 ) FX, the value of the function at X.
!
!    Output, real ( kind = 8 ) FERR, the smallest value of F encountered.
!
!    Output, real ( kind = 8 ) XERR, the width of the change-in-sign interval,
!    if one was encountered.
!
!    Input/output, real ( kind = 8 ) Q(9), storage needed by the function.
!    Before the first call, the user must set Q(1) to 0.
!
!    Output, real ( kind = 8 ) ROOT_RC, an improved estimate for the root.
!
  implicit none

  real ( kind = 8 ) d
  real ( kind = 8 ) decr
  real ( kind = 8 ) ferr
  real ( kind = 8 ) fx
  integer ( kind = 4 ) i
  real ( kind = 8 ) p
  real ( kind = 8 ) q(9)
  real ( kind = 8 ) r
  real ( kind = 8 ) r8_huge
  real ( kind = 8 ) r8_sign
  real ( kind = 8 ) root_rc
  real ( kind = 8 ) u
  real ( kind = 8 ) v
  real ( kind = 8 ) w
  real ( kind = 8 ) x
  real ( kind = 8 ) xerr
  real ( kind = 8 ) z
!
!  If we found an exact zero, there is nothing more to do.
!
  if ( fx == 0.0D+00 ) then
    ferr = 0.0D+00
    xerr = 0.0D+00
    root_rc = x
    return
  end if

  ferr = abs ( fx )
!
!  If this is the first time, initialize, estimate the first root, and exit.
!
  if ( q(1) == 0.0D+00 ) then
    q(1) = fx
    q(2) = x
    q(3:9) = 0.0D+00
    root_rc = x + fx
    xerr = r8_huge ( )
    return
  end if
!
!  This is not the first call.
!
  q(9) = q(9) + 1.0D+00
!
!  Check for too many iterations.
!
  if ( 80.0D+00 < q(9) ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'ROOT_RC - Fatal error!'
    write ( *, '(a,i6)' ) '  Number of iterations = ', int ( q(9) )
    stop
  end if
!
!  Check for a repeated X value.
!
  if ( ( 2.0 <= q(9) .and. x == q(4) ) .or. x == q(2) ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'ROOT_RC - Fatal error!'
    write ( *, '(a,i6)' ) '  Value of X has been input before.'
    stop
  end if
!
!  Push X -> A -> B -> C
!
  do i = 6, 3, -1
    q(i) = q(i-2)
  end do
  q(1) = fx
  q(2) = x
!
!  If we have a change-in-sign interval, store the opposite value.
!
  if ( r8_sign ( q(1) ) /= r8_sign ( q(3) ) ) then
    q(7) = q(3)
    q(8) = q(4)
  end if
!
!  Calculate XERR.
!
  if ( q(7) /= 0.0D+00 ) then
    xerr = abs ( q(8) - q(2) )
  else
    xerr = r8_huge ( )
  end if
!
!  If more than 30 iterations, and we have change-in-sign interval, bisect.
!
  if ( 30.0D+00 < q(9) .and. q(7) /= 0.0D+00 ) then
    root_rc = q(2) + ( q(8) - q(2) ) / 2.0D+00
    return
  end if

  v = ( q(3) - q(1) ) / ( q(4) - q(2) )
!
!  If 3 or more points, try Muller.
!
  if ( q(5) /= 0.0D+00 ) then
    u = ( q(5) - q(3) ) / ( q(6) - q(4) )
    w = q(4) - q(2)
    z = ( q(6) - q(2) ) / w
    r = ( z + 1.0D+00 ) * v - u

    if ( r /= 0.0D+00 ) then
      p = 2.0D+00 * z * q(1) / r
      d = 2.0D+00 * p / ( w * r ) * ( v - u )
      if ( -1.0D+00 <= d ) then
        root_rc = q(2) - p / ( 1.0D+00 + sqrt ( 1.0D+00 + d ) )
        if ( q(7) == 0.0D+00 .or. &
             ( q(2) < root_rc .and. root_rc < q(8) ) .or. &
             ( q(8) < root_rc .and. root_rc < q(2) ) ) then
          return
        end if
      end if
    end if
  end if
!
!  Try the secant step.
!
  if ( q(1) /= q(3) .or. q(7) == 0.0D+00 ) then
    if ( q(1) == q(3) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'ROOT_RC - Fatal error!'
      write ( *, '(a)' ) '  Cannot apply any method.'
      stop
    end if
    decr = q(1) / v
    if ( abs ( decr ) * 4.6D+18 < abs ( q(2) ) ) then
      decr = 1.74D-18 * abs ( q(2) ) * r8_sign ( decr )
    end if
    root_rc = q(2) - decr
    if ( q(7) == 0.0D+00 .or. &
        ( q(2) < root_rc .and. root_rc < q(8) ) .or. &
        ( q(8) < root_rc .and. root_rc < q(2) ) ) then
      return
    end if
  end if
!
!  Apply bisection.
!
  root_rc = q(2) + ( q(8) - q(2) ) / 2.0D+00

  return
end
subroutine roots_rc ( n, x, fx, ferr, xnew, q )

!*****************************************************************************80
!
!! ROOTS_RC solves a system of nonlinear equations using reverse communication.
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
!    Original FORTRAN77 version by Gaston Gonnet.
!    FORTRAN90 version by John Burkardt.
!
!  Reference:
!     
!    Gaston Gonnet,
!    On the Structure of Zero Finders,
!    BIT Numerical Mathematics,
!    Volume 17, Number 2, June 1977, pages 170-183.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of equations.
!
!    Input, real ( kind = 8 ) X(N).  Before the first call, the user should
!    set X to an initial guess or estimate for the root.  Thereafter, the input
!    value of X should be the output value of XNEW from the previous call.
!
!    Input, real ( kind = 8 ) FX(N), the value of the function at XNEW.
!
!    Output, real ( kind = 8 ) FERR, the function error, that is, the sum of
!    the absolute values of the most recently computed function vector.
!
!    Output, real ( kind = 8 ) XNEW(N), a new point at which a function 
!    value is requested.
!
!    Workspace, real ( kind = 8 ) Q(2*N+2,N+2).  Before the first call 
!    for a given problem, the user must set Q(2*N+1,1) to 0.0.
!
  implicit none

  integer ( kind = 4 ) n

  real ( kind = 8 ) damp
  real ( kind = 8 ) ferr
  real ( kind = 8 ) fx(n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) info
  integer ( kind = 4 ) j
  integer ( kind = 4 ) jsma
  integer ( kind = 4 ) jsus
  real ( kind = 8 ) q(2*n+2,n+2)
  real ( kind = 8 ) r8_huge
  real ( kind = 8 ) sump
  real ( kind = 8 ) t
  real ( kind = 8 ) x(n)
  real ( kind = 8 ) xnew(n)

  ferr = sum ( abs ( fx(1:n) ) )
!
!  Initialization if Q(2*N+1,1) = 0.0.
!
  if ( q(2*n+1,1) == 0.0D+00 ) then

    do i = 1, n
      do j = 1, n + 1
        q(i,j) = 0.0D+00
        q(i+1,j) = 0.0D+00
      end do
      q(i,i) = 100.0D+00
      q(i+n,i) = 1.0D+00
    end do
 
    q(2*n+1,1:n) = r8_huge ( )
    q(2*n+2,1:n) = dble ( n )

    do i = 1, n
      q(i+n,n+1) = x(i)
    end do

    q(1:n,n+1) = fx(1:n)

    q(2*n+1,n+1) = ferr
    q(2*n+2,n+1) = 0.0D+00
    damp = 0.99D+00

  else

    jsus = 1
    do i = 2, n + 1
      if ( real ( 2 * n, kind = 8 ) <= q(2*n+2,i) ) then
        q(2*n+1,i) = r8_huge ( )
      end if
      if ( q(2*n+2,jsus) < ( n + 3 ) / 2 ) then
        jsus = i
      end if
      if ( ( n + 3 ) / 2 <= q(2*n+2,i) .and. &
        q(2*n+1,jsus) < q(2*n+1,i) ) then
        jsus = i
      end if
    end do

    do i = 1, n
      q(i+n,jsus) = x(i)
      q(i,jsus) = fx(i)
    end do

    q(2*n+1,jsus) = ferr
    q(2*n+2,jsus) = 0
    jsma = 1
    damp = 0.0D+00

    do j = 1, n + 1
      if ( r8_huge ( ) / 10.0D+00 < q(2*n+1,j) ) then
        damp = 0.99D+00
      end if
      if ( q(2*n+1,j) < q(2*n+1,jsma) ) then
        jsma = j
      end if
    end do

    if ( jsma /= n + 1 ) then
      do i = 1, 2 * n + 2
        t = q(i,jsma)
        q(i,jsma) = q(i,n+1)
        q(i,n+1) = t
      end do
    end if

  end if

  q(1:n,n+2) = q(1:n,n+1)
!
!  Call the linear equation solver, which should not destroy the matrix 
!  in Q(1:N,1:N), and should overwrite the solution into Q(1:N,N+2).
!
  call r8mat_fs ( n, q(1:n,1:n), q(1:n,n+2), info )

  if ( info /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'ROOTS_RC - Fatal error!'
    write ( *, '(a,i6)' ) '  Linear equation solver returns INFO = ', info
    stop
  end if

  sump = sum ( q(1:n,n+2) )

  if ( abs ( 1.0D+00 - sump ) <= 1.0D-10 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'ROOTS_RC - Fatal error!'
    write ( *, '(a)' ) '  SUMP almost exactly 1.'
    write ( *, '(a,g14.6)' ) '  SUMP = ', sump
    stop
  end if

  do i = 1, n
    xnew(i) = q(i+n,n+1)
    do j = 1, n
      xnew(i) = xnew(i) - q(i+n,j) * q(j,n+2)
    end do
!
!  If system not complete, damp the solution.
!
    xnew(i) = xnew(i) / ( 1.0D+00 - sump ) * ( 1.0D+00 - damp ) &
      + q(i+n,n+1) * damp

  end do

  do j = 1, n + 1
    q(2*n+2,j) = q(2*n+2,j) + 1.0D+00
  end do

  return
end
subroutine r8mat_fs ( n, a, b, info )

!*****************************************************************************80
!
!! R8MAT_FS factors and solves a system with one right hand side.
!
!  Discussion:
!
!    An R8MAT is an MxN array of R8's, stored by (I,J) -> [I+J*M].
!
!    This routine differs from R8MAT_FSS in two ways:
!    * only one right hand side is allowed;
!    * the input matrix A is not modified.
!
!    This routine uses partial pivoting, but no pivot vector is required.
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
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the order of the matrix.
!    N must be positive.
!
!    Input/output, real ( kind = 8 ) A(N,N).
!    On input, A is the coefficient matrix of the linear system.
!    On output, A is in unit upper triangular form, and
!    represents the U factor of an LU factorization of the
!    original coefficient matrix.
!
!    Input/output, real ( kind = 8 ) B(N).
!    On input, the right hand side of the linear system.
!    On output, the solution of the linear systems.
!
!    Output, integer ( kind = 4 ) INFO, singularity flag.
!    0, no singularity detected.
!    nonzero, the factorization failed on the INFO-th step.
!
  implicit none

  integer ( kind = 4 ) n

  real ( kind = 8 ) a(n,n)
  real ( kind = 8 ) a2(n,n)
  real ( kind = 8 ) b(n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) info
  integer ( kind = 4 ) ipiv
  integer ( kind = 4 ) j
  integer ( kind = 4 ) jcol
  real ( kind = 8 ) piv
  real ( kind = 8 ) row(n)
  real ( kind = 8 ) t
  real ( kind = 8 ) temp

  a2(1:n,1:n) = a(1:n,1:n)

  info = 0

  do jcol = 1, n
!
!  Find the maximum element in column I.
!
    piv = abs ( a2(jcol,jcol) )
    ipiv = jcol
    do i = jcol + 1, n
      if ( piv < abs ( a2(i,jcol) ) ) then
        piv = abs ( a2(i,jcol) )
        ipiv = i
      end if
    end do

    if ( piv == 0.0D+00 ) then
      info = jcol
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'R8MAT_FS - Fatal error!'
      write ( *, '(a,i8)' ) '  Zero pivot on step ', info
      stop
    end if
!
!  Switch rows JCOL and IPIV, and B.
!
    if ( jcol /= ipiv ) then

      row(1:n) = a2(jcol,1:n)
      a2(jcol,1:n) = a2(ipiv,1:n)
      a2(ipiv,1:n) = row(1:n)

      t       = b(jcol)
      b(jcol) = b(ipiv)
      b(ipiv) = t

    end if
!
!  Scale the pivot row.
!
    a2(jcol,jcol+1:n) = a2(jcol,jcol+1:n) / a2(jcol,jcol)
    b(jcol) = b(jcol) / a2(jcol,jcol)
    a2(jcol,jcol) = 1.0D+00
!
!  Use the pivot row to eliminate lower entries in that column.
!
    do i = jcol + 1, n
      if ( a2(i,jcol) /= 0.0D+00 ) then
        temp = - a2(i,jcol)
        a2(i,jcol) = 0.0D+00
        a2(i,jcol+1:n) = a2(i,jcol+1:n) + temp * a2(jcol,jcol+1:n)
        b(i) = b(i) + temp * b(jcol)
      end if
    end do

  end do
!
!  Back solve.
!
  do jcol = n, 2, -1
    b(1:jcol-1) = b(1:jcol-1) - a2(1:jcol-1,jcol) * b(jcol)
  end do

  return
end
function r8_epsilon ( )

!*****************************************************************************80
!
!! R8_EPSILON returns the R8 roundoff unit.
!
!  Discussion:
!
!    The roundoff unit is a number R which is a power of 2 with the
!    property that, to the precision of the computer's arithmetic,
!      1 < 1 + R
!    but
!      1 = ( 1 + R / 2 )
!
!    FORTRAN90 provides the superior library routine
!
!      EPSILON ( X )
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    01 September 2012
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Output, real ( kind = 8 ) R8_EPSILON, the round-off unit.
!
  implicit none

  real ( kind = 8 ) r8_epsilon

  r8_epsilon = 2.220446049250313D-016

  return
end
function r8_huge ( )

!*****************************************************************************80
!
!! R8_HUGE returns a very large R8.
!
!  Discussion:
!
!    The value returned by this function is NOT required to be the
!    maximum representable R8.  This value varies from machine to machine,
!    from compiler to compiler, and may cause problems when being printed.
!    We simply want a "very large" but non-infinite number.
!
!    FORTRAN90 provides a built-in routine HUGE ( X ) that
!    can return the maximum representable number of the same datatype
!    as X, if that is what is really desired.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    12 October 2007
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Output, real ( kind = 8 ) R8_HUGE, a "huge" value.
!
  implicit none

  real ( kind = 8 ) r8_huge

  r8_huge = 1.0D+30

  return
end
function r8_sign ( x )

!*****************************************************************************80
!
!! R8_SIGN returns the sign of an R8.
!
!  Discussion:
!
!    value = -1 if X < 0;
!    value = +1 if X => 0.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    27 March 2004
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) X, the number whose sign is desired.
!
!    Output, real ( kind = 8 ) R8_SIGN, the sign of X:
!
  implicit none

  real ( kind = 8 ) r8_sign
  real ( kind = 8 ) x

  if ( x < 0.0D+00 ) then
    r8_sign = -1.0D+00
  else
    r8_sign = +1.0D+00
  end if

  return
end
subroutine timestamp ( )

!*****************************************************************************80
!
!! TIMESTAMP prints the current YMDHMS date as a time stamp.
!
!  Example:
!
!    31 May 2001   9:45:54.872 AM
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 May 2013
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    None
!
  implicit none

  character ( len = 8 ) ampm
  integer ( kind = 4 ) d
  integer ( kind = 4 ) h
  integer ( kind = 4 ) m
  integer ( kind = 4 ) mm
  character ( len = 9 ), parameter, dimension(12) :: month = (/ &
    'January  ', 'February ', 'March    ', 'April    ', &
    'May      ', 'June     ', 'July     ', 'August   ', &
    'September', 'October  ', 'November ', 'December ' /)
  integer ( kind = 4 ) n
  integer ( kind = 4 ) s
  integer ( kind = 4 ) values(8)
  integer ( kind = 4 ) y

  call date_and_time ( values = values )

  y = values(1)
  m = values(2)
  d = values(3)
  h = values(5)
  n = values(6)
  s = values(7)
  mm = values(8)

  if ( h < 12 ) then
    ampm = 'AM'
  else if ( h == 12 ) then
    if ( n == 0 .and. s == 0 ) then
      ampm = 'Noon'
    else
      ampm = 'PM'
    end if
  else
    h = h - 12
    if ( h < 12 ) then
      ampm = 'PM'
    else if ( h == 12 ) then
      if ( n == 0 .and. s == 0 ) then
        ampm = 'Midnight'
      else
        ampm = 'AM'
      end if
    end if
  end if

  write ( *, '(i2,1x,a,1x,i4,2x,i2,a1,i2.2,a1,i2.2,a1,i3.3,1x,a)' ) &
    d, trim ( month(m) ), y, h, ':', n, ':', s, '.', mm, trim ( ampm )

  return
end
