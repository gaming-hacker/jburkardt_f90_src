program main

!*****************************************************************************80
!
!  Purpose:
!
!    MAIN is the main program for UMFPACK_WEST.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    19 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Reference:
!
!    Timothy Davis,
!    UMFPACK User Guide,
!    Version 5.6.2, 25 April 2013
!    http://suitesparse.com
!
  implicit none
 
  real ( kind = 8 ), allocatable :: acc(:)
  real ( kind = 8 ), allocatable :: b(:)
  integer ( kind = 4 ), allocatable :: ccc(:)
  real ( kind = 8 ) control(20)
  integer ( kind = 4 ) filenum
  integer ( kind = 4 ) i
  integer ( kind = 4 ), allocatable :: icc(:)
  real ( kind = 8 ) info(90)
  integer ( kind = 4 ) m
  integer ( kind = 4 ) n
  integer ( kind = 4 ) ncc
  integer ( kind = 8 ) numeric
  character ( len = 255 ) :: prefix = 'west'
  real ( kind = 8 ) r
  real ( kind = 8 ) r8vec_diff_norm
  integer ( kind = 4 ) seed
  integer ( kind = 4 ) status
  integer ( kind = 8 ) symbolic
  integer ( kind = 4 ) sys
  real ( kind = 8 ), allocatable :: x1(:)
  real ( kind = 8 ), allocatable :: x2(:)

  call timestamp ( )
  write ( *, '(a)' ) ''
  write ( *, '(a)' ) 'UMFPACK_WEST:'
  write ( *, '(a)' ) '  FORTRAN90 version'
  write ( *, '(a)' ) '  Use UMFPACK for the sparse linear system A*x=b.'
!
!  Set the default control parameters.
!
  call umf4def ( control )
!
!  Get the matrix size.
!
  call cc_header_read ( prefix, ncc, n )

  write ( *, '(a)' ) ''
  write ( *, '(a,i6)' ) '  Number of rows and columns = ', n
  write ( *, '(a,i6)' ) '  Number of nonzeros = ', ncc
!
!  Allocate space.
!
  allocate ( acc(1:ncc) )
  allocate ( ccc(1:n+1) )
  allocate ( icc(1:ncc) )
!
!  Read the matrix data.
!
  call cc_data_read ( prefix, ncc, n, icc, ccc, acc )
!
!  Print the matrix.
!  Temporarily increment the indices.
!
  call i4vec_inc ( ncc, icc )
  call i4vec_inc ( n + 1, ccc )

  m = n
  call cc_print ( m, n, ncc, icc, ccc, acc, '  The CC matrix:' )
!
!  Set up the solution.
!
  seed = 123456789
  allocate ( x1(1:n) )
  call r8vec_uniform_01 ( n, seed, x1 )
!
!  Set the right hand side.
!
  m = n
  allocate ( b(1:n) )
  call cc_mv ( m, n, ncc, icc, ccc, acc, x1, b )
!
!  Restore indices to 0-base.
!
  call i4vec_dec ( ncc, icc )
  call i4vec_dec ( n + 1, ccc )
!
!  From the matrix data, create the symbolic factorization information.
!
  call umf4sym ( n, n, ccc, icc, acc, symbolic, control, info )

  if ( info(1) < 0.0D+00 ) then
    write ( *, '(a)' ) ''
    write ( *, '(a)' ) 'UMFPACK_WEST - Fatal error!'
    write ( *, '(a,g14.6)' ) '  UMF4SYM returns INFO(1) = ', info(1)
    stop 1
  end if
!
!  From the symbolic factorization information, carry out the numeric factorization.
!
  call umf4num ( ccc, icc, acc, symbolic, numeric, control, info )

  if ( info(1) < 0.0D+00 ) then
    write ( *, '(a)' ) ''
    write ( *, '(a)' ) 'UMFPACK_WEST - Fatal error!'
    write ( *, '(a,g14.6)' ) '  UMF4NUM returns INFO(1) = ', info(1)
    stop 1
  end if
!
!  Free the memory associated with the symbolic factorization.
!
  call umf4fsym ( symbolic )
!
!  Solve the linear system.
!
  sys = 0
  allocate ( x2(1:n) )
  call umf4sol ( sys, x2, b, numeric, control, info )

  if ( info(1) < 0.0D+00 ) then
    write ( *, '(a)' ) ''
    write ( *, '(a)' ) 'UMFPACK_WEST - Fatal error!'
    write ( *, '(a,g14.6)' ) '  UMF4SOL returns INFO(1) = ', info(1)
    stop 1
  end if
