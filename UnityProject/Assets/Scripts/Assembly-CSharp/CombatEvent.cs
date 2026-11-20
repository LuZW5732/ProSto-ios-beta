using System;

public class CombatEvent
{
	public enum TargetType
	{
		PlayerTeam = 0,
		AiTeam = 1,
		All = 2,
		None = 3,
		Special = 4
	}

	public enum EventType
	{
		Countdown = 0
	}

	public enum UpdateType
	{
		TurnStart = 0,
		TurnEnd = 1
	}

	public string name { get; set; }

	public TargetType targetType { get; set; }

	public EventType eventType { get; set; }

	public UpdateType updateType { get; set; }

	public int duration { get; set; }

	public string description { get; set; }

	public Action<CombatManager, CombatEvent> InitCallback { get; set; }

	public Action<CombatManager, CombatEvent> UpdateCallback { get; set; }

	public Action<CombatManager, CombatEvent> ExpiredCallback { get; set; }

	public bool UpdateEvent(CombatManager combatManager)
	{
		duration--;
		if (duration == 0)
		{
			if (ExpiredCallback != null)
			{
				ExpiredCallback(combatManager, this);
			}
			return true;
		}
		if (UpdateCallback != null)
		{
			UpdateCallback(combatManager, this);
		}
		return false;
	}
}
