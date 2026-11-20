using UnityEngine;

namespace ProbablyStolen.Port
{
    public sealed class PortPointerFrame
    {
        public Vector2 Position;
        public Vector2 Delta;
        public Vector2 Pan;
        public float Pinch;
        public bool Cancelled;
        public bool TwoFinger;
        public readonly bool[] Held = new bool[3];
        public readonly bool[] Down = new bool[3];
        public readonly bool[] Up = new bool[3];

        public void Begin()
        {
            Delta = Vector2.zero;
            Pan = Vector2.zero;
            Pinch = 0f;
            Cancelled = false;
            TwoFinger = false;
            for (int i = 0; i < 3; i++)
            {
                Down[i] = false;
                Up[i] = false;
            }
        }

        public void Button(int index, bool held)
        {
            if (index < 0 || index >= 3) return;
            if (Held[index] == held) return;
            if (held)
            {
                Down[index] = true;
            }
            else
            {
                Up[index] = true;
            }
            Held[index] = held;
        }
    }
}
