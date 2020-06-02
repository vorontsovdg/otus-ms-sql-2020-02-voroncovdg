using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;
public class re
{   [SqlFunction(IsDeterministic =true)]
    public static bool match(string inputText, string pattern)
    {
        return Regex.IsMatch(inputText, pattern);
    }
}