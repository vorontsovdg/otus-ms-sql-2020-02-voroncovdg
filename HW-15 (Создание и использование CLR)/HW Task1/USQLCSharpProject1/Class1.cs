using Microsoft.SqlServer.Server;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

    public class TableFunctions
    {   [SqlFunction(FillRowMethodName ="FillFiles")]
         public static IEnumerable GetFiles(string dirname)
        {
        DirectoryInfo info = new DirectoryInfo(dirname);
        return info.GetFiles();
        }
        public static void FillFiles(Object obj, out SqlString name, out SqlDateTime creationTime, out SqlDateTime lastWriteTime)
    {
        FileInfo info = (FileInfo)obj;
        name = new SqlString(info.FullName);
        creationTime = new SqlDateTime(info.CreationTime);
        lastWriteTime = new SqlDateTime(info.LastWriteTime);
    }
    }