using System;
using System.Collections.Generic;
using System.Linq;

public class ExchangeBarter
{
	public string identifier;

	public List<BarterCondition> conditions = new List<BarterCondition>();

	public int priority;

	public int barterCounterPerNight = 1;

	public int currentBarterCounter;

	public Action<List<GameItem>> onAccept;

	public bool isPromotional;

	public bool IsRequiredItemPresent()
	{
		if (GetRequiredItems().Count == conditions.Count && GetRequiredItems().Count != 0)
		{
			return true;
		}
		return false;
	}

	public List<GameItem> GetRequiredItemsOld()
	{
		List<GameItem> list = GraphUtils.FindAllChildrenType<GameItem>(EmporiumEntry.Instance.trashcan);
		List<GameItem> list2 = new List<GameItem>();
		foreach (BarterCondition condition in conditions)
		{
			foreach (GameItem item in list)
			{
				if (condition.IsItemValid(item))
				{
					list2.Add(item);
					list.Remove(item);
					break;
				}
			}
		}
		return list2;
	}

	private static readonly System.Reflection.MethodInfo __portHook0 = ProbablyStolen.Port.Mods.PortReflection.Method(typeof(ExchangeBarter), "GetRequiredItems", new System.Type[] {  });
[ProbablyStolen.Port.Mods.StaticHookTarget]
public List<GameItem> GetRequiredItems()
{
    if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks(__portHook0))
    {
        return __PortOriginal();
    }

    return ProbablyStolen.Port.Mods.StaticModHooks.Invoke<List<GameItem>>(__portHook0, this, new object[] { }, __portArguments =>
    {
        return __PortOriginal();
    });
    List<GameItem> __PortOriginal()
    {
        List<GameItem> source = GraphUtils.FindAllChildrenType<GameItem>(EmporiumEntry.Instance.trashcan) ?? new List<GameItem>();
        List<GameItem> list = new List<GameItem>();
        HashSet<GameItem> usedItems = new HashSet<GameItem>();
        foreach (BarterCondition condition in conditions)
        {
            GameItem gameItem = source.FirstOrDefault((GameItem gameItem2) => !usedItems.Contains(gameItem2) && condition.IsItemValid(gameItem2));
            if (gameItem != null)
            {
                list.Add(gameItem);
                usedItems.Add(gameItem);
            }
        }

        return list;
    }
}

	private static readonly System.Reflection.MethodInfo __portHook1 = ProbablyStolen.Port.Mods.PortReflection.Method(typeof(ExchangeBarter), "CanAccept", new System.Type[] {  });
[ProbablyStolen.Port.Mods.StaticHookTarget]
public bool CanAccept()
{
    if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks(__portHook1))
    {
        return __PortOriginal();
    }

    return ProbablyStolen.Port.Mods.StaticModHooks.Invoke<bool>(__portHook1, this, new object[] { }, __portArguments =>
    {
        return __PortOriginal();
    });
    bool __PortOriginal()
    {
        if (IsRequiredItemPresent())
        {
            return currentBarterCounter > 0;
        }

        return false;
    }
}

	private static readonly System.Reflection.MethodInfo __portHook2 = ProbablyStolen.Port.Mods.PortReflection.Method(typeof(ExchangeBarter), "Accept", new System.Type[] {  });
[ProbablyStolen.Port.Mods.StaticHookTarget]
public void Accept()
{
    if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks(__portHook2))
    {
        __PortOriginal();
        return;
    }

    ProbablyStolen.Port.Mods.StaticModHooks.Invoke<object>(__portHook2, this, new object[] { }, __portArguments =>
    {
        __PortOriginal();
        return null;
    });
    void __PortOriginal()
    {
        if (IsRequiredItemPresent())
        {
            Debug.Log(identifier + " Exchange Accepted");
            List<GameItem> requiredItems = GetRequiredItems();
            currentBarterCounter--;
            if (onAccept != null)
            {
                onAccept(requiredItems);
            }

            for (int num = requiredItems.Count - 1; num >= 0; num--)
            {
                requiredItems[num].Destroy();
            }
        }
    }
}

	public void Reset()
	{
		currentBarterCounter = barterCounterPerNight;
	}
}
