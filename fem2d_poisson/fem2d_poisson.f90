program main

!*****************************************************************************80
!
!! MAIN is the main program of FEM2D_POISSON.
!
!  Discussion:
!
!    This program solves the Poisson equation
!
!      -DEL H(X,Y) DEL U(X,Y) + K(X,Y) * U(X,Y) = F(X,Y)
!
!    in a triangulated region in the plane.
!
!    Along the boundary of the region, Dirichlet conditions
!    are imposed:
!
!      U(X,Y) = G(X,Y)
!
!    The code uses continuous piecewise linear basis functions on
!    triangles.
!
!  Problem specification:
!
!    The user defines the geometry by supplying two data files
!    which list the node coordinates, and list the nodes that make up
!    each element.
!
!    The user specifies the right hand side of the Dirichlet boundary
!    conditions by supplying a function
!
!      subroutine dirichlet_condition ( node_num, node_xy, node_bc )
!
!    The user specifies the coefficient function H(X,Y) of the Poisson
!    equation by supplying a routine of the form
!
!      subroutine h_coef ( node_num, node_xy, node_h )
!
!    The user specifies the coefficient function K(X,Y) of the Poisson
!    equation by supplying a routine of the form
!
!      subroutine k_coef ( node_num, node_xy, node_k )
!
!    The user specifies the right hand side of the Poisson equation
!    by supplying a routine of the form
!
!      subroutine rhs ( node_num, node_xy, node_f )
!
!  Usage:
!
!    fem2d_poisson prefix
!
!    where
!
!    * prefix_nodes.txt is the file containing the coordinates of the nodes;
!
!    * prefix_elements.txt is the file containing the indices of nodes
!      that make up each element.
!
!    Files created include:
!
!    * prefix_nodes.eps, an image of the nodes;
!    * prefix_elements.eps, an image of the elements;
!    * prefix_solution.txt, the value of the solution at every node.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    06 December 2010
!
!  Author:
!
!    John Burkardt
!
!  Local parameters:
!
!    Local, real ( kind = 8 ) A(3*IB+1,NODE_NUM), the coefficient matrix.
!
!    Local, integer ( kind = 4 ) ELEMENT_NODE(3,ELEMENT_NUM);
!    ELEMENT_NODE(I,J) is the global index of local node I in element J.
!
!    Local, integer ( kind = 4 ) ELEMENT_NUM, the number of elements.
!
!    Local, integer ( kind = 4 ) ELEMENT_ORDER, the element order.
!
!    Local, real ( kind = 8 ) F(NODE_NUM), the right hand side.
!
!    Local, integer ( kind = 4 ) IB, the half-bandwidth of the matrix.
!
!    Local, logical NODE_BOUNDARY(NODE_NUM), is TRUE if the node is
!    found to lie on the boundary of the region.
!
!    Local, integer ( kind = 4 ) NODE_CONDITION(NODE_NUM),
!    indicates the condition used to determine the variable at a node.
!    0, there is no condition (and no variable) at this node.
!    1, a finite element equation is used;
!    2, a Dirichlet condition is used.
!    3, a Neumann condition is used.
!
!    Local, integer ( kind = 4 ) NODE_NUM, the number of nodes.
!
!    Local, real ( kind = 8 ) NODE_R(NODE_NUM), the residual error.
!
!    Local, real ( kind = 8 ) NODE_U(NODE_NUM), the finite element coefficients.
!
!    Local, real ( kind = 8 ) NODE_XY(2,NODE_NUM), the coordinates of nodes.
!
!    Local, integer ( kind = 4 ) QUAD_NUM, the number of quadrature points
!    used for assembly.  This is currently set to 3, the lowest reasonable
!    value.  Legal values are 1, 3, 4, 6, 7, 9, 13, and for some problems,
!    a value of QUAD_NUM greater than 3 may be appropriate.
!
  implicit none

  real ( kind = 8 ), allocatable, dimension (:,:) :: a
  logical, parameter :: debug = .false.
  integer ( kind = 4 ) dim_num
  character ( len = 255 ) element_eps_filename
  character ( len = 255 ) element_filename
  integer ( kind = 4 ), allocatable, dimension(:,:) :: element_node
  integer ( kind = 4 ) element_num
  integer ( kind = 4 ) element_order
  integer ( kind = 4 ) element_show
  real ( kind = 8 ), allocatable, dimension (:) :: f
  integer ( kind = 4 ) iarg
  integer ( kind = 4 ) iargc
  integer ( kind = 4 ) ib
  integer ( kind = 4 ) ierr
  integer ( kind = 4 ) ios
  integer ( kind = 4 ) job
  integer ( kind = 4 ) node
  logical, allocatable, dimension(:) :: node_boundary
  integer ( kind = 4 ), allocatable, dimension(:) :: node_condition
  character ( len = 255 ) node_eps_filename
  character ( len = 255 ) node_filename
  logical node_label
  integer ( kind = 4 ) node_num
  integer ( kind = 4 ) node_show
  real ( kind = 8 ), allocatable, dimension (:) :: node_r
  real ( kind = 8 ), allocatable, dimension (:) :: node_u
  real ( kind = 8 ), allocatable, dimension(:,:) :: node_xy
  integer ( kind = 4 ) num_arg
  integer ( kind = 4 ), allocatable, dimension (:) :: pivot
  character ( len = 255 ) prefix
  integer ( kind = 4 ), parameter :: quad_num = 7
  character ( len = 255 ) solution_filename

  call timestamp ( )

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'FEM2D_POISSON'
  write ( *, '(a)' ) '  FORTRAN90 version:'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '  Solution of the Poisson equation in an arbitrary region'
  write ( *, '(a)' ) '  in 2 dimensions.'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) &
    '  - DEL H(x,y) DEL U(x,y) + K(x,y) * U(x,y) = F(x,y) in the region'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '                    U(x,y) = G(x,y) on the boundary.'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '  The finite element method is used,'
  write ( *, '(a)' ) '  with triangular elements,'
  write ( *, '(a)' ) '  which must be a 3 node linear triangle.'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '  Current status:'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '  * Boundary conditions cannot be set easily.'
  write ( *, '(a)' ) ' '
!
!  Get the number of command line arguments.
!
  num_arg = iargc ( )

  if ( num_arg < 1 ) then

    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'Enter the filename prefix:'
    read ( *, '(a)', iostat = ios ) prefix

    if ( ios /= 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'FEM2D_POISSON - Fatal error!'
      write ( *, '(a)' ) '  Unexpected read error!'
      stop
    end if

  else

    iarg = 1

    call getarg ( iarg, prefix )

  end if
!
!  Create the filenames.
!
  node_filename = trim ( prefix ) // '_nodes.txt'
  element_filename = trim ( prefix ) // '_elements.txt'
  solution_filename = trim ( prefix ) // '_solution.txt'
  node_eps_filename = trim ( prefix ) // '_nodes.eps'
  element_eps_filename = trim ( prefix ) // '_elements.eps'

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '  Node file is "' // trim ( node_filename ) // '".'
  write ( *, '(a)' ) '  Element file is "' // trim ( element_filename ) &
    // '".'
!
!  Read the node coordinate file.
!
  call r8mat_header_read ( node_filename, dim_num, node_num )

  write ( *, '(a,i8)' ) '  Number of nodes =          ', node_num

  allocate ( node_boundary(node_num) )
  allocate ( node_condition(node_num) )
  allocate ( node_xy(dim_num,node_num) )

  call r8mat_data_read ( node_filename, dim_num, node_num, node_xy )

  call r8mat_transpose_print_some ( dim_num, node_num, node_xy, 1, 1, &
    2, 10, '  First 10 nodes' )
!
!  Read the element description file.
!
  call i4mat_header_read ( element_filename, element_order, element_num )

  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  Element order =            ', element_order
  write ( *, '(a,i8)' ) '  Number of elements =       ', element_num

  if ( element_order /= 3 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'FEM2D_POISSON - Fatal error!'
    write ( *, '(a,i8)' ) '  The input triangulation has order ', element_order
    write ( *, '(a)' ) '  However, a triangulation of order 3 is required.'
    stop
  end if

  allocate ( element_node(3,element_num) )

  call i4mat_data_read ( element_filename, element_order, element_num, &
    element_node )

  call i4mat_transpose_print_some ( 3, element_num, &
    element_node, 1, 1, 3, 10, '  First 10 elements' )

  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  Quadrature order =          ', quad_num
!
!  Determine which nodes are boundary nodes and which have a
!  finite element unknown.  Then set the boundary values.
!
  call triangulation_order3_boundary_node ( node_num, element_num, &
    element_node, node_boundary )

  if ( debug ) then
    call lvec_print ( node_num, node_boundary, '    Node  Boundary?' )
  end if
!
!  Determine the node conditions.
!  For now, we'll just assume all boundary nodes are Dirichlet.
!
  node_condition(1:node_num) = 1

  do node = 1, node_num
    if ( node_boundary(node) ) then
      node_condition(node) = 2
    end if
  end do
!
!  Determine the bandwidth of the coefficient matrix.
!
  call bandwidth ( element_num, element_node, ib )

  write ( *, '(a)'    ) ' '
  write ( *, '(a,i8)' ) '  The matrix half bandwidth is ', ib
  write ( *, '(a,i8)' ) '  The matrix bandwidth is      ', 2 * ib + 1
  write ( *, '(a,i8)' ) '  The storage bandwidth is     ', 3 * ib + 1
!
!  Make a picture of the nodes.
!
  if ( node_num <= 1000 ) then

    if ( node_num <= 100 ) then
      node_label = .true.
    else
      node_label = .false.
    end if

    call points_plot ( node_eps_filename, node_num, node_xy, node_label )

  end if
!
!  Make a picture of the elements.
!
  if ( node_num <= 1000 ) then

    if ( node_num <= 100 ) then
      node_show = 2
    else if ( node_num <= 250 ) then
      node_show = 1
    else
      node_show = 0
    end if

    if ( element_num <= 100 ) then
      element_show = 2
    else
      element_show = 1
    end if

    call triangulation_order3_plot ( element_eps_filename, node_num, &
      node_xy, element_num, element_node, node_show, element_show )

  end if
!
!  Allocate space for the coefficient matrix A and right hand side F.
!
  allocate ( a(3*ib+1,node_num) )
  allocate ( f(node_num) )
  allocate ( node_r(node_num) )
  allocate ( node_u(node_num) )
  allocate ( pivot(node_num) )
!
!  Assemble the finite element coefficient matrix A and the right-hand side F.
!
  call assemble_poisson ( node_num, node_xy, element_num, &
    element_node, quad_num, ib, a, f )

  if ( debug .or. .true. ) then

    call dgb_print_some ( node_num, node_num, ib, ib, a, 1, 1, 10, 10, &
      '  Part of Finite Element matrix A' )

    call r8vec_print_some ( node_num, f, 1, 10, &
      '  Part of right hand side vector F:' )

  end if
!
!  Adjust the linear system to account for Dirichlet boundary conditions.
!
  call dirichlet_apply ( node_num, node_xy, node_condition, ib, a, f )

  if ( debug .or. .true. ) then

    call dgb_print_some ( node_num, node_num, ib, ib, a, 1, 1, 10, 10, &
      '  Part of A after adjustment for Dirichlet condition:' )

    call r8vec_print_some ( node_num, f, 1, 10, &
      '  Part of F after adjustment for Dirichlet condition:' )

  end if
!
!  Solve the linear system using a banded solver.
!
  call dgb_fa ( node_num, ib, ib, a, pivot, ierr )

  if ( ierr /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'FEM2D_POISSON - Fatal error!'
    write ( *, '(a)' ) '  DGB_FA returned an error condition.'
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) '  The linear system was not factored, and the'
    write ( *, '(a)' ) '  algorithm cannot proceed.'
    stop
  end if

  job = 0
  node_u(1:node_num) = f(1:node_num)

  call dgb_sl ( node_num, ib, ib, a, pivot, node_u, job )

  call r8vec_print_some ( node_num, node_u, 1, 10, &
    '  Part of the solution vector U:' )

  call residual_poisson ( node_num, node_xy, node_condition, &
    element_num, element_node, quad_num, ib, a, f, node_u, node_r )

  write ( *, '(a)' ) ' '
  write ( *, '(a,g14.6)' ) '  Maximum absolute residual = ', &
    maxval ( abs ( node_r(1:node_num) ) )
!
!  Write an ASCII file that can be read into MATLAB.
!
  call r8mat_write ( solution_filename, 1, node_num, node_u )

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'FEM2D_POISSON:'
  write ( *, '(a)' ) '  Wrote an ASCII file'
  write ( *, '(a)' ) '    "' // trim ( solution_filename ) // '"'
  write ( *, '(a)' ) '  of the form'
  write ( *, '(a)' ) '    U ( X(I), Y(I) )'
  write ( *, '(a)' ) '  which can be used for plotting.'
!
!  Free memory.
!
  deallocate ( a )
  deallocate ( f )
  deallocate ( node_boundary )
  deallocate ( node_condition )
  deallocate ( node_r )
  deallocate ( node_u )
  deallocate ( node_xy )
  deallocate ( pivot )
  deallocate ( element_node )
!
!  Terminate.
!
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'FEM2D_POISSON:'
  write ( *, '(a)' ) '  Normal end of execution.'

  write ( *, '(a)' ) ' '
  call timestamp ( )

  stop
end
subroutine assemble_poisson ( node_num, node_xy, element_num, element_node, &
  quad_num, ib, a, f )

!*****************************************************************************80
!
!! ASSEMBLE_POISSON assembles the system for the Poisson equation.
!
!  Discussion:
!
!    The matrix is known to be banded.  A special matrix storage format
!    is used to reduce the space required.  Details of this format are
!    discussed in the routine DGB_FA.
!
!    Note that a 3 point quadrature rule, which is sometimes used to
!    assemble the matrix and right hand side, is just barely accurate
!    enough for simple problems.  If you want better results, you
!    should use a quadrature rule that is more accurate.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    22 July 2007
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) NODE_NUM, the number of nodes.
!
!    Input, real ( kind = 8 ) NODE_XY(2,NODE_NUM), the
!    coordinates of nodes.
!
!    Input, integer ( kind = 4 ) ELEMENT_NUM, the number of elements.
!
!    Input, integer ( kind = 4 ) ELEMENT_NODE(3,ELEMENT_NUM);
!    ELEMENT_NODE(I,J) is the global index of local node I in element J.
!
!    Input, integer ( kind = 4 ) QUAD_NUM, the number of quadrature points
!    used in assembly.
!
!    Input, integer ( kind = 4 ) IB, the half-bandwidth of the matrix.
!
!    Output, real ( kind = 8 ) A(3*IB+1,NODE_NUM), the NODE_NUM by NODE_NUM
!    coefficient matrix, stored in a compressed format.
!
!    Output, real ( kind = 8 ) F(NODE_NUM), the right hand side.
!
!  Local parameters:
!
!    Local, real ( kind = 8 ) BI, DBIDX, DBIDY, the value of some basis function
!    and its first derivatives at a quadrature point.
!
!    Local, real ( kind = 8 ) BJ, DBJDX, DBJDY, the value of another basis
!    function and its first derivatives at a quadrature point.
!
  implicit none

  integer ( kind = 4 ) ib
  integer ( kind = 4 ) node_num
  integer ( kind = 4 ) quad_num
  integer ( kind = 4 ) element_num

  real ( kind = 8 ), dimension(3*ib+1,node_num) :: a
  real ( kind = 8 ) area
  integer ( kind = 4 ) basis
  real ( kind = 8 ) bi
  real ( kind = 8 ) bj
  real ( kind = 8 ) dbidx
  real ( kind = 8 ) dbidy
  real ( kind = 8 ) dbjdx
  real ( kind = 8 ) dbjdy
  integer ( kind = 4 ) element
  integer ( kind = 4 ), dimension(3,element_num) :: element_node
  real ( kind = 8 ), dimension(node_num) :: f
  integer ( kind = 4 ) i
  integer ( kind = 4 ) j
  real ( kind = 8 ), dimension(2,node_num) :: node_xy
  real ( kind = 8 ), allocatable, dimension(:) :: phys_h
  real ( kind = 8 ), allocatable, dimension(:) :: phys_k
  real ( kind = 8 ), allocatable, dimension(:) :: phys_rhs
  real ( kind = 8 ) phys_xy(2,quad_num)
  integer ( kind = 4 ) quad
  real ( kind = 8 ), allocatable, dimension(:) :: quad_w
  real ( kind = 8 ), allocatable, dimension(:,:) :: quad_xy
  real ( kind = 8 ), dimension (2,3) :: t3
  integer ( kind = 4 ) test
  real ( kind = 8 ) triangle_area_2d
  real ( kind = 8 ) w(quad_num)
!
!  Initialize the arrays to zero.
!
  f(1:node_num) = 0.0D+00
  a(1:3*ib+1,1:node_num) = 0.0D+00

  allocate ( phys_h(1:quad_num) )
  allocate ( phys_k(1:quad_num) )
  allocate ( phys_rhs(1:quad_num) )

  allocate ( quad_w(1:quad_num) )
  allocate ( quad_xy(1:2,1:quad_num) )
!
!  Get the quadrature weights and nodes.
!
  call quad_rule ( quad_num, quad_w, quad_xy )
!
!  Add up all quantities associated with the ELEMENT-th element.
!
  do element = 1, element_num
!
!  Make a copy of the triangle.
!
    t3(1:2,1:3) = node_xy(1:2,element_node(1:3,element))
!
!  Map the quadrature points QUAD_XY to points XY in the physical triangle.
!
    call reference_to_physical_t3 ( t3, quad_num, quad_xy, phys_xy )

    area = abs ( triangle_area_2d ( t3 ) )

    w(1:quad_num) = area * quad_w(1:quad_num)

    call rhs ( quad_num, phys_xy, phys_rhs )
    call h_coef ( quad_num, phys_xy, phys_h )
    call k_coef ( quad_num, phys_xy, phys_k )
!
!  Consider the QUAD-th quadrature point.
!
    do quad = 1, quad_num
!
!  Consider the TEST-th test function.
!
!  We generate an integral for every node associated with an unknown.
!  But if a node is associated with a boundary condition, we do nothing.
!
      do test = 1, 3

        i = element_node(test,element)

        call basis_one_t3 ( t3, test, phys_xy(1:2,quad), bi, dbidx, dbidy )

        f(i) = f(i) + w(quad) * phys_rhs(quad) * bi
!
!  Consider the BASIS-th basis function, which is used to form the
!  value of the solution function.
!
        do basis = 1, 3

          j = element_node(basis,element)

          call basis_one_t3 ( t3, basis, phys_xy(1:2,quad), bj, dbjdx, dbjdy )

          a(i-j+2*ib+1,j) = a(i-j+2*ib+1,j) &
            + w(quad) * ( &
              phys_h(quad) * ( dbidx * dbjdx + dbidy * dbjdy ) &
            + phys_k(quad) * bj * bi )

        end do

      end do

    end do

  end do

  deallocate ( phys_h )
  deallocate ( phys_k )
  deallocate ( phys_rhs )

  deallocate ( quad_w )
  deallocate ( quad_xy )

  return
end
subroutine bandwidth ( element_num, element_node, nhba )

!*****************************************************************************80
!
!! BANDWIDTH determines the bandwidth of the coefficient matrix.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    26 March 2005
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) ELEMENT_NUM, the number of elements.
!
!    Input, integer ( kind = 4 ) ELEMENT_NODE(3,ELEMENT_NUM);
!    ELEMENT_NODE(I,J) is the global index of local node I in element J.
!
!    Output, integer ( kind = 4 ) NHBA, the half bandwidth of the matrix.
!
  implicit none

  integer ( kind = 4 ) element_num

  integer ( kind = 4 ) element
  integer ( kind = 4 ) element_node(3,element_num)
  integer ( kind = 4 ) global_i
  integer ( kind = 4 ) global_j
  integer ( kind = 4 ) local_i
  integer ( kind = 4 ) local_j
  integer ( kind = 4 ) nhba

  nhba = 0

  do element = 1, element_num
    do local_i = 1, 3
      global_i = element_node(local_i,element)
      do local_j = 1, 3
        global_j = element_node(local_j,element)
        nhba = max ( nhba, abs ( global_j - global_i ) )
      end do
    end do
  end do

  return
