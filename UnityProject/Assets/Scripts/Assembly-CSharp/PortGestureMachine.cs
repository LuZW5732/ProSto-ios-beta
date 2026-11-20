using System;
using System.Collections.Generic;
using UnityEngine;

namespace ProbablyStolen.Port
{
    // Reconstructed from original IPA disassembly (0x1a37900 etc.).
    public sealed class PortGestureMachine
    {
        public struct Contact
        {
            public int Id;
            public Vector2 Position;
            public TouchPhase Phase;
        }

        internal enum Mode
        {
            Idle = 0,
            Pending = 1,
            LeftHold = 2,
            Drag = 3,
            Right = 4,
            TapRelease = 5,
            DragFinalMove = 6,
            DragRelease = 7,
            Dual = 8,
            Blocked = 9
        }

        internal Mode State { get; private set; }
        internal Vector2 Position, Delta, Pan;
        internal float Pinch;
        internal bool Cancelled, TwoFinger;
        internal readonly bool[] Held = new bool[3], Down = new bool[3], Up = new bool[3];

        // Native .ctor reads these floats from RVA 0x387d2f0.
        internal float LongPressSeconds = 0.4f, DragPoints = 8f;
        internal Func<Vector2, bool> RequiresLeftHold;

        private int primary;
        private Vector2 origin, finalPosition, previousCenter;
        private float started, previousDistance;
        private bool cancelRequested;
        private bool pendingLeftHold;

        internal void Cancel() { cancelRequested = true; }

        private void Button(int index, bool held)
        {
            if (Held[index] == held) return;
            Down[index] = held;
            Up[index] = !held;
            Held[index] = held;
        }

        private void CancelButtons()
        {
            Cancelled = true;
            for (int i = 0; i < 3; i++) Button(i, false);
        }

        private readonly List<Contact> convertedContacts = new List<Contact>();
        internal void Step(IReadOnlyList<PortContact> contacts, float now, float pixelsPerPoint)
        {
            convertedContacts.Clear();
            for (int i = 0; i < contacts.Count; i++)
            {
                convertedContacts.Add(contacts[i]);
            }
            Step(convertedContacts, now, pixelsPerPoint);
        }

        internal void Step(IReadOnlyList<Contact> contacts, float now, float pixelsPerPoint)
        {
            Array.Clear(Down, 0, 3);
            Array.Clear(Up, 0, 3);
            Delta = Pan = Vector2.zero;
            Pinch = 0;
            Cancelled = TwoFinger = false;

            var before = Position;
            Contact first = default, second = default, current = default;
            int active = 0;
            bool found = false;
            bool cancelled = cancelRequested;
            cancelRequested = false;

            for (int i = 0; i < contacts.Count; i++)
            {
                var contact = contacts[i];
                if (contact.Id == primary)
                {
                    current = contact;
                    found = true;
                }
                if (contact.Phase == TouchPhase.Canceled)
                {
                    cancelled = true;
                }
                if (contact.Phase == TouchPhase.Ended || contact.Phase == TouchPhase.Canceled)
                {
                    continue;
                }
                if (active == 0) first = contact;
                if (active == 1) second = contact;
                active++;
            }

            if (cancelled)
            {
                CancelButtons();
                State = (active == 0) ? Mode.Idle : Mode.Blocked;
                return;
            }

            if (State == Mode.Blocked)
            {
                if (active == 0) State = Mode.Idle;
                return;
            }

            float scale = Mathf.Max(1f, pixelsPerPoint);

            // Two-finger handling (0x1a37c1c)
            if (active >= 2)
            {
                var center = (first.Position + second.Position) * 0.5f;
                float distance = Vector2.Distance(first.Position, second.Position);
                if (State == Mode.Dual)
                {
                    Pan = (center - previousCenter) / scale;
                    Pinch = (distance - previousDistance) / scale;
                }
                else
                {
                    CancelButtons();
                    Position = center;
                }
                State = Mode.Dual;
                TwoFinger = true;
                previousCenter = center;
                previousDistance = distance;
                return;
            }

            // Dual exited: if fingers dropped below 2, remaining finger must not click (0x1a37b40)
            if (State == Mode.Dual)
            {
                State = (active == 0) ? Mode.Idle : Mode.Blocked;
                return;
            }

            // TapRelease / DragRelease: complete mouse0 up and accept immediate new touch (0x1a37bc4)
            if (State == Mode.TapRelease || State == Mode.DragRelease)
            {
                Button(0, false);
                State = Mode.Idle;
                if (active == 1)
                {
                    // Seamless transition to new gesture on fast consecutive tap
                    primary = first.Id;
                    // Keep the old pointer position for this release. Native
                    // 0x1a37be4 stores the new origin, then 0x1a37e4c enters
                    // Pending; it does not press the next hold in this frame.
                    origin = first.Position;
                    started = now;
                    pendingLeftHold = (RequiresLeftHold != null && RequiresLeftHold(origin));
                    State = Mode.Pending;
                }
                return;
            }

            // DragFinalMove (0x1a37de8): move to finalPosition then transition to DragRelease
            if (State == Mode.DragFinalMove)
            {
                Position = finalPosition;
                Delta = Position - before;
                State = Mode.DragRelease;
                return;
            }

            // Idle state: wait for new contact (0x1a37d0c)
            if (State == Mode.Idle)
            {
                if (active == 0) return;
                primary = first.Id;
                origin = Position = first.Position;
                started = now;
                State = Mode.Pending;
                pendingLeftHold = (RequiresLeftHold != null && RequiresLeftHold(origin));
                if (pendingLeftHold)
                {
                    Button(0, true);
                    State = Mode.LeftHold;
                }
                Delta = Position - before;
                return;
            }

            // Gesture tracking (Pending, LeftHold, Drag, Right) (0x1a37d60)
            if (!found)
            {
                CancelButtons();
                State = (active == 0) ? Mode.Idle : Mode.Blocked;
                return;
            }

            if (current.Phase == TouchPhase.Ended)
            {
                if (State == Mode.LeftHold || State == Mode.Drag)
                {
                    Position = current.Position;
                    State = Mode.DragRelease;
                }
                else if (State == Mode.Pending)
                {
                    Position = origin;
                    Button(0, true);
                    State = Mode.TapRelease;
                    if (Vector2.Distance(origin, current.Position) >= DragPoints * scale)
                    {
                        finalPosition = current.Position;
                        State = Mode.DragFinalMove;
                    }
                }
                else // Mode.Right
                {
                    Button(1, false);
                    State = Mode.Idle;
                }
            }
            else // Phase != TouchPhase.Ended
            {
                if (State == Mode.Pending)
                {
                    if (pendingLeftHold)
                    {
                        Position = origin;
                        Button(0, true);
                        State = Mode.LeftHold;
                    }
                    else if (Vector2.Distance(origin, current.Position) >= DragPoints * scale)
                    {
                        Position = origin;
                        Button(0, true);
                        State = Mode.Drag;
                    }
                    else
                    {
                        Position = current.Position;
                        if (now - started >= LongPressSeconds)
                        {
                            Button(1, true);
                            State = Mode.Right;
                        }
                    }
                }
                else
                {
                    Position = current.Position;
                }
            }

            Delta = Position - before;
        }
    }
}
