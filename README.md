# Calling Fortran LAPACK Subroutines from C#

[From the LAPACK Website]: http://www.netlib.org/lapack/#_presentation

LAPACK is written in Fortran 90 and provides routines for solving systems of simultaneous linear equations, least-squares solutions of linear systems of equations, eigenvalue problems, and singular value problems. The associated matrix factorizations (LU, Cholesky, QR, SVD, Schur, generalized Schur) are also provided, as are related computations such as reordering of the Schur factorizations and estimating condition numbers. Dense and banded matrices are handled, but not general sparse matrices. In all areas, similar functionality is provided for real and complex matrices, in both single and double precision.

I have been writing code professionally in C# since around 2001 and I love the language. I also love math and the thought of recreating algorithms in C# that somebody had already coded seemed like a big waste of time.

I stumbled upon LAPACK since I was working on a mapping app that needed to solve thousands of simultaneous equations. I figured why not use code that had been battle tested for years.

One problem it was written in Fortran. So I boned up on Fortran  using the gfortran compiler on Linux and used the C/PInvoke feature of C#. (See my first foray at this git:)  to call Fortran routines which use the iso_c_binding so that the subroutines can be called by name from c (Fortran name mangles subroutines by default)

[CSharpFortran]: https://github.com/GroupTheorist12/CSharpFortran
[iso_c_binding]: http://fortranwiki.org/fortran/show/iso_c_binding

