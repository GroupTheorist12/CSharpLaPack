using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;

using System.Linq;

using System.Runtime.InteropServices;

namespace CSharpLaPack
{
    public class dgetri
    {
        [DllImport("lapack_module.so", CallingConvention = CallingConvention.Cdecl)]
        static extern void dgetri_dotnet(double[,] a, ref int n, ref int info);

        [DllImport("lapack_module.so", CallingConvention = CallingConvention.Cdecl)]
        static extern void dgetri_dotnet_test();

        public double[,] a
        {
            get; set;
        }

        public int RowsAndCols { get; set; }

        private int m_info = 0;
        public int info
        {
            get { return m_info; }
            set { m_info = value; }
        }

        private void InitAndZero(int order)
        {
            a = new double[order, order];
            RowsAndCols = order;
            m_info = 0;

            for (int i = 0; i < order; i++)
            {
                for (int j = 0; j < order; j++)
                {
                    a[i, j] = 0;
                }
            }

        }

        public dgetri(int order)
        {
            if (order < 2)
            {
                throw new Exception("order must be >= 2");
            }

            InitAndZero(order);
        }

        private dgetri()
        {
            InitAndZero(2);

        }

        public double[,] Transpose()
        {
            double[,] ret = new double[this.RowsAndCols, this.RowsAndCols];
            for(int i = 0; i < this.RowsAndCols; i++)
            {
                for(int j = 0; j < RowsAndCols; j++)
                {
                    ret[j, i] = this.a[i, j];
                }
            }

            return ret;
        }

        public void Execute()
        {
            int n = RowsAndCols;
            //float[,] aa = this.Transpose();
            dgetri_dotnet(this.a, ref n, ref m_info);
        }

        public static void Test_Fortran()
        {
            dgetri_dotnet_test();
        }
        public static void Test()
        {
            dgetri d = new dgetri(3);

/*
  a(1,1) = 1.0D+00
      a(1,2) = 2.0D+00
      a(1,3) = 3.0D+00

      a(2,1) = 4.0D+00
      a(2,2) = 5.0D+00
      a(2,3) = 6.0D+00

      a(3,1) = 7.0D+00
      a(3,2) = 8.0D+00
      a(3,3) = 0.0D+00
*/

            d.a = new double[,]
            {
                {1.0f, 4.0f, 7.0f},
                {2.0f, 5.0f, 8.0f},
                {3.0f, 6.0f, 0.0f},
            };

            int i = 0;
            int j = 0;

            Console.WriteLine("Original Matrix a:");
            StringBuilder sb = new StringBuilder();
            for (i = 0; i < d.RowsAndCols; i++)
            {
                for (j = 0; j < d.RowsAndCols; j++)
                {
                    sb.AppendFormat("{0:0.0000}\t", d.a[i, j]);
                }

                sb.Append(Environment.NewLine);


            }

            Console.Write(sb.ToString());

            Console.WriteLine("Inverse of a is:");

            d.Execute();

            sb.Clear();
            for (i = 0; i < d.RowsAndCols; i++)
            {
                for (j = 0; j < d.RowsAndCols; j++)
                {
                    sb.AppendFormat("{0:0.0000}\t", d.a[i, j]);
                }

                sb.Append(Environment.NewLine);


            }

            Console.Write(sb.ToString());

        }

    }
}