!
!  Free the memory associated with the numeric factorization.
!
  call umf4fnum ( numeric )
!
!  Print the error.
!
  r = r8vec_diff_norm ( n, x1, x2 )
  write ( *, '(a)' ) ''
  write ( *, '(a,g14.6)' ) '  L2 error ||X1 - X2|| = ', r
!
!  Free memory.
!
  deallocate ( acc )
  deallocate ( b )
  deallocate ( ccc )
  deallocate ( icc )
  deallocate ( x1 )
  deallocate ( x2 )
!
!  Terminate.
!
  write ( *, '(a)' ) ''
  write ( *, '(a)' ) 'UMFPACK_WEST:'
  write ( *, '(a)' ) '  Normal end of execution.'
  write ( *, '(a)' ) ''
  call timestamp ( )

  stop
end
subroutine cc_data_read ( prefix, ncc, n, icc, ccc, acc )

!*****************************************************************************80
!
!! CC_DATA_READ reads data about a sparse matrix in CC format.
!
!  Discussion:
!
!    Three files are presumed to exist:
!    * prefix_icc.txt contains NCC ICC values;
!    * prefix_ccc.txt contains N+1 CCC values;
!    * prefix_acc.txt contains NCC ACC values.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) PREFIX, a common prefix for the filenames.
!
!    Input, integer ( kind = 4 ) NCC, the number of CC elements.
!
!    Input, integer ( kind = 4 ) N, the number of columns in the matrix.
!
!    Output, integer ( kind = 4 ) ICC(NCC), the CC rows.
!
!    Output, integer ( kind = 4 ) CCC(N+1), the compressed CC columns.
!
!    Output, real ( kind = 8 ) ACC(NCC), the CC values.
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ) ncc

  real ( kind = 8 ) acc(ncc)
  integer ( kind = 4 ) ccc(n+1)
  character ( len = 255 ) filename_acc
  character ( len = 255 ) filename_ccc
  character ( len = 255 ) filename_icc
  integer ( kind = 4 ) icc(ncc)
  character ( len = * ) prefix

  filename_icc = trim ( prefix ) // "_icc.txt"
  call i4vec_data_read ( filename_icc, ncc, icc )

  filename_ccc = trim ( prefix ) // "_ccc.txt"
  call i4vec_data_read ( filename_ccc, n + 1, ccc )

  filename_acc = trim ( prefix ) // "_acc.txt"
  call r8vec_data_read ( filename_acc, ncc, acc )

  return
end
subroutine cc_header_read ( prefix, ncc, n )

!*****************************************************************************80
!
!! CC_HEADER_READ reads header information about a sparse matrix in CC format.
!
!  Discussion:
!
!    Three files are presumed to exist:
!    * prefix_icc.txt contains NCC ICC values;
!    * prefix_ccc.txt contains N+1 CCC values;
!    * prefix_acc.txt contains NCC ACC values.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) PREFIX, a common prefix for the filenames.
!
!    Output, integer ( kind = 4 ) NCC, the number of CC elements.
!
!    Output, integer ( kind = 4 ) N, the number of columns in the matrix.
!
  implicit none

  character ( len = 255 ) filename_ccc
  character ( len = 255 ) filename_icc
  integer ( kind = 4 ) n
  integer ( kind = 4 ) ncc
  character ( len = * ) prefix

  filename_icc = trim ( prefix ) // "_icc.txt"
  call file_row_count ( filename_icc, ncc )

  filename_ccc = trim ( prefix ) // "_ccc.txt"
  call file_row_count ( filename_ccc, n )
  n = n - 1

  return
end
subroutine cc_mv ( m, n, ncc, icc, ccc, acc, x, b )

