using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;

using System.Linq;

using System.Runtime.InteropServices;

namespace CSharpLaPack
{
    public class sgesv
    {
        [DllImport("lapack_module.so", CallingConvention = CallingConvention.Cdecl)]
        static extern void sgesv_dotnet(float[,] a, float[] b, ref int cols, ref int rows, ref int rc);

        public float[,] a
        {
            get;set;
        }

        public float[] b {get;set;}

        private int m_cols = 0;

        public int cols
        {
            get {return m_cols;}
            set {m_cols = value;}
        }

        private int m_rows = 0;
        public int rows
        {
            get {return m_rows;}
            set {m_rows = value;}
        }

        private int m_rc = 0;
        public int rc
        {
            get {return m_rc;}
            set {m_rc = value;}
        }

        private void InitAndZero(int order)
        {
            a = new float[order, order];
            b = new float[order];
            m_cols = order;
            m_rows = order;
            m_rc = 0;

            for(int i = 0; i < order; i++)
            {
                b[i] = 0;
                for(int j = 0; j < order; j++)
                {
                    a[i, j] = 0;        
                }
            }

        }
        public sgesv(int order) // set default values
        {
            if(order < 2)
            {
                throw new Exception("order must be >= 2");
            }

            InitAndZero(order);
        }

        private sgesv()
        {
            InitAndZero(2);
        }

        public float[,] Transpose()
        {
            float[,] ret = new float[this.cols, this.rows];
            for(int i = 0; i < this.cols; i++)
            {
                for(int j = 0; j < rows; j++)
                {
                    ret[j, i] = this.a[i, j];
                }
            }

            return ret;
        }

        public void Execute()
        {
            float[,] a = this.Transpose();
            sgesv_dotnet(a, this.b, ref this.m_cols, ref this.m_rows, ref this.m_rc);

        }
        public static void Test()
        {
            sgesv s = new sgesv(2);

            s.a = new float[,] 
            {
                {2.0f, 1.0f},
                {3.0f, 1.0f}

            };

            s.b = new float[] {5.0f,  6.0f};

            s.Execute();

            Console.WriteLine();
            Console.WriteLine("From fortran");

            int i = 0;

            Console.Write("[");
            for (i = 0; i < s.cols; i++)
            {
                if (i < s.cols - 1)
                {
                    Console.Write("{0:0.00}\t", s.b[i]);

                }
                else
                {
                    Console.Write("{0:0.00}", s.b[i]);

                }
            }
            Console.Write("]");

            Console.WriteLine();


        }
    }
}