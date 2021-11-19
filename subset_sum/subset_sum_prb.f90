program main

!*****************************************************************************80
!
!! MAIN is the main program for SUBSET_SUM_PRB.
!
!  Discussion:
!
!    SUBSET_SUM_PRB tests the SUBSET_SUM library.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    10 November 2015
!
!  Author:
!
!    John Burkardt
!
  implicit none

  call timestamp ( )
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'SUBSET_SUM_PRB:'
  write ( *, '(a)' ) '  FORTRAN90 version'
  write ( *, '(a)' ) '  Test the SUBSET_SUM library.'

  call subset_sum_count_tests ( )
  call subset_sum_find_tests ( )
  call subset_sum_table_tests ( )
!
!  Terminate.
!
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'SUBSET_SUM_PRB'
  write ( *, '(a)' ) '  Normal end of execution.'
  write ( *, '(a)' ) ' '
  call timestamp ( )

  return
end
subroutine subset_sum_count_tests ( )

!*****************************************************************************80
!
!! SUBSET_SUM_COUNT_TESTS tests SUBSET_SUM_COUNT_TEST.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    10 November 2015
!
!  Author:
!
!    John Burkardt
!
  implicit none

  integer ( kind = 4 ) ind
  integer ( kind = 4 ) ind_max
  integer ( kind = 4 ) ind_min
  integer ( kind = 4 ) n
  integer ( kind = 4 ) t
  integer ( kind = 4 ) test
  integer ( kind = 4 ), parameter :: test_num = 9
  integer ( kind = 4 ), allocatable :: w(:)

  call timestamp ( )
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'SUBSET_SUM_COUNT_TESTS:'
  write ( *, '(a)' ) '  SUBSET_SUM_COUNT_TEST calls SUBSET_SUM_COUNT with'
  write ( *, '(a)' ) '  a particular set of problem data.'
!
!  Simply count solutions.
!
  do test = 1, test_num

    if ( test == 1 ) then
      n = 8
      allocate ( w(1:n) )
      w = (/ 15, 22, 14, 26, 32, 9, 16, 8 /)
      t = 53
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 2 ) then
      n = 8
      allocate ( w(1:n) )
      w = (/ 15, 22, 14, 26, 32, 9, 16, 8 /)
      t = 53
      ind_min = 68
      ind_max = 2 ** n - 1
    else if ( test == 3 ) then
      n = 8
      allocate ( w(1:n) )
      w = (/ 15, 22, 14, 26, 32, 9, 16, 8 /)
      t = 53
      ind_min = 167
      ind_max = 2 ** n - 1
    else if ( test == 4 ) then
      n = 10
      allocate ( w(1:n) )
      w = (/ 267,  493,  869,  961, 1000, 1153, 1246, 1598, 1766, 1922 /)
      t = 5842
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 5 ) then
      n = 21
      allocate ( w(1:n) )
      w = (/  518533, 1037066, 2074132, 1648264, 796528, &
             1593056,  686112, 1372224,  244448, 488896, &
              977792, 1955584, 1411168,  322336, 644672, &
             1289344,   78688,  157376,  314752, 629504, &
             1259008 /)
      t = 2463098
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 6 ) then
      n = 10
      allocate ( w(1:n) )
      w = (/ 41, 34, 21, 20,  8,  7,  7,  4,  3,  3 /)
      t = 50
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 7 ) then
      n = 9
      allocate ( w(1:n) )
      w = (/ 81, 80, 43, 40, 30, 26, 12, 11, 9 /)
      t = 100
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 8 ) then
      n = 6
      allocate ( w(1:n) )
      w = (/ 1, 2, 4, 8, 16, 32 /)
      t = 22
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 9 ) then
      n = 10
      allocate ( w(1:n) )
      w = (/ 25, 27, 3, 12, 6, 15, 9, 30, 21, 19 /)
      t = 50
      ind_min = 0
      ind_max = 2 ** n - 1
    end if

    call subset_sum_count_test ( n, w, t, ind_min, ind_max )

    deallocate ( w )

  end do

  return
end
subroutine subset_sum_count_test ( n, w, t, ind_min, ind_max )

