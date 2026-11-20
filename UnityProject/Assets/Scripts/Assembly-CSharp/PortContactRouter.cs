using System.Collections.Generic;
using UnityEngine;

namespace ProbablyStolen.Port
{
    public sealed class PortContactRouter
    {
        private readonly Dictionary<int, PortTouchControl> owners = new Dictionary<int, PortTouchControl>();
        private readonly HashSet<int> seen = new HashSet<int>();
        private readonly List<int> missing = new List<int>();

        public void Filter(List<PortContact> touches, List<PortContact> game)
        {
            game.Clear();
            seen.Clear();

            for (int i = 0; i < touches.Count; i++)
            {
                var contact = touches[i];
                seen.Add(contact.Id);

                if (owners.TryGetValue(contact.Id, out var owner))
                {
                    if (contact.Phase == TouchPhase.Ended || contact.Phase == TouchPhase.Canceled)
                    {
                        if (!ReferenceEquals(owner, null))
                        {
                            owner.End(contact.Position, contact.Phase == TouchPhase.Canceled);
                        }
                        owners.Remove(contact.Id);
                    }
                }
                else
                {
                    if (contact.Phase == TouchPhase.Began)
                    {
                        for (int c = PortTouchControl.Controls.Count - 1; c >= 0; c--)
                        {
                            var ctrl = PortTouchControl.Controls[c];
                            if (!ReferenceEquals(ctrl, null) && ctrl.Contains(contact.Position))
                            {
                                owners[contact.Id] = ctrl;
                                ctrl.Begin(contact.Position);
                                break;
                            }
                        }
                    }

                    if (!owners.ContainsKey(contact.Id))
                    {
                        game.Add(contact);
                    }
                }
            }

            missing.Clear();
            foreach (var key in owners.Keys)
            {
                if (!seen.Contains(key))
                {
                    missing.Add(key);
                }
            }
            for (int i = 0; i < missing.Count; i++)
            {
                int id = missing[i];
                if (owners.TryGetValue(id, out var owner) && !ReferenceEquals(owner, null))
                {
                    owner.End(Vector2.zero, true);
                }
                owners.Remove(id);
            }
        }

        public void Cancel()
        {
            foreach (var owner in owners.Values)
            {
                if (!ReferenceEquals(owner, null))
                {
                    owner.End(Vector2.zero, true);
                }
            }
            missing.Clear();
            missing.AddRange(owners.Keys);
            for (int i = 0; i < missing.Count; i++)
            {
                owners[missing[i]] = null;
            }
        }
    }
}
