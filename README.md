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

![AX = B](C:\Users\Owner\Desktop\lapack.svg)

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

### Example C# console project

Let's walk through the steps to create a C# .NET 5.0 project to call the above Fortran subroutine.

#### Create console app using *dotnet*  cli.

Open a terminal window and enter the following (I am doing it from my HOME directory):

```bash
$ dotnet new console -o CSharpCallingLaPack
```

Change directories to CSharpCallingLaPack

```bash
$ cd CSharpCallingLaPack
```

#### Edit Program.cs

With your trusty editor (I am using VSCode) edit the *Program.cs* and cut and paste the code from below into it:

```c#
using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;

using System.Linq;

using System.Runtime.InteropServices;

namespace CSharpCallingLaPack
{
    class Program
    {
        [DllImport("lapack_module.so", CallingConvention = CallingConvention.Cdecl)]
        static extern void sgesv_dotnet(float[,] a, float[] b, ref int cols, ref int rows, ref int rc);
        static void Main(string[] args)
        {
            float[,] a = new float[,]
           {
                {2.0f, 1.0f},
                {3.0f, 1.0f}

           };

            float[] b = new float[] { 5.0f, 6.0f };

            int cols = 2;
            int rows = 2;
            int rc = 2;
            int i = 0;


            //Transpose matrix. rows become columns
            float[,] at = new float[cols, rows];
            for (i = 0; i < cols; i++)
            {
                for (int j = 0; j < rows; j++)
                {
                    at[j, i] = a[i, j];
                }
            }

            //Execute fortran subroutine
            sgesv_dotnet(at, b, ref cols, ref rows, ref rc);


            Console.WriteLine("From fortran");

            Console.Write("[");
            for (i = 0; i < cols; i++)
            {
                if (i < cols - 1)
                {
                    Console.Write("{0:0.00}\t", b[i]);

                }
                else
                {
                    Console.Write("{0:0.00}", b[i]);

                }
            }
            Console.Write("]");

            Console.WriteLine();


        }
    }
}

```

#### Copy LAPACK libraries to your usr/local/lib directory

I have provided the libraries on my github site so you can just *wget* them into your */usr/local/lib* directory.

Enter the following into a terminal window.

```bash
$ cd /usr/local/lib
$ sudo wget https://github.com/GroupTheorist12/CSharpLaPack/blob/main/lib/libblas.a
$ sudo wget https://github.com/GroupTheorist12/CSharpLaPack/blob/main/lib/liblapack.a
$ sudo wget https://github.com/GroupTheorist12/CSharpLaPack/blob/main/lib/libtmglib.a
```

#### Create Fortran Source File lapack_module.f90

Change back to the *CSharpCallingLaPack* directory and with your favorite editor cut and paste the Fortran code below and save it.

```fortran
module lapack_module
    use, intrinsic :: iso_c_binding !allow c type bindings and function names
    implicit none !types must be declared
contains

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

end module lapack_module

```

#### Create Fortran Shared Library

Enter the following in your terminal window to create the Fortran shared library.

```bash
$ gfortran -L/usr/local/lib/ -shared -O2 lapack_module.f90 -o lapack_module.so -fPIC -llapack -lblas
```

#### Run the dotnet build command

Enter the following in your terminal window to build the C# project and copy the Fortran module 

```bash
$ dotnet build
$ cp lapack_module.so bin/Debug/net5.0
```

#### Run the app

Run  the following from the terminal window to run the app.

```bash
$ dotnet run
```

You should see the following output:

```bash
From fortran
[1.00   3.00]
```

### Final Remarks

I was surprised by how much I enjoyed working with Fortran and the huge amount of mathematical library code that is written in it. The cool thing about Fortran is that optimizing compilers (Intel) can really speed up operations that involve huge arrays and matrices.

The source code for the above project and other projects I am working on can be found at:

[CSharpLaPack]: https://github.com/GroupTheorist12/CSharpLaPack

Thanks for reading!

