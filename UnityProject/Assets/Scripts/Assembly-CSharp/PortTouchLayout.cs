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
            scale = Mathf.Max(1f, scale);
            float buttonWidth = Mathf.Max(BaseButtonWidth, BaseButtonWidth * scale);
            float buttonHeight = BaseButtonHeight * scale;
            float gap = BaseGap * scale;
            fontSize = BaseFontSize * scale;
            size = new Vector2(buttonWidth, buttonHeight);

            int maxCols = Mathf.Max(3, (int)((safeArea.width - 2f * gap) / (buttonWidth + gap)));
            int row = index / maxCols;
            int remaining = totalVisible - row * maxCols;
            int colsInRow = Mathf.Min(maxCols, remaining);
            int unusedCols = maxCols - colsInRow;

            float horizontalOffset = (row == 0) ? 0f : (unusedCols * (buttonWidth + gap));
            int col = index - row * maxCols;

            float posX = safeArea.xMin + gap + horizontalOffset + col * (buttonWidth + gap);
            float posY = safeArea.yMax - gap - buttonHeight - row * (buttonHeight + gap);

            position = new Vector2(posX, posY);
        }
    }
}
