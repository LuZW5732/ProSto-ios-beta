using TMPro;
using UnityEngine;
using UnityEngine.Localization;

public class FontLoader : MonoBehaviour
{
	public enum FontRole
	{
		Noto_Sans = 0,
		Noto_Serif = 1,
		Rubik = 2,
		Caveat = 3,
		Lubrifont = 4,
		Tektur = 5,
		Tektur_Bold = 6,
		Noto_Sans_Normal = 7,
		Noto_Serif_Medium = 8,
		Noto_Sans_Bold = 9,
		Noto_Serif_Bold = 10
	}

	public TMP_FontAsset westernFont;

	public TMP_FontAsset japaneseFont;

	public TMP_FontAsset koreanFont;

	public TMP_FontAsset simplifiedChineseFont;

	public TMP_FontAsset simplifiedChineseHandwrittenFont;

	public TMP_FontAsset koreanHandwrittenFont;

	public TMP_FontAsset koreanScifiFont;

	public TMP_FontAsset japaneseHandwrittenFont;

	public TMP_FontAsset japaneseScifiFont;

	public TMP_FontAsset notoSans;

	public TMP_FontAsset notoSans_Normal;

	public TMP_FontAsset notoSerif;

	public TMP_FontAsset notoSerif_Medium;

	public TMP_FontAsset rubik;

	public TMP_FontAsset caveat;

	public TMP_FontAsset lubrifont;

	public TMP_FontAsset tektur;

	public TMP_FontAsset tektur_Bold;

	public TMP_FontAsset notoSans_Bold;

	public TMP_FontAsset notoSerif_Bold;

	public TMP_FontAsset polishDisplayFont;

	public static FontLoader Instance { get; private set; }

	private void Awake()
	{
		Debug.Log("FontLoader Awake");
		if (Instance != null && Instance != this)
		{
			Object.Destroy(base.gameObject);
		}
		else
		{
			Instance = this;
#if UNITY_IOS
			var sans = InstallGlyphFallback(simplifiedChineseFont);
			InstallGlyphFallback(simplifiedChineseHandwrittenFont, sans);
			InstallGlyphFallback(lubrifont, sans);
#endif
		}
	}

#if UNITY_IOS
	// Recovered atlas pages are imported textures. Keep them for baked glyphs
	// and rasterize additional glyphs into TMP-owned writable atlas pages.
	private static TMP_FontAsset InstallGlyphFallback(TMP_FontAsset baked, TMP_FontAsset lastResort = null)
	{
		if (baked == null) return lastResort;
		var fallbacks = baked.fallbackFontAssetTable;
		if (fallbacks == null)
			baked.fallbackFontAssetTable = fallbacks = new System.Collections.Generic.List<TMP_FontAsset>();
		string name = baked.name + " iOS dynamic glyphs";
		foreach (var font in fallbacks)
			if (font != null && font.name == name) return font;
		var source = baked.sourceFontFile;
		if (source == null) return lastResort;
		var dynamicFont = TMP_FontAsset.CreateFontAsset(source);
		if (dynamicFont == null) return lastResort;
		dynamicFont.name = name;
		dynamicFont.isMultiAtlasTexturesEnabled = true;
		fallbacks.Add(dynamicFont);
		if (lastResort != null && !fallbacks.Contains(lastResort)) fallbacks.Add(lastResort);
		baked.atlasPopulationMode = AtlasPopulationMode.Static;
		return dynamicFont;
	}
#endif

	private void Start()
	{
	}

	private void Update()
	{
	}

	public TMP_FontAsset GetFontByRole(FontRole role, Locale locale)
	{
		string code = locale.Identifier.Code;
		if (code == "pl" && role == FontRole.Lubrifont && polishDisplayFont != null)
		{
			return polishDisplayFont;
		}
		switch (code)
		{
		case "en":
		case "fr":
		case "de":
		case "ptBR":
		case "it":
		case "es":
		case "ru":
		case "pl":
			return role switch
			{
				FontRole.Noto_Sans => notoSans, 
				FontRole.Noto_Serif => notoSerif, 
				FontRole.Rubik => rubik, 
				FontRole.Caveat => caveat, 
				FontRole.Lubrifont => lubrifont, 
				FontRole.Tektur => tektur, 
				FontRole.Tektur_Bold => tektur_Bold, 
				FontRole.Noto_Sans_Normal => notoSans_Normal, 
				FontRole.Noto_Serif_Medium => notoSerif_Medium, 
				FontRole.Noto_Sans_Bold => notoSans_Bold, 
				FontRole.Noto_Serif_Bold => notoSerif_Bold, 
				_ => notoSans, 
			};
		case "ja":
			return role switch
			{
				FontRole.Caveat => japaneseHandwrittenFont, 
				FontRole.Tektur => japaneseScifiFont, 
				FontRole.Tektur_Bold => japaneseScifiFont, 
				FontRole.Lubrifont => japaneseScifiFont, 
				_ => japaneseFont, 
			};
		case "ko":
			return role switch
			{
				FontRole.Caveat => koreanHandwrittenFont, 
				FontRole.Tektur => koreanScifiFont, 
				FontRole.Tektur_Bold => koreanScifiFont, 
				FontRole.Lubrifont => koreanScifiFont, 
				_ => koreanFont, 
			};
		case "zh-Hans":
		case "zh":
			return role switch
			{
				FontRole.Caveat => simplifiedChineseHandwrittenFont, 
				FontRole.Tektur => lubrifont, 
				FontRole.Tektur_Bold => lubrifont, 
				FontRole.Lubrifont => lubrifont, 
				_ => simplifiedChineseFont, 
			};
		default:
			return notoSans;
		}
	}
}