end
subroutine basis_one_t3 ( t, i, p, qi, dqidx, dqidy )

!*****************************************************************************80
!
!! BASIS_ONE_T3 evaluates a linear basis function.
!
!  Discussion:
!
!    The routine is given the coordinates of the nodes of a triangle.
!
!           3
!          / \
!         /   \
!        /     \
!       1-------2
!
!    It evaluates the linear basis function Q(I)(X,Y) associated with
!    node I, which has the property that it is a linear function
!    which is 1 at node I and zero at the other two nodes.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    07 January 2006
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real T(2,3), the coordinates of the nodes.
!
!    Input, integer ( kind = 4 ) I, the index of the desired basis function.
!    I should be between 1 and 3.
!
!    Input, real P(2), the coordinates of a point at which the basis
!    function is to be evaluated.
!
!    Output, real QI, DQIDX, DQIDY, the values of the basis function
!    and its X and Y derivatives.
!
  implicit none

  real ( kind = 8 ) area
  real ( kind = 8 ) dqidx
  real ( kind = 8 ) dqidy
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i4_wrap
  integer ( kind = 4 ) ip1
  integer ( kind = 4 ) ip2
  real ( kind = 8 ) p(2)
  real ( kind = 8 ) qi
  real ( kind = 8 ) t(2,3)

  area = t(1,1) * ( t(2,2) - t(2,3) ) &
       + t(1,2) * ( t(2,3) - t(2,1) ) &
       + t(1,3) * ( t(2,1) - t(2,2) )

  if ( area == 0.0D+00 ) then

    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'BASIS_ONE_T3 - Fatal error!'
    write ( *, '(a)' ) '  Element has zero area.'
    stop

  end if

  if ( i < 1 .or. 3 < i ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'BASIS_ONE_T3 - Fatal error!'
    write ( *, '(a)' ) '  Basis index I is not between 1 and 3.'
    write ( *, '(a,i8)' ) '  I = ', i
    stop
  end if

  ip1 = i4_wrap ( i + 1, 1, 3 )
  ip2 = i4_wrap ( i + 2, 1, 3 )

  qi = ( ( t(1,ip2) - t(1,ip1) ) * ( p(2) - t(2,ip1) ) &
       - ( t(2,ip2) - t(2,ip1) ) * ( p(1) - t(1,ip1) ) ) / area

  dqidx = - ( t(2,ip2) - t(2,ip1) ) / area
  dqidy =   ( t(1,ip2) - t(1,ip1) ) / area

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
!    Output, logical CH_EQI, the result of the comparison.
!
  implicit none

  logical ch_eqi
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
subroutine dgb_fa ( n, ml, mu, a, pivot, info )

!*****************************************************************************80
!
!! DGB_FA performs a LINPACK-style PLU factorization of an DGB matrix.
!
!  Discussion:
!
!    The DGB storage format is for an M by N banded matrix, with lower
!    bandwidth ML and upper bandwidth MU.  Storage includes room for ML
!    extra superdiagonals, which may be required to store nonzero entries
!    generated during Gaussian elimination.
!
!    The original M by N matrix is "collapsed" downward, so that diagonals
!    become rows of the storage array, while columns are preserved.  The
!    collapsed array is logically 2*ML+MU+1 by N.
!
!    The following program segment will set up the input.
!
!      m = ml + mu + 1
!      do j = 1, n
!        i1 = max ( 1, j-mu )
!        i2 = min ( n, j+ml )
!        do i = i1, i2
!          k = i - j + m
!          a(k,j) = afull(i,j)
!        end do
!      end do
!
!    This uses rows ML+1 through 2*ML+MU+1 of the array A.
!    In addition, the first ML rows in the array are used for
!    elements generated during the triangularization.
!
!    The ML+MU by ML+MU upper left triangle and the
!    ML by ML lower right triangle are not referenced.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    04 March 1999
!
!  Author:
!
!    FORTRAN77 original version by Dongarra, Bunch, Moler, and Stewart.
!    FORTRAN90 version by John Burkardt
!
!  Reference:
!
!    Dongarra, Bunch, Moler, Stewart,
!    LINPACK User's Guide,
!    SIAM, 1979
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the order of the matrix.
!    N must be positive.
!
!    Input, integer ( kind = 4 ) ML, MU, the lower and upper bandwidths.
!    ML and MU must be nonnegative, and no greater than N-1.
!
!    Input/output, real ( kind = 8 ) A(2*ML+MU+1,N), on input, the matrix
!    in band storage, on output, information about the LU factorization.
!
!    Output, integer ( kind = 4 ) PIVOT(N), the pivot vector.
!
!    Output, integer ( kind = 4 ) INFO, singularity flag.
!    0, no singularity detected.
!    nonzero, the factorization failed on the INFO-th step.
!
  implicit none

  integer ( kind = 4 ) ml
  integer ( kind = 4 ) mu
  integer ( kind = 4 ) n

  real ( kind = 8 ) a(2*ml+mu+1,n)
  integer ( kind = 4 ) i0
  integer ( kind = 4 ) info
  integer ( kind = 4 ) pivot(n)
  integer ( kind = 4 ) j
  integer ( kind = 4 ) j0
  integer ( kind = 4 ) j1
  integer ( kind = 4 ) ju
  integer ( kind = 4 ) jz
  integer ( kind = 4 ) k
  integer ( kind = 4 ) l
  integer ( kind = 4 ) lm
  integer ( kind = 4 ) m
  integer ( kind = 4 ) mm
  real ( kind = 8 ) t

  m = ml + mu + 1
  info = 0
!
!  Zero out the initial fill-in columns.
!
  j0 = mu + 2
  j1 = min ( n, m ) - 1

  do jz = j0, j1
    i0 = m + 1 - jz
    a(i0:ml,jz) = 0.0D+00
  end do

  jz = j1
  ju = 0

  do k = 1, n-1
!
!  Zero out the next fill-in column.
!
    jz = jz + 1
    if ( jz <= n ) then
      a(1:ml,jz) = 0.0D+00
    end if
!
!  Find L = pivot index.
!
    lm = min ( ml, n-k )

    l = m
    do j = m+1, m+lm
      if ( abs ( a(l,k) ) < abs ( a(j,k) ) ) then
        l = j
      end if
    end do

    pivot(k) = l + k - m
!
!  Zero pivot implies this column already triangularized.
!
    if ( a(l,k) == 0.0D+00 ) then
      info = k
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'DGB_FA - Fatal error!'
      write ( *, '(a,i8)' ) '  Zero pivot on step ', info
      return
    end if
!
!  Interchange if necessary.
!
    t = a(l,k)
    a(l,k) = a(m,k)
    a(m,k) = t
!
!  Compute multipliers.
!
    a(m+1:m+lm,k) = - a(m+1:m+lm,k) / a(m,k)
!
!  Row elimination with column indexing.
!
    ju = max ( ju, mu+pivot(k) )
    ju = min ( ju, n )
    mm = m

    do j = k+1, ju

      l = l - 1
      mm = mm - 1

      if ( l /= mm ) then
        t = a(l,j)
        a(l,j) = a(mm,j)
        a(mm,j) = t
      end if

      a(mm+1:mm+lm,j) = a(mm+1:mm+lm,j) + a(mm,j) * a(m+1:m+lm,k)

    end do

  end do

  pivot(n) = n
  if ( a(m,n) == 0.0D+00 ) then
    info = n
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'DGB_FA - Fatal error!'
    write ( *, '(a,i8)' ) '  Zero pivot on step ', info
  end if

  return
end
subroutine dgb_mxv ( m, n, ml, mu, a, x, b )

!*****************************************************************************80
!
!! DGB_MXV multiplies a DGB matrix times a vector.
!
!  Discussion:
!
!    The DGB storage format is for an M by N banded matrix, with lower
!    bandwidth ML and upper bandwidth MU.  Storage includes room for ML
!    extra superdiagonals, which may be required to store nonzero entries
!    generated during Gaussian elimination.
!
!    The original M by N matrix is "collapsed" downward, so that diagonals
!    become rows of the storage array, while columns are preserved.  The
!    collapsed array is logically 2*ML+MU+1 by N.
!
!    LINPACK and LAPACK storage of general band matrices requires
!    an extra ML upper diagonals for possible fill in entries during
!    Gauss elimination.  This routine does not access any entries
!    in the fill in diagonals, because it assumes that the matrix
!    has NOT had Gauss elimination applied to it.  If the matrix
!    has been Gauss eliminated, then the routine DGB_MU must be
!    used instead.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    19 January 1999
!
!  Author:
!
!    John Burkardt
!
!  Reference:
!
!    Dongarra, Bunch, Moler, Stewart,
!    LINPACK User's Guide,
!    SIAM, 1979.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, the number of rows of the matrix.
!    M must be positive.
!
!    Input, integer ( kind = 4 ) N, the number of columns of the matrix.
!    N must be positive.
!
!    Input, integer ( kind = 4 ) ML, MU, the lower and upper bandwidths.
!    ML and MU must be nonnegative, and no greater than min(M,N)-1.
!
!    Input, real ( kind = 8 ) A(2*ML+MU+1,N), the DGB matrix.
!
!    Input, real ( kind = 8 ) X(N), the vector to be multiplied by A.
!
!    Output, real ( kind = 8 ) B(M), the product A * x.
!
  implicit none

  integer ( kind = 4 ) ml
  integer ( kind = 4 ) mu
  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  real ( kind = 8 ) a(2*ml+mu+1,n)
  real ( kind = 8 ) b(m)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) j
  integer ( kind = 4 ) jhi
  integer ( kind = 4 ) jlo
  real ( kind = 8 ) x(n)

  do i = 1, m
    b(i) = 0.0D+00
    jlo = max ( 1, i - ml )
    jhi = min ( n, i + mu )
    do j = jlo, jhi
      b(i) = b(i) + a(i-j+ml+mu+1,j) * x(j)
    end do
  end do

  return
