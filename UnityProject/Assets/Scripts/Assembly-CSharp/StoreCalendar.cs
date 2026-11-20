using TMPro;

public class StoreCalendar : TooltipInterface, IClickable
{
	public TextMeshProUGUI dayTMP;

	private static readonly System.Reflection.MethodInfo __portHook0 = ProbablyStolen.Port.Mods.PortReflection.Method(typeof(StoreCalendar), "GetTooltip", new System.Type[] {  });
[ProbablyStolen.Port.Mods.StaticHookTarget]
public override string GetTooltip()
{
    if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks(__portHook0))
    {
        return __PortOriginal();
    }

    return ProbablyStolen.Port.Mods.StaticModHooks.Invoke<string>(__portHook0, this, new object[] { }, __portArguments =>
    {
        return __PortOriginal();
    });
    string __PortOriginal()
    {
        return LocHelper.GetLocalizedUI("inte_calendar_hover");
    }
}

	public override bool IsTooltipEnabled()
	{
		return true;
	}

	public void OnClick()
	{
		AdvCalendarUIManager.Instance.ToggleUI();
	}

	private void Start()
	{
	}

	private void Update()
	{
		if (!(dayTMP == null))
		{
			string text = (PlayerStore.Instance.isPayingMortgage ? LocHelper.GetLocalizedMechanic("mech_calendar_keyword_payment") : LocHelper.GetLocalizedMechanic("mech_calendar_keyword_rent"));
			string text2 = "";
			if (!PlayerStore.Instance.IsPropertyPaid)
			{
				int rentDayCounter = PlayerStore.Instance.GetRentDayCounter();
				text2 = rentDayCounter switch
				{
					0 => LocHelper.GetLocalizedMechanic("mech_calendar_due_today", text), 
					1 => LocHelper.GetLocalizedMechanic("mech_calendar_due_tomorrow", text), 
					_ => LocHelper.GetLocalizedMechanic("mech_calendar_due_in_days", text, rentDayCounter), 
				};
			}
			string localizedMechanic = LocHelper.GetLocalizedMechanic("mech_calendar_day", StoreStation.Instance.dayCounter, GetDayOfWeek());
			dayTMP.text = localizedMechanic + "\n" + text2;
		}
	}

	public string GetDayOfWeek()
	{
		return (StoreStation.Instance.dayCounter % 7) switch
		{
			0 => LocHelper.GetLocalizedMechanic("mech_calendar_sunday"), 
			1 => LocHelper.GetLocalizedMechanic("mech_calendar_monday"), 
			2 => LocHelper.GetLocalizedMechanic("mech_calendar_tuesday"), 
			3 => LocHelper.GetLocalizedMechanic("mech_calendar_wednesday"), 
			4 => LocHelper.GetLocalizedMechanic("mech_calendar_thursday"), 
			5 => LocHelper.GetLocalizedMechanic("mech_calendar_friday"), 
			6 => LocHelper.GetLocalizedMechanic("mech_calendar_saturday"), 
			_ => "Error", 
		};
	}
}
