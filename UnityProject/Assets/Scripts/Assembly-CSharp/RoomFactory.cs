using System;
using System.Collections.Generic;

public class RoomFactory
{
	public enum RoomPrefab
	{
		None = 0,
		hydroponics = 1,
		crew_quarter = 2,
		kitchen = 3,
		cafeteria = 4,
		infirmary = 5,
		workshop = 6,
		supply_depot = 7,
		kitchen_freezer = 8,
		power_bay = 9,
		checkpoint = 10,
		bridge = 11,
		engineering_bay = 12,
		security = 13,
		hallway = 14,
		armory = 15,
		operation_theater = 16,
		bar = 17,
		hydroponics_storage = 18,
		medbay = 19,
		medbay_reception = 20,
		barack = 21,
		medical_storage = 22,
		hotel_room = 23,
		hotel_reception = 24,
		marketplace = 25,
		marketplace_clinic = 26,
		marketplace_trader = 27,
		marketplace_military_surplus = 28,
		research_lab = 29,
		research_lab_medical = 30,
		research_lab_defense = 31,
		research_lobby = 32,
		trader_foundry = 33,
		trader_energy_farm = 34,
		trader_nutrifruit_farm = 35
	}

	public Dictionary<RoomPrefab, Func<Room.Type, Room>> RoomDictionary;

	private static RoomFactory instance = null;

	private static readonly object padlock = new object();

	public static RoomFactory Instance
	{
		get
		{
			lock (padlock)
			{
				if (instance == null)
				{
					instance = new RoomFactory();
					instance.RoomDictionary = new Dictionary<RoomPrefab, Func<Room.Type, Room>>();
					instance.RoomDictionary[RoomPrefab.hydroponics] = CreateHydroponic;
					instance.RoomDictionary[RoomPrefab.crew_quarter] = CreateCrewQuarter;
					instance.RoomDictionary[RoomPrefab.kitchen] = CreateKitchen;
					instance.RoomDictionary[RoomPrefab.cafeteria] = CreateCafeteria;
					instance.RoomDictionary[RoomPrefab.infirmary] = CreateInfirmary;
					instance.RoomDictionary[RoomPrefab.workshop] = CreateWorkshop;
					instance.RoomDictionary[RoomPrefab.supply_depot] = CreateWorkshop;
					instance.RoomDictionary[RoomPrefab.kitchen_freezer] = CreateFreezerRoom;
					instance.RoomDictionary[RoomPrefab.power_bay] = CreatePowerBay;
					instance.RoomDictionary[RoomPrefab.checkpoint] = CreateSecurityCheckpoint;
					instance.RoomDictionary[RoomPrefab.bridge] = CreateBridge;
					instance.RoomDictionary[RoomPrefab.engineering_bay] = CreateEngineering;
					instance.RoomDictionary[RoomPrefab.security] = CreateSecurity;
					instance.RoomDictionary[RoomPrefab.hallway] = CreateHallway;
					instance.RoomDictionary[RoomPrefab.armory] = CreateArmory;
					instance.RoomDictionary[RoomPrefab.operation_theater] = CreateOperationTheater;
					instance.RoomDictionary[RoomPrefab.bar] = CreateBar;
					instance.RoomDictionary[RoomPrefab.hydroponics_storage] = CreateHydroponicStorage;
					instance.RoomDictionary[RoomPrefab.barack] = CreateBarack;
					instance.RoomDictionary[RoomPrefab.medical_storage] = CreateMedicalStorageRoom;
					instance.RoomDictionary[RoomPrefab.medbay_reception] = CreateMedbayReception;
					instance.RoomDictionary[RoomPrefab.medbay] = CreateMedbay;
					instance.RoomDictionary[RoomPrefab.hotel_room] = CreateHotelRoom;
					instance.RoomDictionary[RoomPrefab.hotel_reception] = CreateHotelReception;
					instance.RoomDictionary[RoomPrefab.marketplace] = CreateMarketplace;
					instance.RoomDictionary[RoomPrefab.marketplace_clinic] = CreateMarketplaceClinic;
					instance.RoomDictionary[RoomPrefab.marketplace_trader] = CreateMarketplaceTrader;
					instance.RoomDictionary[RoomPrefab.marketplace_military_surplus] = CreateMarketplaceMilitarySurplus;
					instance.RoomDictionary[RoomPrefab.research_lab] = CreateLabRoom;
					instance.RoomDictionary[RoomPrefab.research_lab_medical] = CreateMedicalLabRoom;
					instance.RoomDictionary[RoomPrefab.research_lab_defense] = CreateDefenseLabRoom;
					instance.RoomDictionary[RoomPrefab.research_lobby] = CreateResearchDivision;
					instance.RoomDictionary[RoomPrefab.trader_foundry] = CreateMarketplaceFoundry;
					instance.RoomDictionary[RoomPrefab.trader_energy_farm] = CreateEnergyFarm;
					instance.RoomDictionary[RoomPrefab.trader_nutrifruit_farm] = CreateNutrifruitFarm;
				}
				return instance;
			}
		}
	}

