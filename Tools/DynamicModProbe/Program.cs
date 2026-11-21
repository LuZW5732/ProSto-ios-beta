using System;

internal static class Program
{
    public static int Main(string[] args)
    {
        try
        {
            Console.WriteLine(ProStoProbeHost.Run(args[0]));
            return 0;
        }
        catch (Exception error)
        {
            Console.Error.WriteLine(error);
            return 1;
        }
    }
}
