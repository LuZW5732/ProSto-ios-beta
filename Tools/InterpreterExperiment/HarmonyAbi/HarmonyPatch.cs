using System;

[assembly: System.Reflection.AssemblyVersion("2.4.2.0")]

namespace HarmonyLib
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public sealed class HarmonyPatch : Attribute
    {
        public readonly Type TargetType;
        public readonly string MethodName;
        public readonly Type[] ArgumentTypes;

        public HarmonyPatch(Type declaringType, string methodName)
            : this(declaringType, methodName, null)
        {
        }

        public HarmonyPatch(Type declaringType, string methodName, params Type[] argumentTypes)
        {
            TargetType = declaringType;
            MethodName = methodName;
            ArgumentTypes = argumentTypes;
        }
    }
}
