program main

!*****************************************************************************80
!
!! MAIN is the main program for PDFLIB_PRB.
!
!  Discussion:
!
!    PDFLIB_PRB tests the PDFLIB library.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    03 August 2015
!
!  Author:
!
!    John Burkardt
!
  implicit none

  call timestamp ( )
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'PDFLIB_PRB'
  write ( *, '(a)' ) '  FORTRAN90 version'
  write ( *, '(a)' ) '  Test the PDFLIB library.'
!
!  Initialize the random number generator package.
!
  call r8vec_multinormal_pdf_test ( )

  call test01 ( )
  call test03 ( )
!
!  Terminate.
!
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'PDFLIB_PRB'
  write ( *, '(a)' ) '  Normal end of execution.'
  write ( *, '(a)' ) ' '
  call timestamp ( )

  stop
end
subroutine test01 ( )

!*****************************************************************************80
!
!! TEST01 tests R8PO_FA.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    04 August 2015
!
!  Author:
!
!    John Burkardt
!
  implicit none

  real ( kind = 8 ), allocatable :: a(:,:)
  real ( kind = 8 ) diff
  integer ( kind = 4 ) i
  integer ( kind = 4 ) j
  integer ( kind = 4 ), parameter :: n = 5
  real ( kind = 8 ), allocatable :: r1(:,:)
  real ( kind = 8 ), allocatable :: r2(:,:)
  real ( kind = 8 ) r8_uniform_01_sample
  real ( kind = 8 ) r8mat_norm_fro_affine

  call initialize ( )

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'TEST01'
  write ( *, '(a)' ) '  R8PO_FA computes the Cholesky factor R of a'
  write ( *, '(a)' ) '  positive definite matrix A, so that A = R'' * R.'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '  Start with random R1;'
  write ( *, '(a)' ) '  Compute A = R1'' * R1.'
  write ( *, '(a)' ) '  Call R8PO_FA and see if you recover R2 = R1.'
!
!  Generate a random upper triangular matrix with positive diagonal.
!
  allocate ( r1(1:n,1:n) )

  r1(1:n,1:n) = 0.0D+00
  do j = 1, n
    do i = 1, j
      r1(i,j) = r8_uniform_01_sample ( )
    end do
  end do

  call r8ge_print ( n, n, r1, '  R1:' )
!
!  Compute a positive definite symmetric matrix A.
!
  allocate ( a(1:n,1:n) )
  a = matmul ( transpose ( r1 ), r1 )

  call r8ge_print ( n, n, a, '  A:' )

  allocate ( r2(1:n,1:n) )
  call r8po_fa ( n, a, r2 )

  diff = r8mat_norm_fro_affine ( n, n, r1, r2 )

  write ( *, '(a)' ) ' '
  write ( *, '(a,g14.6)' ) '  Frobenius difference between R1 and R2 = ', diff

  deallocate ( a )
  deallocate ( r1 )
  deallocate ( r2 )

  return
end
subroutine r8vec_multinormal_pdf_test ( )

!*****************************************************************************80
!
!! R8VEC_MULTINORMAL_PDF_TEST tests R8VEC_MULTINORMAL_PDF.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    03 August 2015
!
!  Author:
!
!    John Burkardt
!
  implicit none

  real ( kind = 8 ), allocatable :: c(:,:)
  real ( kind = 8 ), allocatable :: c_ge(:,:)
  real ( kind = 8 ) c_det
  real ( kind = 8 ), allocatable :: c_inv(:,:)
  real ( kind = 8 ), allocatable :: ciy(:)
  real ( kind = 8 ) eps
  integer ( kind = 4 ) i
  integer ( kind = 4 ) j
  real ( kind = 8 ), allocatable :: mu(:)
  integer ( kind = 4 ), parameter :: n = 5
  real ( kind = 8 ) pdf1
  real ( kind = 8 ) pdf2
  real ( kind = 8 ), parameter :: r8_pi = 3.141592653589793D+00
  real ( kind = 8 ), allocatable :: r1(:,:)
  real ( kind = 8 ), allocatable :: r2(:,:)
  real ( kind = 8 ) r8_normal_01_sample
  real ( kind = 8 ) r8_uniform_01_sample
  real ( kind = 8 ) r8vec_multinormal_pdf
  real ( kind = 8 ), allocatable :: x(:)
  real ( kind = 8 ) xcx
  real ( kind = 8 ), allocatable :: y(:)

  call initialize ( )

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'R8VEC_MULTINORMAL_PDF_TEST'
  write ( *, '(a)' ) '  R8VEC_MULTINORMAL_PDF evaluates the PDF for the'
  write ( *, '(a)' ) '  multinormal distribution.'
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '  The covariance matrix is C.'
  write ( *, '(a)' ) '  The definition uses the inverse of C;'
  write ( *, '(a)' ) '  R8VEC_MULTINORMAL_PDF uses the Cholesky factor.'
  write ( *, '(a)' ) '  Verify that the algorithms are equivalent.'