end
subroutine dgb_print_some ( m, n, ml, mu, a, ilo, jlo, ihi, jhi, title )

!*****************************************************************************80
!
!! DGB_PRINT_SOME prints some of a DGB matrix.
!
!  Discussion:
!
!    The DGB storage format is for an M by N banded matrix, with lower
!    bandwidth ML and upper bandwidth MU.  Storage includes room for ML
!    extra superdiagonals, which may be required to store nonzero entries
!    generated during Gaussian elimination.
!
!    The original M by N matrix is "collapsed" downward, so that diagonals
!    become rows of the storage array, while columns are preserved.  The
!    collapsed array is logically 2*ML+MU+1 by N.
!
!    DGB storage is used by LINPACK and LAPACK.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    04 April 2006
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, the number of rows of the matrix.
!    M must be positive.
!
!    Input, integer ( kind = 4 ) N, the number of columns of the matrix.
!    N must be positive.
!
!    Input, integer ( kind = 4 ) ML, MU, the lower and upper bandwidths.
!    ML and MU must be nonnegative, and no greater than min(M,N)-1..
!
!    Input, real ( kind = 8 ) A(2*ML+MU+1,N), the DGB matrix.
!
!    Input, integer ( kind = 4 ) ILO, JLO, IHI, JHI, the first row and
!    column, and the last row and column to be printed.
!
!    Input, character ( len = * ) TITLE, a title to be printed.
!
  implicit none

  integer ( kind = 4 ), parameter :: incx = 5
  integer ( kind = 4 ) ml
  integer ( kind = 4 ) mu
  integer ( kind = 4 ) n

  real ( kind = 8 ) a(2*ml+mu+1,n)
  character ( len = 14 ) ctemp(incx)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i2hi
  integer ( kind = 4 ) i2lo
  integer ( kind = 4 ) ihi
  integer ( kind = 4 ) ilo
  integer ( kind = 4 ) inc
  integer ( kind = 4 ) j
  integer ( kind = 4 ) j2
  integer ( kind = 4 ) j2hi
  integer ( kind = 4 ) j2lo
  integer ( kind = 4 ) jhi
  integer ( kind = 4 ) jlo
  integer ( kind = 4 ) m
  character ( len = * ) title

  if ( 0 < len_trim ( title ) ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) trim ( title )
  end if
!
!  Print the columns of the matrix, in strips of 5.
!
  do j2lo = jlo, jhi, incx

    j2hi = j2lo + incx - 1
    j2hi = min ( j2hi, n )
    j2hi = min ( j2hi, jhi )

    inc = j2hi + 1 - j2lo

    write ( *, '(a)' ) ' '

    do j = j2lo, j2hi
      j2 = j + 1 - j2lo
      write ( ctemp(j2), '(i7,7x)' ) j
    end do

    write ( *, '(a,5a14)' ) '  Col: ', ( ctemp(j2), j2 = 1, inc )
    write ( *, '(a)' ) '  Row'
    write ( *, '(a)' ) '  ---'
!
!  Determine the range of the rows in this strip.
!
    i2lo = max ( ilo, 1 )
    i2lo = max ( i2lo, j2lo - mu - ml )
    i2hi = min ( ihi, m )
    i2hi = min ( i2hi, j2hi + ml )

    do i = i2lo, i2hi
!
!  Print out (up to) 5 entries in row I, that lie in the current strip.
!
      do j2 = 1, inc

        j = j2lo - 1 + j2

        if ( i < j - ml - mu  .or. j + ml < i ) then
          ctemp(j2) = '              '
        else
          write ( ctemp(j2), '(g14.6)' ) a(i-j+ml+mu+1,j)
        end if

      end do

      write ( *, '(i5,1x,5a14)' ) i, ( ctemp(j2), j2 = 1, inc )

    end do

  end do

  return
end
subroutine dgb_sl ( n, ml, mu, a, pivot, b, job )

!*****************************************************************************80
!
!! DGB_SL solves a system factored by DGB_FA.
!
!  Discussion:
!
!    The DGB storage format is for an M by N banded matrix, with lower
!    bandwidth ML and upper bandwidth MU.  Storage includes room for ML
!    extra superdiagonals, which may be required to store nonzero entries
!    generated during Gaussian elimination.
!
!    The original M by N matrix is "collapsed" downward, so that diagonals
!    become rows of the storage array, while columns are preserved.  The
!    collapsed array is logically 2*ML+MU+1 by N.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    04 March 1999
!
!  Author:
!
!    FORTRAN77 original version by Dongarra, Bunch, Moler and Stewart.
!    FORTRAN90 version by John Burkardt.
!
!  Reference:
!
!    Dongarra, Bunch, Moler, Stewart,
!    LINPACK User's Guide,
!    SIAM, 1979
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the order of the matrix.
!    N must be positive.
!
!    Input, integer ( kind = 4 ) ML, MU, the lower and upper bandwidths.
!    ML and MU must be nonnegative, and no greater than N-1.
!
!    Input, real ( kind = 8 ) A(2*ML+MU+1,N), the LU factors from DGB_FA.
!
!    Input, integer ( kind = 4 ) PIVOT(N), the pivot vector from DGB_FA.
!
!    Input/output, real ( kind = 8 )l B(N).
!    On input, the right hand side vector.
!    On output, the solution.
!
!    Input, integer ( kind = 4 ) JOB.
!    0, solve A * x = b.
!    nonzero, solve A' * x = b.
!
  implicit none

  integer ( kind = 4 ) ml
  integer ( kind = 4 ) mu
  integer ( kind = 4 ) n

  real ( kind = 8 ) a(2*ml+mu+1,n)
  real ( kind = 8 ) b(n)
  integer ( kind = 4 ) pivot(n)
  integer ( kind = 4 ) job
  integer ( kind = 4 ) k
  integer ( kind = 4 ) l
  integer ( kind = 4 ) la
  integer ( kind = 4 ) lb
  integer ( kind = 4 ) lm
  integer ( kind = 4 ) m
  real ( kind = 8 ) t

  m = mu + ml + 1
!
!  Solve A * x = b.
!
  if ( job == 0 ) then
!
!  Solve L * Y = B.
!
    if ( 1 <= ml ) then

      do k = 1, n-1

        lm = min ( ml, n-k )
        l = pivot(k)

        if ( l /= k ) then
          t = b(l)
          b(l) = b(k)
          b(k) = t
        end if

        b(k+1:k+lm) = b(k+1:k+lm) + b(k) * a(m+1:m+lm,k)

      end do
    end if
!
!  Solve U * X = Y.
!
    do k = n, 1, -1

      b(k) = b(k) / a(m,k)
      lm = min ( k, m ) - 1
      la = m - lm
      lb = k - lm

      b(lb:lb+lm-1) = b(lb:lb+lm-1) - b(k) * a(la:la+lm-1,k)

    end do
!
!  Solve A' * X = B.
!
  else
!
!  Solve U' * Y = B.
!
    do k = 1, n
      lm = min ( k, m ) - 1
      la = m - lm
      lb = k - lm
      b(k) = ( b(k) - sum ( a(la:la+lm-1,k) * b(lb:lb+lm-1) ) ) &
        / a(m,k)
    end do
!
!  Solve L' * X = Y.
!
    if ( 1 <= ml ) then

      do k = n-1, 1, -1

        lm = min ( ml, n-k )
        b(k) = b(k) + sum ( a(m+1:m+lm,k) * b(k+1:k+lm) )
        l = pivot(k)

        if ( l /= k ) then
          t = b(l)
          b(l) = b(k)
          b(k) = t
        end if

      end do

    end if

  end if

  return
end
subroutine dirichlet_apply ( node_num, node_xy, node_condition, ib, a, f )

!*****************************************************************************80
!
!! DIRICHLET_APPLY accounts for Dirichlet boundary conditions.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    14 November 2006
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) NODE_NUM, the number of nodes.
!
!    Input, real ( kind = 8 ) NODE_XY(2,NODE_NUM), the coordinates of nodes.
!
!    Input, integer ( kind = 4 ) NODE_CONDITION(NODE_NUM), reports the condition
!    used to set the unknown associated with the node.
!    0, unknown.
!    1, finite element equation.
!    2, Dirichlet condition;
!    3, Neumann condition.
!
!    Input, integer ( kind = 4 ) IB, the half-bandwidth of the matrix.
!
!    Input/output, real ( kind = 8 ) A(3*IB+1,NODE_NUM), the NODE_NUM by
!    NODE_NUM coefficient matrix, stored in a compressed format; on output,
!    the matrix has been adjusted for Dirichlet boundary conditions.
!
!    Input/output, real ( kind = 8 ) F(NODE_NUM), the right hand side.
!    On output, the right hand side has been adjusted for Dirichlet
!    boundary conditions.
!
  implicit none

  integer ( kind = 4 ) ib
  integer ( kind = 4 ) node_num

  real ( kind = 8 ), dimension(3*ib+1,node_num) :: a
  integer ( kind = 4 ) column
  integer ( kind = 4 ) column_high
  integer ( kind = 4 ) column_low
  integer ( kind = 4 ), parameter :: DIRICHLET = 2
  real ( kind = 8 ), dimension(node_num) :: f
  integer ( kind = 4 ) node
  real ( kind = 8 ), dimension ( node_num ) :: node_bc
  integer ( kind = 4 ) node_condition(node_num)
  real ( kind = 8 ), dimension(2,node_num) :: node_xy

  call dirichlet_condition ( node_num, node_xy, node_bc )

  do node = 1, node_num

    if ( node_condition(node) == DIRICHLET ) then

      column_low = max ( node - ib, 1 )
      column_high = min ( node + ib, node_num )

      do column = column_low, column_high
        a(node-column+2*ib+1,column) = 0.0D+00
      end do
      a(2*ib+1,node) = 1.0D+00

      f(node) = node_bc(node)

    end if

  end do

  return
end
subroutine file_column_count ( input_filename, column_num )

!*****************************************************************************80
!
!! FILE_COLUMN_COUNT counts the number of columns in the first line of a file.
!
!  Discussion:
!
!    The file is assumed to be a simple text file.
!
!    Most lines of the file is presumed to consist of COLUMN_NUM words,
!    separated by spaces.  There may also be some blank lines, and some
!    comment lines,
!    which have a "#" in column 1.
!
!    The routine tries to find the first non-comment non-blank line and
!    counts the number of words in that line.
!
!    If all lines are blanks or comments, it goes back and tries to analyze
!    a comment line.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    21 June 2001
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) INPUT_FILE_NAME, the name of the file.
!
!    Output, integer ( kind = 4 ) COLUMN_NUM, the number of columns in the file.
!
  implicit none

  integer ( kind = 4 ) column_num
  logical got_one
  character ( len = * ) input_filename
  integer ( kind = 4 ) input_status
  integer ( kind = 4 ) input_unit
  character ( len = 255 ) line
!
!  Open the file.
!
  call get_unit ( input_unit )

  open ( unit = input_unit, file = input_filename, status = 'old', &
    form = 'formatted', access = 'sequential', iostat = input_status )

  if ( input_status /= 0 ) then
    column_num = -1
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'FILE_COLUMN_COUNT - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open the input file "' &
      // trim ( input_filename ) // '" on unit ', input_unit
    return
  end if
