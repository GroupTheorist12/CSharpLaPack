build:
	gfortran -L/usr/local/lib/ -shared -O2 lapack_module.f90 -o lapack_module.so -fPIC -llapack -lblas

clean:
	rm lapack_module.so

all: build
