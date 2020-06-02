using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public class UserDefinedFunctions
{
    [SqlFunction(FillRowMethodName = "SplitStringFillRow", TableDefinition = "part NVARCHAR(MAX), ID_ORDER INT")]

    static public IEnumerator SplitString(SqlString text, char[] delimiter)
    {
        if (text.IsNull) yield break;

        int valueIndex = 1;
        foreach (string s in text.Value.Split(delimiter, StringSplitOptions.RemoveEmptyEntries))
        {
            yield return new KeyValuePair<int, string>(valueIndex++, s.Trim());
        }
    }

    static public void SplitStringFillRow(object oKeyValuePair, out SqlString value, out SqlInt32 valueIndex)
    {
        KeyValuePair<int, string> keyValuePair = (KeyValuePair<int, string>)oKeyValuePair;

        valueIndex = keyValuePair.Key;
        value = keyValuePair.Value;
    }
}