!*****************************************************************************80
!
!! CC_MV multiplies a CC matrix by a vector
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    13 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Reference:
!
!    Iain Duff, Roger Grimes, John Lewis,
!    User's Guide for the Harwell-Boeing Sparse Matrix Collection,
!    October 1992
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, the number of rows.
!
!    Input, integer ( kind = 4 ) N, the number of columns.
!
!    Input, integer ( kind = 4 ) NCC, the number of CC values.
!
!    Input, integer ( kind = 4 ) RCC(NCC), the CC rows.
!
!    Input, integer ( kind = 4 ) CCC(N+1), the compressed CC columns
!
!    Input, real ( kind = 8 ) ACC(NCC), the CC values.
!
!    Input, real ( kind = 8 ) X(N), the vector to be multiplied.
!
!    Output, real ( kind = 8 ) B(M), the product A*X.
!
  implicit none

  integer ( kind = 4 ) m
  integer ( kind = 4 ) n
  integer ( kind = 4 ) ncc

  real ( kind = 8 ) acc(ncc)
  real ( kind = 8 ) b(m)
  integer ( kind = 4 ) ccc(n+1)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) icc(ncc)
  integer ( kind = 4 ) j
  integer ( kind = 4 ) k
  real ( kind = 8 ) x(n)

  b(1:m) = 0.0D+00

  do j = 1, n
    do k = ccc(j), ccc(j+1) - 1
      i = icc(k)
      b(i) = b(i) + acc(k) * x(j)
    end do
  end do

  return
end
subroutine cc_print ( m, n, ncc, icc, ccc, acc, title )

!*****************************************************************************80
!
!! CC_PRINT prints a sparse matrix in CC format.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    12 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, the number of rows in the matrix.
!
!    Input, integer ( kind = 4 ) N, the number of columns in the matrix.
!
!    Input, integer ( kind = 4 ) NCC, the number of CC elements.
!
!    Input, integer ( kind = 4 ) ICC(NCC), the CC rows.
!
!    Input, integer ( kind = 4 ) CCC(N+1), the compressed CC columns.
!
!    Input, real ( kind = 8 ) ACC(NCC), the CC values.
!
!    Input, character ( len = * ) TITLE, a title.
!
  implicit none

  integer ( kind = 4 ) ncc

  real ( kind = 8 ) acc(ncc)
  integer ( kind = 4 ) ccc(ncc)
  integer ( kind = 4 ) icc(ncc)
  integer ( kind = 4 ) m
  integer ( kind = 4 ) n
  character ( len = * ) title

  call cc_print_some ( 1, m, 1, n, ncc, n, icc, ccc, acc, title )

  return
end
subroutine cc_print_some ( i_min, i_max, j_min, j_max, ncc, n, icc, ccc, acc, &
  title )

!*****************************************************************************80
!
!! CC_PRINT_SOME prints some of a sparse matrix in CC format.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    12 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) I_MIN, IMAX, the first and last rows to print.
!
!    Input, integer ( kind = 4 ) J_MIN, J_MAX, the first and last columns 
!    to print.
!
!    Input, integer ( kind = 4 ) NCC, the number of CC elements.
!
!    Input, integer ( kind = 4 ) N, the number of columns.
!
!    Input, integer ( kind = 4 ) ICC(NCC), the CC rows.
!
!    Input, integer ( kind = 4 ) CCC(N+1), the compressed CC columns.
!
!    Input, real ( kind = 8 ) ACC(NCC), the CC values.
!
!    Input, character ( len = * ) TITLE, a title.
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ) ncc

  real ( kind = 8 ) acc(ncc)
  integer ( kind = 4 ) ccc(n+1)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i_max
  integer ( kind = 4 ) i_min
  integer ( kind = 4 ) icc(ncc)
  integer ( kind = 4 ) j
  integer ( kind = 4 ) j_max
  integer ( kind = 4 ) j_min
  integer ( kind = 4 ) jnext
  integer ( kind = 4 ) k
  character ( len = * ) title

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) trim ( title )
  write ( *, '(a)' ) '     #     I     J       A'
  write ( *, '(a)' ) '  ----  ----  ----  --------------'
  write ( *, '(a)' ) ' '

  j = 1
  jnext = ccc(2)

  do k = 1, ncc

    i = icc(k)
    do while ( jnext <= k )
      j = j + 1
      jnext = ccc(j+1)
    end do
 
    if ( i_min <= i .and. i <= i_max .and. &
         j_min <= j .and. j <= j_max ) then
      write ( *, '(2x,i4,2x,i4,2x,i4,2x,g16.8)' ) k, i, j, acc(k)
    end if
  end do

  return
end
subroutine ch_cap ( c )

!*****************************************************************************80
!
!! CH_CAP capitalizes a single character.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    19 July 1998
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input/output, character C, the character to capitalize.
!
  implicit none

  character c
  integer ( kind = 4 ) itemp

  itemp = ichar ( c )

  if ( 97 <= itemp .and. itemp <= 122 ) then
    c = char ( itemp - 32 )
  end if

  return
end
function ch_eqi ( c1, c2 )

