using TMPro;
using UnityEngine;

namespace ProbablyStolen.Port
{
    // Serialized so a game-created copy of an already scaled label inherits its baseline.
    internal sealed class PortTextScale : MonoBehaviour
    {
        [SerializeField] private Vector3 baseline;
        [SerializeField] private Vector3 applied;
        [SerializeField] private bool initialized;

        internal void Apply(TextMeshProUGUI label, float factor)
        {
            var current = new Vector3(label.fontSize, label.fontSizeMin, label.fontSizeMax);
            if (!initialized || !Mathf.Approximately(current.x, applied.x)) baseline.x = current.x;
            if (!initialized || !Mathf.Approximately(current.y, applied.y)) baseline.y = current.y;
            if (!initialized || !Mathf.Approximately(current.z, applied.z)) baseline.z = current.z;
            initialized = true;
            applied = baseline * factor;
            if (label.enableAutoSizing)
            {
                if (!Mathf.Approximately(current.y, applied.y)) label.fontSizeMin = applied.y;
                if (!Mathf.Approximately(current.z, applied.z)) label.fontSizeMax = applied.z;
            }
            else if (!Mathf.Approximately(current.x, applied.x)) label.fontSize = applied.x;
        }
    }
}