!
!  Read one line, but skip blank lines and comment lines.
!
  got_one = .false.

  do

    read ( input_unit, '(a)', iostat = input_status ) line

    if ( input_status /= 0 ) then
      exit
    end if

    if ( len_trim ( line ) == 0 ) then
      cycle
    end if

    if ( line(1:1) == '#' ) then
      cycle
    end if

    got_one = .true.
    exit

  end do

  if ( .not. got_one ) then

    rewind ( input_unit )

    do

      read ( input_unit, '(a)', iostat = input_status ) line

      if ( input_status /= 0 ) then
        exit
      end if

      if ( len_trim ( line ) == 0 ) then
        cycle
      end if

      got_one = .true.
      exit

    end do

  end if

  close ( unit = input_unit )

  if ( .not. got_one ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'FILE_COLUMN_COUNT - Warning!'
    write ( *, '(a)' ) '  The file does not seem to contain any data.'
    column_num = -1
    return
  end if

  call s_word_count ( line, column_num )

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
!    Input, character ( len = * ) INPUT_FILE_NAME, the name of the input file.
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
    stop
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
!    A "free" FORTRAN unit number is an integer between 1 and 99 which
!    is not currently associated with an I/O device.  A free FORTRAN unit
!    number is needed in order to open a file with the OPEN command.
!
!    If IUNIT = 0, then no free FORTRAN unit could be found, although
!    all 99 units were checked (except for units 5, 6 and 9, which
!    are commonly reserved for console I/O).
!
!    Otherwise, IUNIT is an integer between 1 and 99, representing a
!    free FORTRAN unit.  Note that GET_UNIT assumes that units 5 and 6
!    are special, and will never return those values.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 September 2005
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
  logical lopen

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
function i4_modp ( i, j )

!*****************************************************************************80
!
!! I4_MODP returns the nonnegative remainder of integer division.
!
!  Formula:
!
!    If
!      NREM = I4_MODP ( I, J )
!      NMULT = ( I - NREM ) / J
!    then
!      I = J * NMULT + NREM
!    where NREM is always nonnegative.
!
!  Discussion:
!
!    The MOD function computes a result with the same sign as the
!    quantity being divided.  Thus, suppose you had an angle A,
!    and you wanted to ensure that it was between 0 and 360.
!    Then mod(A,360) would do, if A was positive, but if A
!    was negative, your result would be between -360 and 0.
!
!    On the other hand, I4_MODP(A,360) is between 0 and 360, always.
!
!  Example:
!
!        I     J     MOD  I4_MODP    Factorization
!
!      107    50       7       7    107 =  2 *  50 + 7
!      107   -50       7       7    107 = -2 * -50 + 7
!     -107    50      -7      43   -107 = -3 *  50 + 43
!     -107   -50      -7      43   -107 =  3 * -50 + 43
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    02 March 1999
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) I, the number to be divided.
!
!    Input, integer ( kind = 4 ) J, the number that divides I.
!
!    Output, integer ( kind = 4 ) I4_MODP, the nonnegative remainder when I is
!    divided by J.
!
  implicit none

  integer ( kind = 4 ) i
  integer ( kind = 4 ) i4_modp
  integer ( kind = 4 ) j

  if ( j == 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'I4_MODP - Fatal error!'
    write ( *, '(a,i8)' ) '  I4_MODP ( I, J ) called with J = ', j
    stop
  end if

  i4_modp = mod ( i, j )

  if ( i4_modp < 0 ) then
    i4_modp = i4_modp + abs ( j )
  end if

  return
end
function i4_wrap ( ival, ilo, ihi )

!*****************************************************************************80
!
!! I4_WRAP forces an integer to lie between given limits by wrapping.
!
!  Example:
!
!    ILO = 4, IHI = 8
!
!    I  I4_WRAP
!
!    -2     8
!    -1     4
!     0     5
!     1     6
!     2     7
!     3     8
!     4     4
!     5     5
!     6     6
!     7     7
!     8     8
!     9     4
!    10     5
!    11     6
!    12     7
!    13     8
!    14     4
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    19 August 2003
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) IVAL, an integer value.
!
!    Input, integer ( kind = 4 ) ILO, IHI, the desired bounds for the
!    integer value.
!
!    Output, integer ( kind = 4 ) I4_WRAP, a "wrapped" version of IVAL.
!
  implicit none

  integer ( kind = 4 ) i4_modp
  integer ( kind = 4 ) i4_wrap
  integer ( kind = 4 ) ihi
  integer ( kind = 4 ) ilo
  integer ( kind = 4 ) ival
  integer ( kind = 4 ) jhi
  integer ( kind = 4 ) jlo
  integer ( kind = 4 ) wide

  jlo = min ( ilo, ihi )
  jhi = max ( ilo, ihi )

  wide = jhi - jlo + 1

  if ( wide == 1 ) then
    i4_wrap = jlo
  else
    i4_wrap = jlo + i4_modp ( ival - jlo, wide )
  end if

  return
end
subroutine i4col_compare ( m, n, a, i, j, isgn )

!*****************************************************************************80
!
!! I4COL_COMPARE compares columns I and J of an I4COL.
!
!  Example:
!
!    Input:
!
!      M = 3, N = 4, I = 2, J = 4
!
!      A = (
!        1  2  3  4
!        5  6  7  8
!        9 10 11 12 )
!
!    Output:
!
!      ISGN = -1
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    30 June 2000
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, N, the number of rows and columns.
!
!    Input, integer ( kind = 4 ) A(M,N), an array of N columns of vectors
!    of length M.
!
!    Input, integer ( kind = 4 ) I, J, the columns to be compared.
!    I and J must be between 1 and N.
!
!    Output, integer ( kind = 4 ) ISGN, the results of the comparison:
!    -1, column I < column J,
!     0, column I = column J,
!    +1, column J < column I.
!
  implicit none

  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  integer ( kind = 4 ) a(m,n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) isgn
  integer ( kind = 4 ) j
  integer ( kind = 4 ) k
!
!  Check.
!
  if ( i < 1 .or. n < i ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'I4COL_COMPARE - Fatal error!'
    write ( *, '(a)' ) '  Column index I is out of bounds.'
    write ( *, '(a,i8)' ) '  I = ', i
    stop
  end if

  if ( j < 1 .or. n < j ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'I4COL_COMPARE - Fatal error!'
    write ( *, '(a)' ) '  Column index J is out of bounds.'
    write ( *, '(a,i8)' ) '  J = ', j
    stop
  end if

  isgn = 0

  if ( i == j ) then
    return
  end if

  k = 1

  do while ( k <= m )

    if ( a(k,i) < a(k,j) ) then
      isgn = -1
      return
    else if ( a(k,j) < a(k,i) ) then
      isgn = +1
      return
    end if

    k = k + 1

  end do

  return
end
subroutine i4col_sort_a ( m, n, a )

!*****************************************************************************80
!
!! I4COL_SORT_A ascending sorts an I4COL.
!
!  Discussion:
!
!    In lexicographic order, the statement "X < Y", applied to two real
!    vectors X and Y of length M, means that there is some index I, with
!    1 <= I <= M, with the property that
!
!      X(J) = Y(J) for J < I,
!    and
!      X(I) < Y(I).
!
!    In other words, the first time they differ, X is smaller.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    25 September 2001
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, the number of rows of A, and the length of
!    a vector of data.
!
!    Input, integer ( kind = 4 ) N, the number of columns of A.
!
!    Input/output, integer ( kind = 4 ) A(M,N).
!    On input, the array of N columns of M-vectors.
!    On output, the columns of A have been sorted in ascending
!    lexicographic order.
!
  implicit none

  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  integer ( kind = 4 ) a(m,n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) indx
  integer ( kind = 4 ) isgn
  integer ( kind = 4 ) j

  if ( m <= 0 ) then
    return
  end if

  if ( n <= 1 ) then
    return
  end if
!
!  Initialize.
!
  i = 0
  indx = 0
  isgn = 0
  j = 0
!
!  Call the external heap sorter.
!
  do

    call sort_heap_external ( n, indx, i, j, isgn )
!
!  Interchange the I and J objects.
!
    if ( 0 < indx ) then

      call i4col_swap ( m, n, a, i, j )
!
!  Compare the I and J objects.
!
    else if ( indx < 0 ) then

      call i4col_compare ( m, n, a, i, j, isgn )

    else if ( indx == 0 ) then

      exit

    end if

  end do

  return
end
subroutine i4col_swap ( m, n, a, i, j )

!*****************************************************************************80
!
!! I4COL_SWAP swaps columns I and J of an I4COL.
!
!  Example:
!
!    Input:
!
!      M = 3, N = 4, I = 2, J = 4
!
!      A = (
!        1  2  3  4
!        5  6  7  8
!        9 10 11 12 )
!
!    Output:
!
!      A = (
!        1  4  3  2
!        5  8  7  6
!        9 12 11 10 )
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    04 April 2001
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, N, the number of rows and columns in the
!    array.
!
!    Input/output, integer ( kind = 4 ) A(M,N), an array of N columns
!    of length M.
!
!    Input, integer ( kind = 4 ) I, J, the columns to be swapped.
!
  implicit none

  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  integer ( kind = 4 ) a(m,n)
  integer ( kind = 4 ) col(m)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) j

  if ( i < 1 .or. n < i .or. j < 1 .or. n < j ) then

    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'I4COL_SWAP - Fatal error!'
    write ( *, '(a)' ) '  I or J is out of bounds.'
    write ( *, '(a,i8)' ) '  I =    ', i
    write ( *, '(a,i8)' ) '  J =    ', j
    write ( *, '(a,i8)' ) '  N =    ', n
    stop

  end if

  if ( i == j ) then
    return
  end if

  col(1:m) = a(1:m,i)
  a(1:m,i) = a(1:m,j)
  a(1:m,j) = col(1:m)

  return
end
subroutine i4mat_transpose_print_some ( m, n, a, ilo, jlo, ihi, jhi, title )

!*****************************************************************************80
!
!! I4MAT_TRANSPOSE_PRINT_SOME prints some of the transpose of an I4mat.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    09 February 2005
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, N, the number of rows and columns.
!
!    Input, integer ( kind = 4 ) A(M,N), an M by N matrix to be printed.
!
!    Input, integer ( kind = 4 ) ILO, JLO, the first row and column to print.
!
!    Input, integer ( kind = 4 ) IHI, JHI, the last row and column to print.
!
!    Input, character ( len = * ) TITLE, an optional title.
!
  implicit none

  integer ( kind = 4 ), parameter :: incx = 10
  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  integer ( kind = 4 ) a(m,n)
  character ( len = 7 ) ctemp(incx)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i2hi
  integer ( kind = 4 ) i2lo
  integer ( kind = 4 ) ihi
  integer ( kind = 4 ) ilo
  integer ( kind = 4 ) inc
  integer ( kind = 4 ) j
  integer ( kind = 4 ) j2hi
  integer ( kind = 4 ) j2lo
  integer ( kind = 4 ) jhi
  integer ( kind = 4 ) jlo
  character ( len = * ) title

  if ( 0 < len_trim ( title ) ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) trim ( title )
  end if

  do i2lo = max ( ilo, 1 ), min ( ihi, m ), incx

    i2hi = i2lo + incx - 1
    i2hi = min ( i2hi, m )
    i2hi = min ( i2hi, ihi )

    inc = i2hi + 1 - i2lo

    write ( *, '(a)' ) ' '

    do i = i2lo, i2hi
      i2 = i + 1 - i2lo
      write ( ctemp(i2), '(i7)') i
    end do

    write ( *, '(''  Row '',10a7)' ) ctemp(1:inc)
    write ( *, '(a)' ) '  Col'
    write ( *, '(a)' ) ' '

    j2lo = max ( jlo, 1 )
    j2hi = min ( jhi, n )

    do j = j2lo, j2hi

      do i2 = 1, inc

        i = i2lo - 1 + i2

        write ( ctemp(i2), '(i7)' ) a(i,j)

      end do

      write ( *, '(i5,1x,10a7)' ) j, ( ctemp(i), i = 1, inc )

    end do

  end do

  return
end
subroutine i4mat_data_read ( input_filename, m, n, table )

!*****************************************************************************80
!
!! I4MAT_DATA_READ reads data from an I4MAT file.
!
!  Discussion:
!
!    An I4MAT is an array of I4's.
!
!    The file may contain more than N points, but this routine
!    will return after reading N points.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    27 January 2005
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) INPUT_FILENAME, the name of the input file.
!
!    Input, integer ( kind = 4 ) M, the spatial dimension.
!
!    Input, integer ( kind = 4 ) N, the number of points.
!
!    Output, integer ( kind = 4 ) TABLE(M,N), the table data.
!
  implicit none

  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  integer ( kind = 4 ) ierror
  character ( len = * ) input_filename
  integer ( kind = 4 ) input_status
  integer ( kind = 4 ) input_unit
  integer ( kind = 4 ) j
  character ( len = 255 ) line
  integer ( kind = 4 ) table(m,n)
  integer ( kind = 4 ) x(m)

  ierror = 0

  call get_unit ( input_unit )

  open ( unit = input_unit, file = input_filename, status = 'old', &
    iostat = input_status )

  if ( input_status /= 0 ) then
    ierror = 1
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'I4MAT_DATA_READ - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open the input file "' // &
      trim ( input_filename ) // '" on unit ', input_unit
    stop
  end if

  j = 0

  do while ( j < n )

    read ( input_unit, '(a)', iostat = input_status ) line

    if ( input_status /= 0 ) then
      ierror = 2
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'I4MAT_DATA_READ - Fatal error!'
      write ( *, '(a)' ) '  Error while reading lines of data.'
      write ( *, '(a,i8)' ) '  Number of values expected per line M = ', m
      write ( *, '(a,i8)' ) '  Number of data lines read, J =         ', j
      write ( *, '(a,i8)' ) '  Number of data lines needed, N =       ', n
      stop
    end if

    if ( line(1:1) == '#' .or. len_trim ( line ) == 0 ) then
      cycle
    end if

    call s_to_i4vec ( line, m, x, ierror )

    if ( ierror /= 0 ) then
      cycle
    end if

    j = j + 1

    table(1:m,j) = x(1:m)

  end do

  close ( unit = input_unit )

  return
end
subroutine i4mat_header_read ( input_filename, m, n )

