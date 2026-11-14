#nullable enable
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
namespace SmartInventoryArrange.Core
{

public readonly struct Cell : IEquatable<Cell> {
public int X { get; }
public int Y { get; }
public Cell(int X, int Y) { this.X = X;this.Y = Y; }
public bool Equals(Cell other) => EqualityComparer<int>.Default.Equals(X, other.X) && EqualityComparer<int>.Default.Equals(Y, other.Y);
public override bool Equals(object other) => other is Cell value && Equals(value);
public override int GetHashCode() { var h = new System.HashCode();h.Add(X);h.Add(Y);return h.ToHashCode(); }
public static bool operator ==(Cell a, Cell b) => a.Equals(b);
public static bool operator !=(Cell a, Cell b) => !a.Equals(b);
public void Deconstruct(out int X, out int Y) {X = this.X;Y = this.Y;}
}

public sealed class ShapeMask
{
    public int Width { get; }
    public int Height { get; }
    public IReadOnlyList<Cell> Cells { get; }
    public int Area => Cells.Count;
    public string Signature { get; }

    public ShapeMask(IEnumerable<Cell> cells)
    {
        var normalized = cells.Distinct().OrderBy(c => c.Y).ThenBy(c => c.X).ToArray();
        if (normalized.Length == 0) throw new ArgumentException("Shape must contain at least one cell.");
        int minX = normalized.Min(c => c.X), minY = normalized.Min(c => c.Y);
        var shifted = normalized.Select(c => new Cell(c.X - minX, c.Y - minY)).OrderBy(c => c.Y).ThenBy(c => c.X).ToArray();
        Cells = shifted;
        Width = shifted.Max(c => c.X) + 1;
        Height = shifted.Max(c => c.Y) + 1;
        Signature = string.Join(";", shifted.Select(c => $"{c.X},{c.Y}"));
    }

