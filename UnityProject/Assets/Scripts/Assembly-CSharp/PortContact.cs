using UnityEngine;

namespace ProbablyStolen.Port
{
    public struct PortContact
    {
        public int Id;
        public Vector2 Position;
        public TouchPhase Phase;

        public PortContact(int id, Vector2 position, TouchPhase phase)
        {
            Id = id;
            Position = position;
            Phase = phase;
        }

        public static implicit operator PortGestureMachine.Contact(PortContact c) => new PortGestureMachine.Contact { Id = c.Id, Position = c.Position, Phase = c.Phase };
        public static implicit operator PortContact(PortGestureMachine.Contact c) => new PortContact(c.Id, c.Position, c.Phase);
    }
}