!
!  Generate a random upper triangular matrix with positive diagonal.
!
  allocate ( r1(1:n,1:n) )

  call r8ut_zeros ( n, n, r1 )

  do j = 1, n
    do i = 1, j
      r1(i,j) = r8_uniform_01_sample ( )
    end do
  end do

  call r8ut_print ( n, n, r1, '  R1:' )
!
!  Compute a positive definite symmetric covariance matrix C.
!
  allocate ( c_ge(1:n,1:n) )
  c_ge = matmul ( transpose ( r1 ), r1 )

  call r8ge_print ( n, n, c_ge, '  C:' )
!
!  Convert to R8PO format.
!
  allocate ( c(1:n,1:n) )
  call r8ge_to_r8po ( n, c_ge, c )
!
!  Compute the Cholesky factor R.
!
  allocate ( r2(1:n,1:n) )
  call r8po_fa ( n, c, r2 )

  call r8ut_print ( n, n, r2, '  R2:' )
!
!  Compute the determinant of C.
!
  call r8po_det ( n, r2, c_det )
  write ( *, '(a)' ) ' '
  write ( *, '(a,g14.6)' ) '  Determinant of C = ', c_det
!
!  Compute the inverse of C.
!
  allocate ( c_inv(1:n,1:n) )
  call r8po_inverse ( n, r2, c_inv )
  call r8po_print ( n, c_inv, '  C_INV:' )
!
!  Compute a random set of means.
!
  allocate ( mu(1:n) )
  do i = 1, n
    mu(i) = r8_normal_01_sample ( )
  end do
  call r8vec_print ( n, mu, '  MU:' )
!
!  Compute X as small variations from MU.
!
  allocate ( x(1:n) )
  do i = 1, n
    eps = 0.01D+00 * r8_normal_01_sample ( )
    x(i) = ( 1.0D+00 + eps ) * mu(i)
  end do
  call r8vec_print ( n, x, '  X:' )
!
!  Compute PDF1 from the function.
!
  pdf1 = r8vec_multinormal_pdf ( n, mu, r2, c_det, x )
!
!  Compute PDF2 from the definition.
!
  allocate ( y(1:n) )
  do i = 1, n
    y(i) = x(i) - mu(i)
  end do

  allocate ( ciy(1:n) )
  call r8po_mv ( n, c_inv, y, ciy )
  xcx = dot_product ( y, ciy )

  pdf2 = 1.0D+00 / sqrt ( ( 2.0D+00 * r8_pi ) ** n ) &
    * 1.0D+00 / sqrt ( c_det ) &
    * exp ( - 0.5D+00 * xcx )

  write ( *, '(a)' ) ' '
  write ( *, '(a,g14.6)' ) '  PDF1 = ', pdf1
  write ( *, '(a,g14.6)' ) '  PDF2 = ', pdf2
!
!  Free memory.
!
  deallocate ( c )
  deallocate ( c_ge )
  deallocate ( c_inv )
  deallocate ( ciy )
  deallocate ( mu )
  deallocate ( r1 )
  deallocate ( r2 )
  deallocate ( x )
  deallocate ( y )

  return
end
subroutine test03 ( )

!*****************************************************************************80
!
!! TEST03 calls R8_CHI_SAMPLE.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    04 August 2015
!
!  Author:
!
!    John Burkardt
!
  implicit none

  real ( kind = 8 ) df
  integer ( kind = 4 ) g
  integer ( kind = 4 ) i
  real ( kind = 8 ) r8_chi_sample
  real ( kind = 8 ) r8_uniform_01_sample
  real ( kind = 8 ) u

  call initialize ( )

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'TEST03'
  write ( *, '(a)' ) '  R8_CHI_SAMPLE ( DF ) samples the Chi distribution with'
  write ( *, '(a)' ) '  DF degrees of freedom.'
!
!  Set the current generator index to #2.
!
  g = 2
  call cgn_set ( g )
  write ( *, '(a)' ) ' '
  write ( *, '(a,i2)' ) '  Current generator index = ', g
!
!  Repeatedly call R8_CHI_SAMPLE ( DF ).
!
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) '   I       DF       R8_CHI_SAMPLE ( DF )'
  write ( *, '(a)' ) ' '

  do i = 1, 10
    df = 5.0D+00 * r8_uniform_01_sample ( ) + 1.0D+00
    u = r8_chi_sample ( df )
    write ( *, '(2x,i2,2x,g14.6,2x,g14.6)' ) i, df, u
  end do

  return
end
