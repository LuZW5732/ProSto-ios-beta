using System;

[assembly: System.Reflection.AssemblyVersion("2.4.2.0")]

namespace HarmonyLib
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public sealed class HarmonyPatch : Attribute
    {
        public readonly Type TargetType;
        public readonly string MethodName;

        public HarmonyPatch(Type declaringType, string methodName)
        {
            TargetType = declaringType;
            MethodName = methodName;
        }
    }
}
