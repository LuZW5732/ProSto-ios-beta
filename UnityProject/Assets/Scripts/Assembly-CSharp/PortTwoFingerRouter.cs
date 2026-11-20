using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace ProbablyStolen.Port
{
    public sealed class PortTwoFingerRouter
    {
        public enum Route
        {
            None = 0,
            Scroll = 1,
            Grid = 2,
            Panel = 3
        }

        public Route Mode { get; private set; }
        private StoreUI storeUI;
        private UIDragHandler panel;
        private GameObject scrollTarget;
        private GameObject gridTarget;
        private ScrollRect scrollReceiver;
        private GameGridScrollableInventory gridReceiver;
        private Vector2 origin;
        private float scrollTravel;
        private float pinchTravel;
        private readonly List<RaycastResult> hits = new List<RaycastResult>();

        public void Reset()
        {
            Mode = Route.None;
            storeUI = null;
            panel = null;
            scrollTarget = null;
            gridTarget = null;
            scrollReceiver = null;
            gridReceiver = null;
            scrollTravel = 0f;
            pinchTravel = 0f;
            hits.Clear();
            PortInput.mouseScrollDelta = Vector2.zero;
        }

        public void Update(PortGestureMachine frame, float pixelsPerPoint)
        {
            // Dispatch to the captured receiver below, never broadcast a second
            // copy through EventSystem's current mouse hover target.
            PortInput.ResetScroll();
            if (frame == null)
            {
                Reset();
                return;
            }

            if (!frame.TwoFinger)
            {
                Reset();
                return;
            }

            if (frame.Cancelled)
            {
                Reset();

                if (ItemMouseDragHandler.current != null && ItemMouseDragHandler.current.IsDraggingItem) return;
                if (ItemMultiSelectHandler.current != null && ItemMultiSelectHandler.current.IsGroupDragging) return;

                EventSystem es = EventSystem.current;
                if (es == null) return;

                hits.Clear();
                es.RaycastAll(new PointerEventData(es) { position = frame.Position }, hits);
                if (hits.Count == 0) return;

                GameObject hit = hits[0].gameObject;
                if (hit == null) return;
                origin = frame.Position;

                var scroll = hit.GetComponentInParent<ScrollRect>();
                if (scroll != null)
                {
                    Mode = Route.Scroll;
                    scrollTarget = scroll.gameObject;
                    scrollReceiver = scroll;
                    return;
                }

                var treeNode = hit.GetComponentInParent<TreeNodeRender>();
                while (treeNode != null)
                {
                    var elem = treeNode.element;
                    var inventory = elem as GameGridScrollableInventory;
                    if (elem is GameItem item) inventory = item.parentInventory as GameGridScrollableInventory;
                    if (inventory != null)
                    {
                        Mode = Route.Grid;
                        gridReceiver = inventory;
                        gridTarget = inventory.handler.gameObject;
                        return;
                    }
                    treeNode = treeNode.parent;
                }

                panel = hit.GetComponentInParent<UIDragHandler>();
                storeUI = hit.GetComponentInParent<StoreUI>();
                if (panel != null || (storeUI != null && storeUI.zoomable))
                {
                    Mode = Route.Panel;
                    return;
                }

                return;
            }

            // Verify initial target liveness - if target was destroyed or became inactive, abort immediately
            if (Mode == Route.Scroll)
            {
                if (scrollReceiver == null || !scrollReceiver.isActiveAndEnabled || !StillUncovered(scrollTarget))
                {
                    Reset();
                    return;
                }
            }
            else if (Mode == Route.Grid)
            {
                if (gridReceiver == null || !StillUncovered(gridTarget))
                {
                    Reset();
                    return;
                }
            }
            else if (Mode == Route.Panel)
            {
                bool panelValid = panel != null && panel.gameObject.activeInHierarchy;
                bool storeValid = storeUI != null && storeUI.gameObject.activeInHierarchy;
                if (!panelValid && !storeValid)
                {
                    Reset();
                    return;
                }
            }

            switch (Mode)
            {
                case Route.Scroll:
                    if (frame.Pan != Vector2.zero)
                        scrollReceiver.OnScroll(new PointerEventData(EventSystem.current) {
                            position = origin, scrollDelta = frame.Pan / -24f
                        });
                    break;

                case Route.Grid:
                    scrollTravel -= frame.Pan.y;
                    int steps = (int)(scrollTravel / 24f);
                    if (steps != 0)
                    {
                        float dir = steps >= 0 ? 1f : -1f;
                        gridReceiver.Scroll(new Vector2(0f, dir));
                        scrollTravel += dir * -24f;
                    }
                    else
                    {
                        PortInput.mouseScrollDelta = Vector2.zero;
                    }
                    break;

                case Route.Panel:
                    PortInput.mouseScrollDelta = Vector2.zero;
                    if (panel != null && panel.isActiveAndEnabled && (frame.Pan.x != 0f || frame.Pan.y != 0f))
                    {
                        panel.PanTouch(frame.Pan * pixelsPerPoint);
                    }
                    if (storeUI != null && storeUI.isActiveAndEnabled && storeUI.zoomable)
                    {
                        pinchTravel += frame.Pinch;
                        if (Mathf.Abs(pinchTravel) >= 40f)
                        {
                            storeUI.StepTouchZoom(pinchTravel > 0f ? 1 : -1);
                            pinchTravel = 0f;
                        }
                    }
                    break;

                default:
                    PortInput.mouseScrollDelta = Vector2.zero;
                    break;
            }
        }

        private bool StillUncovered(GameObject target)
        {
            if (target == null || !target.activeInHierarchy || EventSystem.current == null) return false;
            hits.Clear();
            EventSystem.current.RaycastAll(new PointerEventData(EventSystem.current) { position = origin }, hits);
            return hits.Count > 0 && hits[0].gameObject != null &&
                hits[0].gameObject.transform.IsChildOf(target.transform);
        }

    }
}