!*****************************************************************************80
!
!! SUBSET_SUM_COUNT_TEST tests SUBSET_SUM_COUNT.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    10 November 2015
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of weights.
!
!    Input, integer ( kind = 4 ) W(N), a set of weights.  The length of this
!    array must be no more than 31.
!
!    Input, integer ( kind = 4 ) T, the target value.
!
!    Input, integer ( kind = 4 ) IND_MIN, IND_MAX, the lower and upper
!    limits to be searched.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  integer ( kind = 4 ) ind_max
  integer ( kind = 4 ) ind_min
  integer ( kind = 4 ) solution_num
  integer ( kind = 4 ) t
  integer ( kind = 4 ) w(n)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'SUBSET_SUM_COUNT_TEST:'
  write ( *, '(a)' ) '  SUBSET_SUM_COUNT_TEST counts solutions to the subset sum problem.'
  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  Target value T = ', t
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '   I       W(I)'
  write ( *, '(a)' ) ' '
  do i = 1, n
    write ( *, '(2x,i2,2x,i8)' ) i, w(i)
  end do

  call subset_sum_count ( n, w, t, ind_min, ind_max, solution_num )

  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  Number of solutions = ', solution_num

  return
end
subroutine subset_sum_find_tests ( )

!*****************************************************************************80
!
!! SUBSET_SUM_FIND_TESTS tests SUBSET_SUM_FIND_TEST.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 May 2012
!
!  Author:
!
!    John Burkardt
!
  implicit none

  integer ( kind = 4 ) ind
  integer ( kind = 4 ) ind_max
  integer ( kind = 4 ) ind_min
  integer ( kind = 4 ) n
  integer ( kind = 4 ) t
  integer ( kind = 4 ) test
  integer ( kind = 4 ), parameter :: test_num = 9
  integer ( kind = 4 ), allocatable :: w(:)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'SUBSET_SUM_FIND_TESTS:'
  write ( *, '(a)' ) '  SUBSET_SUM_FIND_TEST calls SUBSET_SUM_FIND with'
  write ( *, '(a)' ) '  a particular set of problem data.'
!
!  Find individual solutions.
!
  do test = 1, test_num

    if ( test == 1 ) then
      n = 8
      allocate ( w(1:n) )
      w = (/ 15, 22, 14, 26, 32, 9, 16, 8 /)
      t = 53
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 2 ) then
      n = 8
      allocate ( w(1:n) )
      w = (/ 15, 22, 14, 26, 32, 9, 16, 8 /)
      t = 53
      ind_min = ind + 1
      ind_max = 2 ** n - 1
    else if ( test == 3 ) then
      n = 8
      allocate ( w(1:n) )
      w = (/ 15, 22, 14, 26, 32, 9, 16, 8 /)
      t = 53
      ind_min = ind + 1
      ind_max = 2 ** n - 1
    else if ( test == 4 ) then
      n = 10
      allocate ( w(1:n) )
      w = (/ 267,  493,  869,  961, 1000, 1153, 1246, 1598, 1766, 1922 /)
      t = 5842
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 5 ) then
      n = 21
      allocate ( w(1:n) )
      w = (/  518533, 1037066, 2074132, 1648264, 796528, &
             1593056,  686112, 1372224,  244448, 488896, &
              977792, 1955584, 1411168,  322336, 644672, &
             1289344,   78688,  157376,  314752, 629504, &
             1259008 /)
      t = 2463098
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 6 ) then
      n = 10
      allocate ( w(1:n) )
      w = (/ 41, 34, 21, 20,  8,  7,  7,  4,  3,  3 /)
      t = 50
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 7 ) then
      n = 9
      allocate ( w(1:n) )
      w = (/ 81, 80, 43, 40, 30, 26, 12, 11, 9 /)
      t = 100
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 8 ) then
      n = 6
      allocate ( w(1:n) )
      w = (/ 1, 2, 4, 8, 16, 32 /)
      t = 22
      ind_min = 0
      ind_max = 2 ** n - 1
    else if ( test == 9 ) then
      n = 10
      allocate ( w(1:n) )
      w = (/ 25, 27, 3, 12, 6, 15, 9, 30, 21, 19 /)
      t = 50
      ind_min = 0
      ind_max = 2 ** n - 1
    end if

    call subset_sum_find_test ( n, w, t, ind_min, ind_max, ind )

    deallocate ( w )

  end do

  return
end
subroutine subset_sum_find_test ( n, w, t, ind_min, ind_max, ind )

!*****************************************************************************80
!
!! SUBSET_SUM_FIND_TEST tests SUBSET_SUM_FIND.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    10 November 2015
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of weights.
!
!    Input, integer ( kind = 4 ) W(N), a set of weights.  The length of this
!    array must be no more than 31.
!
!    Input, integer ( kind = 4 ) T, the target value.
!
!    Input, integer ( kind = 4 ) IND_MIN, IND_MAX, the lower and upper
!    limits to be searched.
!
!    Output, integer ( kind = 4 ) IND, the index of a solution, if found,
!    or the value -1 otherwise.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) c(n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) ind
  integer ( kind = 4 ) ind_max
  integer ( kind = 4 ) ind_min
  integer ( kind = 4 ) t
  integer ( kind = 4 ) w(n)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'SUBSET_SUM_FIND_TEST:'
  write ( *, '(a)' ) '  SUBSET_SUM_FIND seeks a subset of W that sums to T.'
  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  Target value T = ', t
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '   I       W(I)'
  write ( *, '(a)' ) ' '
  do i = 1, n
    write ( *, '(2x,i2,2x,i8)' ) i, w(i)
  end do

  call subset_sum_find ( n, w, t, ind_min, ind_max, ind, c )

  if ( ind == -1 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) '  No solution was found.'
    return
  end if

  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' )  '  Solution index = ', ind
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '   I       W(I)  C(I)'
  write ( *, '(a)' ) ' '
  do i = 1, n
    write ( *, '(2x,i2,2x,i8,5x,i1)' ) i, w(i), c(i)
  end do

  return
