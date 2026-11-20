using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace ProbablyStolen.Port
{
    [DefaultExecutionOrder(-11000)]
    public sealed class PortTouchToolbar : MonoBehaviour
    {
        public sealed class Entry
        {
            public int Group;
            public string Name;
            public string TextZh;
            public string TextEn;
            public FontLoader.FontRole Role;
            public Action OnClick;
            public Action OnHold;
            public Action<bool> OnRelease;
            public GameObject Root;
            public PortTouchControl Control;
            public TextMeshProUGUI Label;
        }

        private Canvas canvas;
        private readonly List<Entry> entries = new List<Entry>();
        private bool expanded;
        private int multiplier = 10;
        private readonly object transferOwner = new object();
        private readonly object customerOwner = new object();
        private KeyCode transferKey = KeyCode.None;
        private KeyCode customerKey = KeyCode.None;
        private int releaseTransferFrame = -1;
        private bool dragging;
        private bool quantity;
        private bool typing;
        private bool dirty = true;
        private bool fontBound;
        private string currentLocale = "";
        private Rect lastSafeArea;
        private float lastScale;

        private void Awake()
        {
            Build();
        }

        private void OnEnable()
        {
            dirty = true;
        }

        private void Build()
        {
            if (canvas != null) return;

            var canvasGo = new GameObject("PortTouchToolbar", typeof(RectTransform), typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster), typeof(PortTouchCanvas));
            canvasGo.transform.SetParent(transform, false);

            canvas = canvasGo.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 32000;

            var scaler = canvasGo.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ConstantPixelSize;

            entries.Clear();

            // Group 0: Always visible
            Add(0, "Back", "返回", "Back", FontLoader.FontRole.Noto_Sans, Back);
            Add(0, "Continue", "继续", "Continue", FontLoader.FontRole.Noto_Sans, Continue);
            Add(0, "Actions", "操作", "Actions", FontLoader.FontRole.Noto_Sans, () => { expanded = !expanded; dirty = true; });

            // Group 1: Dragging active
            AddAction(1, "RotateCW", "顺时针", "Rotate CW", FontLoader.FontRole.Noto_Sans, "rotate_cw");
            AddAction(1, "RotateCCW", "逆时针", "Rotate CCW", FontLoader.FontRole.Noto_Sans, "rotate_ccw");
            AddAction(1, "Flip", "翻转", "Flip", FontLoader.FontRole.Noto_Sans, "flip_item");
            AddAction(1, "Reset", "复位", "Reset", FontLoader.FontRole.Noto_Sans, "reset_orientation");

            // Group 3: Quantity / Transfer
            Add(3, "CountMinus", "数量 −", "Count −", FontLoader.FontRole.Noto_Sans, () => ItemMouseDragHandler.current?.AdjustTouchAmount(-multiplier));
            Add(3, "CountPlus", "数量 +", "Count +", FontLoader.FontRole.Noto_Sans, () => ItemMouseDragHandler.current?.AdjustTouchAmount(multiplier));
            Add(3, "Mult10", "×10", "×10", FontLoader.FontRole.Noto_Sans, () => { multiplier = multiplier == 10 ? 1 : 10; dirty = true; });
            Add(3, "Mult100", "×100", "×100", FontLoader.FontRole.Noto_Sans, () => { multiplier = multiplier == 100 ? 1 : 100; dirty = true; });
            AddTransfer(3, "ToInventory", "移入背包", "To inventory", FontLoader.FontRole.Noto_Sans, "quick_move_inventory");
            AddTransfer(3, "ToShowcase", "移入展示柜", "To showcase", FontLoader.FontRole.Noto_Sans, "quick_move_showcase");
            AddTransfer(3, "ToStorage", "移入仓库", "To storage", FontLoader.FontRole.Noto_Sans, "quick_move_storage");

            // Group 2: Expanded actions
            AddAction(2, "Sort", "排序", "Sort", FontLoader.FontRole.Noto_Sans, "sort_menu");
            AddAction(2, "Discard", "丢弃", "Discard", FontLoader.FontRole.Noto_Sans, "trash_item");
            AddAction(2, "PinMode", "固定模式", "Pin mode", FontLoader.FontRole.Noto_Sans, "pin_mode");
            AddAction(2, "Settings", "设置", "Settings", FontLoader.FontRole.Noto_Sans, "open_options");
            AddAction(2, "Controls", "操作提示", "Controls", FontLoader.FontRole.Noto_Sans, "control_hints");
            Add(2, "NextCustomer", "下一位顾客", "Next customer", FontLoader.FontRole.Noto_Sans, null,
                onHold: () =>
                {
                    if (StoreUIManager.IsAnyTyping() || KeyBindHelper.SuppressHotkeys) return;
                    KeyCode key = KeyBindHelper.Get("call_next_customer");
                    customerKey = key;
                    PortInput.HoldKey(customerOwner, key, true);
                },
                onRelease: (inside) =>
                {
                    if (!inside)
                    {
                        var bell = UnityEngine.Object.FindObjectOfType<StoreBell>();
                        bell?.CancelTouchHotkeyHold();
                    }
                    if (customerKey != KeyCode.None)
                    {
                        PortInput.HoldKey(customerOwner, customerKey, false);
                        customerKey = KeyCode.None;
                    }
                });

            dirty = true;
        }

        private void Add(int group, string name, string textZh, string textEn, FontLoader.FontRole role, Action onClick, Action onHold = null, Action<bool> onRelease = null)
        {
            var btnGo = new GameObject(name, typeof(RectTransform), typeof(Image), typeof(Button), typeof(PortTouchControl));
            btnGo.transform.SetParent(canvas.transform, false);

            var img = btnGo.GetComponent<Image>();
            img.color = new Color(0.12f, 0.12f, 0.14f, 0.92f);

            var btn = btnGo.GetComponent<Button>();
            var colors = btn.colors;
            colors.normalColor = new Color(1f, 1f, 1f, 1f);
            colors.highlightedColor = new Color(1.2f, 1.2f, 1.2f, 1f);
            colors.pressedColor = new Color(0.7f, 0.7f, 0.7f, 1f);
            btn.colors = colors;

            var ctrl = btnGo.GetComponent<PortTouchControl>();
            if (onClick != null) ctrl.Clicked = onClick;
            if (onHold != null) ctrl.Pressed = onHold;
            if (onRelease != null) ctrl.HoldEnded = onRelease;

            var textGo = new GameObject("Text", typeof(RectTransform), typeof(TextMeshProUGUI));
            textGo.transform.SetParent(btnGo.transform, false);
            var label = textGo.GetComponent<TextMeshProUGUI>();
            label.alignment = TextAlignmentOptions.Center;
            label.enableAutoSizing = false;
            label.fontSize = 18f;
            label.color = Color.white;

            var textRect = textGo.GetComponent<RectTransform>();
            textRect.anchorMin = Vector2.zero;
            textRect.anchorMax = Vector2.one;
            textRect.sizeDelta = Vector2.zero;

            entries.Add(new Entry
            {
                Group = group,
                Name = name,
                TextZh = textZh,
                TextEn = textEn,
                Role = role,
                OnClick = onClick,
                OnHold = onHold,
                OnRelease = onRelease,
                Root = btnGo,
                Control = ctrl,
                Label = label
            });
        }

        private void AddAction(int group, string name, string textZh, string textEn, FontLoader.FontRole role, string actionId)
        {
            Add(group, name, textZh, textEn, role, () => PortInput.PulseAction(actionId));
        }

        private void AddTransfer(int group, string name, string textZh, string textEn, FontLoader.FontRole role, string transferActionId)
        {
            Add(group, name, textZh, textEn, role, () =>
            {
                if (StoreUIManager.IsAnyTyping() || KeyBindHelper.SuppressHotkeys) return;
                if (transferKey != KeyCode.None)
                {
                    PortInput.HoldKey(transferOwner, transferKey, false);
                }
                KeyCode key = KeyBindHelper.Get(transferActionId);
                transferKey = key;
                releaseTransferFrame = -1;
                PortInput.HoldKey(transferOwner, key, true);
            });
        }

        private bool Visible(Entry entry)
        {
            switch (entry.Group)
            {
                case 0: return true;
                case 1: return dragging;
                case 2: return expanded;
                case 3: return quantity;
                default: return false;
            }
        }

        public void ResetState()
        {
            if (customerKey != KeyCode.None)
            {
                var bell = UnityEngine.Object.FindObjectOfType<StoreBell>();
                bell?.CancelTouchHotkeyHold();
                PortInput.HoldKey(customerOwner, customerKey, false);
                customerKey = KeyCode.None;
            }
            if (transferKey != KeyCode.None)
            {
                PortInput.HoldKey(transferOwner, transferKey, false);
                transferKey = KeyCode.None;
                releaseTransferFrame = -1;
            }
            expanded = false;
            dirty = true;
        }

        private void Update()
        {
            if (canvas == null) Build();
            bool showToolbar = !PortAuthorNotice.IsOpen;
            if (canvas.gameObject.activeSelf != showToolbar) canvas.gameObject.SetActive(showToolbar);
            if (!showToolbar) return;

            // Handle transfer key release per original IPA 0x1A3DF7C
            if (transferKey != KeyCode.None)
            {
                if (PortInput.Cancelled || StoreUIManager.IsAnyTyping() || KeyBindHelper.SuppressHotkeys)
                {
                    PortInput.HoldKey(transferOwner, transferKey, false);
                    transferKey = KeyCode.None;
                    releaseTransferFrame = -1;
                    dirty = true;
                }
                else if (releaseTransferFrame < 0)
                {
                    if (PortInput.GetMouseButtonUp(0))
                    {
                        releaseTransferFrame = Time.frameCount;
                    }
                }
                else if (Time.frameCount > releaseTransferFrame)
                {
                    PortInput.HoldKey(transferOwner, transferKey, false);
                    transferKey = KeyCode.None;
                    releaseTransferFrame = -1;
                    dirty = true;
                }
            }

            // Suppress customerKey when typing
            if (customerKey != KeyCode.None && (StoreUIManager.IsAnyTyping() || KeyBindHelper.SuppressHotkeys))
            {
                var bell = UnityEngine.Object.FindObjectOfType<StoreBell>();
                bell?.CancelTouchHotkeyHold();
                PortInput.HoldKey(customerOwner, customerKey, false);
                customerKey = KeyCode.None;
                dirty = true;
            }

            bool nowDragging = (ItemMouseDragHandler.current != null && ItemMouseDragHandler.current.IsDraggingItem) ||
                               (ItemMultiSelectHandler.current != null && ItemMultiSelectHandler.current.IsGroupDragging);
            if (dragging != nowDragging)
            {
                dragging = nowDragging;
                dirty = true;
            }

            bool nowQuantity = ItemMouseDragHandler.current != null && ItemMouseDragHandler.current.CanAdjustTouchAmount;
            if (quantity != nowQuantity)
            {
                quantity = nowQuantity;
                dirty = true;
            }

            bool nowTyping = StoreUIManager.IsAnyTyping();
            if (typing != nowTyping)
            {
                typing = nowTyping;
                dirty = true;
            }

            string loc = LocHelper.GetCurrentLocaleCode();
            if (currentLocale != loc)
            {
                currentLocale = loc;
                dirty = true;
            }

            Rect sa = Screen.safeArea;
            if (lastSafeArea != sa)
            {
                lastSafeArea = sa;
                dirty = true;
            }

            float currentScale = TouchInputBridge.Instance != null ? TouchInputBridge.Instance.PixelsPerPoint : Mathf.Max(1f, Screen.dpi / 163f);
            if (Mathf.Abs(lastScale - currentScale) > 0.001f)
            {
                lastScale = currentScale;
                dirty = true;
            }

            // Retry font binding if FontLoader initialized later
            if (!fontBound)
            {
                try
                {
                    if (FontLoader.Instance != null && UnityEngine.Localization.Settings.LocalizationSettings.SelectedLocale != null)
                    {
                        var f = FontLoader.Instance.GetFontByRole(FontLoader.FontRole.Noto_Sans, UnityEngine.Localization.Settings.LocalizationSettings.SelectedLocale);
                        if (f != null) dirty = true;
                    }
                }
                catch { }
            }

            if (dirty)
            {
                Layout();
                dirty = false;
            }
        }

        private void Layout()
        {
            bool isZh = string.IsNullOrEmpty(currentLocale) || currentLocale.StartsWith("zh", StringComparison.OrdinalIgnoreCase);
            float scale = TouchInputBridge.Instance != null ? TouchInputBridge.Instance.PixelsPerPoint : Mathf.Max(1f, Screen.dpi / 163f);
            Rect sa = Screen.safeArea;
            if (sa.width <= 0f || sa.height <= 0f) return;
            TMP_FontAsset font = null;
            try
            {
                if (FontLoader.Instance != null && UnityEngine.Localization.Settings.LocalizationSettings.SelectedLocale != null)
                {
                    font = FontLoader.Instance.GetFontByRole(FontLoader.FontRole.Noto_Sans, UnityEngine.Localization.Settings.LocalizationSettings.SelectedLocale);
                    if (font != null) fontBound = true;
                }
            }
            catch { }

            int totalVisible = 0;
            for (int i = 0; i < entries.Count; i++)
            {
                if (Visible(entries[i])) totalVisible++;
            }

            int visibleIndex = 0;
            for (int i = 0; i < entries.Count; i++)
            {
                var entry = entries[i];
                bool vis = Visible(entry);
                entry.Root.SetActive(vis);

                if (!vis) continue;

                if (font != null) entry.Label.font = font;
                entry.Label.text = isZh ? entry.TextZh : entry.TextEn;

                PortTouchLayout.CalculateButtonRect(sa, scale, visibleIndex, totalVisible, out var size, out var pos, out var fontSize);

                entry.Label.enableAutoSizing = false;
                entry.Label.fontSize = fontSize;

                var rt = entry.Root.GetComponent<RectTransform>();
                rt.anchorMin = Vector2.zero;
                rt.anchorMax = Vector2.zero;
                rt.pivot = Vector2.zero;
                rt.sizeDelta = size;
                rt.anchoredPosition = pos;

                visibleIndex++;
            }
        }

        public void Back()
        {
            if (StoreUIManager.IsAnyTyping())
            {
                FinishText(true);
                return;
            }
            if (expanded)
            {
                expanded = false;
                dirty = true;
                return;
            }
            if (transferKey != KeyCode.None)
            {
                PortInput.HoldKey(transferOwner, transferKey, false);
                transferKey = KeyCode.None;
                releaseTransferFrame = -1;
                dirty = true;
                return;
            }
            PortInput.PulseKey(KeyCode.Escape);
        }

        public void Continue()
        {
            if (StoreUIManager.IsAnyTyping())
            {
                FinishText(false);
                return;
            }
            var newGame = UnityEngine.Object.FindObjectOfType<NewGamePanelFrame>();
            if (newGame != null && newGame.continueButton != null && newGame.continueButton.interactable)
            {
                newGame.continueButton.onClick.Invoke();
                return;
            }
            PortInput.PulseAction("advance_dialogue");
        }

        public static void FinishText(bool cancel)
        {
            var es = EventSystem.current;
            var current = es != null ? es.currentSelectedGameObject : null;
            var input = current != null ? current.GetComponent<TMP_InputField>() : null;
            if (input != null && input.isFocused)
            {
                input.ProcessEvent(Event.KeyboardEvent(cancel ? "escape" : "return"));
                if (!cancel && input.onSubmit != null)
                {
                    input.onSubmit.Invoke(input.text);
                }
                input.DeactivateInputField();
            }
            if (es != null && es.currentSelectedGameObject == current)
            {
                es.SetSelectedGameObject(null);
            }
        }
    }
}