!*****************************************************************************80
!
!! I4MAT_HEADER_READ reads the header from an I4MAT.
!
!  Discussion:
!
!    An I4MAT is an array of I4's.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    04 June 2004
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) INPUT_FILENAME, the name of the input file.
!
!    Output, integer ( kind = 4 ) M, spatial dimension.
!
!    Output, integer ( kind = 4 ) N, the number of points.
!
  implicit none

  character ( len = * ) input_filename
  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  call file_column_count ( input_filename, m )

  if ( m <= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'I4MAT_HEADER_READ - Fatal error!'
    write ( *, '(a)' ) '  There was some kind of I/O problem while trying'
    write ( *, '(a)' ) '  to count the number of data columns in'
    write ( *, '(a)' ) '  the file "' // trim ( input_filename ) // '".'
    stop
  end if

  call file_row_count ( input_filename, n )

  if ( n <= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'I4MAT_HEADER_READ - Fatal error!'
    write ( *, '(a)' ) '  There was some kind of I/O problem while trying'
    write ( *, '(a)' ) '  to count the number of data rows in'
    write ( *, '(a)' ) '  the file "' // trim ( input_filename ) // '".'
    stop
  end if

  return
end
subroutine lvec_print ( n, a, title )

!*****************************************************************************80
!
!! LVEC_PRINT prints a logical vector.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    26 March 2005
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of components of the vector.
!
!    Input, logical A(N), the vector to be printed.
!
!    Input, character ( len = * ) TITLE, a title to be printed first.
!    TITLE may be blank.
!
  implicit none

  integer ( kind = 4 ) n

  logical a(n)
  integer ( kind = 4 ) i
  character ( len = * ) title

  if ( 0 < len_trim ( title ) ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) trim ( title )
  end if

  write ( *, '(a)' ) ' '
  do i = 1, n
    write ( *, '(2x,i8,2x,l1)' ) i, a(i)
  end do

  return
end
subroutine points_plot ( filename, node_num, node_xy, node_label )

!*****************************************************************************80
!
!! POINTS_PLOT plots a pointset.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    27 September 2006
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) FILE_NAME, the name of the output file.
!
!    Input, integer ( kind = 4 ) NODE_NUM, the number of points.
!
!    Input, real ( kind = 8 ) NODE_XY(2,NODE_NUM), the nodes.
!
!    Input, logical NODE_LABEL, is TRUE if the nodes should be labeled.
!
  implicit none

  integer ( kind = 4 ) node_num

  integer ( kind = 4 ) :: circle_size
  integer ( kind = 4 ) delta
  character ( len = * ) filename
  integer ( kind = 4 ) file_status
  integer ( kind = 4 ) file_unit
  integer ( kind = 4 ) node
  logical node_label
  real ( kind = 8 ) node_xy(2,node_num)
  character ( len = 40 ) string
  real ( kind = 8 ) x_max
  real ( kind = 8 ) x_min
  integer ( kind = 4 ) x_ps
  integer ( kind = 4 ) :: x_ps_max = 576
  integer ( kind = 4 ) :: x_ps_max_clip = 594
  integer ( kind = 4 ) :: x_ps_min = 36
  integer ( kind = 4 ) :: x_ps_min_clip = 18
  real ( kind = 8 ) x_scale
  real ( kind = 8 ) y_max
  real ( kind = 8 ) y_min
  integer ( kind = 4 ) y_ps
  integer ( kind = 4 ) :: y_ps_max = 666
  integer ( kind = 4 ) :: y_ps_max_clip = 684
  integer ( kind = 4 ) :: y_ps_min = 126
  integer ( kind = 4 ) :: y_ps_min_clip = 108
  real ( kind = 8 ) y_scale
!
!  We need to do some figuring here, so that we can determine
!  the range of the data, and hence the height and width
!  of the piece of paper.
!
  x_max = maxval ( node_xy(1,1:node_num) )
  x_min = minval ( node_xy(1,1:node_num) )
  x_scale = x_max - x_min

  x_max = x_max + 0.05D+00 * x_scale
  x_min = x_min - 0.05D+00 * x_scale
  x_scale = x_max - x_min

  y_max = maxval ( node_xy(2,1:node_num) )
  y_min = minval ( node_xy(2,1:node_num) )
  y_scale = y_max - y_min

  y_max = y_max + 0.05D+00 * y_scale
  y_min = y_min - 0.05D+00 * y_scale
  y_scale = y_max - y_min

  if ( x_scale < y_scale ) then

    delta = nint ( real ( x_ps_max - x_ps_min, kind = 8 ) &
      * ( y_scale - x_scale ) / ( 2.0D+00 * y_scale ) )

    x_ps_max = x_ps_max - delta
    x_ps_min = x_ps_min + delta

    x_ps_max_clip = x_ps_max_clip - delta
    x_ps_min_clip = x_ps_min_clip + delta

    x_scale = y_scale

  else if ( y_scale < x_scale ) then

    delta = nint ( real ( y_ps_max - y_ps_min, kind = 8 ) &
      * ( x_scale - y_scale ) / ( 2.0D+00 * x_scale ) )

    y_ps_max = y_ps_max - delta
    y_ps_min = y_ps_min + delta

    y_ps_max_clip = y_ps_max_clip - delta
    y_ps_min_clip = y_ps_min_clip + delta

    y_scale = x_scale

  end if

  call get_unit ( file_unit )

  open ( unit = file_unit, file = filename, status = 'replace', &
    iostat = file_status )

  if ( file_status /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'POINTS_PLOT - Fatal error!'
    write ( *, '(a)' ) '  Can not open output file.'
    return
  end if

  write ( file_unit, '(a)' ) '%!PS-Adobe-3.0 EPSF-3.0'
  write ( file_unit, '(a)' ) '%%Creator: points_plot.f90'
  write ( file_unit, '(a)' ) '%%Title: ' // trim ( filename )
  write ( file_unit, '(a)' ) '%%Pages: 1'
  write ( file_unit, '(a,i3,2x,i3,2x,i3,2x,i3)' ) '%%BoundingBox: ', &
    x_ps_min, y_ps_min, x_ps_max, y_ps_max
  write ( file_unit, '(a)' ) '%%Document-Fonts: Times-Roman'
  write ( file_unit, '(a)' ) '%%LanguageLevel: 1'
  write ( file_unit, '(a)' ) '%%EndComments'
  write ( file_unit, '(a)' ) '%%BeginProlog'
  write ( file_unit, '(a)' ) '/inch {72 mul} def'
  write ( file_unit, '(a)' ) '%%EndProlog'
  write ( file_unit, '(a)' ) '%%Page: 1 1'
  write ( file_unit, '(a)' ) 'save'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Set the RGB line color to very light gray.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '0.900  0.900  0.900 setrgbcolor'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Draw a gray border around the page.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) 'newpath'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_min, y_ps_min, ' moveto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_max, y_ps_min, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_max, y_ps_max, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_min, y_ps_max, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_min, y_ps_min, ' lineto'
  write ( file_unit, '(a)' ) 'stroke'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Set the RGB line color to black.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '0.000  0.000  0.000 setrgbcolor'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Set the font and its size.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '/Times-Roman findfont'
  write ( file_unit, '(a)' ) '0.50 inch scalefont'
  write ( file_unit, '(a)' ) 'setfont'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Print a title.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  210  702  moveto'
  write ( file_unit, '(a)' ) '%  (Pointset)  show'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Define a clipping polygon.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) 'newpath'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_min_clip, y_ps_min_clip, ' moveto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_max_clip, y_ps_min_clip, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_max_clip, y_ps_max_clip, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_min_clip, y_ps_max_clip, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_min_clip, y_ps_min_clip, ' lineto'
  write ( file_unit, '(a)' ) 'clip newpath'
!
!  Draw the nodes.
!
  if ( node_num <= 200 ) then
    circle_size = 5
  else if ( node_num <= 500 ) then
    circle_size = 4
  else if ( node_num <= 1000 ) then
    circle_size = 3
  else if ( node_num <= 5000 ) then
    circle_size = 2
  else
    circle_size = 1
  end if

  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Draw filled dots at each node.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Set the RGB color to blue.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '0.000  0.150  0.750 setrgbcolor'
  write ( file_unit, '(a)' ) '%'

  do node = 1, node_num

    x_ps = int ( &
      ( ( x_max - node_xy(1,node)         ) * real ( x_ps_min, kind = 8 )   &
      + (         node_xy(1,node) - x_min ) * real ( x_ps_max, kind = 8 ) ) &
      / ( x_max                   - x_min ) )

    y_ps = int ( &
      ( ( y_max - node_xy(2,node)         ) * real ( y_ps_min, kind = 8 )   &
      + (         node_xy(2,node) - y_min ) * real ( y_ps_max, kind = 8 ) ) &
      / ( y_max                   - y_min ) )

    write ( file_unit, '(a,i4,2x,i4,2x,i4,2x,a)' ) 'newpath ', x_ps, y_ps, &
      circle_size, '0 360 arc closepath fill'

  end do
!
!  Label the nodes.
!
  if ( node_label ) then

    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Label the nodes:'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Set the RGB color to darker blue.'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '0.000  0.250  0.850 setrgbcolor'
    write ( file_unit, '(a)' ) '/Times-Roman findfont'
    write ( file_unit, '(a)' ) '0.20 inch scalefont'
    write ( file_unit, '(a)' ) 'setfont'

    do node = 1, node_num

      x_ps = int ( &
        ( ( x_max - node_xy(1,node)         ) * real ( x_ps_min, kind = 8 )   &
        + (       + node_xy(1,node) - x_min ) * real ( x_ps_max, kind = 8 ) ) &
        / ( x_max                   - x_min ) )

      y_ps = int ( &
        ( ( y_max - node_xy(2,node)         ) * real ( y_ps_min, kind = 8 )   &
        + (         node_xy(2,node) - y_min ) * real ( y_ps_max, kind = 8 ) ) &
        / ( y_max                   - y_min ) )

      write ( string, '(i4)' ) node
      string = adjustl ( string )

      write ( file_unit, '(i4,2x,i4,a)' ) x_ps, y_ps+5, &
        ' moveto (' // trim ( string ) // ') show'

    end do

  end if

  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) 'restore  showpage'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  End of page.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%%Trailer'
  write ( file_unit, '(a)' ) '%%EOF'
  close ( unit = file_unit )

  return
end
subroutine quad_rule ( quad_num, quad_w, quad_xy )

!*****************************************************************************80
!
!! QUAD_RULE sets the quadrature rule for assembly.
!
!  Discussion:
!
!    The quadrature rule is given for a reference element.
!
!      0 <= X,
!      0 <= Y, and
!      X + Y <= 1.
!
!      ^
!    1 | *
!      | |\
!    Y | | \
!      | |  \
!    0 | *---*
!      +------->
!        0 X 1
!
!    The rules have the following precision:
!
!    QUAD_NUM  Precision
!
!     1        1
!     3        2
!     4        3
!     6        4
!     7        5
!     9        6
!    13        7
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    18 July 2005
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) QUAD_NUM, the number of quadrature nodes.
!
!    Output, real ( kind = 8 ) QUAD_W(QUAD_NUM), the quadrature weights.
!
!    Output, real ( kind = 8 ) QUAD_XY(2,QUAD_NUM),
!    the coordinates of the quadrature nodes.
!
  implicit none

  integer ( kind = 4 ), parameter :: dim_num = 2
  integer ( kind = 4 ) quad_num

  real ( kind = 8 ) a
  real ( kind = 8 ) b
  real ( kind = 8 ) c
  real ( kind = 8 ) d
  real ( kind = 8 ) e
  real ( kind = 8 ) f
  real ( kind = 8 ) g
  real ( kind = 8 ) h
  real ( kind = 8 ), dimension(quad_num) :: quad_w
  real ( kind = 8 ), dimension(dim_num,quad_num) :: quad_xy
  real ( kind = 8 ) t
  real ( kind = 8 ) u
  real ( kind = 8 ) v
  real ( kind = 8 ) w

  if ( quad_num == 1 ) then

    quad_xy(1:dim_num,1:quad_num) = reshape ( (/ &
      1.0D+00 / 3.0D+00, 1.0D+00 / 3.0D+00 /), (/ dim_num, quad_num /) )

    quad_w(1:quad_num) = 1.0D+00

  else if ( quad_num == 3 ) then

    quad_xy(1:dim_num,1:quad_num) = reshape ( (/ &
      0.5D+00, 0.0D+00, &
      0.5D+00, 0.5D+00, &
      0.0D+00, 0.5D+00 /), (/ dim_num, quad_num /) )

    quad_w(1:quad_num) = 1.0D+00 / 3.0D+00

  else if ( quad_num == 4 ) then

    a =   6.0D+00 / 30.0D+00
    b =  10.0D+00 / 30.0D+00
    c =  18.0D+00 / 30.0D+00

    d =  25.0D+00 / 48.0D+00
    e = -27.0D+00 / 48.0D+00

    quad_xy(1:dim_num,1:quad_num) = reshape ( (/ &
      b, b, &
      c, a, &
      a, c, &
      a, a /), (/ dim_num, quad_num /) )

    quad_w(1:quad_num) = (/ e, d, d, d /)

  else if ( quad_num == 6 ) then

    a = 0.816847572980459D+00
    b = 0.091576213509771D+00
    c = 0.108103018168070D+00
    d = 0.445948490915965D+00
    v = 0.109951743655322D+00
    w = 0.223381589678011D+00

    quad_xy(1:dim_num,1:quad_num) = reshape ( (/ &
      a, b, &
      b, a, &
      b, b, &
      c, d, &
      d, c, &
      d, d /), (/ dim_num, quad_num /) )

    quad_w(1:quad_num) = (/ v, v, v, w, w, w /)

  else if ( quad_num == 7 ) then

    a = 1.0D+00 / 3.0D+00
    b = ( 9.0D+00 + 2.0D+00 * sqrt ( 15.0D+00 ) ) / 21.0D+00
    c = ( 6.0D+00 -       sqrt ( 15.0D+00 ) ) / 21.0D+00
    d = ( 9.0D+00 - 2.0D+00 * sqrt ( 15.0D+00 ) ) / 21.0D+00
    e = ( 6.0D+00 +       sqrt ( 15.0D+00 ) ) / 21.0D+00
    u = 0.225D+00
    v = ( 155.0D+00 - sqrt ( 15.0D+00 ) ) / 1200.0D+00
    w = ( 155.0D+00 + sqrt ( 15.0D+00 ) ) / 1200.0D+00

    quad_xy(1:dim_num,1:quad_num) = reshape ( (/ &
      a, a, &
      b, c, &
      c, b, &
      c, c, &
      d, e, &
      e, d, &
      e, e /), (/ dim_num, quad_num /) )

    quad_w(1:quad_num) = (/ u, v, v, v, w, w, w /)

  else if ( quad_num == 9 ) then

    a = 0.124949503233232D+00
    b = 0.437525248383384D+00
    c = 0.797112651860071D+00
    d = 0.165409927389841D+00
    e = 0.037477420750088D+00

    u = 0.205950504760887D+00
    v = 0.063691414286223D+00

    quad_xy(1:dim_num,1:quad_num) = reshape ( (/ &
      a, b, &
      b, a, &
      b, b, &
      c, d, &
      c, e, &
      d, c, &
      d, e, &
      e, c, &
      e, d /), (/ dim_num, quad_num /) )

    quad_w(1:quad_num) = (/ u, u, u, v, v, v, v, v, v /)

  else if ( quad_num == 13 ) then

    h = 1.0D+00 / 3.0D+00
    a = 0.479308067841923D+00
    b = 0.260345966079038D+00
    c = 0.869739794195568D+00
    d = 0.065130102902216D+00
    e = 0.638444188569809D+00
    f = 0.312865496004875D+00
    g = 0.048690315425316D+00

    w = -0.149570044467670D+00
    t =  0.175615257433204D+00
    u =  0.053347235608839D+00
    v =  0.077113760890257D+00

    quad_xy(1:dim_num,1:quad_num) = reshape ( (/ &
      h, h, &
      a, b, &
      b, a, &
      b, b, &
      c, d, &
      d, c, &
      d, d, &
      e, f, &
      e, g, &
      f, e, &
      f, g, &
      g, e, &
      g, f /), (/ dim_num, quad_num /) )

    quad_w(1:quad_num) = (/ w, t, t, t, u, u, u, v, v, v, v, v, v /)

  else

    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'QUAD_RULE - Fatal error!'
    write ( *, '(a,i8)' ) '  No rule is available of order QUAD_NUM = ', &
      quad_num
    stop

  end if

  return
