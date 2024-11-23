LorePlay = LorePlay or {}
-- --- definitions : local event codes for LibEventHandler
local EVENT_ON_SMART_EMOTE = "EVENT_ON_SMART_EMOTE"
local EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE = "EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE"

-- ------------------------------------------------------------

-- === SmartEmotes.lua ===

local SmartEmotes = LorePlay
local L = GetString

local indicator
local wasIndicatorTurnedOffForTTL
local indicatorFadeIn
local indicatorFadeOut
local timelineFadeIn
local timelineFadeOut

local EVENT_STARTUP = "EVENT_STARTUP"
local EVENT_KILLED_CREATURE = "EVENT_KILLED_CREATURE"
local EVENT_POWER_UPDATE_STAMINA = "EVENT_POWER_UPDATE_STAMINA"
local EVENT_RETICLE_TARGET_CHANGED_TO_FRIEND = "EVENT_RETICLE_TARGET_CHANGED_TO_FRIEND"
local EVENT_RETICLE_TARGET_CHANGED_TO_EPIC = "EVENT_RETICLE_TARGET_CHANGED_TO_EPIC"
local EVENT_RETICLE_TARGET_CHANGED_TO_EPIC_SAME = "EVENT_RETICLE_TARGET_CHANGED_TO_EPIC_SAME"
local EVENT_RETICLE_TARGET_CHANGED_TO_NORMAL = "EVENT_RETICLE_TARGET_CHANGED_TO_NORMAL"
local EVENT_RETICLE_TARGET_CHANGED_TO_SPOUSE = "EVENT_RETICLE_TARGET_CHANGED_TO_SPOUSE"
local EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT = "EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT"
local EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT_FLED = "EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT_FLED"
local EVENT_PLAYER_COMBAT_STATE_INCOMBAT = "EVENT_PLAYER_COMBAT_STATE_INCOMBAT"
local EVENT_LOCKPICK_SUCCESS_EASY = "EVENT_LOCKPICK_SUCCESS_EASY"
local EVENT_LOCKPICK_SUCCESS_MEDIUM = "EVENT_LOCKPICK_SUCCESS_MEDIUM"
local EVENT_LOCKPICK_SUCCESS_HARD = "EVENT_LOCKPICK_SUCCESS_HARD"
local EVENT_LOOT_RECEIVED_RUNE_TA = "EVENT_LOOT_RECEIVED_RUNE_TA"
local EVENT_LOOT_RECEIVED_RUNE_REKUTA = "EVENT_LOOT_RECEIVED_RUNE_REKUTA"
local EVENT_LOOT_RECEIVED_RUNE_KUTA = "EVENT_LOOT_RECEIVED_RUNE_KUTA"
local EVENT_LOOT_RECEIVED_UNIQUE = "EVENT_LOOT_RECEIVED_UNIQUE"
local EVENT_LOOT_RECEIVED_GENERAL = "EVENT_LOOT_RECEIVED_GENERAL"
local EVENT_LOOT_RECEIVED_BETTER = "EVENT_LOOT_RECEIVED_BETTER"
local EVENT_LOOT_RECEIVED_RECIPE_OR_MATERIAL = "EVENT_LOOT_RECEIVED_RECIPE_OR_MATERIAL"
local EVENT_LOOT_RECEIVED_RARE_RECIPE_OR_MATERIAL = "EVENT_LOOT_RECEIVED_RARE_RECIPE_OR_MATERIAL"
local EVENT_KILLED_BOSS = "EVENT_KILLED_BOSS"
local EVENT_INDICATOR_ON = "EVENT_INDICATOR_ON"
local EVENT_BANKED_MONEY_UPDATE_GROWTH = "EVENT_BANKED_MONEY_UPDATE_GROWTH"
local EVENT_BANKED_MONEY_UPDATE_DOUBLE = "EVENT_BANKED_MONEY_UPDATE_DOUBLE"
local EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG = "EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG"
local EVENT_PLEDGE_OF_MARA_RESULT_PLEDGED = "EVENT_PLEDGE_OF_MARA_RESULT_PLEDGED"

local isMounted
local isInCombat
local lockpickQuality
local defaultEmotes
local defaultEmotesByRegionKeys
local defaultEmotesByCityKeys
local defaultEmotesForDungeons
local defaultEmotesForDolmens
local defaultEmotesForHousing
local eventTTLEmotes
local eventLatchedEmotes
local loadedOrCreatedEmotesTable
local reticleEmotesTable
local lastEventTimeStamp
local existsPreviousEvent
local lastLatchedEvent
local emoteFromLatched
local emoteFromReticle
local lastEmoteUsed = 0

local emoteFromTTL = {}
local lockpickValues = {
	[LOCK_QUALITY_PRACTICE] = 1,
	[LOCK_QUALITY_TRIVIAL] = 2,
	[LOCK_QUALITY_SIMPLE] = 3,
	[LOCK_QUALITY_INTERMEDIATE] = 4,
	[LOCK_QUALITY_ADVANCED] = 5,
	[LOCK_QUALITY_MASTER] = 6,
	[LOCK_QUALITY_IMPOSSIBLE] = 7
}
local runeQualityToEvents = {
	[ITEM_QUALITY_NORMAL] = EVENT_LOOT_RECEIVED_RUNE_TA,
	[ITEM_QUALITY_ARTIFACT] = EVENT_LOOT_RECEIVED_RUNE_REKUTA,
	[ITEM_QUALITY_LEGENDARY] = EVENT_LOOT_RECEIVED_RUNE_KUTA
}