!*****************************************************************************80
!
!! CH_EQI is a case insensitive comparison of two characters for equality.
!
!  Example:
!
!    CH_EQI ( 'A', 'a' ) is .TRUE.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    28 July 2000
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character C1, C2, the characters to compare.
!
!    Output, logical ( kind = 4 ) CH_EQI, the result of the comparison.
!
  implicit none

  logical ( kind = 4 ) ch_eqi
  character c1
  character c1_cap
  character c2
  character c2_cap

  c1_cap = c1
  c2_cap = c2

  call ch_cap ( c1_cap )
  call ch_cap ( c2_cap )

  if ( c1_cap == c2_cap ) then
    ch_eqi = .true.
  else
    ch_eqi = .false.
  end if

  return
end
subroutine ch_to_digit ( c, digit )

!*****************************************************************************80
!
!! CH_TO_DIGIT returns the integer value of a base 10 digit.
!
!  Example:
!
!     C   DIGIT
!    ---  -----
!    '0'    0
!    '1'    1
!    ...  ...
!    '9'    9
!    ' '    0
!    'X'   -1
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    04 August 1999
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character C, the decimal digit, '0' through '9' or blank
!    are legal.
!
!    Output, integer ( kind = 4 ) DIGIT, the corresponding integer value.
!    If C was 'illegal', then DIGIT is -1.
!
  implicit none

  character c
  integer ( kind = 4 ) digit

  if ( lge ( c, '0' ) .and. lle ( c, '9' ) ) then

    digit = ichar ( c ) - 48

  else if ( c == ' ' ) then

    digit = 0

  else

    digit = -1

  end if

  return
end
subroutine file_row_count ( input_filename, row_num )

!*****************************************************************************80
!
!! FILE_ROW_COUNT counts the number of row records in a file.
!
!  Discussion:
!
!    It does not count lines that are blank, or that begin with a
!    comment symbol '#'.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    06 March 2003
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) INPUT_FILENAME, the name of the input file.
!
!    Output, integer ( kind = 4 ) ROW_NUM, the number of rows found.
!
  implicit none

  integer ( kind = 4 ) bad_num
  integer ( kind = 4 ) comment_num
  integer ( kind = 4 ) ierror
  character ( len = * ) input_filename
  integer ( kind = 4 ) input_status
  integer ( kind = 4 ) input_unit
  character ( len = 255 ) line
  integer ( kind = 4 ) record_num
  integer ( kind = 4 ) row_num

  call get_unit ( input_unit )

  open ( unit = input_unit, file = input_filename, status = 'old', &
    iostat = input_status )

  if ( input_status /= 0 ) then
    row_num = -1;
    ierror = 1
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'FILE_ROW_COUNT - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open the input file "' // &
      trim ( input_filename ) // '" on unit ', input_unit
    stop 1
  end if

  comment_num = 0
  row_num = 0
  record_num = 0
  bad_num = 0

  do

    read ( input_unit, '(a)', iostat = input_status ) line

    if ( input_status /= 0 ) then
      ierror = record_num
      exit
    end if

    record_num = record_num + 1

    if ( line(1:1) == '#' ) then
      comment_num = comment_num + 1
      cycle
    end if

    if ( len_trim ( line ) == 0 ) then
      comment_num = comment_num + 1
      cycle
    end if

    row_num = row_num + 1

  end do

  close ( unit = input_unit )

  return
end
subroutine get_unit ( iunit )

!*****************************************************************************80
!
!! GET_UNIT returns a free FORTRAN unit number.
!
!  Discussion:
!
!    A "free" FORTRAN unit number is a value between 1 and 99 which
!    is not currently associated with an I/O device.  A free FORTRAN unit
!    number is needed in order to open a file with the OPEN command.
!
!    If IUNIT = 0, then no free FORTRAN unit could be found, although
!    all 99 units were checked (except for units 5, 6 and 9, which
!    are commonly reserved for console I/O).
!
!    Otherwise, IUNIT is a value between 1 and 99, representing a
!    free FORTRAN unit.  Note that GET_UNIT assumes that units 5 and 6
!    are special, and will never return those values.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    26 October 2008
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Output, integer ( kind = 4 ) IUNIT, the free unit number.
!
  implicit none

  integer ( kind = 4 ) i
  integer ( kind = 4 ) ios
  integer ( kind = 4 ) iunit
  logical ( kind = 4 ) lopen

  iunit = 0

  do i = 1, 99

    if ( i /= 5 .and. i /= 6 .and. i /= 9 ) then

      inquire ( unit = i, opened = lopen, iostat = ios )

      if ( ios == 0 ) then
        if ( .not. lopen ) then
          iunit = i
          return
        end if
      end if

    end if

  end do

  return
