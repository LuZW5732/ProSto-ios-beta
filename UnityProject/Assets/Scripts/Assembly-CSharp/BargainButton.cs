using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

[RequireComponent(typeof(Button))]
public class BargainButton : MonoBehaviour, IPointerEnterHandler, IEventSystemHandler, IPointerExitHandler
{
	[SerializeField]
	private BargainType bargainType;

	[SerializeField]
	private int percent;

	private Button button;

	private void Awake()
	{
		button = GetComponent<Button>();
	}

	private static readonly System.Reflection.MethodInfo __portHook0 = ProbablyStolen.Port.Mods.PortReflection.Method(typeof(BargainButton), "Setup", new System.Type[] { typeof(BargainType), typeof(int) });
[ProbablyStolen.Port.Mods.StaticHookTarget]
public void Setup(BargainType type, int magnitude)
{
    if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks(__portHook0))
    {
        __PortOriginal();
        return;
    }

    ProbablyStolen.Port.Mods.StaticModHooks.Invoke<object>(__portHook0, this, new object[] { type, magnitude }, __portArguments =>
    {
        type = (BargainType)__portArguments[0];
        magnitude = (int)__portArguments[1];
        __PortOriginal();
        return null;
    });
    void __PortOriginal()
    {
        bargainType = type;
        percent = magnitude;
    }
}

	private static readonly System.Reflection.MethodInfo __portHook1 = ProbablyStolen.Port.Mods.PortReflection.Method(typeof(BargainButton), "OnPointerEnter", new System.Type[] { typeof(PointerEventData) });
[ProbablyStolen.Port.Mods.StaticHookTarget]
public void OnPointerEnter(PointerEventData eventData)
{
    if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks(__portHook1))
    {
        __PortOriginal();
        return;
    }

    ProbablyStolen.Port.Mods.StaticModHooks.Invoke<object>(__portHook1, this, new object[] { eventData }, __portArguments =>
    {
        eventData = (PointerEventData)__portArguments[0];
        __PortOriginal();
        return null;
    });
    void __PortOriginal()
    {
        if (!(BargainUIManager.Instance == null))
        {
            BargainUIManager.Instance.SetRepPreview(bargainType, percent);
            if ((!(button != null) || button.IsInteractable()) && TooltipManager._instance != null)
            {
                TooltipManager._instance.SetAndShowTooltip(BargainUIManager.Instance.GetBargainTooltip(bargainType, percent), this);
            }
        }
    }
}

	public void OnPointerExit(PointerEventData eventData)
	{
		if (BargainUIManager.Instance != null)
		{
			BargainUIManager.Instance.ClearRepPreview();
		}
		if (TooltipManager._instance != null)
		{
			TooltipManager._instance.HideTooltip();
		}
	}

	private void OnDisable()
	{
		if (BargainUIManager.Instance != null)
		{
			BargainUIManager.Instance.ClearRepPreview();
		}
		if (TooltipManager._instance != null)
		{
			TooltipManager._instance.HideTooltip();
		}
	}
}