end
subroutine r8mat_data_read ( input_filename, m, n, table )

!*****************************************************************************80
!
!! R8MAT_DATA_READ reads data from an R8MAT file.
!
!  Discussion:
!
!    An R8MAT is an array of R8 values.
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
!    18 October 2008
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) INPUT_FILENAME, the name of the input file.
!
!    Input, integer ( kind = 4 ) M, the spatial dimension.
!
!    Input, integer ( kind = 4 ) N, the number of points.
!
!    Output, real ( kind = 8 ) TABLE(M,N), the table data.
!
  implicit none

  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  integer ( kind = 4 ) ierror
  character ( len = * ) input_filename
  integer ( kind = 4 ) input_status
  integer ( kind = 4 ) input_unit
  integer ( kind = 4 ) j
  character ( len = 255 ) line
  real ( kind = 8 ) table(m,n)
  real ( kind = 8 ) x(m)

  ierror = 0

  call get_unit ( input_unit )

  open ( unit = input_unit, file = input_filename, status = 'old', &
    iostat = input_status )

  if ( input_status /= 0 ) then
    ierror = 1
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'R8MAT_DATA_READ - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open the input file "' // &
      trim ( input_filename ) // '" on unit ', input_unit
    stop
  end if

  j = 0

  do while ( j < n )

    read ( input_unit, '(a)', iostat = input_status ) line

    if ( input_status /= 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'R8MAT_DATA_READ - Fatal error!'
      write ( *, '(a)' ) '  Error while reading lines of data.'
      write ( *, '(a,i8)' ) '  Number of values expected per line M = ', m
      write ( *, '(a,i8)' ) '  Number of data lines read, J =         ', j
      write ( *, '(a,i8)' ) '  Number of data lines needed, N =       ', n
      stop
    end if

    if ( line(1:1) == '#' .or. len_trim ( line ) == 0 ) then
      cycle
    end if

    call s_to_r8vec ( line, m, x, ierror )

    if ( ierror /= 0 ) then
      cycle
    end if

    j = j + 1

    table(1:m,j) = x(1:m)

  end do

  close ( unit = input_unit )

  return
end
subroutine r8mat_header_read ( input_filename, m, n )

!*****************************************************************************80
!
!! R8MAT_HEADER_READ reads the header from an R8MAT file.
!
!  Discussion:
!
!    An R8MAT is an array of R8 values.
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
!    Input, character ( len = * ) INPUT_FILENAME, the name of the input file.
!
!    Output, integer ( kind = 4 ) M, spatial dimension.
!
!    Output, integer ( kind = 4 ) N, the number of points.
!
  implicit none

  character ( len = * ) input_filename
  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  call file_column_count ( input_filename, m )

  if ( m <= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'R8MAT_HEADER_READ - Fatal error!'
    write ( *, '(a)' ) '  There was some kind of I/O problem while trying'
    write ( *, '(a)' ) '  to count the number of data columns in'
    write ( *, '(a)' ) '  the file "' // trim ( input_filename ) // '".'
    stop
  end if

  call file_row_count ( input_filename, n )

  if ( n <= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'R8MAT_HEADER_READ - Fatal error!'
    write ( *, '(a)' ) '  There was some kind of I/O problem while trying'
    write ( *, '(a)' ) '  to count the number of data rows in'
    write ( *, '(a)' ) '  the file "' // trim ( input_filename ) // '".'
    stop
  end if

  return
end
subroutine r8mat_transpose_print_some ( m, n, a, ilo, jlo, ihi, jhi, title )

!*****************************************************************************80
!
!! R8MAT_TRANSPOSE_PRINT_SOME prints some of an R8MAT, transposed.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    14 June 2004
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) M, N, the number of rows and columns.
!
!    Input, real ( kind = 8 ) A(M,N), an M by N matrix to be printed.
!
!    Input, integer ( kind = 4 ) ILO, JLO, the first row and column to print.
!
!    Input, integer ( kind = 4 ) IHI, JHI, the last row and column to print.
!
!    Input, character ( len = * ) TITLE, an optional title.
!
  implicit none

  integer ( kind = 4 ), parameter :: incx = 5
  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  real ( kind = 8 ) a(m,n)
  character ( len = 14 ) ctemp(incx)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i2hi
  integer ( kind = 4 ) i2lo
  integer ( kind = 4 ) ihi
  integer ( kind = 4 ) ilo
  integer ( kind = 4 ) inc
  integer ( kind = 4 ) j
  integer ( kind = 4 ) j2hi
  integer ( kind = 4 ) j2lo
  integer ( kind = 4 ) jhi
  integer ( kind = 4 ) jlo
  character ( len = * ) title

  if ( 0 < len_trim ( title ) ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) trim ( title )
  end if

  do i2lo = max ( ilo, 1 ), min ( ihi, m ), incx

    i2hi = i2lo + incx - 1
    i2hi = min ( i2hi, m )
    i2hi = min ( i2hi, ihi )

    inc = i2hi + 1 - i2lo

    write ( *, '(a)' ) ' '

    do i = i2lo, i2hi
      i2 = i + 1 - i2lo
      write ( ctemp(i2), '(i7,7x)') i
    end do

    write ( *, '(''  Row   '',5a14)' ) ctemp(1:inc)
    write ( *, '(a)' ) '  Col'
    write ( *, '(a)' ) ' '

    j2lo = max ( jlo, 1 )
    j2hi = min ( jhi, n )

    do j = j2lo, j2hi

      do i2 = 1, inc
        i = i2lo - 1 + i2
        write ( ctemp(i2), '(g14.6)' ) a(i,j)
      end do

      write ( *, '(i5,1x,5a14)' ) j, ( ctemp(i), i = 1, inc )

    end do

  end do

  return
end
subroutine r8mat_write ( output_filename, m, n, table )

!*****************************************************************************80
!
!! R8MAT_WRITE writes an R8MAT file.
!
!  Discussion:
!
!    An R8MAT is an array of R8 values.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    31 May 2009
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) OUTPUT_FILENAME, the output file name.
!
!    Input, integer ( kind = 4 ) M, the spatial dimension.
!
!    Input, integer ( kind = 4 ) N, the number of points.
!
!    Input, real ( kind = 8 ) TABLE(M,N), the table data.
!
  implicit none

  integer ( kind = 4 ) m
  integer ( kind = 4 ) n

  integer ( kind = 4 ) j
  character ( len = * ) output_filename
  integer ( kind = 4 ) output_status
  integer ( kind = 4 ) output_unit
  character ( len = 30 ) string
  real ( kind = 8 ) table(m,n)
!
!  Open the file.
!
  call get_unit ( output_unit )

  open ( unit = output_unit, file = output_filename, &
    status = 'replace', iostat = output_status )

  if ( output_status /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'R8MAT_WRITE - Fatal error!'
    write ( *, '(a,i8)' ) '  Could not open the output file "' // &
      trim ( output_filename ) // '" on unit ', output_unit
    output_unit = -1
    stop
  end if
!
!  Create a format string.
!
!  For less precision in the output file, try:
!
!                                            '(', m, 'g', 14, '.', 6, ')'
!
  if ( 0 < m .and. 0 < n ) then

    write ( string, '(a1,i8,a1,i8,a1,i8,a1)' ) '(', m, 'g', 24, '.', 16, ')'
!
!  Write the data.
!
    do j = 1, n
      write ( output_unit, string ) table(1:m,j)
    end do

  end if
!
!  Close the file.
!
  close ( unit = output_unit )

  return
end
subroutine r8vec_print_some ( n, a, i_lo, i_hi, title )

!*****************************************************************************80
!
!! R8VEC_PRINT_SOME prints "some" of an R8VEC.
!
!  Discussion:
!
!    An R8VEC is a vector of R8 values.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    16 October 2006
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of entries of the vector.
!
!    Input, real ( kind = 8 ) A(N), the vector to be printed.
!
!    Input, integer ( kind = 4 ) I_LO, I_HI, the first and last indices
!    to print.  The routine expects 1 <= I_LO <= I_HI <= N.
!
!    Input, character ( len = * ) TITLE, an optional title.
!
  implicit none

  integer ( kind = 4 ) n

  real ( kind = 8 ) a(n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i_hi
  integer ( kind = 4 ) i_lo
  character ( len = * ) title

  if ( 0 < len_trim ( title ) ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) trim ( title )
  end if

  write ( *, '(a)' ) ' '
  do i = max ( i_lo, 1 ), min ( i_hi, n )
    write ( *, '(2x,i8,2x,g14.8)' ) i, a(i)
  end do

  return
end
subroutine reference_to_physical_t3 ( t, n, ref, phy )

!*****************************************************************************80
!
!! REFERENCE_TO_PHYSICAL_T3 maps reference points to physical points.
!
!  Discussion:
!
!    Given the vertices of an order 3 physical triangle and a point
!    (XSI,ETA) in the reference triangle, the routine computes the value
!    of the corresponding image point (X,Y) in physical space.
!
!    Note that this routine may also be appropriate for an order 6
!    triangle, if the mapping between reference and physical space
!    is linear.  This implies, in particular, that the sides of the
!    image triangle are straight and that the "midside" nodes in the
!    physical triangle are literally halfway along the sides of
!    the physical triangle.
!
!  Reference Element T3:
!
!    |
!    1  3
!    |  |\
!    |  | \
!    S  |  \
!    |  |   \
!    |  |    \
!    0  1-----2
!    |
!    +--0--R--1-->
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    24 June 2005
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) T(2,3), the coordinates of the vertices.
!    The vertices are assumed to be the images of (0,0), (1,0) and
!    (0,1) respectively.
!
!    Input, integer ( kind = 4 ) N, the number of objects to transform.
!
!    Input, real ( kind = 8 ) REF(2,N), points in the reference triangle.
!
!    Output, real ( kind = 8 ) PHY(2,N), corresponding points in the
!    physical triangle.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  real ( kind = 8 ) phy(2,n)
  real ( kind = 8 ) ref(2,n)
  real ( kind = 8 ) t(2,3)

  do i = 1, 2
    phy(i,1:n) = t(i,1) * ( 1.0D+00 - ref(1,1:n) - ref(2,1:n) ) &
               + t(i,2) *             ref(1,1:n)                &
               + t(i,3) *                          ref(2,1:n)
  end do

  return
end
subroutine residual_poisson ( node_num, node_xy, node_condition, &
  element_num, element_node, quad_num, ib, a, f, node_u, node_r )

!*****************************************************************************80
!
!! RESIDUAL_POISSON evaluates the residual for the Poisson equation.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    14 November 2006
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) NODE_NUM, the number of nodes.
!
!    Input, real ( kind = 8 ) NODE_XY(2,NODE_NUM), the
!    coordinates of nodes.
!
!    Input, integer ( kind = 4 ) NODE_CONDITION(NODE_NUM), reports the
!    condition used to set the unknown associated with the node.
!    0, unknown.
!    1, finite element equation.
!    2, Dirichlet condition;
!    3, Neumann condition.
!
!    Input, integer ( kind = 4 ) ELEMENT_NUM, the number of elements.
!
!    Input, integer ( kind = 4 ) ELEMENT_NODE(3,ELEMENT_NUM);
!    ELEMENT_NODE(I,J) is the global index of local node I in element J.
!
!    Input, integer ( kind = 4 ) QUAD_NUM, the number of quadrature points
!    used in assembly.
!
!    Input, integer ( kind = 4 ) IB, the half-bandwidth of the matrix.
!
!    Workspace, real ( kind = 8 ) A(3*IB+1,NODE_NUM), the NODE_NUM by NODE_NUM
!    coefficient matrix, stored in a compressed format.
!
!    Workspace, real ( kind = 8 ) F(NODE_NUM), the right hand side.
!
!    Input, real ( kind = 8 ) NODE_U(NODE_NUM), the value of the solution
!    at each node.
!
!    Output, real ( kind = 8 ) NODE_R(NODE_NUM), the finite element
!    residual at each node.
!
!  Local parameters:
!
!    Local, real ( kind = 8 ) BI, DBIDX, DBIDY, the value of some basis function
!    and its first derivatives at a quadrature point.
!
!    Local, real ( kind = 8 ) BJ, DBJDX, DBJDY, the value of another basis
!    function and its first derivatives at a quadrature point.
!
  implicit none

  integer ( kind = 4 ) ib
  integer ( kind = 4 ) node_num
  integer ( kind = 4 ) quad_num
  integer ( kind = 4 ) element_num

  real ( kind = 8 ), dimension(3*ib+1,node_num) :: a
  integer ( kind = 4 ) basis
  real ( kind = 8 ) bi
  real ( kind = 8 ) bj
  real ( kind = 8 ) dbidx
  real ( kind = 8 ) dbidy
  real ( kind = 8 ) dbjdx
  real ( kind = 8 ) dbjdy
  integer ( kind = 4 ) element
  integer ( kind = 4 ), dimension(3,element_num) :: element_node
  real ( kind = 8 ), dimension(node_num) :: f
  integer ( kind = 4 ) i
  integer ( kind = 4 ) j
  integer ( kind = 4 ) node_condition(node_num)
  real ( kind = 8 ), dimension(node_num) :: node_r
  real ( kind = 8 ), dimension(node_num) :: node_u
  real ( kind = 8 ), dimension(2,node_num) :: node_xy
  integer ( kind = 4 ) quad
  real ( kind = 8 ), dimension(quad_num) :: phys_h
  real ( kind = 8 ), dimension(quad_num) :: phys_k
  real ( kind = 8 ), dimension(quad_num) :: phys_rhs
  real ( kind = 8 ) phys_xy(2,quad_num)
  real ( kind = 8 ), dimension(quad_num) :: quad_w
  real ( kind = 8 ), dimension(2,quad_num) :: quad_xy
  real ( kind = 8 ), dimension (2,3) :: t3
  integer ( kind = 4 ) test
  real ( kind = 8 ) triangle_area_2d
  real ( kind = 8 ) w(quad_num)
!
!  Initialize the arrays to zero.
!
  f(1:node_num) = 0.0D+00
  a(1:3*ib+1,1:node_num) = 0.0D+00
!
!  Get the quadrature weights and nodes.
!
  call quad_rule ( quad_num, quad_w, quad_xy )
!
!  The actual values of A and F are determined by summing up
!  contributions from all the elements.
!
  do element = 1, element_num
!
!  Make a copy of the triangle.
!
    t3(1:2,1:3) = node_xy(1:2,element_node(1:3,element))
!
!  Map the quadrature points QUAD_XY to points XY in the physical triangle.
!
    call reference_to_physical_t3 ( t3, quad_num, quad_xy, phys_xy )

    w(1:quad_num) = quad_w(1:quad_num) * abs ( triangle_area_2d ( t3 ) )

    call rhs ( quad_num, phys_xy, phys_rhs )
    call h_coef ( quad_num, phys_xy, phys_h )
    call k_coef ( quad_num, phys_xy, phys_k )
!
!  Consider a quadrature point QUAD, with coordinates (X,Y).
!
    do quad = 1, quad_num
!
!  Consider one of the basis functions, which will play the
!  role of test function in the integral.
!
!  We generate an integral for every node associated with an unknown.
!  But if a node is associated with a boundary condition, we do nothing.
!
      do test = 1, 3

        i = element_node(test,element)

        call basis_one_t3 ( t3, test, phys_xy(1:2,quad), bi, dbidx, dbidy )

        f(i) = f(i) + w(quad) * phys_rhs(quad) * bi
!
!  Consider another basis function, which is used to form the
!  value of the solution function.
!
        do basis = 1, 3

          j = element_node(basis,element)

          call basis_one_t3 ( t3, basis, phys_xy(1:2,quad), bj, dbjdx, dbjdy )

          a(i-j+2*ib+1,j) = a(i-j+2*ib+1,j) + w(quad) &
            * ( phys_h(quad) * ( dbidx * dbjdx + dbidy * dbjdy ) &
            + phys_k(quad) * bj * bi )

        end do

      end do

    end do

  end do
!
!  Apply boundary conditions.
!
  call dirichlet_apply ( node_num, node_xy, node_condition, ib, a, f )
!
!  Compute A*U.
!
  call dgb_mxv ( node_num, node_num, ib, ib, a, node_u, node_r )
!
!  Set RES = A * U - F.
!
  node_r(1:node_num) = node_r(1:node_num) - f(1:node_num)

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
subroutine s_to_i4vec ( s, n, ivec, ierror )

!*****************************************************************************80
!
!! S_TO_I4VEC reads an I4VEC from a string.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    08 October 2003
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) S, the string to be read.
!
!    Input, integer ( kind = 4 ) N, the number of values expected.
!
!    Output, integer ( kind = 4 ) IVEC(N), the values read from the string.
!
!    Output, integer ( kind = 4 ) IERROR, error flag.
!    0, no errors occurred.
!    -K, could not read data for entries -K through N.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  integer ( kind = 4 ) ierror
  integer ( kind = 4 ) ilo
  integer ( kind = 4 ) ivec(n)
  integer ( kind = 4 ) length
  character ( len = * ) s

  i = 0
  ierror = 0
  ilo = 1

  do while ( i < n )

    i = i + 1

    call s_to_i4 ( s(ilo:), ivec(i), ierror, length )

    if ( ierror /= 0 ) then
      ierror = -i
      exit
    end if

    ilo = ilo + length

  end do

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
!    '-12.73e-9.23'   -12.73 * 10.0**(-9.23)
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

  logical ch_eqi
  character c
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
  if ( iterm /= 1 .and. length+1 == nchar ) then
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
subroutine s_to_r8vec ( s, n, rvec, ierror )