end
subroutine i4vec_data_read ( input_filename, n, table )

!*****************************************************************************80
!
!! I4VEC_DATA_READ reads data from an I4VEC file.
!
!  Discussion:
!
!    An I4VEC is a vector of I4 values.
!
!  Discussion:
!
!    The file may contain more than N points, but this routine will
!    return after reading N of them.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) INPUT_FILENAME, the name of the input file.
!
!    Input, integer ( kind = 4 ) N, the number of points.
!
!    Output, integer ( kind = 4 ) TABLE(N), the data.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) ierror
  character ( len = * ) input_filename
  integer ( kind = 4 ) input_status
  integer ( kind = 4 ) input_unit
  integer ( kind = 4 ) j
  integer ( kind = 4 ) length
  character ( len = 255 ) line
  integer ( kind = 4 ) table(n)
  integer ( kind = 4 ) x

  ierror = 0

  call get_unit ( input_unit )

  open ( unit = input_unit, file = input_filename, status = 'old', &
    iostat = input_status )

  if ( input_status /= 0 ) then
    ierror = 1
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'I4VEC_DATA_READ - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open the input file "' // &
      trim ( input_filename ) // '" on unit ', input_unit
    stop 1
  end if

  j = 0

  do while ( j < n )

    read ( input_unit, '(a)', iostat = input_status ) line

    if ( input_status /= 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'I4VEC_DATA_READ - Fatal error!'
      write ( *, '(a)' ) '  Error while reading lines of data.'
      write ( *, '(a,i8)' ) '  Number of data lines read, J =         ', j
      write ( *, '(a,i8)' ) '  Number of data lines needed, N =       ', n
      stop 1
    end if

    if ( line(1:1) == '#' .or. len_trim ( line ) == 0 ) then
      cycle
    end if

    call s_to_i4 ( line, x, ierror, length )

    if ( ierror /= 0 ) then
      cycle
    end if

    j = j + 1

    table(j) = x

  end do

  close ( unit = input_unit )

  return
end
subroutine i4vec_dec ( n, a )

!*****************************************************************************80
!
!! I4VEC_DEC decrements an I4VEC.
!
!  Discussion:
!
!    An I4VEC is a vector of I4's.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of entries in the vector.
!
!    Input/output, integer ( kind = 4 ) A(N), the vector to be decremented.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) a(n)

  a(1:n) = a(1:n) - 1

  return
end
subroutine i4vec_inc ( n, a )

!*****************************************************************************80
!
!! I4VEC_INC increments an I4VEC.
!
!  Discussion:
!
!    An I4VEC is a vector of I4's.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 July 2014
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of entries in the vector.
!
!    Input/output, integer ( kind = 4 ) A(N), the vector to be incremented.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) a(n)

  a(1:n) = a(1:n) + 1

  return
end
subroutine r8vec_data_read ( input_filename, n, table )

