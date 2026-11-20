using System;
using System.Collections.Generic;
using UnityEngine;

namespace ProbablyStolen.Port
{
    internal static class PortInput
    {
        internal static Func<PortGestureMachine> FrameProvider;
        internal static Func<bool> ActiveProvider;
        internal static PortGestureMachine Frame => FrameProvider != null ? FrameProvider() : null;
        internal static bool Active => ActiveProvider != null && ActiveProvider();

        public static Func<bool> IsTypingSuppressed;
        public static Func<string, KeyCode> ResolveActionKey;

        public static bool Cancelled => Active && Frame != null && Frame.Cancelled;
        public static Vector3 mousePosition => Active ? (Vector3)(Frame != null ? Frame.Position : Vector2.zero) : UnityEngine.Input.mousePosition;

        private static Vector2 customScroll;
        public static Vector2 mouseScrollDelta
        {
            get => Active ? customScroll : UnityEngine.Input.mouseScrollDelta;
            set => customScroll = value;
        }

        public static void ResetScroll()
        {
            customScroll = Vector2.zero;
        }

        private static bool Mouse(KeyCode key) => key >= KeyCode.Mouse0 && key <= KeyCode.Mouse6;

        private static readonly HashSet<KeyCode> heldKeys = new HashSet<KeyCode>();
        private static readonly HashSet<KeyCode> downKeys = new HashSet<KeyCode>();
        private static readonly HashSet<KeyCode> upKeys = new HashSet<KeyCode>();

        private static readonly Dictionary<object, KeyCode> requestedHolds = new Dictionary<object, KeyCode>();
        private static readonly HashSet<KeyCode> pendingPulse = new HashSet<KeyCode>();
        private static readonly HashSet<KeyCode> nextKeys = new HashSet<KeyCode>();

        // Each UI action owns its hold. Releasing one cannot release another
        // action bound to the same key. Requests become visible at SnapshotKeys.
        public static void HoldKey(KeyCode key, bool held) => HoldKey((object)key, key, held);
        public static void HoldKey(object owner, KeyCode key, bool held)
        {
            if (owner == null || key == KeyCode.None) return;
            if (held)
            {
                if (IsTypingSuppressed?.Invoke() == true) return;
                requestedHolds[owner] = key;
            }
            else if (requestedHolds.TryGetValue(owner, out var existing) && existing == key)
                requestedHolds.Remove(owner);
        }

        public static void PulseKey(KeyCode key)
        {
            if (key == KeyCode.None) return;
            if (IsTypingSuppressed?.Invoke() == true) return;
            pendingPulse.Add(key);
        }

        public static void PulseAction(string actionId)
        {
            if (string.IsNullOrEmpty(actionId)) return;
            if (IsTypingSuppressed?.Invoke() == true) return;
            KeyCode key = ResolveActionKey != null ? ResolveActionKey(actionId) : KeyCode.None;
            PulseKey(key);
        }

        public static void SnapshotKeys()
        {
            // Suppression cancels pending actions rather than executing them.
            if (IsTypingSuppressed?.Invoke() == true) { Reset(); return; }
            nextKeys.Clear();
            foreach (var key in requestedHolds.Values) nextKeys.Add(key);
            nextKeys.UnionWith(pendingPulse);
            downKeys.Clear(); upKeys.Clear();
            foreach (var key in nextKeys)
                if (!heldKeys.Contains(key)) downKeys.Add(key);
            foreach (var key in heldKeys)
                if (!nextKeys.Contains(key)) upKeys.Add(key);
            heldKeys.Clear(); heldKeys.UnionWith(nextKeys);
            pendingPulse.Clear();
            // Adjacent pulses and overlapping holds coalesce into one hold.
            // Up is emitted only when the final source releases the key.
        }

        public static void Reset()
        {
            requestedHolds.Clear(); nextKeys.Clear();
            heldKeys.Clear(); downKeys.Clear(); upKeys.Clear();
            pendingPulse.Clear(); customScroll = Vector2.zero;
        }

        public static bool GetMouseButton(int button)
        {
            if (Active)
            {
                if (button >= 0 && button < 3 && Frame != null && !Frame.Cancelled && Frame.Held[button]) return true;
                if (button >= 0 && button <= 6)
                {
                    KeyCode code = KeyCode.Mouse0 + button;
                    if (heldKeys.Contains(code)) return true;
                }
                return false;
            }
            return UnityEngine.Input.GetMouseButton(button);
        }

