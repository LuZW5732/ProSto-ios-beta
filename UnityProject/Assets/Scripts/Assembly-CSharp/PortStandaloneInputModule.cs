using UnityEngine.EventSystems;

namespace ProbablyStolen.Port
{
    public sealed class PortStandaloneInputModule : StandaloneInputModule
    {
        public override bool ShouldActivateModule() => PortInput.Active || base.ShouldActivateModule();

        public override void UpdateModule()
        {
            if (PortInput.Frame?.Cancelled == true) CancelPointers();
            base.UpdateModule();
        }

        public override void Process()
        {
            if (PortInput.Frame?.Cancelled == true) { CancelPointers(); return; }
            base.Process();
        }

        public void CancelPointers()
        {
            foreach (var pointer in m_PointerData.Values)
            {
                pointer.eligibleForClick = false;
                if (pointer.pointerPress != null)
                {
                    var interactable = pointer.pointerPress.GetComponentInParent<Interactable>() ?? pointer.pointerPress.GetComponent<Interactable>();
                    interactable?.CancelTouchHold();
                    ExecuteEvents.Execute(pointer.pointerPress, pointer, ExecuteEvents.pointerUpHandler);
                }
                if (pointer.dragging && pointer.pointerDrag != null)
                    ExecuteEvents.Execute(pointer.pointerDrag, pointer, ExecuteEvents.endDragHandler);
                pointer.dragging = false;
                pointer.pointerPress = null;
                pointer.rawPointerPress = null;
                pointer.pointerDrag = null;
                HandlePointerExitAndEnter(pointer, null);
            }
            m_PointerData.Clear();
        }
    }
}
