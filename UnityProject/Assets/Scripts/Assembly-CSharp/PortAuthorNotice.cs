using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace ProbablyStolen.Port
{
    internal static class PortAuthorNotice
    {
        private const string Authors = "iOS移植作者：樱大路露娜、海森堡";
        private const string FooterCredits = Authors + "\niOS杀戮尖塔2q群：1087477769\nQQ频道：iOS深空当铺";
        private const string HideNotice = "iosPortAuthorNoticeOptOut";
        private static bool dismissedThisLaunch;
        private static TMP_FontAsset authorFont;
        private static GameObject notice;
        internal static bool IsOpen => notice != null && notice.activeInHierarchy;

        private static RectTransform Box(string name, Transform parent, Vector2 min, Vector2 max)
        {
            var rect = (RectTransform)new GameObject(name, typeof(RectTransform)).transform;
            rect.SetParent(parent, false);
            rect.gameObject.layer = parent.gameObject.layer;
            rect.anchorMin = min;
            rect.anchorMax = max;
            rect.offsetMin = rect.offsetMax = Vector2.zero;
            return rect;
        }

        private static TextMeshProUGUI Label(RectTransform rect, TMP_FontAsset font, string value)
        {
            var label = rect.gameObject.AddComponent<TextMeshProUGUI>();
            label.font = font;
            label.text = value;
            label.alignment = TextAlignmentOptions.Center;
            label.raycastTarget = false;
            label.enableAutoSizing = true;
            label.fontSizeMin = 10;
            label.fontSizeMax = 42;
            return label;
        }

        internal static void Install(TextMeshProUGUI version, Font typeface)
        {
            if (version == null || version.transform.Find("Port authors") != null) return;
            if (authorFont == null && typeface != null)
                authorFont = TMP_FontAsset.CreateFontAsset(typeface);
            var font = authorFont != null ? authorFont : version.font;
            var line = Box("Port authors", version.transform, Vector2.zero, Vector2.zero);
            line.pivot = Vector2.zero;
            var credit = Label(line, font, FooterCredits);
            credit.enableAutoSizing = false;
            credit.fontSize = version.fontSize;
            credit.alignment = TextAlignmentOptions.BottomLeft;
            credit.color = version.color;
            line.sizeDelta = credit.GetPreferredValues(FooterCredits) + new Vector2(4, 2);
            line.anchoredPosition = new Vector2(version.margin.x, version.margin.w + version.preferredHeight + 2);

            if (dismissedThisLaunch || PlayerPrefs.GetInt(HideNotice, 0) == 1 || IsOpen) return;
            var root = Box("iOS author notice", version.canvas.rootCanvas.transform, Vector2.zero, Vector2.one);
            notice = root.gameObject;
            var canvas = notice.AddComponent<Canvas>();
            canvas.overrideSorting = true;
            canvas.sortingOrder = 32760;
            notice.AddComponent<GraphicRaycaster>();
            notice.AddComponent<Image>().color = new Color(0, 0, 0, 0.72f);
            var panel = Box("Panel", root, new Vector2(.17f, .16f), new Vector2(.83f, .84f));
            panel.gameObject.AddComponent<Image>().color = new Color(.15f, .14f, .20f, 1);
            Label(Box("Title", panel, new Vector2(.06f, .77f), new Vector2(.94f, .94f)), font, "移植作者与隐私说明");
            var body = Label(Box("Body", panel, new Vector2(.08f, .32f), new Vector2(.92f, .75f)), font,
                Authors + "\n\n游戏及原作素材的权利归相应权利人所有。\n本版本已关闭游戏内的 Unity Analytics 统计。此提示的确认状态保存在本设备。\n反馈问题可自愿发送邮件，请勿附上密码或其他敏感信息。\n\n联系邮箱：zheng573275@gmail.com");
            body.alignment = TextAlignmentOptions.MidlineLeft;
            var row = Box("Hide on future launches", panel, new Vector2(.28f, .19f), new Vector2(.72f, .31f));
            row.gameObject.AddComponent<Image>().color = Color.clear;
            var toggle = row.gameObject.AddComponent<Toggle>();
            var square = Box("Checkbox", row, new Vector2(.05f,.18f), new Vector2(.05f,.82f));
            square.gameObject.AddComponent<AspectRatioFitter>().aspectMode = AspectRatioFitter.AspectMode.HeightControlsWidth;
            var outline = square.gameObject.AddComponent<Image>();
            outline.color = Color.gray;
            var mark = Box("Selected", square, Vector2.one * .16f, Vector2.one * .84f).gameObject.AddComponent<Image>();
            mark.color = Color.white;
            toggle.targetGraphic = outline;
            toggle.graphic = mark;
            toggle.isOn = false;
            Label(Box("Option", row, new Vector2(.18f,0), Vector2.one), font, "不再弹出");
            var ok = Box("Acknowledge", panel, new Vector2(.34f, .03f), new Vector2(.66f, .17f));
            var background = ok.gameObject.AddComponent<Image>();
            background.color = new Color(.28f, .32f, .40f);
            var button = ok.gameObject.AddComponent<Button>();
            button.targetGraphic = background;
            Label(Box("Label", ok, Vector2.zero, Vector2.one), font, "我知道了");
            button.onClick.AddListener(() =>
            {
                dismissedThisLaunch = true;
                if (toggle.isOn)
                {
                    PlayerPrefs.SetInt(HideNotice, 1);
                    PlayerPrefs.Save();
                }
                notice.SetActive(false);
                Object.Destroy(notice);
            });
        }
    }
}
