using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace ProbablyStolen.Port
{
    internal sealed class PortDisplaySettings : MonoBehaviour
    {
        internal sealed class Percentage
        {
            private readonly string key, chinese, english;
            private readonly int minimum, maximum;
            private int? value;

            internal Percentage(string key, string chinese, string english, int minimum, int maximum)
            {
                this.key = key;
                this.chinese = chinese;
                this.english = english;
                this.minimum = minimum;
                this.maximum = maximum;
            }

            private int Value => value ?? (value = Mathf.Clamp(PlayerPrefs.GetInt(key, 100), minimum, maximum)).Value;
            internal float Scale => Value / 100f;

            internal GameOptionRegistry.Entry CreateSlider() => GameOptionRegistry.Slider(key,
                () => LocHelper.GetCurrentLocaleCode()?.StartsWith("zh") == true ? chinese : english,
                () => Value, Set, minimum, maximum, wholeNumbers: true, valueText: n => Mathf.RoundToInt(n) + "%");

            private void Set(float n)
            {
                int next = Mathf.Clamp(Mathf.RoundToInt(n), minimum, maximum);
                if (next == Value) return;
                value = next;
                PlayerPrefs.SetInt(key, next);
                PlayerPrefs.Save();
                refresh = true;
            }
        }

        internal static readonly Percentage UiSize = new Percentage("ios_ui_scale", "界面大小", "Interface size", 85, 150);
        internal static readonly Percentage TextSize = new Percentage("ios_text_scale", "文字大小", "Text size", 85, 175);
        private static bool refresh;
        private static Font typeface;
        private static TMP_FontAsset settingsFont;
        private static Transform browser;
        private readonly Dictionary<CanvasScaler, Vector2> originalResolution = new Dictionary<CanvasScaler, Vector2>();
        private readonly Dictionary<CanvasScaler, float> originalPixelScale = new Dictionary<CanvasScaler, float>();
        private readonly HashSet<TextMeshProUGUI> changed = new HashSet<TextMeshProUGUI>();
        private readonly List<TextMeshProUGUI> work = new List<TextMeshProUGUI>();

        internal static void ConfigureFont(Font source, GameObject modPanel)
        {
            typeface = source;
            browser = modPanel != null ? modPanel.transform : null;
            refresh = true;
        }

        private void OnEnable()
        {
            refresh = true;
            SceneManager.sceneLoaded += SceneLoaded;
            TMPro_EventManager.TEXT_CHANGED_EVENT.Add(TextChanged);
        }

        private void OnDisable()
        {
            SceneManager.sceneLoaded -= SceneLoaded;
            TMPro_EventManager.TEXT_CHANGED_EVENT.Remove(TextChanged);
            changed.Clear();
        }

        private void SceneLoaded(Scene scene, LoadSceneMode mode)
        {
            foreach (var key in new List<CanvasScaler>(originalResolution.Keys))
                if (key == null) originalResolution.Remove(key);
            foreach (var key in new List<CanvasScaler>(originalPixelScale.Keys))
                if (key == null) originalPixelScale.Remove(key);
            refresh = true;
        }

        private void TextChanged(Object obj)
        {
            if (obj is TextMeshProUGUI label) changed.Add(label);
        }

        private void LateUpdate()
        {
            if (refresh)
            {
                refresh = false;
                foreach (var scaler in FindObjectsOfType<CanvasScaler>())
                    ScaleCanvas(scaler.GetComponent<Canvas>());
                foreach (var label in FindObjectsOfType<TextMeshProUGUI>()) changed.Add(label);
            }
            if (changed.Count == 0) return;
            work.AddRange(changed);
            changed.Clear();
            foreach (var label in work)
            {
                if (label == null || label.canvas == null) continue;
                var root = label.canvas.rootCanvas;
                if (root.renderMode == RenderMode.WorldSpace || root.GetComponent<PortTouchCanvas>() != null) continue;
                ScaleCanvas(root);
                if (typeface != null && label.font != settingsFont && IsSettingsLabel(label) && NeedsChineseFont(label.text))
                {
                    if (settingsFont == null) settingsFont = TMP_FontAsset.CreateFontAsset(typeface);
                    if (settingsFont != null)
                    {
                        settingsFont.isMultiAtlasTexturesEnabled = true;
                        label.font = settingsFont;
                        label.fontSharedMaterial = settingsFont.material;
                    }
                }
                var state = label.GetComponent<PortTextScale>();
                if (state == null && TextSize.Scale != 1f) state = label.gameObject.AddComponent<PortTextScale>();
                if (state != null) state.Apply(label, TextSize.Scale);
            }
            work.Clear();
        }

        private static bool NeedsChineseFont(string text)
        {
            var locale = LocHelper.GetCurrentLocaleCode();
            if (locale?.StartsWith("zh") == true) return true;
            if (text == null || locale == "ja" || locale == "ko") return false;
            foreach (char c in text)
                if (c >= 0x3400 && c <= 0x9fff) return true;
            return false;
        }

        private static bool IsSettingsLabel(TextMeshProUGUI label)
        {
            if (browser != null && label.transform.IsChildOf(browser)) return true;
            for (var t = label.transform; t != null; t = t.parent)
                if (t.name == "custom_window_game_options" || t.name.StartsWith("custom_window_mod_config:", System.StringComparison.Ordinal))
                    return true;
            return false;
        }

        private void ScaleCanvas(Canvas canvas)
        {
            if (canvas == null || !canvas.isRootCanvas || canvas.renderMode == RenderMode.WorldSpace ||
                canvas.GetComponent<PortTouchCanvas>() != null) return;
            // These screen-space layers are aligned to the store backdrop.
            var render = RenderHandler.current;
            if (canvas.name == "CanvasWorldStoreInteract" ||
                (render != null && (canvas == render.windowUICanvas || canvas == render.OverlayCanvas))) return;
            var scaler = canvas.GetComponent<CanvasScaler>();
            if (scaler == null) return;
            if (scaler.uiScaleMode == CanvasScaler.ScaleMode.ScaleWithScreenSize)
            {
                if (!originalResolution.TryGetValue(scaler, out var resolution))
                    originalResolution.Add(scaler, resolution = scaler.referenceResolution);
                var target = resolution / UiSize.Scale;
                if (scaler.referenceResolution != target) scaler.referenceResolution = target;
            }
            else if (scaler.uiScaleMode == CanvasScaler.ScaleMode.ConstantPixelSize)
            {
                if (!originalPixelScale.TryGetValue(scaler, out float size))
                    originalPixelScale.Add(scaler, size = scaler.scaleFactor);
                float target = size * UiSize.Scale;
                if (!Mathf.Approximately(scaler.scaleFactor, target)) scaler.scaleFactor = target;
            }
        }
    }
}
