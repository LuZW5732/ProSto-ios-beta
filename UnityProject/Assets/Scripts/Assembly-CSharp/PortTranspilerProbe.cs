#if PROSTO_INTERP
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using DseCecil;
using DseCecil.Cil;
using ProbablyStolen.Port.Mods;

namespace ProbablyStolen.Port
{
    internal static class PortTranspilerProbe
    {
        private const string Owner = "port.transpiler-probe";
        private const string Marker = "port-transpiler-probe.enable";
        private const string Report = "port-transpiler-probe.txt";
        private const string GeneratedType = "PortExperiment.Arithmetic";
        private const int OriginalOffset = 7;
        private const int ReplacementOffset = 42;
        private static readonly MethodInfo Target = typeof(PortTranspilerProbe).GetMethod(
            nameof(Evaluate), BindingFlags.Static | BindingFlags.NonPublic);
        private static MethodInfo replacement;

        [UnityEngine.RuntimeInitializeOnLoadMethod(UnityEngine.RuntimeInitializeLoadType.AfterSceneLoad)]
        private static void RunIfEnabled()
        {
            try
            {
                string directory = UnityEngine.Application.persistentDataPath;
                string marker = Path.Combine(directory, Marker);
                if (!File.Exists(marker)) return;
                File.Delete(marker);

                string result;
                try { result = Run(); }
                catch (Exception ex) { result = "FAIL\n" + ex; }
                File.WriteAllText(Path.Combine(directory, Report), result);
                UnityEngine.Debug.Log("[PortTranspilerProbe] " + result);
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogWarning("[PortTranspilerProbe] " + ex);
            }
        }

        internal static string Run()
        {
            long memoryBefore = GC.GetTotalMemory(false);
            var clock = Stopwatch.StartNew();
            Require(Evaluate(11) == 18, "Original implementation");
            using (var fixture = CreateFixture(out MethodDefinition body))
            {
                RewriteOffset(body);
                using var stream = new MemoryStream();
                fixture.Write(stream);
                long generationMs = clock.ElapsedMilliseconds;
                replacement = Assembly.Load(stream.ToArray()).GetType(GeneratedType, true)
                    .GetMethod("Evaluate", BindingFlags.Public | BindingFlags.Static);
                long loadMs = clock.ElapsedMilliseconds - generationMs;
                try
                {
                    var prefix = typeof(PortTranspilerProbe).GetMethod(
                        nameof(Replace), BindingFlags.Static | BindingFlags.NonPublic);
                    using (StaticModHooks.Register(Owner, Target, new HookCallback(prefix)))
                    {
                        Require(Evaluate(11) == 53, "Rewritten implementation");
                        Require(Evaluate(-11) == 31, "Argument forwarding");
                    }
                }
                finally { replacement = null; }

                Require(Evaluate(11) == 18 && !StaticModHooks.HasHooks(Target), "Original restored");
                return $"PASS original=18 rewritten=53 restored=18 generationMs={generationMs} " +
                    $"loadMs={loadMs} totalMs={clock.ElapsedMilliseconds} moduleBytes={stream.Length} " +
                    $"managedHeapDeltaBytes={GC.GetTotalMemory(false) - memoryBefore}";
            }
        }

        private static AssemblyDefinition CreateFixture(out MethodDefinition method)
        {
            var name = new AssemblyNameDefinition("PortTranspilerProbe_" + Guid.NewGuid().ToString("N"), new Version(1, 0));
            var assembly = AssemblyDefinition.CreateAssembly(name, name.Name, ModuleKind.Dll);
            var module = assembly.MainModule;
            var type = new TypeDefinition("PortExperiment", "Arithmetic",
                DseCecil.TypeAttributes.Public | DseCecil.TypeAttributes.Abstract | DseCecil.TypeAttributes.Sealed,
                module.TypeSystem.Object);
            module.Types.Add(type);
            method = new MethodDefinition("Evaluate", DseCecil.MethodAttributes.Public |
                DseCecil.MethodAttributes.Static, module.TypeSystem.Int32);
            method.Parameters.Add(new ParameterDefinition(module.TypeSystem.Int32));
            type.Methods.Add(method);
            var il = method.Body.GetILProcessor();
            il.Emit(OpCodes.Ldarg_0);
            il.Emit(OpCodes.Ldc_I4, OriginalOffset);
            il.Emit(OpCodes.Add);
            il.Emit(OpCodes.Ret);
            return assembly;
        }

        private static void RewriteOffset(MethodDefinition method)
        {
            var instructions = method.Body.Instructions;
            Require(instructions.Count == 4 && instructions[0].OpCode == OpCodes.Ldarg_0 &&
                instructions[1].OpCode == OpCodes.Ldc_I4 && Equals(instructions[1].Operand, OriginalOffset) &&
                instructions[2].OpCode == OpCodes.Add && instructions[3].OpCode == OpCodes.Ret, "Unexpected fixture IL");
            instructions[1].Operand = ReplacementOffset;
        }

        [StaticHookTarget]
        private static int Evaluate(int value)
        {
            return StaticModHooks.Invoke<int>(Target, null, new object[] { value }, args => (int)args[0] + OriginalOffset);
        }

        private static bool Replace(int value, ref int __result)
        {
            __result = (int)replacement.Invoke(null, new object[] { value });
            return false;
        }

        private static void Require(bool condition, string step)
        {
            if (!condition) throw new InvalidOperationException("Probe failed at " + step);
        }
    }
}
#endif
