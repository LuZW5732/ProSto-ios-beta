using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ES3CreateSlot : MonoBehaviour
{
	[Tooltip("The button used to bring up the 'Create Slot' dialog.")]
	public Button createButton;

	[Tooltip("The ES3SlotDialog Component of the Create Slot dialog")]
	public ES3SlotDialog createDialog;

	[Tooltip("The TMP_Text input text field of the create slot dialog.")]
	public TMP_InputField inputField;

	[Tooltip("The ES3SlotManager this Create Slot Dialog belongs to.")]
	public ES3SlotManager mgr;

	protected virtual void OnEnable()
	{
		base.gameObject.SetActive(mgr.showCreateSlotButton);
		createButton.onClick.AddListener(() =>
		{
			createDialog.gameObject.SetActive(value: true);
		});
		createDialog.confirmButton.onClick.AddListener(TryCreateNewSlot);
	}

	protected virtual void OnDisable()
	{
		inputField.text = string.Empty;
		createButton.onClick.RemoveAllListeners();
		createDialog.confirmButton.onClick.RemoveAllListeners();
	}

	public virtual void TryCreateNewSlot()
	{
		if (string.IsNullOrEmpty(inputField.text))
		{
			mgr.ShowErrorDialog("You must specify a name for your save slot");
			return;
		}
		if (ES3.FileExists(mgr.GetSlotPath(inputField.text)))
		{
			mgr.ShowErrorDialog("A slot already exists with this name. Please choose a different name.");
			return;
		}
		CreateNewSlot(inputField.text);
		inputField.text = "";
		createDialog.gameObject.SetActive(value: false);
	}

	protected virtual void CreateNewSlot(string slotName)
	{
		DateTime now = DateTime.Now;
		mgr.InstantiateSlot(slotName, now).transform.SetSiblingIndex(1);
	}
}