!*****************************************************************************80
!
!! S_TO_R8VEC reads an R8VEC from a string.
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
!    Input, character ( len = * ) S, the string to be read.
!
!    Input, integer ( kind = 4 ) N, the number of values expected.
!
!    Output, real ( kind = 8 ) RVEC(N), the values read from the string.
!
!    Output, integer ( kind = 4 ) IERROR, error flag.
!    0, no errors occurred.
!    -K, could not read data for entries -K through N.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  integer ( kind = 4 ) ierror
  integer ( kind = 4 ) ilo
  integer ( kind = 4 ) lchar
  real ( kind = 8 ) rvec(n)
  character ( len = * ) s

  i = 0
  ierror = 0
  ilo = 1

  do while ( i < n )

    i = i + 1

    call s_to_r8 ( s(ilo:), rvec(i), ierror, lchar )

    if ( ierror /= 0 ) then
      ierror = -i
      exit
    end if

    ilo = ilo + lchar

  end do

  return
end
subroutine s_word_count ( s, nword )

!*****************************************************************************80
!
!! S_WORD_COUNT counts the number of "words" in a string.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    14 April 1999
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) S, the string to be examined.
!
!    Output, integer ( kind = 4 ) NWORD, the number of "words" in the string.
!    Words are presumed to be separated by one or more blanks.
!
  implicit none

  logical blank
  integer ( kind = 4 ) i
  integer ( kind = 4 ) lens
  integer ( kind = 4 ) nword
  character ( len = * ) s

  nword = 0
  lens = len ( s )

  if ( lens <= 0 ) then
    return
  end if

  blank = .true.

  do i = 1, lens

    if ( s(i:i) == ' ' ) then
      blank = .true.
    else if ( blank ) then
      nword = nword + 1
      blank = .false.
    end if

  end do

  return
end
subroutine solution_evaluate ( xy, t, node_u, u, dudx, dudy )

!*****************************************************************************80
!
!! SOLUTION_EVALUATE evaluates the solution at a point in an element.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    06 April 2004
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) XY(2), the point where the solution is
!    to be evaluated.
!
!    Input, real ( kind = 8 ) T(2,3), the coordinates of the vertices
!    of the triangle which contains XY.
!
!    Input, real ( kind = 8 ) NODE_U(3), the value of the solution
!    at the nodes of the triangle.
!
!    Output, real ( kind = 8 ) U, DUDX, DUDY, the solution and its X and
!    Y derivatives at XY.
!
  implicit none

  real ( kind = 8 ) b
  real ( kind = 8 ) dbdx
  real ( kind = 8 ) dbdy
  real ( kind = 8 ) dudx
  real ( kind = 8 ) dudy
  integer ( kind = 4 ) i
  real ( kind = 8 ) node_u(3)
  real ( kind = 8 ) t(2,3)
  real ( kind = 8 ) u
  real ( kind = 8 ) xy(2)

  u = 0.0D+00
  dudx = 0.0D+00
  dudy = 0.0D+00

  do i = 1, 3

    call basis_one_t3 ( t, i, xy, b, dbdx, dbdy )

    u    = u    + node_u(i) * b
    dudx = dudx + node_u(i) * dbdx
    dudy = dudy + node_u(i) * dbdy

  end do

  return
end
subroutine sort_heap_external ( n, indx, i, j, isgn )

!*****************************************************************************80
!
!! SORT_HEAP_EXTERNAL externally sorts a list of items into ascending order.
!
!  Discussion:
!
!    The actual list of data is not passed to the routine.  Hence this
!    routine may be used to sort integers, reals, numbers, names,
!    dates, shoe sizes, and so on.  After each call, the routine asks
!    the user to compare or interchange two items, until a special
!    return value signals that the sorting is completed.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    05 February 2004
!
!  Author:
!
!    Original FORTRAN77 version by Albert Nijenhuis and Herbert Wilf.
!    FORTRAN90 version by John Burkardt.
!
!  Reference:
!
!    A Nijenhuis and H Wilf,
!    Combinatorial Algorithms,
!    Academic Press, 1978, second edition,
!    ISBN 0-12-519260-6.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of items to be sorted.
!
!    Input/output, integer ( kind = 4 ) INDX, the main communication signal.
!
!    The user must set INDX to 0 before the first call.
!    Thereafter, the user should not change the value of INDX until
!    the sorting is done.
!
!    On return, if INDX is
!
!      greater than 0,
!      * interchange items I and J;
!      * call again.
!
!      less than 0,
!      * compare items I and J;
!      * set ISGN = -1 if I < J, ISGN = +1 if J < I;
!      * call again.
!
!      equal to 0, the sorting is done.
!
!    Output, integer ( kind = 4 ) I, J, the indices of two items.
!    On return with INDX positive, elements I and J should be interchanged.
!    On return with INDX negative, elements I and J should be compared, and
!    the result reported in ISGN on the next call.
!
!    Input, integer ( kind = 4 ) ISGN, results of comparison of elements
!    I and J. (Used only when the previous call returned INDX less than 0).
!    ISGN <= 0 means I is less than or equal to J;
!    0 <= ISGN means I is greater than or equal to J.
!
  implicit none

  integer ( kind = 4 ) i
  integer ( kind = 4 ), save :: i_save = 0
  integer ( kind = 4 ) indx
  integer ( kind = 4 ) isgn
  integer ( kind = 4 ) j
  integer ( kind = 4 ), save :: j_save = 0
  integer ( kind = 4 ), save :: k = 0
  integer ( kind = 4 ), save :: k1 = 0
  integer ( kind = 4 ) n
  integer ( kind = 4 ), save :: n1 = 0
!
!  INDX = 0: This is the first call.
!
  if ( indx == 0 ) then

    i_save = 0
    j_save = 0
    k = n / 2
    k1 = k
    n1 = n
!
!  INDX < 0: The user is returning the results of a comparison.
!
  else if ( indx < 0 ) then

    if ( indx == -2 ) then

      if ( isgn < 0 ) then
        i_save = i_save + 1
      end if

      j_save = k1
      k1 = i_save
      indx = -1
      i = i_save
      j = j_save
      return

    end if

    if ( 0 < isgn ) then
      indx = 2
      i = i_save
      j = j_save
      return
    end if

    if ( k <= 1 ) then

      if ( n1 == 1 ) then
        i_save = 0
        j_save = 0
        indx = 0
      else
        i_save = n1
        n1 = n1 - 1
        j_save = 1
        indx = 1
      end if

      i = i_save
      j = j_save
      return

    end if

    k = k - 1
    k1 = k
!
!  0 < INDX, the user was asked to make an interchange.
!
  else if ( indx == 1 ) then

    k1 = k

  end if

  do

    i_save = 2 * k1

    if ( i_save == n1 ) then
      j_save = k1
      k1 = i_save
      indx = -1
      i = i_save
      j = j_save
      return
    else if ( i_save <= n1 ) then
      j_save = i_save + 1
      indx = -2
      i = i_save
      j = j_save
      return
    end if

    if ( k <= 1 ) then
      exit
    end if

    k = k - 1
    k1 = k

  end do

  if ( n1 == 1 ) then
    i_save = 0
    j_save = 0
    indx = 0
    i = i_save
    j = j_save
  else
    i_save = n1
    n1 = n1 - 1
    j_save = 1
    indx = 1
    i = i_save
    j = j_save
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
!    06 August 2005
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
function triangle_area_2d ( t )

!*****************************************************************************80
!
!! TRIANGLE_AREA_2D computes the area of a triangle in 2D.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    17 December 2004
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) T(2,3), the triangle vertices.
!
!    Output, real ( kind = 8 ) TRIANGLE_AREA_2D, the absolute area of
!    the triangle.
!
  implicit none

  integer ( kind = 4 ), parameter :: dim_num = 2

  real ( kind = 8 ) t(dim_num,3)
  real ( kind = 8 ) triangle_area_2d

  triangle_area_2d = 0.5D+00 * abs ( &
      t(1,1) * ( t(2,2) - t(2,3) ) &
    + t(1,2) * ( t(2,3) - t(2,1) ) &
    + t(1,3) * ( t(2,1) - t(2,2) ) )

  return
end
subroutine triangulation_order3_boundary_node ( node_num, &
  element_num, element_node, node_boundary )

!*****************************************************************************80
!
!! TRIANGULATION_ORDER3_BOUNDARY_NODE indicates which nodes are on the boundary.
!
!  Discussion:
!
!    This routine is given a triangulation, an abstract list of sets of
!    of nodes.  It is assumed that the nodes in each triangle are listed
!    in a counterclockwise order, although the routine should work
!    if the nodes are consistently listed in a clockwise order as well.
!
!    It is assumed that each edge of the triangulation is either
!    * an INTERIOR edge, which is listed twice, once with positive
!      orientation and once with negative orientation, or;
!    * a BOUNDARY edge, which will occur only once.
!
!    This routine should work even if the region has holes - as long
!    as the boundary of the hole comprises more than 3 edges!
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    07 June 2005
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) NODE_NUM, the number of nodes.
!
!    Input, integer ( kind = 4 ) ELEMENT_NUM, the number of elements.
!
!    Input, integer ( kind = 4 ) ELEMENT_NODE(3,ELEMENT_NUM),
!    the nodes that make up the triangular elements.  These should be listed
!    in counterclockwise order.
!
!    Output, logical NODE_BOUNDARY(NODE_NUM), is TRUE if the node
!    is on a boundary edge.
!
  implicit none

  integer ( kind = 4 ) node_num
  integer ( kind = 4 ) element_num

  integer ( kind = 4 ) e1(3*element_num)
  integer ( kind = 4 ) e2(3*element_num)
  integer ( kind = 4 ) edge(2,3*element_num)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) m
  integer ( kind = 4 ) n
  logical node_boundary(node_num)
  integer ( kind = 4 ) element_node(3,element_num)

  m = 2
  n = 3 * element_num
