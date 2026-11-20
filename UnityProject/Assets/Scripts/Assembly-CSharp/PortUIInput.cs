using UnityEngine;
using UnityEngine.EventSystems;

namespace ProbablyStolen.Port
{
    public sealed class PortUIInput : BaseInput
    {
        public override bool mousePresent => true;
        public override bool touchSupported => false;
        public override int touchCount => 0;
        public override Vector2 mousePosition => PortInput.mousePosition;
        public override Vector2 mouseScrollDelta => PortInput.mouseScrollDelta;
        public override bool GetMouseButton(int button) => PortInput.GetMouseButton(button);
        public override bool GetMouseButtonDown(int button) => PortInput.GetMouseButtonDown(button);
        public override bool GetMouseButtonUp(int button) => PortInput.GetMouseButtonUp(button);
        public override float GetAxisRaw(string axisName) => PortInput.Active ? 0f : base.GetAxisRaw(axisName);
        public override bool GetButtonDown(string buttonName) => PortInput.Active ? false : base.GetButtonDown(buttonName);
    }
}