-- ---------
local zoneIdDatabase = {	---------------------- zoneId database table for RegionKeys, converted from languageTable.zoneToRegionEmotes
		-- NOTE : by Calamath
		--	 This table will need to be updated as new regions are implemented in future DLCs or Chapters.
		--	 The word 'zone' here means the parent zone id.
		--	 emoteKey indicates which region the zone belongs to. SmartEmote feature uses this data to select the emote table.
		--
	[381]	= { emoteKey = "ad1", 	}, 		-- Auridon
	[383]	= { emoteKey = "ad2", 	}, 		-- Grahtwood
	[108]	= { emoteKey = "ad2", 	}, 		-- Greenshade
	[537]	= { emoteKey = "ad1", 	}, 		-- Khenarthi's Roost
	[58]	= { emoteKey = "ad2", 	}, 		-- Malabal Tor
	[382]	= { emoteKey = "ad2", 	}, 		-- Reaper's March
	[104]	= { emoteKey = "dc1", 	}, 		-- Alik'r Desert
	[92]	= { emoteKey = "dc1", 	}, 		-- Bangkorai
	[535]	= { emoteKey = "dc2", 	}, 		-- Betnikh
	[3]		= { emoteKey = "dc2", 	}, 		-- Glenumbra
	[20]	= { emoteKey = "dc2", 	}, 		-- Rivenspire
	[19]	= { emoteKey = "dc2", 	}, 		-- Stormhaven
	[534]	= { emoteKey = "dc1", 	}, 		-- Stros M'Kai
	[281]	= { emoteKey = "ep2", 	}, 		-- Bal Foyen
	[280]	= { emoteKey = "ep2", 	}, 		-- Bleakrock Isle
	[57]	= { emoteKey = "ep2", 	}, 		-- Deshaan
	[101]	= { emoteKey = "ep1", 	}, 		-- Eastmarch
	[103]	= { emoteKey = "ep1", 	}, 		-- The Rift
	[117]	= { emoteKey = "ep3", 	}, 		-- Shadowfen
	[41]	= { emoteKey = "ep2", 	}, 		-- Stonefalls
	[347]	= { emoteKey = "ch", 	}, 		-- Coldharbour
	[888]	= { emoteKey = "other", }, 		-- Craglorn
	[181]	= { emoteKey = "ip", 	}, 		-- Cyrodiil
	[823]	= { emoteKey = "other", }, 		-- Gold Coast
	[816]	= { emoteKey = "other", }, 		-- Hew's Bane
	[726]	= { emoteKey = "ep3", 	}, 		-- Murkmire
	[684]	= { emoteKey = "other", }, 		-- Wrothgar
	[849]	= { emoteKey = "ep2", 	}, 		-- Vvardenfell
	[980]	= { emoteKey = "other", }, 		-- Clockwork City
	[267]	= { emoteKey = "ad1", 	}, 		-- Eyevea
	[1011]	= { emoteKey = "ad1", 	},		-- Summerset
	[1086]	= { emoteKey = "other", },		-- Northern Elsweyr
	[1133]	= { emoteKey = "other", },		-- Southern Elsweyr
	[1160]	= { emoteKey = "ep1", 	},		-- Western Skyrim
	[1161]	= { emoteKey = "other", },		-- Blackreach: Greymoor Caverns
	[1207]	= { emoteKey = "ep1", 	},		-- The Reach
	[1208]	= { emoteKey = "other", },		-- Blackreach: Arkthzand Cavern
	[1261]	= { emoteKey = "ep3", 	}, 		-- Blackwood
	[1282]	= { emoteKey = "other", },		-- Fargrave
	[1286]	= { emoteKey = "other", },		-- The Deadlands
	[1318]	= { emoteKey = "dc2", 	},		-- High Isle
	[1383]	= { emoteKey = "dc2", 	},		-- Galen
	[1414]	= { emoteKey = "ep2", 	},		-- Telvanni Peninsula
	[1443]	= { emoteKey = "other",	},		-- West Weald
	[1463]	= { emoteKey = "ad1",	},		-- The Scholarium

}
-- ---------
local mapIdDatabase = {	-------------------------- mapId database table for CityKeys, converted from languageTable.defaultEmotesByCity
		-- NOTE : by Calamath
		--	 This table will need to be updated as new regions are implemented in future DLCs or Chapters.
		--	 The word 'mapId' here means the mapId not mapIndex.
		--	 emoteKey indicates which region the map belongs to. SmartEmote feature uses this data to select the emote table.
		--	 useMapBorder indicates a special map that uses map borders instead of subzone borders for city recognition.  Set this flag only on special indoor maps.
		--	 noSubZone indicates a special map where no city subzones are defined.
		--
	[445]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root
	[446]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root
	[447]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root
	[448]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root
	[449]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root
	[450]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root
	[451]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root
	[571]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root
	[243]	= { emoteKey = "Vulkhel Guard", }, 		-- Vulkhel Guard
	[205]	= { emoteKey = "Mournhold", 	}, 		-- Mournhold
	[160]	= { emoteKey = "Windhelm", 		}, 		-- Windhelm
	[198]	= { emoteKey = "Riften", 		}, 		-- Riften
	[33]	= { emoteKey = "Wayrest", 		}, 		-- Wayrest

	[993]	= { emoteKey = "DC", 			}, 		-- Abah's Landing
	[1038]	= { emoteKey = "DC", 			}, 		-- Abah's Landing
	[1039]	= { emoteKey = "DC", 			}, 		-- Abah's Landing
	[531]	= { emoteKey = "DC", 			}, 		-- Aldcroft
	[1074]	= { emoteKey = "Other", 		}, 		-- Anvil
	[1343]	= { emoteKey = "Other", 		}, 		-- Anvil
	[535]	= { emoteKey = "AD", 			}, 		-- Arenthia
	[282]	= { emoteKey = "AD", 			}, 		-- Baandari Trading Post
	[1131]	= { emoteKey = "DC", 			}, 		-- Belkarth
--			= { emoteKey = "DC", 			}, 		-- Camlorn
	[1348]	= { emoteKey = "EP", 			}, 		-- Brass Fortress
	[63]	= { emoteKey = "DC", 			}, 		-- Daggerfall
	[24]	= { emoteKey = "EP", 			}, 		-- Davon's Watch
	[533]	= { emoteKey = "AD", 			}, 		-- Dune
	[342]	= { emoteKey = "EP", 			}, 		-- Ebonheart
	[511]	= { emoteKey = "EP", 			}, 		-- Ebonheart
--			= { emoteKey = "DC", 			}, 		-- Elinhir
	[84]	= { emoteKey = "DC", 			}, 		-- Evermore
	[540]	= { emoteKey = "AD", 			}, 		-- Firsthold
	[360]	= { emoteKey = "DC", 			}, 		-- Hallin's Stand
	[512]	= { emoteKey = "AD", 			}, 		-- Haven
--			= { emoteKey = "Other", 		}, 		-- Hollow City
	[422]	= { emoteKey = "Other", 		}, 		-- The Hollow City
	[660]	= { emoteKey = "Other", 		}, 		-- Imperial City
	[538]	= { emoteKey = "DC", 			}, 		-- Kozanset
	[510]	= { emoteKey = "EP", 			}, 		-- Kragenmoor
	[1064]	= { emoteKey = "Other", 		}, 		-- Kvatch
	[387]	= { emoteKey = "AD", 			}, 		-- Marbruk
	[567]	= { emoteKey = "AD", 			}, 		-- Mistral
	[513]	= { emoteKey = "DC", 			}, 		-- Northpoint
	[895]	= { emoteKey = "DC", 			}, 		-- Orsinium
	[530]	= { emoteKey = "DC", 			}, 		-- Port Hunding
	[312]	= { emoteKey = "AD", 			}, 		-- Rawl'kha
	[83]	= { emoteKey = "DC", 			}, 		-- Sentinel
	[85]	= { emoteKey = "DC", 			}, 		-- Shornhelm
--			= { emoteKey = "AD", 			}, 		-- Silvenar
--			= { emoteKey = "AD", 			}, 		-- Silvenar's Audience Hall
	[217]	= { emoteKey = "EP", 			}, 		-- Stormhold
--			= { emoteKey = "DC", 			}, 		-- Tava's Blessing
	[545]	= { emoteKey = "AD", 			}, 		-- Skywatch
	[529]	= { emoteKey = "AD", 			}, 		-- Woodhearth
	[1287]	= { emoteKey = "EP", 			}, 		-- Vivec City
	[1220]	= { emoteKey = "EP", 			}, 		-- Vivec City (Palace Receiving Room)
	[1221]	= { emoteKey = "EP", 			}, 		-- Vivec City (Lord Vivec's Chambers)
	[1222]	= { emoteKey = "EP", 			}, 		-- Vivec City (Library of Vivec)
	[1224]	= { emoteKey = "EP", 			}, 		-- Vivec City (Archcanon's Office)
	[1225]	= { emoteKey = "EP", 			}, 		-- Vivec City (Hall of Justice)
	[1230]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saint Olms Plaza)
	[1231]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saint Olms Waistworks)
	[1232]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saint Olms Square)
	[1233]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saint Olms Guild Halls)
	[1234]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saint Delyn Plaza)
	[1235]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saint Delyn Waistworks)
	[1236]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saing Delyn Square)
	[1237]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saint Delyn Guild Halls)
	[1238]	= { emoteKey = "EP", 			}, 		-- Vivec City (Saint Delyn's Inn)
--			= { emoteKey = "EP", 			}, 		-- Seyda Neen
	[1290]	= { emoteKey = "EP", 			}, 		-- Balmora
	[1288]	= { emoteKey = "EP", 			}, 		-- Sadrith Mora
	[1430]	= { emoteKey = "AD", 			}, 		-- Alinor
	[1445]	= { emoteKey = "AD", 			}, 		-- Alinor (Alinor Royal Palace)    note: Dungeon
	[1431]	= { emoteKey = "AD", 			}, 		-- Shimmerene
	[1455]	= { emoteKey = "AD", 			}, 		-- Lillandril
	[1560]	= { emoteKey = "EP", 			}, 		-- Lilmoth
	[1576]	= { emoteKey = "Other", 		}, 		-- Rimmen
	[1675]	= { emoteKey = "Other", noSubZone = true, 		}, 		-- Senchal
	[1690]	= { emoteKey = "Other", useMapBorder = true, 	}, 		-- Senchal Palace
	[1762]	= { emoteKey = "Other", 		}, 		-- Senchal
	[1773]	= { emoteKey = "EP", 			}, 		-- Solitude
	[1858]	= { emoteKey = "EP", 			}, 		-- Markarth
	[1888]	= { emoteKey = "EP", useMapBorder = true,		}, 		-- Understone Keep
	[1940]	= { emoteKey = "EP", noSubZone = true, 			}, 		-- Leyawiin
	[2018]	= { emoteKey = "EP", 			}, 		-- Gideon
	[2035]	= { emoteKey = "Other", useMapBorder = true, 	}, 		-- Fargrave City District
	[2080]	= { emoteKey = "Other", useMapBorder = true		}, 		-- Fargrave City District (1st floor of the Collector's Villa)
	[2136]	= { emoteKey = "Other", useMapBorder = true, 	}, 		-- Fargrave City District (The Bazaar)
	[2163]	= { emoteKey = "DC", noSubZone = true,			}, 		-- Gonfalon Bay
	[2214]	= { emoteKey = "DC", 			}, 		-- Amenos Station
	[2227]	= { emoteKey = "DC", noSubZone = true,			}, 		-- Vastyr
	[2279]	= { emoteKey = "DC", useMapBorder = true, 	}, 		-- Castle Mornard (Vastyr)
	[2280]	= { emoteKey = "DC", useMapBorder = true, 	}, 		-- Castle Mornard (Vastyr)
	[2281]	= { emoteKey = "DC", useMapBorder = true, 	}, 		-- Castle Mornard (Vastyr)
	[2343]	= { emoteKey = "EP", 			}, 		-- Necrom
	[2385]	= { emoteKey = "EP", 			}, 		-- Necrom Underways
	[2514]	= { emoteKey = "Other", 		}, 		-- Skingrad

}
-- ---------
local subZoneIdDatabase = {	---------------------- subZoneId database table for CityKeys, converted from languageTable.defaultEmotesByCity
		-- NOTE : by Calamath
		--	 Using subZoneId is a special case, such as a city without its sub-map, or an enclave, etc.
		--	 This table will need to be updated as new regions are implemented in future DLCs or Chapters.
		--	 emoteKey indicates which region the subzone belongs to. SmartEmote feature uses this data to select the emote table.
		--
	[279]	= { emoteKey = "DC", 			}, 		-- Camlorn
	[7829]	= { emoteKey = "DC", 			}, 		-- Elinhir
	[10941]	= { emoteKey = "DC", 			}, 		-- Elinhir
--	[8006]	= { emoteKey = "DC", 			}, 		-- Elinhir Wayshrine
--	[11004]	= { emoteKey = "DC", 			}, 		-- Elinhir Wayshrine
	[4730]	= { emoteKey = "Other", 		}, 		-- The Hollow City
	[2955]	= { emoteKey = "AD", 			}, 		-- Silvenar
	[9348]	= { emoteKey = "AD", 			}, 		-- Silvenar Treetops
	[3370]	= { emoteKey = "AD", 			}, 		-- Silvenar's Audience Hall
	[933]	= { emoteKey = "DC", 			}, 		-- Tava's Blessing
	[11558]	= { emoteKey = "EP", 			}, 		-- Vivec City Wayshrine
	[11580]	= { emoteKey = "EP", 			}, 		-- Seyda Neen
	[11659]	= { emoteKey = "EP", 			}, 		-- Seyda Neen
	[11851]	= { emoteKey = "EP", 			}, 		-- Seyda Neen
	[12168]	= { emoteKey = "EP", 			}, 		-- Seyda Neen
--	[11549]	= { emoteKey = "EP", 			}, 		-- Seyda Neen Wayshrine
	[12386]	= { emoteKey = "EP", 			}, 		-- Illumination Academy (in Summerset)
	[14317]	= { emoteKey = "Other", 		}, 		-- Riverhold (in Northern Elsweyr)
	[15239]	= { emoteKey = "Other", 		},		-- Black Heights (in Southern Elsweyr)
	[15336]	= { emoteKey = "Other", 		},		-- Senchal (in Southern Elsweyr)
	[15545]	= { emoteKey = "EP", 			},		-- Solitude
	[15547]	= { emoteKey = "EP", 			},		-- Morthal (in Western Skyrim)
	[15744]	= { emoteKey = "EP", 			},		-- Morthal Wayshrine (in Western Skyrim)
--	[15550]	= { emoteKey = "EP", 			},		-- Dragon Bridge (in Western Skyrim)				--> If you want to add Dragon Bridge as a city, change this line manually.
--	[15754]	= { emoteKey = "EP", 			},		-- Dragon Bridge Wayshrine (in Western Skyrim)		--> If you want to add Dragon Bridge as a city, change this line manually.
	[15625]	= { emoteKey = "Other", 		},		-- Dusktown (in Blackreach Cavern)
	[16357]	= { emoteKey = "EP", 			},		-- Karthwasten (in the Reach)
	[17280]	= { emoteKey = "EP", 			}, 		-- Leyawiin (in Blackwood)
	[19422]	= { emoteKey = "DC", 			}, 		-- Vastyr (in Galen)
	[19942]	= { emoteKey = "EP", 			}, 		-- Necrom (in Telvanni Peninsula)
	[20988]	= { emoteKey = "Other",			}, 		-- Skingrad (in West Weald)
	[21008]	= { emoteKey = "Other",			}, 		-- Ontus (in West Weald)
	[20999]	= { emoteKey = "AD",			}, 		-- Vashabar (in West Weald)
	[21204]	= { emoteKey = "AD",			}, 		-- Vashabar Wayshrine (in West Weald)

--	[2092]	= { emoteKey = "Mournhold", 	}, 		-- Mournhold Plaza of the Gods	--> no longer needed
--	[2094]	= { emoteKey = "Mournhold", 	}, 		-- Mournhold Banking District	--> no longer needed
--	[6637]	= { emoteKey = "Elden Root", 	}, 		-- Elden Root Services			--> no longer needed
--	[11807]	= { emoteKey = "EP", 			}, 		-- Vivec Temple Wayshrine		--> no longer needed
}
-- ---------
local poiDatabase = {
		-- NOTE : by Calamath
		--	 Basically, this table should not be used, but for cities where subzones are not detectable.
	[2428019372] = { id = 15336, emoteKey = "Other", 	}, 		-- EN:Senchal
	[2224387413] = { id = 15336, emoteKey = "Other", 	}, 		-- DE:Senchal
	[3482854427] = { id = 15336, emoteKey = "Other", 	}, 		-- FR:Senchal, ES:Senchal
	[3754689769] = { id = 15336, emoteKey = "Other", 	}, 		-- JP:Senchal
	[824842596]	 = { id = 15336, emoteKey = "Other", 	}, 		-- RU:Senchal
	[2560225998] = { id = 15336, emoteKey = "Other", 	}, 		-- ZH:Senchal
	[4102247096] = { id = 17280, emoteKey = "EP", 		}, 		-- EN:Leyawiin
	[708531273]	 = { id = 17280, emoteKey = "EP", 		}, 		-- DE:Leyawiin
	[2666761760] = { id = 17280, emoteKey = "EP", 		}, 		-- FR:Leyawiin, ES:Leyawiin
	[1970724318] = { id = 17280, emoteKey = "EP", 		}, 		-- JP:Leyawiin
	[3595650480] = { id = 17280, emoteKey = "EP", 		}, 		-- RU:Leyawiin
	[1061249791] = { id = 17280, emoteKey = "EP", 		}, 		-- ZH:Leyawiin
}
-- ---------
local blacklistedDungeonDatabase = {
		-- NOTE : by Calamath
		--	 Basically, this table should not be used.
		--	 IsUnitInDungeon API returns TRUE in the dungeons, but zones registered in this table will be treated as FALSE.
		--   In other words, register only the zone ID of the dungeon that you absolutely want to recognize as a region area (adventure zone).
	[1048] = true, 			-- Alinor Royal Palace (in Summerset)
	[1191] = true, 			-- Blackreach Mzark Cavern (in Eastmarch)
	[1205] = true, 			-- Grayhome (in Rivenspire)
	[1245] = true, 			-- Borderwatch Ruins (in Blackwood)
	[1284] = true, 			-- The Collector's Villa (in Fargrave)
}
-- ---------
local harrowstormRitualSiteDatabase = {
	[15935] = true, 		-- Old Karth Ritual Site
	[15936] = true, 		-- Black Morass Ritual Site
	[15937] = true, 		-- Giant's Coast Ritual Site
	[15939] = true, 		-- Chilblain Peak Ritual Site
	[16003] = true, 		-- Hailstone Valley Ritual Site
	[16004] = true, 		-- Northern Watch Ritual Site
	[16086] = true, 		-- Gloomforest Ritual Site
	[16123] = true, 		-- Dwarf's Bane Ritual Site
	[16124] = true, 		-- Miner's Lament Ritual Site
	[16125] = true, 		-- Nightstone Ritual Site
--	----------------------------------------------------
	[16363] = true, 		-- Ragnvald Ritual Site
	[16364] = true, 		-- Witchborne Ritual Site
	[16368] = true, 		-- Harrowed Haunt Ritual Site
	[16369] = true, 		-- Reachwind Ritual Site
}
-- ---------
local mirrormoorMosaicDatabase = {
	[21298] = true, 		-- Ostumir Mirrormoor Mosaic
	[21302] = true, 		-- Sutch Mirrormoor Mosaic
	[21539] = true, 		-- Colovia Mirrormoor Mosaic
	[21540] = true, 		-- Silorn Mirrormoor Mosaic
}
-- ---------
local titleIdToMaleTitleName = {	------------------ titleId to male titleName table, converted from languageTable.playerTitles
	[41]	= L(SI_LOREPLAY_PC_TITLE_NAME_M_41), -- "Emperor"
	[42]	= L(SI_LOREPLAY_PC_TITLE_NAME_M_42), -- "Former Emperor"
	[47]	= L(SI_LOREPLAY_PC_TITLE_NAME_M_47), -- "Daedric Lord Slayer"
	[48]	= L(SI_LOREPLAY_PC_TITLE_NAME_M_48), -- "Savior of Nirn"
	[51]	= L(SI_LOREPLAY_PC_TITLE_NAME_M_51), -- "Dragonstar Arena Champion"
	[54]	= L(SI_LOREPLAY_PC_TITLE_NAME_M_54), -- "Maelstrom Arena Champion"
	[55]	= L(SI_LOREPLAY_PC_TITLE_NAME_M_55), -- "Stormproof"
	[56] 	= L(SI_LOREPLAY_PC_TITLE_NAME_M_56), -- "The Flawless Conqueror"
	[63] 	= L(SI_LOREPLAY_PC_TITLE_NAME_M_63), -- "Ophidian Overlord"
}
local titleIdToFemaleTitleName = {	------------------ titleId to female titleName table, converted from languageTable.playerTitles
	[41]	= L(SI_LOREPLAY_PC_TITLE_NAME_F_41), -- "Empress"
	[42]	= L(SI_LOREPLAY_PC_TITLE_NAME_F_42), -- "Former Empress"
	[47]	= L(SI_LOREPLAY_PC_TITLE_NAME_F_47), -- "Daedric Lord Slayer"
	[48]	= L(SI_LOREPLAY_PC_TITLE_NAME_F_48), -- "Savior of Nirn"
	[51]	= L(SI_LOREPLAY_PC_TITLE_NAME_F_51), -- "Dragonstar Arena Champion"
	[54]	= L(SI_LOREPLAY_PC_TITLE_NAME_F_54), -- "Maelstrom Arena Champion"
	[55]	= L(SI_LOREPLAY_PC_TITLE_NAME_F_55), -- "Stormproof"
	[56] 	= L(SI_LOREPLAY_PC_TITLE_NAME_F_56), -- "The Flawless Conqueror"
	[63] 	= L(SI_LOREPLAY_PC_TITLE_NAME_F_63), -- "Ophidian Overlord"
}
local TitleNameToTitleId = {}
-- ---------

local function fromSimpleFormat(listedEmoteTables)
	local emotesTable = {}

	if listedEmoteTables == nil or type(listedEmoteTables) ~= "table" then
		return {}
	end

	-- load emote value from list.
	local function enumerate(list)
		local emotes = {}
		local allEmotesTableExists = LPEmotesTable.allEmotesTable ~= nil
		local fallBackEmote = 91 -- /stretch
		for i, emote in ipairs(list) do
			emotes[i] = type(emote) == "string"
				and (allEmotesTableExists and LPEmotesTable.allEmotesTable[emote]["index"] or fallbackEmote)
				or emote
		end
		return emotes
	end

	for i, categoryTable in ipairs(listedEmoteTables) do
		local key = categoryTable["Key"] or categoryTable["EventName"] or i

		if categoryTable["SubEntries"] ~= nil then
			emotesTable[key] = {}
			for k1, subEntry in pairs(categoryTable["SubEntries"]) do
				emotesTable[key][k1] = {
					["Emotes"] =  enumerate(subEntry["Emotes"]),
				}
			end
		else
			emotesTable[key] = categoryTable
			emotesTable[key]["Emotes"] = enumerate(categoryTable["Emotes"] or {})
		end
	end
	return emotesTable
end

function SmartEmotes.RecreatDefaulSmartEmotes()
	local fromCode = {}

	local createdEmotesTable = {
		["EVENT_TTL_EMOTES"] =
		{
			{
				["EventName"] = EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG,
				["Duration"] = 5000,
				["Emotes"] = {115, 62, 22, 148, 134}
			},
			{
				["EventName"] = EVENT_KILLED_BOSS,
				["Duration"] = 30000,
				["Emotes"] = { 199, 161, 119, 178, 25, 151, 145, 62, 13, 22, 97, 8 },
			},
			{
				["EventName"] = EVENT_KILLED_CREATURE,
				["Duration"] = 30000,
				["Emotes"] = { },
			},
			{
				["EventName"] = EVENT_STARTUP,
				["Duration"] = 60000,
				["Emotes"] = { 91, 96, },
			},
			{
				["EventName"] = EVENT_LOOT_RECEIVED_BETTER,
				["Duration"] = 30000,
				["Emotes"] = { 130, 25, 25, 39, 14, 150, 54, 163, },
			},
			{
				["EventName"] = EVENT_LOOT_RECEIVED_RUNE_TA,
				["Duration"] = 20000,
				["Emotes"] = { 23, 29, 69, 73, 33, 134, 40, 133, },
			},
			{
				["EventName"] = EVENT_LOOT_RECEIVED_RUNE_REKUTA,
				["Duration"] = 20000,
				["Emotes"] = { 36,54,42,81,129,26, },
			},
			{
				["EventName"] = EVENT_LOOT_RECEIVED_RUNE_KUTA,
				["Duration"] = 30000,
				["Emotes"] = { 26, 67, 13, 66, 25, 162, 72, 149, },
			},
			{
				["EventName"] = EVENT_LOOT_RECEIVED_UNIQUE,
				["Duration"] = 30000,
				["Emotes"] = {},
			},
			{
				["EventName"] = EVENT_PLEDGE_OF_MARA_RESULT_PLEDGED,
				["Duration"] = 120000,
				["Emotes"] = { 20,21,130, },
			},
			{
				["EventName"] = EVENT_LOOT_RECEIVED_RARE_RECIPE_OR_MATERIAL,
				["Duration"] = 30000,
				["Emotes"] = { 26, 67, 13, 66, 25, 162, 72, 149, },
			},
			{
				["EventName"]  = EVENT_LOCKPICK_SUCCESS_EASY,
				["Duration"] = 30000,
				["Emotes"] = { 129, 42, 36, 78, 41, },
			},
			{
				["EventName"] = EVENT_LOCKPICK_SUCCESS_MEDIUM,
				["Duration"] = 30000,
				["Emotes"] = { 129, 36, 36, 91, 95, 95, },
			},
			{
				["EventName"] = EVENT_LOCKPICK_SUCCESS_HARD,
				["Duration"] = 30000,
				["Emotes"] = { 95, 25, 25, 25, 82, 149, 36, 26, 66, },
			},
			{
				["EventName"] = EVENT_PLAYER_COMBAT_STATE_INCOMBAT,
				["Duration"] = 20000,
				["Emotes"] = { 27, 159, 163, 106, 158, 158, },
			},
			{
				["EventName"] = EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT_FLED,
				["Duration"] = 15000,
				["Emotes"] = { 95, 95, 74, 73, 93, 109, 78, },
			},
			{
				["EventName"] = EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT,
				["Duration"] = 15000,
				["Emotes"] = { 78, 161, 39, 178, 52, 119, 199, },
			},
			{
				["EventName"] = EVENT_BANKED_MONEY_UPDATE_DOUBLE,
				["Duration"] = 30000,
				["Emotes"] = { 25, 193, 78, 82, 97, },
			},
			{
				["EventName"] = EVENT_BANKED_MONEY_UPDATE_GROWTH,
				["Duration"] = 30000,
				["Emotes"] = { 193, 193, 173, 198, 54, },
			},
			{
				["EventName"] = 131109, -- TODO 2024-11-23 where does this come from.
				["Duration"] = 20000,
				["Emotes"] = { 71, 115, 148, 12, 167, 133, 80, 172, },
			},
			{
				["EventName"] = 131498,
				["Duration"] = 30000,
				["Emotes"] = { 10, 125, 211, },
			},
			{
				["EventName"] = 131403,
				["Duration"] = 15000,
				["Emotes"] = { 148, 152, 169, 54, 81, 155, 32, 62, 44, 44, 44, 151, },
			},
			{
				["EventName"] = 131442,
				["Duration"] = 30000,
				["Emotes"] = { 164, 104, 52, 98, },
			},
			{
				["EventName"] = 131411,
				["Duration"] = 15000,
				["Emotes"] = { 130, 150, },
			},
			{
				["EventName"] = 131224,
				["Duration"] = 20000,
				["Emotes"] = { 91, 110, 80, },
			},
			{
				["EventName"] = 131110,
				["Duration"] = 15000,
				["Emotes"] = { 148, 133, 80, 33, },
			},
			{
				["EventName"] = 131130,
				["Duration"] = 120000,
				["Emotes"] = { 52, 8, 82, 164, 25, 129, 97, 97, 97, },
			},
			{
				["EventName"] = 131542,
				["Duration"] = 20000,
				["Emotes"] = { 32, 32, 154, 12, 166, 109, 109, },
			},
			{
				["EventName"] = 131391,
				["Duration"] = 30000,
				["Emotes"] = { 64, },
			},
		},
		["DEFAULT_EVENTS"] =
		{
			{
				["Key"] = "DEFAULT_EMOTES_BY_CITY_KEYS",
				["SubEntries"] = {
					["Vulkhel Guard"] = {
						["Emotes"] = { 8, 173, 8, 38, 190, 209, 11, 121, 52, 9, 91, 181, 5, 6, 7, 79, },
					},
					["EP"] = {
						["Emotes"] = { 173, 8, 52, 7, 202, 168, 121, 184, 5, 6, 72, 72, 187, 182, 100, 8, 79, },
					},
					["Windhelm"] = {
						["Emotes"] = { 8, 139, 162, 168, 5, 79, 208, 64, 173, 52, 187, 6, 7, 8, },
					},
					["Riften"] = {
						["Emotes"] = { 8, 139, 162, 168, 5, 79, 208, 64, 52, 187, 6, 7, 8, },
					},
					["Wayrest"] = {
						["Emotes"] = { 25, 52, 200, 11, 110, 122, 91, 38, 9, 91, 95, 95, 202, 202, 180, 5, 6, 7, 8, 79, },
					},
					["DC"] = {
						["Emotes"] = { 25, 52, 200, 11, 6, 122, 91, 38, 9, 72, 95, 7, 180, 5, 188, 189, 8, 79, },
					},
					["Elden Root"] = {
						["Emotes"] = { 8, 202, 202, 202, 202, 176, 173, 201, 99, 8, 52, 183, 5, 6, 7, 79, },
					},
					["AD"] = {
						["Emotes"] = { 176, 173, 201, 99, 8, 52, 183, 5, 6, 7, 72, 72, 181, 186, 52, 8, 79, },
					},
					["Other"] = {
						["Emotes"] = { 176, 8, 72, 72, 52, 5, 6, 7, 210, 100, 8, 79, },
					},
					["Mournhold"] = {
						["Emotes"] = { 173, 8, 52, 52, 202, 202, 121, 184, 5, 6, 7, 79, 8, },
					},
				},
			},
			{
				["Key"] = "DEFAULT_EMOTES_BY_REGION_KEYS",
				["SubEntries"] = {
					["ad2"] = {
						["Emotes"] = { 209, 119, 102, 200, 201, 99, 121, 38, 52, 104, 91, 209, 123, 104, },
					},
					["ep2"] = {
						["Emotes"] = { 110, 52, 200, 168, 177, 120, 91, 9, },
					},
					["dc2"] = {
						["Emotes"] = { 52, 119, 200, 99, 121, 38, 9, 91, 123, 104, },
					},
					["ep3"] = {
						["Emotes"] = { 52, 200, 168, 177, 201, 38, 9, 91, 104, },
					},
					["ip"] = {
						["Emotes"] = { 52, 34, 148, 110, 38, 9, 91, },
					},
					["ad1"] = {
						["Emotes"] = { 190, 190, 209, 173, 173, 11, 121, 38, 52, 9, 91, 209, },
					},
					["other"] = {
						["Emotes"] = { 9, 202, 54, 83, 91, 190, 40, 110, 176, 177, 173, 200, 138, 99, 121, 52, },
					},
					["ep1"] = {
						["Emotes"] = { 8, 168, 64, 213, 52, 38, 104, 64, 213, 168, },
					},
					["ch"] = {
						["Emotes"] = { 63, 27, 122, 52, 102, 104, },
					},
					["dc1"] = {
						["Emotes"] = { 52, 200, 11, 110, 122, 91, 38, 9, 91, 95, 95, 110, },
					},
				},
			},
			{
				["Key"] = "DEFAULT_EMOTES_FOR_HOUSING",
				["Emotes"] = { 91, 10, 138, 191, 192, 125, 113, 100, },
			},
			{
				["Key"] = "DEFAULT_EMOTES_FOR_DUNGEONS",
				["Emotes"] = { 63, 1, 101, 102, 52, 22, 170, 1, 22, },
			},
			{
				["Key"] = "DEFAULT_EMOTES_FOR_DOLMENS",
				["Emotes"] = { 63, 110, 101, 102, 52, 22, 170, 63, 22, 110, 151, },
			},
		},
		["RETICLE_EMOTES"] = {
			{
				["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_FRIEND,
				["Emotes"] = { 70, 72, 8, 137, 94, }
			},
			{
				["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_SPOUSE,
				["Emotes"] = { 70, 72, 8, 137, 21, 146, 39, 212, 165, 21, }
			},
			{
				["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_EPIC,
				["Emotes"] = { 142, 67, 212, 24, 174, 142, }
			},
			{
				["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_EPIC_SAME,
				["Emotes"] = { 56, 57, 58, }
			},
			{
				["EventName"] = EVENT_RETICLE_TARGET_CHANGED_TO_NORMAL,
				["Emotes"] = { 56, 136, 137, 17, }
			},
		},
		["LATCHED_EMOTES"] = {
			{
				["EventName"] = EVENT_POWER_UPDATE_STAMINA,
				["Emotes"] = { 114, },
			},
		},
	}
	for key, values in pairs(createdEmotesTable) do
		fromCode[key] = fromSimpleFormat(values)
	end
	return fromCode
end

function SmartEmotes.LoadSmartEmotesFromSavedVariables()
	local fromSaveedVariables = {}
	local savedVariables
		= LorePlaySavedCustomSmartEmotes and LorePlay.LPUtilities.DeepCopy(LorePlaySavedCustomSmartEmotes["EMOTES"] or {})
		or {}

	for key, values in pairs(savedVariables) do
		fromSaveedVariables[key] = fromSimpleFormat(values)
	end
	return fromSaveedVariables
end

function SmartEmotes.ReloadSmartEmotes()
	loadedOrCreatedEmotesTable = {}

	-- initial Smart Emote Setup by Code.
	local fromCodedEmotesTables
	fromCodedEmotesTables = SmartEmotes.RecreatDefaulSmartEmotes()

	-- loaded Smart Emote Setup from SavedVariables
	local fromSavedVariables
	fromSavedVariables = SmartEmotes.LoadSmartEmotesFromSavedVariables()

	-- Merge Together, keep From Configuration on Top.
	loadedOrCreatedEmotesTable = LorePlay.LPUtilities.DeepMergeTables(
		fromCodedEmotesTables,
		fromSavedVariables)

	loadedOrCreatedEmotesTable["Metadata"] = {
		["Loaded"] = os.date("%FT%T%z")
	}

	return loadedOrCreatedEmotesTable
end

local function GetRegionKeyByZoneId(zoneId)
	if zoneIdDatabase[zoneId] then return zoneIdDatabase[zoneId].emoteKey end
end

local function GetCityKeyByMapId(mapId)
	if mapIdDatabase[mapId] then return mapIdDatabase[mapId].emoteKey end
end

local function DoesUseMapBorder(mapId)
	if mapIdDatabase[mapId] then
		if mapIdDatabase[mapId].useMapBorder == true then
			return true
		end
	end
	return false
end

function SmartEmotes.HasCitySubZone(mapId)
	if mapIdDatabase[mapId] then
		if mapIdDatabase[mapId].noSubZone == true then
			return false
		end
	end
	return true
end

local function GetCityKeyBySubZoneId(subZoneId)
	if subZoneIdDatabase[subZoneId] then return subZoneIdDatabase[subZoneId].emoteKey end
end

local function GetCityKeyByPOIName(poiName)
	if type(poiName) == "string" then
		local v = poiDatabase[HashString(poiName)]
		if v then return v.emoteKey, v.id end
	end
end

local function TurnIndicatorOff()
	timelineFadeOut:PlayFromStart()
	indicator = false
end


local function TurnIndicatorOn()
	SmartEmotesIndicator:SetHidden(false)
	timelineFadeIn:PlayFromStart()
	indicator = true
end


function SmartEmotes.IsTargetSpouse()
	if GetUnitNameHighlightedByReticle() == LorePlay.db.maraSpouseName then
		return true
	end
	return false
end


local function UpdateEmoteFromReticle()
	local unitTitle = GetUnitTitle("reticleover")
	local unitTitleId
	if unitTitle then
		unitTitleId = TitleNameToTitleId[unitTitle]
	end

	if IsUnitFriend("reticleover") then
		if SmartEmotes.IsTargetSpouse() then
			emoteFromReticle = reticleEmotesTable[EVENT_RETICLE_TARGET_CHANGED_TO_SPOUSE]
		else
			emoteFromReticle = reticleEmotesTable[EVENT_RETICLE_TARGET_CHANGED_TO_FRIEND]
		end
	elseif unitTitleId ~= nil then
		local playerTitle = GetUnitTitle("player")
		local playerTitleId
		if playerTitle then
			playerTitleId = TitleNameToTitleId[playerTitle]
		end
		if unitTitleId == playerTitleId then
			emoteFromReticle = reticleEmotesTable[EVENT_RETICLE_TARGET_CHANGED_TO_EPIC_SAME]
		else
			emoteFromReticle = reticleEmotesTable[EVENT_RETICLE_TARGET_CHANGED_TO_EPIC]
		end
	else
		emoteFromReticle = reticleEmotesTable[EVENT_RETICLE_TARGET_CHANGED_TO_NORMAL]
	end
end


local function GetSmartEmoteIndex(emoteTable)
	local randomNumber, smartEmoteIndex
	randomNumber = math.random(#emoteTable["Emotes"])
	smartEmoteIndex = emoteTable["Emotes"][randomNumber]
	return smartEmoteIndex
end


local function GetNonRepeatEmoteIndex(emoteTable)
	-- Attempts to randomly select a different emote from the table than last time.
	-- However, after the maximum number of attempts, the same emotes as last time may be selected.
	local smartEmoteIndex
	local maximumAttempts = 4 + #emoteTable["Emotes"]			-- Number of emotes registered + 4 times
	for i = 1, maximumAttempts do
		smartEmoteIndex = GetSmartEmoteIndex(emoteTable)
		if lastEmoteUsed ~= smartEmoteIndex then break end
	end
	return smartEmoteIndex
end


function SmartEmotes.PerformSmartEmote()
	if IsPlayerMoving() or isMounted then return end
	local smartEmoteIndex, wasReticle, wasTTL
	if IsUnitPlayer("reticleover") and
	not SmartEmotes.DoesEmoteFromTTLEqualEvent(EVENT_TRADE_SUCCEEDED, EVENT_TRADE_CANCELED) then
		UpdateEmoteFromReticle()
		smartEmoteIndex = GetNonRepeatEmoteIndex(emoteFromReticle)
		wasReticle = true
	elseif eventLatchedEmotes["isEnabled"] then
		smartEmoteIndex = GetNonRepeatEmoteIndex(emoteFromLatched)
	elseif eventTTLEmotes["isEnabled"] then
		smartEmoteIndex = GetNonRepeatEmoteIndex(emoteFromTTL)
		wasTTL = true
	else
		SmartEmotes.UpdateDefaultEmotesTable()
		smartEmoteIndex = GetNonRepeatEmoteIndex(defaultEmotes)
	end
	LPEventHandler:FireEvent(EVENT_ON_SMART_EMOTE, false, smartEmoteIndex)
	PlayEmoteByIndex(smartEmoteIndex)
	if not LorePlay.db.isSmartEmotesIndicatorOn then return end
	if indicator and not wasReticle then
		TurnIndicatorOff()
		if wasTTL then
			wasIndicatorTurnedOffForTTL = true
		end
	end
	lastEmoteUsed = smartEmoteIndex
end


function SmartEmotes.DisableTTLEmotes()
	eventTTLEmotes["isEnabled"] = false
	if not LorePlay.db.isSmartEmotesIndicatorOn then return end
	if indicator and not eventLatchedEmotes["isEnabled"] then
		TurnIndicatorOff()
	end
end


function SmartEmotes.DisableLatchedEmotes()
	eventLatchedEmotes["isEnabled"] = false
	if not LorePlay.db.isSmartEmotesIndicatorOn then return end
	if indicator and not eventTTLEmotes["isEnabled"] or wasIndicatorTurnedOffForTTL then
		TurnIndicatorOff()
	end
end


function SmartEmotes.CheckToDisableTTLEmotes()
	local now = GetTimeStamp()
	local resetDurInSecs = emoteFromTTL["Duration"]/1000
	if GetDiffBetweenTimeStamps(now, lastEventTimeStamp) >= resetDurInSecs then
		SmartEmotes.DisableTTLEmotes()
	end
end


function SmartEmotes.UpdateLatchedEmoteTable(eventCode)
	if not eventCode then return end
	if not eventLatchedEmotes[eventCode] then return end
	--if emoteFromLatched == eventLatchedEmotes[eventCode] and eventLatchedEmotes["isEnabled"] then return end
	emoteFromLatched = eventLatchedEmotes[eventCode]
	eventLatchedEmotes["isEnabled"] = true
	if not LorePlay.db.isSmartEmotesIndicatorOn then return end
	if not indicator then
		TurnIndicatorOn()
	end
end


function SmartEmotes.UpdateTTLEmoteTable(eventCode)
	if eventCode == nil then return end
	if eventTTLEmotes[eventCode] == nil then return end
	lastEventTimeStamp = GetTimeStamp()
	if not eventTTLEmotes["isEnabled"] then
		eventTTLEmotes["isEnabled"] = true
	end
	emoteFromTTL = eventTTLEmotes[eventCode]
	zo_callLater(SmartEmotes.CheckToDisableTTLEmotes, eventTTLEmotes[eventCode]["Duration"])
	if not LorePlay.db.isSmartEmotesIndicatorOn then return end
	if not indicator then
		TurnIndicatorOn()
	end
	wasIndicatorTurnedOffForTTL = false
end


function SmartEmotes.CreateEmotesByRegionTable()
--	SmartEmotes.defaultEmotesByRegion = {
	defaultEmotesByRegionKeys = loadedOrCreatedEmotesTable["DEFAULT_EVENTS"]["DEFAULT_EMOTES_BY_REGION_KEYS"]
end


function SmartEmotes.CreateEmotesByCityTable()
	-- NOTE : by Calamath
	-- these unique emote tables with special city name dentifiers were imported from table languageTable.defaultEmotesByCity.
	defaultEmotesByCityKeys = loadedOrCreatedEmotesTable["DEFAULT_EVENTS"]["DEFAULT_EMOTES_BY_CITY_KEYS"]
end


function SmartEmotes.CreateDungeonTable()
	defaultEmotesForDungeons = loadedOrCreatedEmotesTable["DEFAULT_EVENTS"]["DEFAULT_EMOTES_FOR_DUNGEONS"]
end


function SmartEmotes.CreateDolmenTable()
	defaultEmotesForDolmens =  loadedOrCreatedEmotesTable["DEFAULT_EVENTS"]["DEFAULT_EMOTES_FOR_DOLMENS"]
end


function SmartEmotes.CreateHousingTable()
	defaultEmotesForHousing = loadedOrCreatedEmotesTable["DEFAULT_EVENTS"]["DEFAULT_EMOTES_FOR_HOUSING"]
end


function SmartEmotes.CreateDefaultEmoteTables()
	SmartEmotes.CreateEmotesByRegionTable()
	SmartEmotes.CreateEmotesByCityTable()
	SmartEmotes.CreateDungeonTable()
	SmartEmotes.CreateDolmenTable()
	SmartEmotes.CreateHousingTable()
end


function SmartEmotes.CreateReticleEmoteTable()
	reticleEmotesTable = loadedOrCreatedEmotesTable["RETICLE_EMOTES"]
end


function SmartEmotes.CreateLatchedEmoteEventTable()
	eventLatchedEmotes = loadedOrCreatedEmotesTable["LATCHED_EMOTES"]

	eventLatchedEmotes["isEnabled"] = false -- initially disenabled.

	-- refine.
	eventLatchedEmotes[EVENT_POWER_UPDATE_STAMINA]["Switch"] = function()
		local currentStam, _, effectiveMaxStam = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
		if currentStam < effectiveMaxStam*(.60) then
			return true
		end
	end
end


function SmartEmotes.CreateTTLEmoteEventTable()
	-- Duration in miliseconds that the emote should be playable
	local defaultDuration = 30000
	eventTTLEmotes = loadedOrCreatedEmotesTable["EVENT_TTL_EMOTES"]
	eventTTLEmotes["isEnabled"] = false -- initially disenabled.
end


function SmartEmotes.CreateTitleNameReverseTable()
	for k, v in pairs(titleIdToMaleTitleName) do
		TitleNameToTitleId[v] = k
	end
	for k, v in pairs(titleIdToFemaleTitleName) do
		TitleNameToTitleId[v] = k
	end
end


function SmartEmotes.IsPlayerInHouse()
	local currHouseId = GetCurrentZoneHouseId()
	if currHouseId ~= 0 then
		return true
	end
	return false
end


--[[
function SmartEmotes.ThisZoneIsParentZone(zoneId)
	if GetParentZoneId(zoneId) == zoneId then
		return true
	end
	return false
end
]]

function SmartEmotes.IsPlayerInAnySubZone()
	local _, poiIndex = GetCurrentSubZonePOIIndices()
	if poiIndex then
		return true
	end
	return false
end

function SmartEmotes.IsPlayerInSpecificPOI(poiName)
	local key, id = GetCityKeyByPOIName(poiName)
	if key ~= nil then
		return true, key, id
	end
	return false
end

function SmartEmotes.IsPlayerInParentZone()
	local key = GetRegionKeyByZoneId(GetParentZoneId(GetUnitWorldPosition("player")))
	if key ~= nil then
		return true, key
	end
	return false
end

function SmartEmotes.IsPlayerInZone()
	local key = GetRegionKeyByZoneId(GetUnitWorldPosition("player"))
	if key ~= nil then
		return true, key
	end
	return false
end

function SmartEmotes.IsPlayerInSeparatedArea()
	local _, x, y, z = GetUnitWorldPosition("player")
	local _, rx, ry, rz = GetUnitRawWorldPosition("player")
	if x == rx and y == ry and z == rz then
		return false
	else
		return true
	end
end


function SmartEmotes.IsPlayerInCity()
--	local location = GetPlayerActiveSubzoneName()	-- NOTE : GetPlayerActiveSubzoneName() returns the empty string when not in a subzone, so it is NOT used here.
	local location = GetPlayerLocationName()
	local subZoneId = LorePlay.db.savedSubZoneId
	local mapId = GetCurrentMapId()
	local key
	if subZoneId ~= 0 then
		key = GetCityKeyBySubZoneId(subZoneId)
		if key then
			return true, key
		end
	else
		if not DoesUseMapBorder(mapId) and not SmartEmotes.IsPlayerInSeparatedArea() then
			if location == GetPlayerActiveZoneName() then
				if LorePlay.db.specificPOINameNearby == nil then
					return false
				end
			end
		end
	end
	key = GetCityKeyByMapId(mapId)
	if key ~= nil then
		return true, key
	end
	return false
end


function SmartEmotes.IsPlayerInDungeon()
	return IsUnitInDungeon("player") and not blacklistedDungeonDatabase[GetUnitWorldPosition("player")]
end


function SmartEmotes.IsPlayerInDolmen()
	local location = GetPlayerLocationName()
	if PlainStringFind(location, L(SI_LOREPLAY_LOCATION_KEYWORD_DOLMEN)) then
		return true
	end
	return false
end


function SmartEmotes.IsPlayerInAbyssalGeyser()
	local location = GetPlayerLocationName()
	if PlainStringFind(location, L(SI_LOREPLAY_LOCATION_KEYWORD_ABYSSAL_GEYSER)) then
		return true
	end
	return false
end


function SmartEmotes.IsPlayerInHarrowstormRitualSite()
	local subzoneId = LorePlay.db.savedSubZoneId
	if harrowstormRitualSiteDatabase[subzoneId] then
		return true
	else
		return false
	end
end


function SmartEmotes.IsPlayerInMirrormoorMosaic()
	local subzoneId = LorePlay.db.savedSubZoneId
	if mirrormoorMosaicDatabase[subzoneId] then
		return true
	else
		return false
	end
end


-- Here we pass in event codes
function SmartEmotes.DoesEmoteFromTTLEqualEvent(...)
	if not eventTTLEmotes["isEnabled"] then return false end
	local arg = {...}
	for i = 1, #arg, 1 do
		if emoteFromTTL["EventName"] == eventTTLEmotes[arg[i]]["EventName"] then
			return true
		end
	end
	return false
end


-- Here we pass in event codes
function SmartEmotes.DoesEmoteFromLatchedEqualEvent(...)
	if not eventLatchedEmotes["isEnabled"] then return false end
	local arg = {...}
	for i = 1, #arg, 1 do
		if emoteFromLatched["EventName"] == eventLatchedEmotes[arg[i]]["EventName"] then
			return true
		end
	end
	return false
end


-- Here we pass in event codes to check if current latched event equals an incoming latched event.
-- If so, then it's false because that means the last event was the same.
function SmartEmotes.DoesPreviousLatchedEventExist(...)
	if emoteFromLatched == nil then return false end
	local arg = {...}
	for i = 1, #arg, 1 do
		if emoteFromLatched == eventLatchedEmotes[arg[i]] then return false end
	end
	existsPreviousEvent = true
	return existsPreviousEvent
end


function SmartEmotes.UpdateDefaultEmotesTable()
	local result, key
	if SmartEmotes.IsPlayerInHouse() then
		defaultEmotes = defaultEmotesForHousing
		return
	end
	if SmartEmotes.IsPlayerInDungeon() then
		defaultEmotes = defaultEmotesForDungeons
		return
	end
	if SmartEmotes.IsPlayerInDolmen() then
		defaultEmotes = defaultEmotesForDolmens
		return
	end
	if SmartEmotes.IsPlayerInAbyssalGeyser() then
		defaultEmotes = defaultEmotesForDolmens		-- same as Dolens
		return
	end
	if SmartEmotes.IsPlayerInHarrowstormRitualSite() then
		defaultEmotes = defaultEmotesForDolmens		-- same as Dolens
		return
	end
	if SmartEmotes.IsPlayerInMirrormoorMosaic() then
		defaultEmotes = defaultEmotesForDolmens		-- same as Dolens
		return
	end
	result, key = SmartEmotes.IsPlayerInCity()
	if result then
		defaultEmotes = defaultEmotesByCityKeys[key]
		return
	end
	result, key = SmartEmotes.IsPlayerInParentZone()
	if result then
		defaultEmotes = defaultEmotesByRegionKeys[key]
		return
	end
	defaultEmotes = defaultEmotesForDungeons	-- unregistered region case
	return
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LEVEL_UPDATE(eventCode)
	SmartEmotes.UpdateTTLEmoteTable(eventCode)
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_PLAYER_NOT_SWIMMING(eventCode)
	SmartEmotes.UpdateTTLEmoteTable(eventCode)
end


function SmartEmotes.UpdateTTLEmoteTable_For_FALL_DAMAGE(eventCode)
	SmartEmotes.UpdateTTLEmoteTable(eventCode)
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_COMBAT_EVENT(eventCode, result, sourceName)
	if sourceName ~= GetUnitName("player").."^Fx" or isInCombat then return end
	if result == ACTION_RESULT_DIED_XP or result == ACTION_RESULT_DIED or
	result == ACTION_RESULT_KILLING_BLOW or result == ACTION_RESULT_TARGET_DEAD then
		if SmartEmotes.DoesEmoteFromTTLEqualEvent(EVENT_LEVEL_UPDATE, EVENT_KILLED_BOSS) then return end
		SmartEmotes.UpdateTTLEmoteTable(EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT)
	end
end


local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	zo_callLater(function()
		SmartEmotes.UpdateTTLEmoteTable_For_EVENT_COMBAT_EVENT(eventCode, result, sourceName)
	end, 0250)
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_PLAYER_COMBAT_STATE(eventCode, inCombat)
	if SmartEmotes.DoesEmoteFromTTLEqualEvent(EVENT_LEVEL_UPDATE, EVENT_KILLED_BOSS,
		EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT) then return end
	if not inCombat then
		isInCombat = false
		SmartEmotes.UpdateTTLEmoteTable(EVENT_PLAYER_COMBAT_STATE_NOT_INCOMBAT_FLED)
	else
		isInCombat = true
		SmartEmotes.UpdateTTLEmoteTable(EVENT_PLAYER_COMBAT_STATE_INCOMBAT)
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_MOUNTED_STATE_CHANGED(eventCode, mounted)
	if not mounted then
		isMounted = false
		SmartEmotes.UpdateTTLEmoteTable(eventCode)
	else
		isMounted = true
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE(eventCode, categoryIndex, collectionIndex, bookIndex, guildIndex, skillType, skillIndex, rank, previousXP, currentXP)
	SmartEmotes.UpdateTTLEmoteTable(eventCode)
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_TRADE_SUCCEEDED(eventCode)
	SmartEmotes.UpdateTTLEmoteTable(eventCode)
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOOT_RECEIVED_GENERAL(eventCode, itemName)
	if eventCode ~= EVENT_LOOT_RECEIVED_GENERAL then return end
	local equipSlot1, equipSlot2 = GetComparisonEquipSlotsFromItemLink(itemName)
	if not equipSlot1 or equipSlot1 == EQUIP_SLOT_NONE or equipSlot1 == EQUIP_SLOT_COSTUME then return end
	local qualityReceived = GetItemLinkQuality(itemName)
	local wornItem1 = GetSlotItemLink(equipSlot1)
	local wornItem2
	if equipSlot2 and equipSlot2 ~= EQUIP_SLOT_NONE then
		wornItem2 = GetSlotItemLink(equipSlot2)
	end
	local wornQuality1 = GetItemLinkQuality(wornItem1)
	local wornQuality2
	if wornItem2 then
		wornQuality2 = GetItemLinkQuality(wornItem2)
	end
	if qualityReceived > wornQuality1 or wornQuality2 and qualityReceived > wornQuality2 then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_LOOT_RECEIVED_BETTER)
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOOT_RECEIVED_RUNE(eventCode, itemName)
	local quality = GetItemLinkQuality(itemName)
	if quality == ITEM_QUALITY_NORMAL or quality == ITEM_QUALITY_ARTIFACT or
	quality == ITEM_QUALITY_LEGENDARY then
		SmartEmotes.UpdateTTLEmoteTable(runeQualityToEvents[quality])
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOOT_RECEIVED_RECIPE_OR_MATERIAL(eventCode, itemName)
	local quality = GetItemLinkQuality(itemName)
	if quality == ITEM_QUALITY_ARTIFACT or quality == ITEM_QUALITY_LEGENDARY then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_LOOT_RECEIVED_RARE_RECIPE_OR_MATERIAL)
	end
end


local function OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId)
	if emoteFromTTL["EventName"] == eventTTLEmotes[EVENT_LEVEL_UPDATE]["EventName"] or
	emoteFromTTL["EventName"] == eventTTLEmotes[EVENT_KILLED_BOSS]["EventName"] then return end

	local itemType = GetItemLinkItemType(itemName)
	if IsItemLinkEnchantingRune(itemName) then
		SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOOT_RECEIVED_RUNE(EVENT_LOOT_RECEIVED_RUNE, itemName)
	elseif itemType == ITEMTYPE_RAW_MATERIAL or ITEMTYPE_RECIPE then
		SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOOT_RECEIVED_RECIPE_OR_MATERIAL(EVENT_LOOT_RECEIVED_RECIPE_OR_MATERIAL, itemName)
	elseif IsItemLinkUnique(itemName) then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_LOOT_RECEIVED_BETTER)
	else
		SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOOT_RECEIVED_GENERAL(EVENT_LOOT_RECEIVED_GENERAL, itemName)
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_TRADE_CANCELED(eventCode)
	SmartEmotes.UpdateTTLEmoteTable(eventCode)
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_SKILL_POINTS_CHANGED(eventCode, pointsBefore, pointsNow, partialPointsBefore, partialPointsNow)
	if emoteFromTTL["EventName"] == eventTTLEmotes[EVENT_LEVEL_UPDATE]["EventName"] then return end
	--[[ MAKE NEW TABLE FOR DIFFERENCE BETWEEN SKYSHARD AND SKILL POINT GAIN ]]--
	if partialPointsNow > partialPointsBefore then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_SKILL_POINTS_CHANGED)
	elseif pointsNow > pointsBefore then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_SKILL_POINTS_CHANGED)
	end
end


-- Stamina bar
function SmartEmotes.UpdateLatchedEmoteTable_For_EVENT_POWER_UPDATE(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if unitTag ~= "player" then return end
	if powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
		local lowerThreshold = powerEffectiveMax*(.20)
		local upperThreshold = powerEffectiveMax*(.60)
		if powerValue <= lowerThreshold then
			SmartEmotes.UpdateLatchedEmoteTable(EVENT_POWER_UPDATE_STAMINA)
		elseif powerValue >= upperThreshold
		and SmartEmotes.DoesEmoteFromLatchedEqualEvent(EVENT_POWER_UPDATE_STAMINA) then
			SmartEmotes.DisableLatchedEmotes()
		end
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_EXPERIENCE_UPDATE(eventCode, unitTag, currentExp, maxExp, reason)
	if unitTag ~= "player" then return end
	if SmartEmotes.DoesEmoteFromTTLEqualEvent(EVENT_LEVEL_UPDATE) then return end
	if reason == PROGRESS_REASON_OVERLAND_BOSS_KILL then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_KILLED_BOSS)
		return
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOCKPICK_FAILED(eventCode)
	if eventCode ~= EVENT_LOCKPICK_FAILED then return end
	if SmartEmotes.DoesEmoteFromTTLEqualEvent(EVENT_LEVEL_UPDATE) then return end
	SmartEmotes.UpdateTTLEmoteTable(EVENT_LOCKPICK_FAILED)
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOCKPICK_SUCCESS(eventCode)
	if eventCode ~= EVENT_LOCKPICK_SUCCESS then return end
	if SmartEmotes.DoesEmoteFromTTLEqualEvent(EVENT_LEVEL_UPDATE) then return end
	if not lockpickQuality then return end
	if lockpickQuality <= lockpickValues[LOCK_QUALITY_SIMPLE] then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_LOCKPICK_SUCCESS_EASY)
		return
	elseif lockpickQuality > lockpickValues[LOCK_QUALITY_SIMPLE]
	and lockpickQuality <= lockpickValues[LOCK_QUALITY_ADVANCED] then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_LOCKPICK_SUCCESS_MEDIUM)
		return
	elseif lockpickQuality > lockpickValues[LOCK_QUALITY_ADVANCED] then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_LOCKPICK_SUCCESS_HARD)
		return
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_BANKED_MONEY_UPDATE(eventCode, newBankedMoney, oldBankedMoney)
	if eventCode ~= EVENT_BANKED_MONEY_UPDATE then return end

	local doubleOld = 2*oldBankedMoney
	if newBankedMoney >= doubleOld then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_BANKED_MONEY_UPDATE_DOUBLE)
		return
	end

	local acquisition = newBankedMoney - oldBankedMoney
	local threshold = (.1)*oldBankedMoney
	if acquisition >= threshold then
		SmartEmotes.UpdateTTLEmoteTable(EVENT_BANKED_MONEY_UPDATE_GROWTH)
		return
	end