	public static Room CreateCustomRoom(string roomName, Drops drops = null, Room.Type type = Room.Type.None)
	{
		Room room = new Room(roomName, type);
		if (drops != null)
		{
			room.AttachLootToBeSpawn(drops.GetDrops());
		}
		return room;
	}

	public static Room CreateMarketplace(Room.Type type = Room.Type.None)
	{
		return new Room("Marketplace", type)
		{
			theme = Room.Theme.Service
		};
	}

	public static Room CreateMarketplaceClinic(Room.Type type = Room.Type.None)
	{
		return new Room("Clinic", type)
		{
			theme = Room.Theme.Medical
		};
	}

	public static Room CreateMarketplaceTrader(Room.Type type = Room.Type.None)
	{
		return new Room("Shop", type)
		{
			theme = Room.Theme.Service
		};
	}

	public static Room CreateMarketplaceMilitarySurplus(Room.Type type = Room.Type.None)
	{
		return new Room("Military Surplus", type)
		{
			theme = Room.Theme.Service
		};
	}

	public static Room CreateArmory(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Armory", type);
		room.AttachLootToBeSpawn(DropDirectory.GetArmoryDrop().GetDrops());
		room.theme = Room.Theme.Military;
		return room;
	}

	public static Room CreateEngineering(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Engineering", type);
		room.AttachLootToBeSpawn(DropDirectory.GetHydroponicDrop().GetDrops());
		room.theme = Room.Theme.Engineering;
		return room;
	}

	public static Room CreatePowerBay(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Power Bay", type);
		room.AttachLootToBeSpawn(DropDirectory.GetPowerBayDrop().GetDrops());
		room.theme = Room.Theme.Engineering;
		return room;
	}

	public static Room CreateMedbay(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Medbay", type);
		room.AttachLootToBeSpawn(DropDirectory.GetMedbayDrop().GetDrops());
		room.theme = Room.Theme.Medical;
		return room;
	}

	public static Room CreateMedbayReception(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Medbay Reception", type);
		room.AttachLootToBeSpawn(DropDirectory.GetMedbayDrop().GetDrops());
		room.theme = Room.Theme.Medical;
		return room;
	}

	public static Room CreateOperationTheater(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Operation Theater", type);
		room.AttachLootToBeSpawn(DropDirectory.GetOperationTheaterDrop().GetDrops());
		room.theme = Room.Theme.Medical;
		return room;
	}

