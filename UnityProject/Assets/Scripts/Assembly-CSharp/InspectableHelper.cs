public class InspectableHelper
{
	public const string INSPECTABLE_TAG = "INSPECTABLE_TAG";

	public const string ALREADY_CONFRONTED_TAG = "ALREADY_CONFRONTED_TAG";

	public static void InitInspectableItem(GameItem gameItem)
	{
		gameItem.EnableTag("INSPECTABLE_TAG");
	}

	private static readonly System.Reflection.MethodInfo __portHook0 = ProbablyStolen.Port.Mods.PortReflection.Method(typeof(InspectableHelper), "CreateInspectableTooltip", new System.Type[] { typeof(RichTextBuilder), typeof(GameItem) });
[ProbablyStolen.Port.Mods.StaticHookTarget]
public static void CreateInspectableTooltip(RichTextBuilder builder, GameItem item)
{
    if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks(__portHook0))
    {
        __PortOriginal();
        return;
    }

    ProbablyStolen.Port.Mods.StaticModHooks.Invoke<object>(__portHook0, null, new object[] { builder, item }, __portArguments =>
    {
        builder = (RichTextBuilder)__portArguments[0];
        item = (GameItem)__portArguments[1];
        __PortOriginal();
        return null;
    });
    void __PortOriginal()
    {
        if (item.IsTag("INSPECTABLE_TAG") && PlayerStore.Instance.isVisualInspectionIntroduced)
        {
            builder.AddLine(LocHelper.GetLocalizedMechanic("mech_inspectable_tooltip"), ignoreEmpty: true, RenderHandler.ColorPalette.LightOrange, bold: false, italic: true);
        }
    }
}

	public static void OnConfrontSuccess(GameItem gameItem)
	{
		gameItem.EnableTag("ALREADY_CONFRONTED_TAG");
		gameItem.AddItemFeature(ItemFeatureList.ConfrontSucessDiscount());
		InspectionUIManager.Instance.OnConfrontSuccess();
	}

	public static bool IsConfrontCorrect(string reason, GameItem item)
	{
		if (item.IsTag(reason))
		{
			return true;
		}
		return false;
	}
}