end


function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_CAPTURE_FLAG_STATE_CHANGED(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, objectiveName, objectiveControlEvent, objectiveControlState, originalOwnerAlliance, holderAlliance, lastHolderAlliance, pinType)
	if eventCode ~= EVENT_CAPTURE_FLAG_STATE_CHANGED then return end

	local playerAlliance = GetUnitBattlegroundAlliance("player")
	if objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then
		if originalOwnerAlliance == playerAlliance and holderAlliance ~= playerAlliance then
			SmartEmotes.UpdateTTLEmoteTable(EVENT_CAPTURE_FLAG_STATE_CHANGED_LOST_FLAG)
		end
	end
end

function SmartEmotes.UpdateTTLEmoteTable_For_EVENT_PLEDGE_OF_MARA_RESULT(eventCode, reason, targetCharacterName, targetDisplayName)
 	if eventCode ~= EVENT_PLEDGE_OF_MARA_RESULT then return end
 	local isReasonPledged = false
 	local isReasonBegin = false
 	if reason == PLEDGE_OF_MARA_RESULT_BEGIN_PLEDGE then
 		isReasonBegin = true
 		--PUT ON SUIT IN LOREWEAR
 		LPEventHandler:FireEvent(EVENT_PLEDGE_OF_MARA_MARRIAGE, true, true) --isGettingMarried
 	elseif reason == PLEDGE_OF_MARA_RESULT_PLEDGED then
 		isReasonPledged = true
 		LPEventHandler:FireEvent(EVENT_PLEDGE_OF_MARA_MARRIAGE, true, false, targetCharacterName) --isGettingMarried
 	end
 	if isReasonBegin or isReasonPledged then
 		SmartEmotes.UpdateTTLEmoteTable(EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE)
 	end
