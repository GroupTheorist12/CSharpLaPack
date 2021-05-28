module lapack_module
    use, intrinsic :: iso_c_binding !allow c type bindings and function names
    implicit none !types must be declared
contains

    !subroutine dgbtrf        (        integer         M,
    !    integer         N,
    !    integer         KL,
    !    integer         KU,
    !    double precision, dimension( ldab, * )         AB,
    !    integer         LDAB,
    !    integer, dimension( * )         IPIV,
    !    integer         INFO
    !    )

    subroutine dgbtrf_dotnet(n, ml, mu, lda, a, b, info) bind(c, name='dgbtrf_dotnet')
        implicit none !types must be declared

        integer(c_int), intent(in) :: n

        integer(c_int), intent(in) :: ml

        integer(c_int), intent(in) :: mu
        integer(c_int), intent(inout) :: lda

        real(c_double), intent(inout), dimension(lda, n) :: a
        real(c_double), intent(inout), dimension(n) :: b

        integer(c_int), intent(inout) :: info

        integer i
        integer ipiv(n)
        integer j
        integer m

        b(1) = 1.0D+00
        do i = 2, n - 1
            b(i) = 0.0D+00
        end do
        b(n) = 1.0D+00
        !
        !  Zero out the matrix.
        !
        do i = 1, lda
            do j = 1, n
                a(i, j) = 0.0D+00
            end do
        end do

        m = ml + mu + 1
        !
        !  Superdiagonal,
        !  Diagonal,
        !  Subdiagonal.
        !
        do j = 2, n
            a(m - 1, j) = -1.0D+00
        end do

        do j = 1, n
            a(m, j) = 2.0D+00
        end do

        do j = 1, n - 1
            a(m + 1, j) = -1.0D+00
        end do
        !
        !  Factor the matrix.
        !

        call dgbtrf(n, n, ml, mu, a, lda, ipiv, info)

        !
        !  Solve the linear system.
        !
        call dgbtrs('n', n, ml, mu, 1, a, lda, ipiv, b, n, info)

    end subroutine dgbtrf_dotnet

    subroutine dgbtrf_dotnet_test() bind(c, name='dgbtrf_dotnet_test')
        implicit none !types must be declared

        integer n
        integer ml
        integer mu
        integer lda

        parameter(n=25)
        parameter(ml=1)
        parameter(mu=1)
        parameter(lda=2*ml + mu + 1)

        double precision a(lda, n)
        double precision b(n)
        integer i
        integer info
        integer ipiv(n)
        integer j
        integer m

        write (*, '(a)') ' '
        write (*, '(a)') 'TEST01'
        write (*, '(a)') '  For a double precision real matrix (D)'
        write (*, '(a)') '  in general band storage mode (GB):'
        write (*, '(a)') ' '
        write (*, '(a)') '  DGBTRF factors a general band matrix.'
        write (*, '(a)') '  DGBTRS solves a factored system.'
        write (*, '(a)') ' '

        b(1) = 1.0D+00
        do i = 2, n - 1
            b(i) = 0.0D+00
        end do
        b(n) = 1.0D+00
        !
        !  Zero out the matrix.
        !
        do i = 1, lda
            do j = 1, n
                a(i, j) = 0.0D+00
            end do
        end do

        m = ml + mu + 1
        !
        !  Superdiagonal,
        !  Diagonal,
        !  Subdiagonal.
        !
        do j = 2, n
            a(m - 1, j) = -1.0D+00
        end do

        do j = 1, n
            a(m, j) = 2.0D+00
        end do

        do j = 1, n - 1
            a(m + 1, j) = -1.0D+00
        end do
        !
        !  Factor the matrix.
        !
        write (*, '(a)') ' '
        write (*, '(a,i8)') '  Bandwidth is ', m
        write (*, '(a)') ' '

        call dgbtrf(n, n, ml, mu, a, lda, ipiv, info)

        if (info .ne. 0) then
            write (*, '(a)') ' '
            write (*, '(a)') 'TEST01'
            write (*, '(a,i8)') '  Factorization failed, INFO = ', info
            return
        end if
        !
        !  Solve the linear system.
        !
        call dgbtrs('n', n, ml, mu, 1, a, lda, ipiv, b, n, info)

        if (info .ne. 0) then
            write (*, '(a)') ' '
            write (*, '(a)') 'TEST01'
            write (*, '(a,i8)') '  Solution failed, INFO = ', info
            return
        end if

        call r8vec_print_some(n, b, 5, &
                              '  Partial solution (all should be 1)')

    end subroutine dgbtrf_dotnet_test

    subroutine r8vec_print_some(n, a, max_print, title)

        implicit none

        integer n

        double precision a(n)
        integer i
        integer max_print
        character*(*) title

        if (max_print .le. 0) then
            return
        end if

        if (n .le. 0) then
            return
        end if

        write (*, '(a)') ' '
        write (*, '(a)') title
        write (*, '(a)') ' '

        if (n .le. max_print) then

            do i = 1, n
                write (*, '(2x,i8,2x,g14.6)') i, a(i)
            end do

        else if (3 .le. max_print) then

            do i = 1, max_print - 2
                write (*, '(2x,i8,2x,g14.6)') i, a(i)
            end do
            write (*, '(a)') '  ......  ..............'
            i = n
            write (*, '(2x,i8,2x,g14.6)') i, a(i)

        else

            do i = 1, max_print - 1
                write (*, '(2x,i8,2x,g14.6)') i, a(i)
            end do
            i = max_print
            write (*, '(2x,i8,2x,g14.6,2x,a)') &
                i, a(i), '...more entries...'

        end if

        return
    end subroutine r8vec_print_some

    subroutine r8mat_print(m, n, a, title)
        implicit none

        integer m
        integer n

        double precision a(m, n)
        character*(*) title

        call r8mat_print_some(m, n, a, 1, 1, m, n, title)

        return
    end subroutine r8mat_print

    subroutine r8mat_print_some(m, n, a, ilo, jlo, ihi, jhi, title)

        implicit none

        integer incx
        integer m
        integer n

        parameter(incx=5)

        double precision a(m, n)
        character(len=14) ctemp(incx)
        integer i
        integer i2hi
        integer i2lo
        integer ihi
        integer ilo
        integer inc
        integer j
        integer j2
        integer j2hi
        integer j2lo
        integer jhi
        integer jlo
        character*(*) title

        write (*, '(a)') ' '
        write (*, '(a)') title

        do j2lo = max(jlo, 1), min(jhi, n), incx

            j2hi = j2lo + incx - 1
            j2hi = min(j2hi, n)
            j2hi = min(j2hi, jhi)

            inc = j2hi + 1 - j2lo

            write (*, '(a)') ' '

            do j = j2lo, j2hi
                j2 = j + 1 - j2lo
                write (ctemp(j2), '(i7,7x)') j
            end do

            write (*, '(''  Col   '',5a14)') (ctemp(j), j=1, inc)
            write (*, '(a)') '  Row'
            write (*, '(a)') ' '

            i2lo = max(ilo, 1)
            i2hi = min(ihi, m)

            do i = i2lo, i2hi

                do j2 = 1, inc

                    j = j2lo - 1 + j2

                    if (a(i, j) .eq. dble(int(a(i, j)))) then
                        write (ctemp(j2), '(f8.0,6x)') a(i, j)
                    else
                        write (ctemp(j2), '(g14.6)') a(i, j)
                    end if

                end do

                write (*, '(i5,1x,5a14)') i, (ctemp(j), j=1, inc)

            end do

        end do

        write (*, '(a)') ' '

        return
    end subroutine r8mat_print_some

    subroutine sgesv_dotnet(a, b, cols, rows, rc) bind(c, name='sgesv_dotnet')
        implicit none
        external :: sgesv
        real(c_float), intent(in) :: a(cols, rows)  ! Matrix A.
        real(c_float), intent(inout) :: b(cols)     ! Vector b/x.
        integer(c_int), intent(in)  :: cols       ! columns.
        integer(c_int), intent(in)  :: rows       ! rows.
        integer(c_int), intent(inout)  :: rc       ! Return code.

        real     :: pivot(cols) ! Pivot indices (list of swap operations).

        call sgesv(cols, 1, a, rows, pivot, b, cols, rc)
    end subroutine sgesv_dotnet

    subroutine dgetri_dotnet(a, n, info) bind(c, name='dgetri_dotnet')
        implicit none
        external :: dgetrf
        external :: dgetri

        real(c_double), intent(in) :: a(n, n)  ! Matrix A.
        integer(c_int), intent(in)  :: n       ! columns and rows of square matrix
        integer(c_int), intent(inout)  :: info       ! Return info.

        integer :: lda
        integer :: lwork
        integer :: ipiv(n)
        double precision :: work(n)

        lda = n
        lwork = n

        call dgetrf(n, n, a, lda, ipiv, info)

        if (info .ne. 0) then
            write (*, '(a)') ' '
            write (*, '(a,i8)') '  DGETRF returned INFO = ', info
            write (*, '(a)') '  The matrix is numerically singular.'
            return
        end if

        call dgetri(n, a, lda, ipiv, work, lwork, info)

        if (info .ne. 0) then
            write (*, '(a)') ' '
            write (*, '(a)') '  The inversion procedure failedc'
            write (*, '(a,i8)') '  INFO = ', info
            return
        end if
    end subroutine dgetri_dotnet

    subroutine dgetri_dotnet_test() bind(c, name='dgetri_dotnet_test')
        implicit none

        integer n
        integer lda
        integer lwork

        parameter(n=3)
        parameter(lda=n)
        parameter(lwork=n)

        double precision a(lda, n)
        integer info
        integer ipiv(n)
        double precision work(lwork)

        write (*, '(a)') ' '
        write (*, '(a)') 'TEST05'
        write (*, '(a)') '  For a double precision real matrix (D)'
        write (*, '(a)') '  in general storage mode (GE):'
        write (*, '(a)') ' '
        write (*, '(a)') '  DGETRF factors a general matrix;'
        write (*, '(a)') '  DGETRI computes the inverse.'
        a(1, 1) = 1.0D+00
        a(1, 2) = 2.0D+00
        a(1, 3) = 3.0D+00

        a(2, 1) = 4.0D+00
        a(2, 2) = 5.0D+00
        a(2, 3) = 6.0D+00

        a(3, 1) = 7.0D+00
        a(3, 2) = 8.0D+00
        a(3, 3) = 0.0D+00

        call r8mat_print(n, n, a, '  The matrix A:')
        call dgetrf(n, n, a, lda, ipiv, info)

        if (info .ne. 0) then
            write (*, '(a)') ' '
            write (*, '(a,i8)') '  DGETRF returned INFO = ', info
            write (*, '(a)') '  The matrix is numerically singular.'
            return
        end if

        call dgetri(n, a, lda, ipiv, work, lwork, info)

        if (info .ne. 0) then
            write (*, '(a)') ' '
            write (*, '(a)') '  The inversion procedure failedc'
            write (*, '(a,i8)') '  INFO = ', info
            return
        end if

        call r8mat_print(n, n, a, '  The inverse matrix:')

        return
    end subroutine dgetri_dotnet_test

end module lapack_module
