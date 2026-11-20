using System.Collections.Generic;
using System.Linq;

public class MachineFurnace
{
	public static GameItem Furnace()
	{
		(PixelWindow, GameSlotInventory, GameInventory, GameGridInventory, GameInventory, GameSlotInventory) tuple = CreateMachineInventoryWindow(8, 8);
		GameInventory item = tuple.Item4;
		PixelWindow item2 = tuple.Item1;
		GameSlotInventory itemInventoryBattery = tuple.Item2;
		GameInventory itemInventoryModule = tuple.Item3;
		GameInventory itemInventoryLeft = item;
		GameInventory itemInventoryRight = tuple.Item5;
		GameSlotInventory item3 = tuple.Item6;
		item3.mayInventoryAddItemFunc = (GameItem gameItem, GameInventory _) => gameItem.identifier.Equals("postit");
		item3.SetBackgroundFadeSprite("Items/items_tool", "postit");
		itemInventoryLeft.mayInventoryAddItemFunc = (GameItem gameItem, GameInventory _) =>
		{
			if (!GeneralHelper.IsItemOwned(gameItem))
			{
				return false;
			}
			if (gameItem.identifier.Equals("junk") && HaveJunkModule(itemInventoryModule))
			{
				return true;
			}
			return gameItem.identifier.Equals("scrap_metal") || gameItem.identifier.Equals("common_ore") || gameItem.identifier.Equals("flux_agent") || gameItem.identifier.Equals("advanced_flux_agent");
		};
		itemInventoryRight.mayInventoryAddItemFunc = (GameItem _, GameInventory _) => false;
		GameItem furnace = ItemDirectory.CreateEmptyItem().SetContentWindow(item2).SetSpriteAndShape("Items/items_tool2", "furnace");
		furnace.name = LocHelper.GetLocalizedItem("item_furnace_name");
		furnace.shortDescription = LocHelper.GetLocalizedItem("item_furnace_desc");
		furnace.unitValue = 200L;
		furnace.EnableTag("CONTAINER_TAG");
		furnace.EnableTag("STANDARD_MACHINE_TAG");
		furnace.EnableTag("manufacture");
		MachineHelper.SetupBatterySlot(itemInventoryBattery, furnace);
		MachineryHelper.InitMachinery(furnace, 8);
		string[] tags = new string[2] { "MODULE_TYPE_UNIVERSAL", "MODULE_TYPE_FURNACE" };
		ContainerHelper.AllowOnlyTaggedItemsOr(itemInventoryModule, tags, ownedOnly: true);
		itemInventoryModule.onSlotAddItemEndFunc = (GameItem addedItem, GameInventory parentInventory, SlotMarker slot) =>
		{
			ModuleEffectHelper.OnAddedModuleToGrid(addedItem, furnace, itemInventoryModule.childItems);
			if (addedItem.IsTag("MODULE_TAG"))
			{
				ModuleHelper.ComputeModuleEffect(itemInventoryModule, addedItem, furnace);
				ModuleHelper.ApplyBasicModuleEffect(itemInventoryModule, addedItem, furnace);
			}
			MachineryHelper.UpdatePowerUsageProcessTypeMachine(furnace);
		};
		itemInventoryModule.onSlotRemoveItemEndFunc = (GameItem addedItem, GameInventory parentInventory, SlotMarker slot) =>
		{
			ModuleEffectHelper.OnRemovedModuleFromGrid(addedItem, furnace, itemInventoryModule.childItems);
			if (addedItem.IsTag("MODULE_TAG"))
			{
				ModuleHelper.ComputeModuleEffect(itemInventoryModule, addedItem, furnace);
				ModuleHelper.ApplyBasicModuleEffect(itemInventoryModule, addedItem, furnace);
			}
			MachineryHelper.UpdatePowerUsageProcessTypeMachine(furnace);
		};
		furnace.onCycleEndSlotItemFunc = (GameItem gameItem6, GameInventory parentInventory, SlotMarker slot) =>
		{
			itemInventoryRight.mayInventoryAddItemFunc = (GameItem gameItem10, GameInventory _) =>
			{
				if (!GeneralHelper.IsItemOwned(gameItem10))
				{
					return false;
				}
				return gameItem10.IsGameItemType("MATERIAL") ? true : false;
			};
			GameItem gameItem = DirectoryMaster.Item("metal_ingot");
			bool num = GraphUtils.CanAccept(itemInventoryRight, gameItem);
			gameItem.Destroy();
			if (num)
			{
				List<GameItem> first = GraphUtils.FindAllChildrenType(itemInventoryLeft, (GameItem gameItem10) => gameItem10.identifier == "scrap_metal");
				List<GameItem> second = GraphUtils.FindAllChildrenType(itemInventoryLeft, (GameItem gameItem10) => gameItem10.identifier == "common_ore");
				List<GameItem> list = first.Concat(second).ToList();
				GameItem gameItem2 = GraphUtils.FindChildType(itemInventoryLeft, (GameItem gameItem10) => gameItem10.identifier == "flux_agent");
				GameItem gameItem3 = GraphUtils.FindChildType(itemInventoryLeft, (GameItem gameItem10) => gameItem10.identifier == "advanced_flux_agent");
				GameItem gameItem4 = GraphUtils.FindChildType(itemInventoryModule, (GameItem gameItem10) => gameItem10.identifier == "furnace_module_blast");
				GameItem gameItem5 = GraphUtils.FindChildType(itemInventoryModule, (GameItem gameItem10) => gameItem10.identifier == "furnace_module_junk");
				bool flag = false;
				int num2 = 2;
				if (gameItem4 != null)
				{
					num2 = 3;
				}
				if (list.Count >= num2 && itemInventoryBattery.childItem != null)
				{
					int machinePowerUsage = MachineryHelper.GetMachinePowerUsage(gameItem6);
					if (PowerHelper.DrawPowerSource(itemInventoryBattery.childItem, machinePowerUsage))
					{
						int num3 = MachineryHelper.GetCurrentQualityBonus(furnace) / 100;
						if (gameItem4 != null)
						{
							num3--;
						}
						if (gameItem3 != null)
						{
							if (num3 < 1)
							{
								num3 = 1;
							}
						}
						else if (gameItem2 != null && num3 < 1)
						{
							num3 = 1;
							gameItem2.Destroy();
						}
						List<GameItem> range = list.GetRange(list.Count - num2, num2);
						GameItem gameItem7 = DirectoryMaster.Item("metal_ingot");
						IngotPurityHelper.SetPurityFromInput(gameItem7, range, num3);
						GraphUtils.EmporiumTryAdd(itemInventoryRight, gameItem7);
						if (gameItem4 != null)
						{
							GameItem gameItem8 = DirectoryMaster.Item("metal_ingot");
							IngotPurityHelper.SetPurityFromInput(gameItem8, range, num3);
							GraphUtils.EmporiumTryAdd(itemInventoryRight, gameItem8);
						}
						foreach (GameItem item5 in range)
						{
							item5.Destroy();
						}
						flag = true;
						MachineHelper.OnMachineActioned(furnace, itemInventoryModule);
					}
				}
				if (!flag && gameItem5 != null)
				{
					List<GameItem> list2 = GraphUtils.FindAllChildrenType(itemInventoryLeft, (GameItem gameItem10) => gameItem10.identifier == "junk");
					if (list2.Count >= 6 && itemInventoryBattery.childItem != null)
					{
						GameItem gameItem9 = DirectoryMaster.Item("scrap_metal");
						bool num4 = GraphUtils.CanAccept(itemInventoryRight, gameItem9);
						gameItem9.Destroy();
						int machinePowerUsage2 = MachineryHelper.GetMachinePowerUsage(gameItem6);
						if (num4 && PowerHelper.DrawPowerSource(itemInventoryBattery.childItem, machinePowerUsage2))
						{
							for (int num5 = 0; num5 < 6; num5++)
							{
								list2[num5].Destroy();
							}
							for (int num6 = 0; num6 < 4; num6++)
							{
								GameItem item4 = DirectoryMaster.Item("scrap_metal");
								GraphUtils.EmporiumTryAdd(itemInventoryRight, item4);
							}
							MachineHelper.OnMachineActioned(furnace, itemInventoryModule);
						}
					}
				}
				itemInventoryRight.mayInventoryAddItemFunc = (GameItem _, GameInventory _) => false;
			}
		};
		return furnace;
	}

