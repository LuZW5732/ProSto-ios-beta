using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace ProbablyStolen.Port
{
    public class PortTouchControl : MonoBehaviour
    {
        public static readonly List<PortTouchControl> Controls = new List<PortTouchControl>();

        public Action Pressed;
        public Action Released;
        public Action Clicked;
        public Action<bool> HoldEnded;

        private RectTransform rect;
        private Button button;

        private void Awake()
        {
            rect = GetComponent<RectTransform>();
            button = GetComponent<Button>();
        }

        private void OnEnable()
        {
            Controls.Add(this);
        }

        private void OnDisable()
        {
            Controls.Remove(this);
        }

        public Func<Vector2, bool> CustomContains;

        public virtual bool Contains(Vector2 screenPoint)
        {
            if (CustomContains != null) return CustomContains(screenPoint);
            if (!isActiveAndEnabled) return false;
            if (button != null && !button.IsInteractable()) return false;
            if (rect == null) return false;

            Canvas canvas = GetComponentInParent<Canvas>();
            Camera cam = (canvas != null && canvas.renderMode != RenderMode.ScreenSpaceOverlay) ? canvas.worldCamera : null;
            return RectTransformUtility.RectangleContainsScreenPoint(rect, screenPoint, cam);
        }

        public void Begin(Vector2 screenPoint)
        {
            if (button != null)
            {
                try
                {
                    button.OnPointerDown(new PointerEventData(EventSystem.current) { button = PointerEventData.InputButton.Left });
                }
                catch { }
            }
            Pressed?.Invoke();
        }

        public void End(Vector2 screenPoint, bool cancelled)
        {
            if (button != null)
            {
                try
                {
                    button.OnPointerUp(new PointerEventData(EventSystem.current) { button = PointerEventData.InputButton.Left });
                }
                catch { }
            }
            Released?.Invoke();
            bool inside = !cancelled && Contains(screenPoint);
            HoldEnded?.Invoke(inside);
            if (inside)
            {
                Clicked?.Invoke();
            }
        }
    }
}
