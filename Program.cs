using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;

using System.Linq;

using System.Runtime.InteropServices;

namespace CSharpLaPack
{
    public class dgbtrf
    {
        [DllImport("lapack_module.so", CallingConvention = CallingConvention.Cdecl)]
        static extern void dgbtrf_dotnet_test();

        [DllImport("lapack_module.so", CallingConvention = CallingConvention.Cdecl)]
        static extern void dgbtrf_dotnet(ref int n, ref int ml, ref int mu, ref int lda, double[,] a, double[] b, ref int info);


        public static void Test()
        {
            int n = 5;
            int ml = 1;
            int mu = 1;
            int lda = 2 * ml + mu + 1;
            int info = 0;

            int i = 0;
            int j = 0;

            double[,] a = new double[n, lda];

            for (i = 0; i < n; i++)
            {
                for (j = 0; j < lda; j++)
                {
                    a[i, j] = 0;
                }

            }

            double[] b = new double[n];
            for (i = 0; i < n; i++)
            {
                b[i] = 0;
            }

            dgbtrf_dotnet(ref n, ref ml, ref mu, ref lda, a, b, ref info);

            if(info != 0)
            {
                Console.WriteLine($" Factorization failed, INFO = {info}");
                return;
            }
            Console.WriteLine();
            Console.WriteLine("From fortran");

            Console.Write("[");
            for (i = 0; i < n; i++)
            {
                if (i < n - 1)
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
            Console.WriteLine();

            StringBuilder sb = new StringBuilder();
            for (i = 0; i < n; i++)
            {
                for (j = 0; j < lda; j++)
                {
                    sb.AppendFormat("{0:0.00}\t", a[i, j]);
                }

                sb.Append(Environment.NewLine);


            }

            Console.Write(sb.ToString());

        }
    }
    class Program
    {
        static void Main(string[] args)
        {
            sgesv.Test();
        }
    }
}