	public static void Produce()
	{
	}

	public static (PixelWindow, GameSlotInventory, GameInventory, GameGridInventory, GameInventory, GameSlotInventory) CreateMachineInventoryWindow(int width, int height, bool isDraggable = true, bool isCentered = true, int minWidth = 5)
	{
		GameSlotInventory gameSlotInventory = new GameSlotInventory();
		GameGridInventory gameGridInventory = new GameGridInventory("10000010001000001110000010001000001", 7);
		GameGridInventory gameGridInventory2 = new GameGridInventory(9, 6);
		GameGridInventory gameGridInventory3 = new GameGridInventory(9, 6);
		GameSlotInventory gameSlotInventory2 = new GameSlotInventory();
		return (MachineHelper.CreateMachineryWindow(isDraggable, MachineHelper.PowerPanel(gameSlotInventory), MachineHelper.Panel(LocHelper.GetLocalizedMechanic("mech_furnace_label_module"), gameGridInventory, "module"), MachineHelper.Panel(LocHelper.GetLocalizedMechanic("mech_furnace_label_input"), gameGridInventory2, "input"), MachineHelper.Panel(LocHelper.GetLocalizedMechanic("mech_furnace_label_output"), gameGridInventory3, "output"), MachineHelper.NotePanel(gameSlotInventory2)), gameSlotInventory, gameGridInventory, gameGridInventory2, gameGridInventory3, gameSlotInventory2);
	}

	public static GameItem CreateNote()
	{
		GameItem gameItem = DirectoryMaster.Item("postit");
		gameItem.name = LocHelper.GetLocalizedItem("item_furnace_instruction_name");
		gameItem.flavorText = LocHelper.GetLocalizedItem("item_furnace_instruction_flavor");
		gameItem.shortDescription = LocHelper.GetLocalizedItem("item_furnace_instruction_short");
		gameItem.SetGameItemType("DOCUMENT");
		gameItem.EnableTag("IMPORTANT_TAG");
		gameItem.unitValue = 0L;
		return gameItem;
	}

	public static bool HaveJunkModule(GameInventory moduleInventory)
	{
		return GraphUtils.FindChildType(moduleInventory, (GameItem item) => item.identifier == "furnace_module_junk") != null;
	}
}
