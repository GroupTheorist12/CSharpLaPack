module lapack_module
    use, intrinsic :: iso_c_binding !allow c type bindings and function names
    implicit none !types must be declared
contains

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