    public ShapeMask Rotate90() => new(Cells.Select(c => new Cell(Height - 1 - c.Y, c.X)));
}

public sealed record Orientation(int GameOrientation, ShapeMask Mask, bool Rotated);

public sealed class LayoutItem
{
    public string StableId { get; init; } = "";
    public string ItemId { get; init; } = "";
    public string PrimaryCategory { get; init; } = "~unknown";
    public IReadOnlyList<string> Categories { get; init; } = Array.Empty<string>();
    public IReadOnlyList<Orientation> Orientations { get; init; } = Array.Empty<Orientation>();
    public ShapeMask? OriginalMask { get; init; }
    public int OriginalOrientation { get; init; }
    public int OriginalX { get; init; }
    public int OriginalY { get; init; }
    public int VisualPriority { get; init; } = 1000;
    public int Area => Orientations[0].Mask.Area;
    public int Complexity => Orientations[0].Mask.Width * Orientations[0].Mask.Height - Area;
}

public sealed record Placement(string StableId, int X, int Y, int GameOrientation, ShapeMask Mask, string Category, bool Rotated);

public sealed class LayoutProblem
{
    public int Width { get; init; }
    public int Height { get; init; }
    public bool[,] Usable { get; init; } = new bool[0, 0];
    public IReadOnlyList<Placement> Fixed { get; init; } = Array.Empty<Placement>();
    public IReadOnlyList<LayoutItem> Items { get; init; } = Array.Empty<LayoutItem>();
    public IReadOnlyDictionary<string, int> CategoryOrder { get; init; } = new Dictionary<string, int>(StringComparer.Ordinal);
}

public readonly struct LayoutScore : IComparable<LayoutScore>, IEquatable<LayoutScore> {
public int PlacedCount { get; }
public int PlacedArea { get; }
public int NegativeTypeRuns { get; }
public int SameTypeRowAlignment { get; }
public int SameTypeHorizontalContact { get; }
public int NegativeCohortRuns { get; }
public int CohortRowAlignment { get; }
public int CohortHorizontalContact { get; }
public int OrientationConsistency { get; }
public int VerticalPreference { get; }
public int PriorityOrderAlignment { get; }
public int CategoryOrderAlignment { get; }
public int LargeFirstAlignment { get; }
public int SameTypeContact { get; }
public int SameCategoryContact { get; }
public int TopLeftCompactness { get; }
public int RowRegularity { get; }
public int NegativeFragments { get; }
public int NegativeInterleaving { get; }
public int NegativeRotations { get; }
public string StableTie { get; }
public LayoutScore(
    int PlacedCount, int PlacedArea,
    int NegativeTypeRuns, int SameTypeRowAlignment,
    int SameTypeHorizontalContact,
    int NegativeCohortRuns, int CohortRowAlignment,
    int CohortHorizontalContact, int OrientationConsistency,
    int VerticalPreference, int PriorityOrderAlignment,
    int CategoryOrderAlignment,
    int LargeFirstAlignment, int SameTypeContact,
    int SameCategoryContact, int TopLeftCompactness,
    int RowRegularity, int NegativeFragments,
    int NegativeInterleaving, int NegativeRotations,
    string StableTie) { this.PlacedCount = PlacedCount;this.PlacedArea = PlacedArea;this.NegativeTypeRuns = NegativeTypeRuns;this.SameTypeRowAlignment = SameTypeRowAlignment;this.SameTypeHorizontalContact = SameTypeHorizontalContact;this.NegativeCohortRuns = NegativeCohortRuns;this.CohortRowAlignment = CohortRowAlignment;this.CohortHorizontalContact = CohortHorizontalContact;this.OrientationConsistency = OrientationConsistency;this.VerticalPreference = VerticalPreference;this.PriorityOrderAlignment = PriorityOrderAlignment;this.CategoryOrderAlignment = CategoryOrderAlignment;this.LargeFirstAlignment = LargeFirstAlignment;this.SameTypeContact = SameTypeContact;this.SameCategoryContact = SameCategoryContact;this.TopLeftCompactness = TopLeftCompactness;this.RowRegularity = RowRegularity;this.NegativeFragments = NegativeFragments;this.NegativeInterleaving = NegativeInterleaving;this.NegativeRotations = NegativeRotations;this.StableTie = StableTie; }
public bool Equals(LayoutScore other) => EqualityComparer<int>.Default.Equals(PlacedCount, other.PlacedCount) && EqualityComparer<int>.Default.Equals(PlacedArea, other.PlacedArea) && EqualityComparer<int>.Default.Equals(NegativeTypeRuns, other.NegativeTypeRuns) && EqualityComparer<int>.Default.Equals(SameTypeRowAlignment, other.SameTypeRowAlignment) && EqualityComparer<int>.Default.Equals(SameTypeHorizontalContact, other.SameTypeHorizontalContact) && EqualityComparer<int>.Default.Equals(NegativeCohortRuns, other.NegativeCohortRuns) && EqualityComparer<int>.Default.Equals(CohortRowAlignment, other.CohortRowAlignment) && EqualityComparer<int>.Default.Equals(CohortHorizontalContact, other.CohortHorizontalContact) && EqualityComparer<int>.Default.Equals(OrientationConsistency, other.OrientationConsistency) && EqualityComparer<int>.Default.Equals(VerticalPreference, other.VerticalPreference) && EqualityComparer<int>.Default.Equals(PriorityOrderAlignment, other.PriorityOrderAlignment) && EqualityComparer<int>.Default.Equals(CategoryOrderAlignment, other.CategoryOrderAlignment) && EqualityComparer<int>.Default.Equals(LargeFirstAlignment, other.LargeFirstAlignment) && EqualityComparer<int>.Default.Equals(SameTypeContact, other.SameTypeContact) && EqualityComparer<int>.Default.Equals(SameCategoryContact, other.SameCategoryContact) && EqualityComparer<int>.Default.Equals(TopLeftCompactness, other.TopLeftCompactness) && EqualityComparer<int>.Default.Equals(RowRegularity, other.RowRegularity) && EqualityComparer<int>.Default.Equals(NegativeFragments, other.NegativeFragments) && EqualityComparer<int>.Default.Equals(NegativeInterleaving, other.NegativeInterleaving) && EqualityComparer<int>.Default.Equals(NegativeRotations, other.NegativeRotations) && EqualityComparer<string>.Default.Equals(StableTie, other.StableTie);
public override bool Equals(object other) => other is LayoutScore value && Equals(value);
public override int GetHashCode() { var h = new System.HashCode();h.Add(PlacedCount);h.Add(PlacedArea);h.Add(NegativeTypeRuns);h.Add(SameTypeRowAlignment);h.Add(SameTypeHorizontalContact);h.Add(NegativeCohortRuns);h.Add(CohortRowAlignment);h.Add(CohortHorizontalContact);h.Add(OrientationConsistency);h.Add(VerticalPreference);h.Add(PriorityOrderAlignment);h.Add(CategoryOrderAlignment);h.Add(LargeFirstAlignment);h.Add(SameTypeContact);h.Add(SameCategoryContact);h.Add(TopLeftCompactness);h.Add(RowRegularity);h.Add(NegativeFragments);h.Add(NegativeInterleaving);h.Add(NegativeRotations);h.Add(StableTie);return h.ToHashCode(); }
public static bool operator ==(LayoutScore a, LayoutScore b) => a.Equals(b);
public static bool operator !=(LayoutScore a, LayoutScore b) => !a.Equals(b);
public void Deconstruct(out int PlacedCount, out int PlacedArea, out int NegativeTypeRuns, out int SameTypeRowAlignment, out int SameTypeHorizontalContact, out int NegativeCohortRuns, out int CohortRowAlignment, out int CohortHorizontalContact, out int OrientationConsistency, out int VerticalPreference, out int PriorityOrderAlignment, out int CategoryOrderAlignment, out int LargeFirstAlignment, out int SameTypeContact, out int SameCategoryContact, out int TopLeftCompactness, out int RowRegularity, out int NegativeFragments, out int NegativeInterleaving, out int NegativeRotations, out string StableTie) {PlacedCount = this.PlacedCount;PlacedArea = this.PlacedArea;NegativeTypeRuns = this.NegativeTypeRuns;SameTypeRowAlignment = this.SameTypeRowAlignment;SameTypeHorizontalContact = this.SameTypeHorizontalContact;NegativeCohortRuns = this.NegativeCohortRuns;CohortRowAlignment = this.CohortRowAlignment;CohortHorizontalContact = this.CohortHorizontalContact;OrientationConsistency = this.OrientationConsistency;VerticalPreference = this.VerticalPreference;PriorityOrderAlignment = this.PriorityOrderAlignment;CategoryOrderAlignment = this.CategoryOrderAlignment;LargeFirstAlignment = this.LargeFirstAlignment;SameTypeContact = this.SameTypeContact;SameCategoryContact = this.SameCategoryContact;TopLeftCompactness = this.TopLeftCompactness;RowRegularity = this.RowRegularity;NegativeFragments = this.NegativeFragments;NegativeInterleaving = this.NegativeInterleaving;NegativeRotations = this.NegativeRotations;StableTie = this.StableTie;}

    public int CompareTo(LayoutScore o)
    {
        int[] a = { PlacedCount, PlacedArea,
            NegativeTypeRuns, SameTypeRowAlignment,
            SameTypeHorizontalContact,
            NegativeCohortRuns, CohortRowAlignment,
            CohortHorizontalContact, OrientationConsistency,
            VerticalPreference, PriorityOrderAlignment,
            CategoryOrderAlignment,
            LargeFirstAlignment, SameTypeContact,
            SameCategoryContact, TopLeftCompactness,
            RowRegularity, NegativeFragments,
            NegativeInterleaving, NegativeRotations };
        int[] b = { o.PlacedCount, o.PlacedArea,
            o.NegativeTypeRuns, o.SameTypeRowAlignment,
            o.SameTypeHorizontalContact,
            o.NegativeCohortRuns, o.CohortRowAlignment,
            o.CohortHorizontalContact, o.OrientationConsistency,
            o.VerticalPreference, o.PriorityOrderAlignment,
            o.CategoryOrderAlignment,
            o.LargeFirstAlignment, o.SameTypeContact,
            o.SameCategoryContact, o.TopLeftCompactness,
            o.RowRegularity, o.NegativeFragments,
            o.NegativeInterleaving, o.NegativeRotations };
        for (int i = 0; i < a.Length; i++)
        {
            int c = a[i].CompareTo(b[i]);
            if (c != 0) return c;
        }
        return -StringComparer.Ordinal.Compare(StableTie, o.StableTie);
    }
}
public sealed record LayoutResult(bool Complete, IReadOnlyList<Placement> Placements, LayoutScore Score,
    bool UsedFallback, bool TimedOut, TimeSpan Elapsed, int Holes, int NarrowFragments);



/// <summary>Native unique ID is stable across child-list reordering. An absent or
/// duplicated native ID uses an explicit snapshot index, never an object address.</summary>
public static class InstanceIdentity
{
    public static string From(string itemId,int uniqueId,int index,int multiplicity)
    {
        string key=$"{itemId}\u001f{uniqueId:D10}";
        return uniqueId!=0&&multiplicity==1?key:$"{key}\u001f{index:D6}";
    }
}

}