end


local function OnBeginLockpick(eventCode)
	if eventCode ~= EVENT_BEGIN_LOCKPICK then return end
	lockpickQuality = lockpickValues[GetLockQuality()]
end


function SmartEmotes.RegisterSmartEvents()
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_LEVEL_UPDATE, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LEVEL_UPDATE)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_NOT_SWIMMING, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_PLAYER_NOT_SWIMMING)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_POWER_UPDATE, SmartEmotes.UpdateLatchedEmoteTable_For_EVENT_POWER_UPDATE)
	EVENT_MANAGER:AddFilterForEvent(LorePlay.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_STAMINA)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_TRADE_CANCELED, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_TRADE_CANCELED)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_TRADE_SUCCEEDED, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_TRADE_SUCCEEDED)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_HIGH_FALL_DAMAGE, SmartEmotes.UpdateTTLEmoteTable_For_FALL_DAMAGE)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_LOW_FALL_DAMAGE, SmartEmotes.UpdateTTLEmoteTable_For_FALL_DAMAGE)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_SKILL_POINTS_CHANGED, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_SKILL_POINTS_CHANGED)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_MOUNTED_STATE_CHANGED, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_MOUNTED_STATE_CHANGED)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_COMBAT_STATE, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_PLAYER_COMBAT_STATE)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_EXPERIENCE_UPDATE, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_EXPERIENCE_UPDATE)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_LOCKPICK_FAILED, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOCKPICK_FAILED)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_LOCKPICK_SUCCESS, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_LOCKPICK_SUCCESS)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_BEGIN_LOCKPICK, OnBeginLockpick)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_COMBAT_EVENT, OnCombatEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_LOOT_RECEIVED, OnLootReceived)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_BANKED_MONEY_UPDATE, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_BANKED_MONEY_UPDATE)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_CAPTURE_FLAG_STATE_CHANGED, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_CAPTURE_FLAG_STATE_CHANGED)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLEDGE_OF_MARA_RESULT, SmartEmotes.UpdateTTLEmoteTable_For_EVENT_PLEDGE_OF_MARA_RESULT)
