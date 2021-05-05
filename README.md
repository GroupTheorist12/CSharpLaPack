# Calling Fortran LAPACK Subroutines from C#

### Introduction

[From the LAPACK Website]: http://www.netlib.org/lapack/#_presentation

LAPACK is written in Fortran 90 and provides routines for solving systems of simultaneous linear equations, least-squares solutions of linear systems of equations, eigenvalue problems, and singular value problems. The associated matrix factorizations (LU, Cholesky, QR, SVD, Schur, generalized Schur) are also provided, as are related computations such as reordering of the Schur factorizations and estimating condition numbers. Dense and banded matrices are handled, but not general sparse matrices. In all areas, similar functionality is provided for real and complex matrices, in both single and double precision.

I have been writing code professionally in C# since around 2001 and I love the language. I also love math and the thought of recreating algorithms in C# that somebody had already coded seemed like a big waste of time.

I stumbled upon LAPACK since I was working on a mapping app that needed to solve thousands of simultaneous equations. I figured why not use code that had been battle tested for years.

One problem it was written in Fortran. So I boned up on Fortran  using the gfortran compiler on Linux and used the C/PInvoke feature of C#. (See my first foray at the git below:)  to call Fortran routines which use the iso_c_binding so that the subroutines can be called by name from c (Fortran name mangles subroutines by default)

[CSharpFortran]: https://github.com/GroupTheorist12/CSharpFortran

### Modern Fortran

From Fortran Wiki:

`iso_c_binding` is a standard intrinsic module which defines named constants, types, and procedures for [C interoperability](http://fortranwiki.org/fortran/show/C+interoperability).

[iso_c_binding](http://fortranwiki.org/fortran/show/iso_c_binding)

The code in this git exploits this interoperability to call Fortran routines from C# using P/Invoke (Platform Invocation Services). Below is a Fortran subroutine we wish to call:

### Example Fortran Subroutine with iso_c_binding

```fortran
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

```

This example can solve a series of simultaneous equations.

Below is the C# code which will call the Fortran subroutine.

### Example P/Invoke C# code to call Fortran Subroutine.

```c#
        [DllImport("lapack_module.so", CallingConvention = CallingConvention.Cdecl)]
        static extern void sgesv_dotnet(float[,] a, float[] b, ref int cols, ref int rows, ref int rc);

```

### Setting up your environment

The assumption is that you have *gfortran*, *make* and the *.NET 5.0 SDK* installed either on Linux or on Windows in the WSL Linux subsystem. If not, directions for Ubuntu are given below.

#### Install gfortran

```
sudo apt-get install gfortran
```

#### Install make

```
sudo apt-get install build-essential
```

#### Install .NET 5.0 SDK

[Install the .NET SDK](https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu)