!
!  Set up the edge array.
!
  edge(1:2,               1:  element_num) = element_node(1:2,1:element_num)
  edge(1:2,  element_num+1:2*element_num) = element_node(2:3,1:element_num)
  edge(1,  2*element_num+1:3*element_num) = element_node(3,  1:element_num)
  edge(2,  2*element_num+1:3*element_num) = element_node(1,  1:element_num)
!
!  In each column, force the smaller entry to appear first.
!
  e1(1:n) = minval ( edge(1:2,1:n), dim = 1 )
  e2(1:n) = maxval ( edge(1:2,1:n), dim = 1 )

  edge(1,1:n) = e1(1:n)
  edge(2,1:n) = e2(1:n)
!
!  Ascending sort the column array.
!
  call i4col_sort_a ( m, n, edge )
!
!  Records which appear twice are internal edges and can be ignored.
!
  node_boundary(1:node_num) = .false.

  i = 0

  do while ( i < 3 * element_num )

    i = i + 1

    if ( i == 3 * element_num ) then
      node_boundary(edge(1:m,i)) = .true.
    else if ( all ( edge(1:m,i) == edge(1:m,i+1) ) ) then
      i = i + 1
    else
      node_boundary(edge(1:m,i)) = .true.
    end if

  end do

  return
end
subroutine triangulation_order3_plot ( filename, node_num, node_xy, &
  element_num, element_node, node_show, element_show )

!*****************************************************************************80
!
!! TRIANGULATION_ORDER3_PLOT plots a 3-node triangulation of a pointset.
!
!  Discussion:
!
!    The triangulation is most usually a Delaunay triangulation,
!    but this is not necessary.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    27 September 2006
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) FILE_NAME, the name of the output file.
!
!    Input, integer ( kind = 4 ) NODE_NUM, the number of points.
!
!    Input, real ( kind = 8 ) NODE_XY(2,NODE_NUM), the nodes.
!
!    Input, integer ( kind = 4 ) ELEMENT_NUM, the number of elements.
!
!    Input, integer ( kind = 4 ) ELEMENT_NODE(3,ELEMENT_NUM), lists,
!    for each element, the indices of the points that form the vertices
!    of the element.
!
!    Input, integer ( kind = 4 ) NODE_SHOW,
!    0, do not show nodes;
!    1, show nodes;
!    2, show nodes and label them.
!
!    Input, integer ( kind = 4 ) ELEMENT_SHOW,
!    0, do not show elements;
!    1, show elements;
!    2, show elements and label them.
!
  implicit none

  integer ( kind = 4 ) node_num
  integer ( kind = 4 ) element_num

  real ( kind = 8 ) ave_x
  real ( kind = 8 ) ave_y
  integer ( kind = 4 ) :: circle_size
  integer ( kind = 4 ) delta
  integer ( kind = 4 ) e
  character ( len = * ) filename
  integer ( kind = 4 ) file_status
  integer ( kind = 4 ) file_unit
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i4_wrap
  integer ( kind = 4 ) node
  integer ( kind = 4 ) node_show
  real ( kind = 8 ) node_xy(2,node_num)
  character ( len = 40 ) string
  integer ( kind = 4 ) triangle
  integer ( kind = 4 ) element_node(3,element_num)
  integer ( kind = 4 ) element_show
  real ( kind = 8 ) x_max
  real ( kind = 8 ) x_min
  integer ( kind = 4 ) x_ps
  integer ( kind = 4 ) :: x_ps_max = 576
  integer ( kind = 4 ) :: x_ps_max_clip = 594
  integer ( kind = 4 ) :: x_ps_min = 36
  integer ( kind = 4 ) :: x_ps_min_clip = 18
  real ( kind = 8 ) x_scale
  real ( kind = 8 ) y_max
  real ( kind = 8 ) y_min
  integer ( kind = 4 ) y_ps
  integer ( kind = 4 ) :: y_ps_max = 666
  integer ( kind = 4 ) :: y_ps_max_clip = 684
  integer ( kind = 4 ) :: y_ps_min = 126
  integer ( kind = 4 ) :: y_ps_min_clip = 108
  real ( kind = 8 ) y_scale
!
!  We need to do some figuring here, so that we can determine
!  the range of the data, and hence the height and width
!  of the piece of paper.
!
  x_max = maxval ( node_xy(1,1:node_num) )
  x_min = minval ( node_xy(1,1:node_num) )
  x_scale = x_max - x_min

  x_max = x_max + 0.05D+00 * x_scale
  x_min = x_min - 0.05D+00 * x_scale
  x_scale = x_max - x_min

  y_max = maxval ( node_xy(2,1:node_num) )
  y_min = minval ( node_xy(2,1:node_num) )
  y_scale = y_max - y_min

  y_max = y_max + 0.05D+00 * y_scale
  y_min = y_min - 0.05D+00 * y_scale
  y_scale = y_max - y_min

  if ( x_scale < y_scale ) then

    delta = nint ( real ( x_ps_max - x_ps_min, kind = 8 ) &
      * ( y_scale - x_scale ) / ( 2.0D+00 * y_scale ) )

    x_ps_max = x_ps_max - delta
    x_ps_min = x_ps_min + delta

    x_ps_max_clip = x_ps_max_clip - delta
    x_ps_min_clip = x_ps_min_clip + delta

    x_scale = y_scale

  else if ( y_scale < x_scale ) then

    delta = nint ( real ( y_ps_max - y_ps_min, kind = 8 ) &
      * ( x_scale - y_scale ) / ( 2.0D+00 * x_scale ) )

    y_ps_max      = y_ps_max - delta
    y_ps_min      = y_ps_min + delta

    y_ps_max_clip = y_ps_max_clip - delta
    y_ps_min_clip = y_ps_min_clip + delta

    y_scale = x_scale

  end if

  call get_unit ( file_unit )

  open ( unit = file_unit, file = filename, status = 'replace', &
    iostat = file_status )

  if ( file_status /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'TRIANGULATION_ORDER3_PLOT - Fatal error!'
    write ( *, '(a)' ) '  Can not open output file.'
    return
  end if

  write ( file_unit, '(a)' ) '%!PS-Adobe-3.0 EPSF-3.0'
  write ( file_unit, '(a)' ) '%%Creator: triangulation_order3_plot.f90'
  write ( file_unit, '(a)' ) '%%Title: ' // trim ( filename )
  write ( file_unit, '(a)' ) '%%Pages: 1'
  write ( file_unit, '(a,i3,2x,i3,2x,i3,2x,i3)' ) '%%BoundingBox: ', &
    x_ps_min, y_ps_min, x_ps_max, y_ps_max
  write ( file_unit, '(a)' ) '%%Document-Fonts: Times-Roman'
  write ( file_unit, '(a)' ) '%%LanguageLevel: 1'
  write ( file_unit, '(a)' ) '%%EndComments'
  write ( file_unit, '(a)' ) '%%BeginProlog'
  write ( file_unit, '(a)' ) '/inch {72 mul} def'
  write ( file_unit, '(a)' ) '%%EndProlog'
  write ( file_unit, '(a)' ) '%%Page: 1 1'
  write ( file_unit, '(a)' ) 'save'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Set the RGB line color to very light gray.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '0.900  0.900  0.900 setrgbcolor'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Draw a gray border around the page.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) 'newpath'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_min, y_ps_min, ' moveto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_max, y_ps_min, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_max, y_ps_max, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_min, y_ps_max, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', x_ps_min, y_ps_min, ' lineto'
  write ( file_unit, '(a)' ) 'stroke'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Set the RGB color to black.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '0.000  0.000  0.000 setrgbcolor'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Set the font and its size.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '/Times-Roman findfont'
  write ( file_unit, '(a)' ) '0.50 inch scalefont'
  write ( file_unit, '(a)' ) 'setfont'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Print a title.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  210  702  moveto'
  write ( file_unit, '(a)' ) '%  (Triangulation)  show'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  Define a clipping polygon.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) 'newpath'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_min_clip, y_ps_min_clip, ' moveto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_max_clip, y_ps_min_clip, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_max_clip, y_ps_max_clip, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_min_clip, y_ps_max_clip, ' lineto'
  write ( file_unit, '(a,i3,2x,i3,2x,a)' ) '  ', &
    x_ps_min_clip, y_ps_min_clip, ' lineto'
  write ( file_unit, '(a)' ) 'clip newpath'
!
!  Draw the nodes.
!
  if ( node_num <= 200 ) then
    circle_size = 5
  else if ( node_num <= 500 ) then
    circle_size = 4
  else if ( node_num <= 1000 ) then
    circle_size = 3
  else if ( node_num <= 5000 ) then
    circle_size = 2
  else
    circle_size = 1
  end if

  if ( 1 <= node_show ) then
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Draw filled dots at the nodes.'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Set the RGB color to blue.'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '0.000  0.150  0.750 setrgbcolor'
    write ( file_unit, '(a)' ) '%'

    do node = 1, node_num

      x_ps = int ( &
        ( ( x_max - node_xy(1,node)         ) * real ( x_ps_min, kind = 8 )   &
        + (         node_xy(1,node) - x_min ) * real ( x_ps_max, kind = 8 ) ) &
        / ( x_max                   - x_min ) )

      y_ps = int ( &
        ( ( y_max - node_xy(2,node)         ) * real ( y_ps_min, kind = 8 )   &
        + (         node_xy(2,node) - y_min ) * real ( y_ps_max, kind = 8 ) ) &
        / ( y_max                   - y_min ) )

      write ( file_unit, '(a,i4,2x,i4,2x,i4,2x,a)' ) 'newpath ', x_ps, y_ps, &
        circle_size, '0 360 arc closepath fill'

    end do

  end if
!
!  Label the nodes.
!
  if ( 2 <= node_show ) then

    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Label the nodes:'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Set the RGB color to darker blue.'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '0.000  0.250  0.850 setrgbcolor'
    write ( file_unit, '(a)' ) '/Times-Roman findfont'
    write ( file_unit, '(a)' ) '0.20 inch scalefont'
    write ( file_unit, '(a)' ) 'setfont'
    write ( file_unit, '(a)' ) '%'

    do node = 1, node_num

      x_ps = int ( &
        ( ( x_max - node_xy(1,node)         ) * real ( x_ps_min, kind = 8 )   &
        + (       + node_xy(1,node) - x_min ) * real ( x_ps_max, kind = 8 ) ) &
        / ( x_max                   - x_min ) )

      y_ps = int ( &
        ( ( y_max - node_xy(2,node)         ) * real ( y_ps_min, kind = 8 )   &
        + (         node_xy(2,node) - y_min ) * real ( y_ps_max, kind = 8 ) ) &
        / ( y_max                   - y_min ) )

      write ( string, '(i4)' ) node
      string = adjustl ( string )

      write ( file_unit, '(i4,2x,i4,a)' ) x_ps, y_ps+5, &
        ' moveto (' // trim ( string ) // ') show'

    end do

  end if
!
!  Draw the triangles.
!
  if ( 1 <= element_show ) then
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Set the RGB color to red.'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '0.900  0.200  0.100 setrgbcolor'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Draw the triangles.'
    write ( file_unit, '(a)' ) '%'

    do triangle = 1, element_num

      write ( file_unit, '(a)' ) 'newpath'

      do i = 1, 4

        e = i4_wrap ( i, 1, 3 )

        node = element_node(e,triangle)

        x_ps = int ( &
          ( ( x_max - node_xy(1,node)         ) &
          * real ( x_ps_min, kind = 8 )   &
          + (         node_xy(1,node) - x_min ) &
          * real ( x_ps_max, kind = 8 ) ) &
          / ( x_max                   - x_min ) )

        y_ps = int ( &
          ( ( y_max - node_xy(2,node)         ) &
          * real ( y_ps_min, kind = 8 )   &
          + (         node_xy(2,node) - y_min ) &
          * real ( y_ps_max, kind = 8 ) ) &
          / ( y_max                   - y_min ) )

        if ( i == 1 ) then
          write ( file_unit, '(i3,2x,i3,2x,a)' ) x_ps, y_ps, ' moveto'
        else
          write ( file_unit, '(i3,2x,i3,2x,a)' ) x_ps, y_ps, ' lineto'
        end if

      end do

      write ( file_unit, '(a)' ) 'stroke'

    end do

  end if
!
!  Label the triangles.
!
  if ( 2 <= element_show ) then

    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Label the triangles:'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '%  Set the RGB color to darker red.'
    write ( file_unit, '(a)' ) '%'
    write ( file_unit, '(a)' ) '0.950  0.250  0.150 setrgbcolor'
    write ( file_unit, '(a)' ) '/Times-Roman findfont'
    write ( file_unit, '(a)' ) '0.20 inch scalefont'
    write ( file_unit, '(a)' ) 'setfont'
    write ( file_unit, '(a)' ) '%'

    do triangle = 1, element_num

      ave_x = 0.0D+00
      ave_y = 0.0D+00

      do i = 1, 3

        node = element_node(i,triangle)

        ave_x = ave_x + node_xy(1,node)
        ave_y = ave_y + node_xy(2,node)

      end do

      ave_x = ave_x / 3.0D+00
      ave_y = ave_y / 3.0D+00

      x_ps = int ( &
        ( ( x_max - ave_x         ) * real ( x_ps_min, kind = 8 )   &
        + (       + ave_x - x_min ) * real ( x_ps_max, kind = 8 ) ) &
        / ( x_max         - x_min ) )

      y_ps = int ( &
        ( ( y_max - ave_y         ) * real ( y_ps_min, kind = 8 )   &
        + (         ave_y - y_min ) * real ( y_ps_max, kind = 8 ) ) &
        / ( y_max         - y_min ) )

      write ( string, '(i4)' ) triangle
      string = adjustl ( string )

      write ( file_unit, '(i4,2x,i4,a)' ) x_ps, y_ps, ' moveto (' &
        // trim ( string ) // ') show'

    end do

  end if

  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) 'restore  showpage'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%  End of page.'
  write ( file_unit, '(a)' ) '%'
  write ( file_unit, '(a)' ) '%%Trailer'
  write ( file_unit, '(a)' ) '%%EOF'
  close ( unit = file_unit )

  return
end