!*****************************************************************************80
!
!! R8VEC_DATA_READ reads data from an R8VEC file.
!
!  Discussion:
!
!    An R8VEC is a vector of R8 values.
!
!  Discussion:
!
!    The file may contain more than N points, but this routine will
!    return after reading N of them.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    10 June 2012
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) INPUT_FILENAME, the name of the input file.
!
!    Input, integer ( kind = 4 ) N, the number of points.
!
!    Output, real ( kind = 8 ) TABLE(N), the data.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) ierror
  character ( len = * ) input_filename
  integer ( kind = 4 ) input_status
  integer ( kind = 4 ) input_unit
  integer ( kind = 4 ) j
  integer ( kind = 4 ) length
  character ( len = 255 ) line
  real ( kind = 8 ) table(n)
  real ( kind = 8 ) x

  ierror = 0

  call get_unit ( input_unit )

  open ( unit = input_unit, file = input_filename, status = 'old', &
    iostat = input_status )

  if ( input_status /= 0 ) then
    ierror = 1
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'R8VEC_DATA_READ - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open the input file "' // &
      trim ( input_filename ) // '" on unit ', input_unit
    stop 1
  end if

  j = 0

  do while ( j < n )

    read ( input_unit, '(a)', iostat = input_status ) line

    if ( input_status /= 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'R8VEC_DATA_READ - Fatal error!'
      write ( *, '(a)' ) '  Error while reading lines of data.'
      write ( *, '(a,i8)' ) '  Number of data lines read, J =         ', j
      write ( *, '(a,i8)' ) '  Number of data lines needed, N =       ', n
      stop 1
    end if

    if ( line(1:1) == '#' .or. len_trim ( line ) == 0 ) then
      cycle
    end if

    call s_to_r8 ( line, x, ierror, length )

    if ( ierror /= 0 ) then
      cycle
    end if

    j = j + 1

    table(j) = x

  end do

  close ( unit = input_unit )

  return
end
function r8vec_diff_norm ( n, a, b )

!*****************************************************************************80
!
!! R8VEC_DIFF_NORM returns the L2 norm of the difference of R8VEC's.
!
!  Discussion:
!
!    An R8VEC is a vector of R8's.
!
!    The vector L2 norm is defined as:
!
!      R8VEC_NORM_L2 = sqrt ( sum ( 1 <= I <= N ) A(I)^2 ).
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    02 April 2010
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of entries in A.
!
!    Input, real ( kind = 8 ) A(N), B(N), the vectors
!
!    Output, real ( kind = 8 ) R8VEC_DIFF_NORM, the L2 norm of A - B.
!
  implicit none

  integer ( kind = 4 ) n

  real ( kind = 8 ) a(n)
  real ( kind = 8 ) b(n)
  real ( kind = 8 ) r8vec_diff_norm

  r8vec_diff_norm = sqrt ( sum ( ( a(1:n) - b(1:n) )**2 ) )

  return
end
subroutine r8vec_print ( n, a, title )

!*****************************************************************************80
!
!! R8VEC_PRINT prints an R8VEC.
!
!  Discussion:
!
!    An R8VEC is a vector of R8's.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    22 August 2000
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of components of the vector.
!
!    Input, real ( kind = 8 ) A(N), the vector to be printed.
!
!    Input, character ( len = * ) TITLE, a title.
!
  implicit none

  integer ( kind = 4 ) n

  real ( kind = 8 ) a(n)
  integer ( kind = 4 ) i
  character ( len = * ) title

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) trim ( title )
  write ( *, '(a)' ) ' '

  do i = 1, n
    write ( *, '(2x,i8,a,1x,g16.8)' ) i, ':', a(i)
  end do

  return
end
subroutine r8vec_uniform_01 ( n, seed, r )

!*****************************************************************************80
!
!! R8VEC_UNIFORM_01 returns a unit pseudorandom R8VEC.
!
!  Discussion:
!
!    An R8VEC is a vector of R8's.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    05 July 2006
!
!  Author:
!
!    John Burkardt
!
!  Reference:
!
!    Paul Bratley, Bennett Fox, Linus Schrage,
!    A Guide to Simulation,
!    Springer Verlag, pages 201-202, 1983.
!
!    Bennett Fox,
!    Algorithm 647:
!    Implementation and Relative Efficiency of Quasirandom
!    Sequence Generators,
!    ACM Transactions on Mathematical Software,
!    Volume 12, Number 4, pages 362-376, 1986.
!
!    Peter Lewis, Allen Goodman, James Miller
!    A Pseudo-Random Number Generator for the System/360,
!    IBM Systems Journal,
!    Volume 8, pages 136-143, 1969.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of entries in the vector.
!
!    Input/output, integer ( kind = 4 ) SEED, the "seed" value, which
!    should NOT be 0.  On output, SEED has been updated.
!
!    Output, real ( kind = 8 ) R(N), the vector of pseudorandom values.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  integer ( kind = 4 ) k
  integer ( kind = 4 ) seed
  real ( kind = 8 ) r(n)

  if ( seed == 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'R8VEC_UNIFORM_01 - Fatal error!'
    write ( *, '(a)' ) '  Input value of SEED = 0.'
    stop 1
  end if

  do i = 1, n

    k = seed / 127773

    seed = 16807 * ( seed - k * 127773 ) - k * 2836

    if ( seed < 0 ) then
      seed = seed + 2147483647
    end if

    r(i) = real ( seed, kind = 8 ) * 4.656612875D-10

  end do

  return
end
subroutine s_to_i4 ( s, ival, ierror, length )

!*****************************************************************************80
!
!! S_TO_I4 reads an I4 from a string.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    28 June 2000
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) S, a string to be examined.
!
!    Output, integer ( kind = 4 ) IVAL, the integer value read from the string.
!    If the string is blank, then IVAL will be returned 0.
!
!    Output, integer ( kind = 4 ) IERROR, an error flag.
!    0, no error.
!    1, an error occurred.
!
!    Output, integer ( kind = 4 ) LENGTH, the number of characters of S
!    used to make IVAL.
!
  implicit none

  character c
  integer ( kind = 4 ) i
  integer ( kind = 4 ) ierror
  integer ( kind = 4 ) isgn
  integer ( kind = 4 ) istate
  integer ( kind = 4 ) ival
  integer ( kind = 4 ) length
  character ( len = * ) s

  ierror = 0
  istate = 0
  isgn = 1
  ival = 0

  do i = 1, len_trim ( s )

    c = s(i:i)