        public static bool GetMouseButtonDown(int button)
        {
            if (Active)
            {
                if (button >= 0 && button < 3 && Frame != null && !Frame.Cancelled && Frame.Down[button]) return true;
                if (button >= 0 && button <= 6)
                {
                    KeyCode code = KeyCode.Mouse0 + button;
                    if (downKeys.Contains(code)) return true;
                }
                return false;
            }
            return UnityEngine.Input.GetMouseButtonDown(button);
        }

        public static bool GetMouseButtonUp(int button)
        {
            if (Active)
            {
                if (button >= 0 && button < 3 && Frame != null && !Frame.Cancelled && Frame.Up[button]) return true;
                if (button >= 0 && button <= 6)
                {
                    KeyCode code = KeyCode.Mouse0 + button;
                    if (upKeys.Contains(code)) return true;
                }
                return false;
            }
            return UnityEngine.Input.GetMouseButtonUp(button);
        }

        public static bool GetKey(KeyCode key)
        {
            if (Active)
            {
                if (heldKeys.Contains(key)) return true;
                if (Mouse(key))
                {
                    int btn = key - KeyCode.Mouse0;
                    if (btn >= 0 && btn < 3 && Frame != null && !Frame.Cancelled && Frame.Held[btn]) return true;
                }
                return false;
            }
            return UnityEngine.Input.GetKey(key);
        }

        public static bool GetKeyDown(KeyCode key)
        {
            if (Active)
            {
                if (downKeys.Contains(key)) return true;
                if (Mouse(key))
                {
                    int btn = key - KeyCode.Mouse0;
                    if (btn >= 0 && btn < 3 && Frame != null && !Frame.Cancelled && Frame.Down[btn]) return true;
                }
                return false;
            }
            return UnityEngine.Input.GetKeyDown(key);
        }

        public static bool GetKeyUp(KeyCode key)
        {
            if (Active)
            {
                if (upKeys.Contains(key)) return true;
                if (Mouse(key))
                {
                    int btn = key - KeyCode.Mouse0;
                    if (btn >= 0 && btn < 3 && Frame != null && !Frame.Cancelled && Frame.Up[btn]) return true;
                }
                return false;
            }
            return UnityEngine.Input.GetKeyUp(key);
        }

        private static bool TryResolveKey(string key, out KeyCode code)
        {
            if (string.IsNullOrEmpty(key)) { code = KeyCode.None; return false; }
            if (key.Equals("mouse 0", StringComparison.OrdinalIgnoreCase) || key.Equals("mouse0", StringComparison.OrdinalIgnoreCase)) { code = KeyCode.Mouse0; return true; }
            if (key.Equals("mouse 1", StringComparison.OrdinalIgnoreCase) || key.Equals("mouse1", StringComparison.OrdinalIgnoreCase)) { code = KeyCode.Mouse1; return true; }
            if (key.Equals("mouse 2", StringComparison.OrdinalIgnoreCase) || key.Equals("mouse2", StringComparison.OrdinalIgnoreCase)) { code = KeyCode.Mouse2; return true; }
            return Enum.TryParse(key, true, out code);
        }

        public static bool GetKey(string key) => Active && TryResolveKey(key, out var code) ? GetKey(code) : UnityEngine.Input.GetKey(key);
        public static bool GetKeyDown(string key) => Active && TryResolveKey(key, out var code) ? GetKeyDown(code) : UnityEngine.Input.GetKeyDown(key);
        public static bool GetKeyUp(string key) => Active && TryResolveKey(key, out var code) ? GetKeyUp(code) : UnityEngine.Input.GetKeyUp(key);
        public static bool anyKeyDown => Active ? (downKeys.Count > 0 || GetMouseButtonDown(0) || GetMouseButtonDown(1) || GetMouseButtonDown(2)) : UnityEngine.Input.anyKeyDown;

        public static float GetAxis(string axis)
        {
            if (Active && axis == "Mouse ScrollWheel") return mouseScrollDelta.y;
            if (Active && axis == "Mouse X") return Frame != null ? Frame.Delta.x : 0f;
            if (Active && axis == "Mouse Y") return Frame != null ? Frame.Delta.y : 0f;
            return UnityEngine.Input.GetAxis(axis);
        }
    }
}
