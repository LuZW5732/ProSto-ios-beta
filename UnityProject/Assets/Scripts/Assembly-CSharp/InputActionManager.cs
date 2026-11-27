using Input = ProbablyStolen.Port.PortInput;
using System.Collections.Generic;
using UnityEngine;

public class InputActionManager : MonoBehaviour
{
	public static InputActionManager current;

	public List<InputActionHandler> actionHandlers = new List<InputActionHandler>();

	private ISet<KeyCode> tempKeysPressed = new HashSet<KeyCode>();

	private ISet<KeyCode> tempKeysReleased = new HashSet<KeyCode>();

	private Vector3 lastMousePosition;

	[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
	private void Awake()
	{
		current = this;
	}

	private void Start()
	{
		lastMousePosition = Vector3.zero;
	}

	public bool Add(InputActionHandler actionHandler)
	{
		if (actionHandlers.Contains(actionHandler))
		{
			return false;
		}
		actionHandlers.Add(actionHandler);
		return true;
	}

	public void ResetAfter(InputActionHandler actionHandler)
	{
		bool flag = false;
		for (int i = 0; i < actionHandlers.Count; i++)
		{
			if (flag)
			{
				actionHandlers[i].UpdateReset();
			}
			if (actionHandlers[i] == actionHandler)
			{
				flag = true;
			}
		}
	}

	public void ResetBefore(InputActionHandler actionHandler)
	{
		bool flag = true;
		for (int i = 0; i < actionHandlers.Count; i++)
		{
			if (actionHandlers[i] == actionHandler)
			{
				flag = false;
			}
			if (flag)
			{
				actionHandlers[i].UpdateReset();
			}
		}
	}

	public void ResetExcept(InputActionHandler actionHandler)
	{
		for (int i = 0; i < actionHandlers.Count; i++)
		{
			if (actionHandlers[i] != actionHandler)
			{
				actionHandlers[i].UpdateReset();
			}
		}
	}

	public void CancelPointerActions()
	{
		var dragHandler = GetComponentInChildren<ItemMouseDragHandler>() ?? FindObjectOfType<ItemMouseDragHandler>();
		if (dragHandler != null)
		{
			dragHandler.UpdateReset();
		}
		for (int i = 0; i < actionHandlers.Count; i++)
		{
			if (actionHandlers[i] != null && actionHandlers[i].enabled)
			{
				actionHandlers[i].UpdateReset();
			}
		}
		Reset();
		lastMousePosition = Input.mousePosition;
		CustomEventHandler.ClearDoubleClickTarget();
	}

	private void Update()
	{
		if (Input.Active && ProbablyStolen.Port.PortInput.Cancelled)
		{
			CancelPointerActions();
			return;
		}

		Vector3 mousePosition = Input.mousePosition;
		Vector3 mouseDelta = mousePosition - lastMousePosition;
		actionHandlers.Sort((InputActionHandler a, InputActionHandler b) => b.priority.CompareTo(a.priority));
		for (int num = 0; num < actionHandlers.Count; num++)
		{
			actionHandlers[num].Check();
		}
		for (int num2 = 0; num2 < actionHandlers.Count; num2++)
		{
			UpdateKeys(actionHandlers[num2].keyListeners);
			actionHandlers[num2].UpdateRelease(tempKeysReleased);
			actionHandlers[num2].UpdatePress(tempKeysPressed);
			actionHandlers[num2].UpdateMouseMove(mousePosition, mouseDelta);
			actionHandlers[num2].UpdateMouseScroll(Input.mouseScrollDelta);
			if (actionHandlers[num2].UpdateUpdate())
			{
				break;
			}
		}
		lastMousePosition = Input.mousePosition;
	}

	private static readonly System.Reflection.MethodInfo __portHook0 = ProbablyStolen.Port.Mods.PortReflection.Method(typeof(InputActionManager), "UpdateKeys", new System.Type[] { typeof(List<KeyCode>) });
[ProbablyStolen.Port.Mods.StaticHookTarget]
private void UpdateKeys(List<KeyCode> keyListeners)
{
    if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks(__portHook0))
    {
        __PortOriginal();
        return;
    }

    ProbablyStolen.Port.Mods.StaticModHooks.Invoke<object>(__portHook0, this, new object[] { keyListeners }, __portArguments =>
    {
        keyListeners = (List<KeyCode>)__portArguments[0];
        __PortOriginal();
        return null;
    });
    void __PortOriginal()
    {
        tempKeysPressed.Clear();
        tempKeysReleased.Clear();
        bool flag = StoreUIManager.IsAnyTyping() || KeyBindHelper.SuppressHotkeys;
        foreach (KeyCode keyListener in keyListeners)
        {
            if (!flag && Input.GetKeyDown(keyListener))
            {
                tempKeysPressed.Add(keyListener);
            }

            if (Input.GetKeyUp(keyListener))
            {
                tempKeysReleased.Add(keyListener);
            }

            if (!KeyBindHelper.SuppressHotkeys && GetMouseKeyDown(keyListener))
            {
                tempKeysPressed.Add(keyListener);
            }

            if (GetMouseKeyUp(keyListener))
            {
                tempKeysReleased.Add(keyListener);
            }
        }
    }
}

	public void Reset()
	{
		tempKeysPressed.Clear();
		tempKeysReleased.Clear();
	}

	private bool GetMouseKeyDown(KeyCode code)
	{
		return code switch
		{
			KeyCode.Mouse0 => Input.GetMouseButtonDown(0), 
			KeyCode.Mouse1 => Input.GetMouseButtonDown(1), 
			KeyCode.Mouse2 => Input.GetMouseButtonDown(2), 
			KeyCode.Mouse3 => Input.GetMouseButtonDown(3), 
			KeyCode.Mouse4 => Input.GetMouseButtonDown(4), 
			KeyCode.Mouse5 => Input.GetMouseButtonDown(5), 
			KeyCode.Mouse6 => Input.GetMouseButtonDown(6), 
			_ => false, 
		};
	}

	private bool GetMouseKeyUp(KeyCode code)
	{
		return code switch
		{
			KeyCode.Mouse0 => Input.GetMouseButtonUp(0), 
			KeyCode.Mouse1 => Input.GetMouseButtonUp(1), 
			KeyCode.Mouse2 => Input.GetMouseButtonUp(2), 
			KeyCode.Mouse3 => Input.GetMouseButtonUp(3), 
			KeyCode.Mouse4 => Input.GetMouseButtonUp(4), 
			KeyCode.Mouse5 => Input.GetMouseButtonUp(5), 
			KeyCode.Mouse6 => Input.GetMouseButtonUp(6), 
			_ => false, 
		};
	}
}
