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

    subroutine sgesv_dotnet(a, b, cols, rows, rc)  bind(c, name='sgesv_dotnet')   
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

end module lapack_module