end
subroutine subset_sum_table_tests ( )

!*****************************************************************************80
!
!! SUBSET_SUM_TABLE_TESTS tests SUBSET_SUM_TABLE_TEST.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    10 November 2015
!
!  Author:
!
!    John Burkardt
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ) t
  integer ( kind = 4 ) test
  integer ( kind = 4 ), parameter :: test_num = 7
  integer ( kind = 4 ), allocatable :: w(:)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'SUBSET_SUM_TABLE_TESTS:'
  write ( *, '(a)' ) '  SUBSET_SUM_TABLE_TEST calls SUBSET_SUM_TABLE with'
  write ( *, '(a)' ) '  a particular set of problem data.'
!
!  Find individual solutions.
!
  do test = 1, test_num

    if ( test == 1 ) then
      t = 53
      n = 8
      allocate ( w(1:n) )
      w = (/ 15, 22, 14, 26, 32, 9, 16, 8 /)
    else if ( test == 2 ) then
      t = 5842
      n = 10
      allocate ( w(1:n) )
      w = (/ 267,  493,  869,  961, 1000, 1153, 1246, 1598, 1766, 1922 /)
    else if ( test == 3 ) then
      t = 2463098
      n = 21
      allocate ( w(1:n) )
      w = (/  518533, 1037066, 2074132, 1648264, 796528, &
             1593056,  686112, 1372224,  244448, 488896, &
              977792, 1955584, 1411168,  322336, 644672, &
             1289344,   78688,  157376,  314752, 629504, &
             1259008 /)
    else if ( test == 4 ) then
      t = 50
      n = 10
      allocate ( w(1:n) )
      w = (/ 41, 34, 21, 20,  8,  7,  7,  4,  3,  3 /)
    else if ( test == 5 ) then
      t = 100
      n = 9
      allocate ( w(1:n) )
      w = (/ 81, 80, 43, 40, 30, 26, 12, 11, 9 /)
    else if ( test == 6 ) then
      t = 22
      n = 6
      allocate ( w(1:n) )
      w = (/ 1, 2, 4, 8, 16, 32 /)
    else if ( test == 7 ) then
      t = 50
      n = 10
      allocate ( w(1:n) )
      w = (/ 25, 27, 3, 12, 6, 15, 9, 30, 21, 19 /)
    end if

    call subset_sum_table_test ( t, n, w )

    deallocate ( w )

  end do

  return
end
subroutine subset_sum_table_test ( t, n, w )

!*****************************************************************************80
!
!! SUBSET_SUM_TABLE_TEST tests SUBSET_SUM_TABLE.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    10 November 2015
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) T, the target value.
!
!    Input, integer ( kind = 4 ) N, the number of weights.
!
!    Input, integer ( kind = 4 ) W(N), a set of weights.
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ) t

  integer ( kind = 4 ) c(n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) list(t)
  integer ( kind = 4 ) m
  integer ( kind = 4 ) table(t)
  integer ( kind = 4 ) w(n)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'SUBSET_SUM_TABLE_TEST:'
  write ( *, '(a)' ) '  SUBSET_SUM_TABLE seeks a subset of W that sums to T.'
  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  Target value T = ', t
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '   I       W(I)'
  write ( *, '(a)' ) ' '
  do i = 1, n
    write ( *, '(2x,i2,2x,i8)' ) i, w(i)
  end do

  call subset_sum_table ( t, n, w, table )

  write ( *, '(a)' ) ''

  if ( table(t) == 0 ) then
    write ( *, '(a)' ) '  No solution was found.'
  else
    call subset_sum_table_to_list ( t, table, m, list )
    write ( *, '(i8)', advance = 'no' ) t
    write ( *, '(a)', advance = 'no' ) ' = '
    do i = 1, m
      if ( 1 < i ) then
        write ( *, '(a)', advance = 'no' ) ' + '
      end if
      write ( *, '(i8)', advance = 'no' ) list(i)
    end do
    write ( *, '(a)' ) ''
  end if

  return
end


