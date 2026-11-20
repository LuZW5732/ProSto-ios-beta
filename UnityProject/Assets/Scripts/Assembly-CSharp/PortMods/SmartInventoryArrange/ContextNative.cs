#nullable enable
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using ProbablyStolen.Port.Mods;

namespace SmartInventoryArrange
{

/// <summary>Strongly typed access to private Mono fields exposed publicly by IL2CPP interop upstream.</summary>
internal static class ContextNative
{
    private static readonly Func<ItemContextHandler, GameGridInventory> CurrentInventoryField =
        PortReflection.FieldReader<ItemContextHandler, GameGridInventory>("currentInventory");
    private static readonly Func<ItemContextHandler, PixelWindow> SortWindowField =
        PortReflection.FieldReader<ItemContextHandler, PixelWindow>("sortWindow");
    private static readonly Func<ItemContextHandler, RenderHandler.ColorPalette> TextColorField =
        PortReflection.FieldReader<ItemContextHandler, RenderHandler.ColorPalette>("textColor");
    private static readonly Func<ItemContextHandler, RichTextElement> BigStartField =
        PortReflection.FieldReader<ItemContextHandler, RichTextElement>("buttonSortBigStart");
    private static readonly Func<ItemContextHandler, RichTextElement> SmallStartField =
        PortReflection.FieldReader<ItemContextHandler, RichTextElement>("buttonSortSmallStart");
    private static readonly Func<ItemContextHandler, RichTextElement> BigEndField =
        PortReflection.FieldReader<ItemContextHandler, RichTextElement>("buttonSortBigEnd");
    private static readonly Func<ItemContextHandler, RichTextElement> SmallEndField =
        PortReflection.FieldReader<ItemContextHandler, RichTextElement>("buttonSortSmallEnd");
    private static readonly Func<ItemContextHandler, RichTextElement> UndoField =
        PortReflection.FieldReader<ItemContextHandler, RichTextElement>("buttonSortUndo");
    private static readonly Func<RichTextElement, int> LeftPaddingField = PortReflection.FieldReader<RichTextElement, int>("leftPadding");
    private static readonly Func<RichTextElement, int> RightPaddingField = PortReflection.FieldReader<RichTextElement, int>("rightPadding");
    private static readonly Func<RichTextElement, int> TopPaddingField = PortReflection.FieldReader<RichTextElement, int>("topPadding");
    private static readonly Func<RichTextElement, int> BottomPaddingField = PortReflection.FieldReader<RichTextElement, int>("bottomPadding");
    private static readonly Func<GridPixelElement, int> XSpacingField = PortReflection.FieldReader<GridPixelElement, int>("_xSpacing");
    private static readonly Func<GridPixelElement, int> YSpacingField = PortReflection.FieldReader<GridPixelElement, int>("_ySpacing");

    internal static GameGridInventory Inventory(ItemContextHandler owner) => CurrentInventoryField(owner);
    internal static PixelWindow SortWindow(ItemContextHandler owner) => SortWindowField(owner);
    internal static RenderHandler.ColorPalette TextColor(ItemContextHandler owner) => TextColorField(owner);
    internal static RichTextElement SmallEnd(ItemContextHandler owner) => SmallEndField(owner);
    internal static RichTextElement[] NativeSortButtons(ItemContextHandler owner) =>
        new[] { BigStartField(owner), SmallStartField(owner), BigEndField(owner), SmallEndField(owner), UndoField(owner) };
    internal static (int Left, int Right, int Top, int Bottom) Padding(RichTextElement element) =>
        (LeftPaddingField(element), RightPaddingField(element), TopPaddingField(element), BottomPaddingField(element));
    internal static int XSpacing(GridPixelElement grid) => XSpacingField(grid);
    internal static int YSpacing(GridPixelElement grid) => YSpacingField(grid);
}

}