	public static Room CreateHydroponic(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Hydroponics", type);
		room.AttachLootToBeSpawn(DropDirectory.GetHydroponicDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateHydroponicStorage(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Hydroponics Storage", type);
		room.AttachLootToBeSpawn(DropDirectory.GetHydroponicDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateCanningRoom(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Canning Room", type);
		room.AttachLootToBeSpawn(DropDirectory.GetCanningRoomDrop().GetDrops());
		room.theme = Room.Theme.Manufacturing;
		return room;
	}

	public static Room CreateCrewQuarter(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Crew Quarter", type);
		room.AttachLootToBeSpawn(DropDirectory.GetCrewQuarterDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateBarack(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Barack", type);
		room.AttachLootToBeSpawn(DropDirectory.GetBarackDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateKitchen(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Kitchen", type);
		room.AttachLootToBeSpawn(DropDirectory.GetKitchenDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreatePantry(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Pantry", type);
		room.AttachLootToBeSpawn(DropDirectory.GetPantryDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateCafeteria(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Cafeteria", type);
		room.AttachLootToBeSpawn(DropDirectory.GetCafeteriaDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateBar(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Bar", type);
		room.AttachLootToBeSpawn(DropDirectory.GetCafeteriaDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateInfirmary(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Infirmary", type);
		room.AttachLootToBeSpawn(DropDirectory.GetInfirmaryDrop().GetDrops());
		room.theme = Room.Theme.Medical;
		return room;
	}

	public static Room CreateMedicalStorageRoom(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Medical Storage", type);
		room.AttachLootToBeSpawn(DropDirectory.GetMedicalStorageRoomDrop().GetDrops());
		room.theme = Room.Theme.Medical;
		return room;
	}

	public static Room CreateWorkshop(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Workshop", type);
		room.AttachLootToBeSpawn(DropDirectory.GetWorkshopDrop().GetDrops());
		room.theme = Room.Theme.Manufacturing;
		return room;
	}

	public static Room CreateSupplyDepot(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Supply Depot", type);
		room.AttachLootToBeSpawn(DropDirectory.GetSupplyDepotDrop().GetDrops());
		room.theme = Room.Theme.Manufacturing;
		return room;
	}

	public static Room CreateSecurityCheckpoint(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Security Checkpoint", type);
		room.AttachLootToBeSpawn(DropDirectory.GetSecurityCheckpointDrop().GetDrops());
		room.theme = Room.Theme.Security;
		return room;
	}

	public static Room CreateSecurity(Room.Type type = Room.Type.None)
	{
		return new Room("Security", type)
		{
			theme = Room.Theme.Security
		};
	}

	public static Room CreateHallway(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Hallway", type);
		room.AttachLootToBeSpawn(DropDirectory.GetHallwayDrop().GetDrops());
		room.theme = Room.Theme.Default;
		return room;
	}

	public static Room CreateEntrance(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Station Entrance", type);
		room.AttachLootToBeSpawn(DropDirectory.GetEntranceDrop().GetDrops());
		room.theme = Room.Theme.Security;
		return room;
	}

	public static Room CreateBridge(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Bridge", type);
		room.AttachLootToBeSpawn(DropDirectory.GetBridgeDrop().GetDrops());
		room.theme = Room.Theme.Command;
		return room;
	}

	public static Room CreateFreezerRoom(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Freezer Room", type);
		room.AttachLootToBeSpawn(DropDirectory.GetFreezerRoomDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateHotelRoom(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Hotel Room", type);
		room.AttachLootToBeSpawn(DropDirectory.GetCrewQuarterDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateHotelReception(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Hotel Reception", type);
		room.AttachLootToBeSpawn(DropDirectory.GetCrewQuarterDrop().GetDrops());
		room.theme = Room.Theme.Service;
		return room;
	}

	public static Room CreateLabRoom(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Laboratory", type);
		room.AttachLootToBeSpawn(DropDirectory.GetLabDrop().GetDrops());
		room.theme = Room.Theme.Research;
		return room;
	}

	public static Room CreateMedicalLabRoom(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Medical Research Laboratory", type);
		room.AttachLootToBeSpawn(DropDirectory.GetLabMedicalDrop().GetDrops());
		room.theme = Room.Theme.Research;
		return room;
	}

	public static Room CreateDefenseLabRoom(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Defense Research Laboratory", type);
		room.AttachLootToBeSpawn(DropDirectory.GetLabDefenseDrop().GetDrops());
		room.theme = Room.Theme.Research;
		return room;
	}

	public static Room CreateResearchDivision(Room.Type type = Room.Type.None)
	{
		Room room = new Room("Research Division", type);
		room.AttachLootToBeSpawn(DropDirectory.GetCrewQuarterDrop().GetDrops());
		room.theme = Room.Theme.Research;
		return room;
	}

	public static Room CreateMarketplaceFoundry(Room.Type type = Room.Type.None)
	{
		return new Room("Foundry", type)
		{
			theme = Room.Theme.Manufacturing
		};
	}

	public static Room CreateEnergyFarm(Room.Type type = Room.Type.None)
	{
		return new Room("Energy Farm", type)
		{
			theme = Room.Theme.Manufacturing
		};
	}

	public static Room CreateNutrifruitFarm(Room.Type type = Room.Type.None)
	{
		return new Room("Nutrifruit Farm", type)
		{
			theme = Room.Theme.Manufacturing
		};
	}
}