!
!  Haven't read anything.
!
    if ( istate == 0 ) then

      if ( c == ' ' ) then

      else if ( c == '-' ) then
        istate = 1
        isgn = -1
      else if ( c == '+' ) then
        istate = 1
        isgn = + 1
      else if ( lle ( '0', c ) .and. lle ( c, '9' ) ) then
        istate = 2
        ival = ichar ( c ) - ichar ( '0' )
      else
        ierror = 1
        return
      end if
!
!  Have read the sign, expecting digits.
!
    else if ( istate == 1 ) then

      if ( c == ' ' ) then

      else if ( lle ( '0', c ) .and. lle ( c, '9' ) ) then
        istate = 2
        ival = ichar ( c ) - ichar ( '0' )
      else
        ierror = 1
        return
      end if
!
!  Have read at least one digit, expecting more.
!
    else if ( istate == 2 ) then

      if ( lle ( '0', c ) .and. lle ( c, '9' ) ) then
        ival = 10 * ival + ichar ( c ) - ichar ( '0' )
      else
        ival = isgn * ival
        length = i - 1
        return
      end if

    end if

  end do
!
!  If we read all the characters in the string, see if we're OK.
!
  if ( istate == 2 ) then
    ival = isgn * ival
    length = len_trim ( s )
  else
    ierror = 1
    length = 0
  end if

  return
end
subroutine s_to_r8 ( s, dval, ierror, length )

!*****************************************************************************80
!
!! S_TO_R8 reads an R8 from a string.
!
!  Discussion:
!
!    The routine will read as many characters as possible until it reaches
!    the end of the string, or encounters a character which cannot be
!    part of the number.
!
!    Legal input is:
!
!       1 blanks,
!       2 '+' or '-' sign,
!       2.5 blanks
!       3 integer part,
!       4 decimal point,
!       5 fraction part,
!       6 'E' or 'e' or 'D' or 'd', exponent marker,
!       7 exponent sign,
!       8 exponent integer part,
!       9 exponent decimal point,
!      10 exponent fraction part,
!      11 blanks,
!      12 final comma or semicolon,
!
!    with most quantities optional.
!
!  Example:
!
!    S                 DVAL
!
!    '1'               1.0
!    '     1   '       1.0
!    '1A'              1.0
!    '12,34,56'        12.0
!    '  34 7'          34.0
!    '-1E2ABCD'        -100.0
!    '-1X2ABCD'        -1.0
!    ' 2E-1'           0.2
!    '23.45'           23.45
!    '-4.2E+2'         -420.0
!    '17d2'            1700.0
!    '-14e-2'         -0.14
!    'e2'              100.0
!    '-12.73e-9.23'   -12.73 * 10.0^(-9.23)
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    07 September 2004
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) S, the string containing the
!    data to be read.  Reading will begin at position 1 and
!    terminate at the end of the string, or when no more
!    characters can be read to form a legal real.  Blanks,
!    commas, or other nonnumeric data will, in particular,
!    cause the conversion to halt.
!
!    Output, real ( kind = 8 ) DVAL, the value read from the string.
!
!    Output, integer ( kind = 4 ) IERROR, error flag.
!    0, no errors occurred.
!    1, 2, 6 or 7, the input number was garbled.  The
!    value of IERROR is the last type of input successfully
!    read.  For instance, 1 means initial blanks, 2 means
!    a plus or minus sign, and so on.
!
!    Output, integer ( kind = 4 ) LENGTH, the number of characters read
!    to form the number, including any terminating
!    characters such as a trailing comma or blanks.
!
  implicit none

  character c
  logical ( kind = 4 ) ch_eqi
  real ( kind = 8 ) dval
  integer ( kind = 4 ) ierror
  integer ( kind = 4 ) ihave
  integer ( kind = 4 ) isgn
  integer ( kind = 4 ) iterm
  integer ( kind = 4 ) jbot
  integer ( kind = 4 ) jsgn
  integer ( kind = 4 ) jtop
  integer ( kind = 4 ) length
  integer ( kind = 4 ) nchar
  integer ( kind = 4 ) ndig
  real ( kind = 8 ) rbot
  real ( kind = 8 ) rexp
  real ( kind = 8 ) rtop
  character ( len = * ) s

  nchar = len_trim ( s )

  ierror = 0
  dval = 0.0D+00
  length = -1
  isgn = 1
  rtop = 0
  rbot = 1
  jsgn = 1
  jtop = 0
  jbot = 1
  ihave = 1
  iterm = 0

  do

    length = length + 1

    if ( nchar < length+1 ) then
      exit
    end if

    c = s(length+1:length+1)
