using System;
using UnityEngine;

public class DropTableItem
{
	public enum Distribution
	{
		Fixed = 0,
		Normal = 1,
		Uniform = 2,
		Beta = 3
	}

	public int id { get; set; }

	public int quantityLow { get; set; }

	public int quantityHigh { get; set; }

	public int quantityFixed { get; set; }

	public int weight { get; set; }

	public Func<int, GameItem> dropFunction { get; set; }

	public Distribution distribution { get; set; }

	public DropTableItem()
	{
		distribution = Distribution.Fixed;
		quantityFixed = 1;
		weight = 1;
	}

	public int GetQuantity()
	{
		if (distribution == Distribution.Fixed)
		{
			return quantityFixed;
		}
		if (distribution == Distribution.Uniform)
		{
			return UnityEngine.Random.Range(quantityLow, quantityHigh);
		}
		if (distribution == Distribution.Normal)
		{
			return quantityFixed;
		}
		_ = distribution;
		_ = 3;
		return quantityFixed;
	}
}