end


function SmartEmotes.InitializeIndicator()
	if not LorePlay.db.isSmartEmotesIndicatorOn then
		SmartEmotesIndicator:SetHidden(true)
	end
	if LorePlay.db.indicatorTop then
		SmartEmotesIndicator:ClearAnchors()
		SmartEmotesIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LorePlay.db.indicatorLeft, LorePlay.db.indicatorTop)
	end
	local fadeTime = 1500
	indicatorFadeIn, timelineFadeIn = CreateSimpleAnimation(ANIMATION_ALPHA, SmartEmotesIndicator)
	indicatorFadeOut, timelineFadeOut = CreateSimpleAnimation(ANIMATION_ALPHA, SmartEmotesIndicator) --SmartEmotesIndicator defined in xml file of same name
	indicatorFadeIn:SetAlphaValues(0, EmoteImage:GetAlpha())
	indicatorFadeIn:SetDuration(fadeTime)
	indicatorFadeOut:SetAlphaValues(EmoteImage:GetAlpha(), 0)
	indicatorFadeOut:SetDuration(fadeTime)
	timelineFadeIn:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	timelineFadeOut:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	indicator = false
end


function SmartEmotes.CreateAllEmotesTables()
	SmartEmotes.ReloadSmartEmotes() -- sets loadedOrCreatedEmotesTable[]
	SmartEmotes.CreateTTLEmoteEventTable()
	SmartEmotes.CreateLatchedEmoteEventTable()
	SmartEmotes.CreateReticleEmoteTable()
	SmartEmotes.CreateDefaultEmoteTables()
	SmartEmotes.CreateTitleNameReverseTable()