!
!  Blank character.
!
    if ( c == ' ' ) then

      if ( ihave == 2 ) then

      else if ( ihave == 6 .or. ihave == 7 ) then
        iterm = 1
      else if ( 1 < ihave ) then
        ihave = 11
      end if
!
!  Comma.
!
    else if ( c == ',' .or. c == ';' ) then

      if ( ihave /= 1 ) then
        iterm = 1
        ihave = 12
        length = length + 1
      end if
!
!  Minus sign.
!
    else if ( c == '-' ) then

      if ( ihave == 1 ) then
        ihave = 2
        isgn = -1
      else if ( ihave == 6 ) then
        ihave = 7
        jsgn = -1
      else
        iterm = 1
      end if
!
!  Plus sign.
!
    else if ( c == '+' ) then

      if ( ihave == 1 ) then
        ihave = 2
      else if ( ihave == 6 ) then
        ihave = 7
      else
        iterm = 1
      end if
!
!  Decimal point.
!
    else if ( c == '.' ) then

      if ( ihave < 4 ) then
        ihave = 4
      else if ( 6 <= ihave .and. ihave <= 8 ) then
        ihave = 9
      else
        iterm = 1
      end if
!
!  Scientific notation exponent marker.
!
    else if ( ch_eqi ( c, 'E' ) .or. ch_eqi ( c, 'D' ) ) then

      if ( ihave < 6 ) then
        ihave = 6
      else
        iterm = 1
      end if
!
!  Digit.
!
    else if (  ihave < 11 .and. lle ( '0', c ) .and. lle ( c, '9' ) ) then

      if ( ihave <= 2 ) then
        ihave = 3
      else if ( ihave == 4 ) then
        ihave = 5
      else if ( ihave == 6 .or. ihave == 7 ) then
        ihave = 8
      else if ( ihave == 9 ) then
        ihave = 10
      end if

      call ch_to_digit ( c, ndig )

      if ( ihave == 3 ) then
        rtop = 10.0D+00 * rtop + real ( ndig, kind = 8 )
      else if ( ihave == 5 ) then
        rtop = 10.0D+00 * rtop + real ( ndig, kind = 8 )
        rbot = 10.0D+00 * rbot
      else if ( ihave == 8 ) then
        jtop = 10 * jtop + ndig
      else if ( ihave == 10 ) then
        jtop = 10 * jtop + ndig
        jbot = 10 * jbot
      end if
!
!  Anything else is regarded as a terminator.
!
    else
      iterm = 1
    end if
!
!  If we haven't seen a terminator, and we haven't examined the
!  entire string, go get the next character.
!
    if ( iterm == 1 ) then
      exit
    end if

  end do
!
!  If we haven't seen a terminator, and we have examined the
!  entire string, then we're done, and LENGTH is equal to NCHAR.
!
  if ( iterm /= 1 .and. length + 1 == nchar ) then
    length = nchar
  end if
!
!  Number seems to have terminated.  Have we got a legal number?
!  Not if we terminated in states 1, 2, 6 or 7!
!
  if ( ihave == 1 .or. ihave == 2 .or. ihave == 6 .or. ihave == 7 ) then
    ierror = ihave
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'S_TO_R8 - Serious error!'
    write ( *, '(a)' ) '  Illegal or nonnumeric input:'
    write ( *, '(a)' ) '    ' // trim ( s )
    return
  end if
!
!  Number seems OK.  Form it.
!
  if ( jtop == 0 ) then
    rexp = 1.0D+00
  else
    if ( jbot == 1 ) then
      rexp = 10.0D+00 ** ( jsgn * jtop )
    else
      rexp = 10.0D+00 ** ( real ( jsgn * jtop, kind = 8 ) &
        / real ( jbot, kind = 8 ) )
    end if
  end if

  dval = real ( isgn, kind = 8 ) * rexp * rtop / rbot

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
