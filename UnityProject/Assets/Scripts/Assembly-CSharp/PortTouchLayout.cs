using UnityEngine;

namespace ProbablyStolen.Port
{
    public static class PortTouchLayout
    {
        public const float BaseButtonWidth = 112f;
        public const float BaseButtonHeight = 48f;
        public const float BaseGap = 6f;
        public const float BaseFontSize = 18f;

        public static void CalculateButtonRect(
            Rect safeArea,
            float scale,
            int index,
            int totalVisible,
            out Vector2 size,
            out Vector2 position,
            out float fontSize)
        {
            // Keep proportions stable on high-density phones. Ten buttons fit
            // across a landscape row, and one row occupies at most 1/14 height.
            float widthLimit = safeArea.width / (10f * (BaseButtonWidth + BaseGap) + BaseGap);
            float heightLimit = safeArea.height / (14f * (BaseButtonHeight + BaseGap));
            scale = Mathf.Min(Mathf.Max(1f, scale), Mathf.Min(widthLimit, heightLimit));
            float buttonWidth = BaseButtonWidth * scale;
            float buttonHeight = BaseButtonHeight * scale;
            float gap = BaseGap * scale;
            fontSize = BaseFontSize * scale;
            size = new Vector2(buttonWidth, buttonHeight);

            int maxCols = Mathf.Max(1, Mathf.FloorToInt((safeArea.width - gap) / (buttonWidth + gap) + 0.00001f));
            int row = index / maxCols;
            int col = index - row * maxCols;

            float posX = safeArea.xMin + gap + col * (buttonWidth + gap);
            float posY = safeArea.yMax - gap - buttonHeight - row * (buttonHeight + gap);

            position = new Vector2(posX, posY);
        }
    }
}
