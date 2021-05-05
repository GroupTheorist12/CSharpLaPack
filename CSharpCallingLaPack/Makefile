build:
	gfortran -L/usr/local/lib/ -shared -O2 lapack_module.f90 -o lapack_module.so -fPIC -llapack -lblas

clean:
	rm lapack_module.so

all: build

run: clean build
	dotnet build
	cp lapack_module.so bin/Debug/net5.0
	dotnet run

