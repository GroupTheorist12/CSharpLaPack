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