end

function SmartEmotes.ExportSmartEmotes()
	local currentEmotes = LorePlay.LPUtilities.DeepCopy(loadedOrCreatedEmotesTable) or {}
	local copyCurrent = {}
	for category, categoryTable in pairs(currentEmotes) do
		copyCurrent[category] = {}
		if type(categoryTable) == "table" then
			for eventKey, eventTable in pairs(categoryTable) do
				if type(eventTable) == "table" then
					-- map emote indeces to slashNames
					if eventTable["Emotes"] ~= nil then
						eventTable["Emotes"] = LorePlay.LPUtilities.Map(eventTable["Emotes"], GetEmoteSlashNameByIndex)
					elseif type(eventTable) == "table" then
						local subEntries = {}
						for key, value in pairs(eventTable) do
							subEntries[key] = {
								["Emotes"] = LorePlay.LPUtilities.Map(
									value["Emotes"],
									GetEmoteSlashNameByIndex
							) }
						end
						eventTable["SubEntries"] = subEntries
					end

					-- Whitelist Attributes.
					copyCurrentEvent = {
						["Duration"] = eventTable["Duration"],
						["Emotes"] = eventTable["Emotes"],
						["SubEntries"] = eventTable["SubEntries"],
					}

					if eventTable["EventName"] ~= nil then
						copyCurrentEvent["EventName"] = eventTable["EventName"]
					else
						copyCurrentEvent["Key"] = eventTable["Key"] or eventKey
					end

					-- not as table but as list
					table.insert(copyCurrent[category], copyCurrentEvent)
				end
			end
		end
	end

	return copyCurrent
end


function SmartEmotes.InitializeEmotes()
	SmartEmotes.CreateAllEmotesTables()
	SmartEmotes.RegisterSmartEvents()
	SmartEmotes.InitializeIndicator()
	SmartEmotes.UpdateTTLEmoteTable(EVENT_STARTUP)
	isMounted = IsMounted()
end

LorePlay = SmartEmotes
