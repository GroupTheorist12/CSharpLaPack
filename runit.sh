#!/bin/bash
make --directory lapack_module
cp lapack_module/lapack_module.so bin/Debug/net5.0
dotnet run
