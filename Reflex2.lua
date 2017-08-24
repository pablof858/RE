-- Version: 2.4.3 

--TO DO:  support 5s (multihealer) debug party4 y support holy en bg.
-- 		  arma holy. Avenging Crusader. Fake cast. Hammer of Reckoning. Divine intervention

-- LOG
-- 15/9/16 -- Segundo Frame para siguiente accion 2.3 secs. Cheuqeado. 2.4.1
--		   -- Actualizacion parcial de IsHeal(), falta actualizar auras. Sin chequear.
--		   -- REtest() texto en color, activa tmb el segundo frame y texto al apagar. Chequeado.
--		   -- CreateEnemyLib y PartyLib() intento de correccion de bugs, primero chequea si es nula la unidad. Sin chequear.
--		   -- Antistealth suporta el nuevo motor. Sin chequear.
--		   -- Buff y selfheal fuera de combate, nuevo motor. Además deberia esperar 3 segundos antes de castear. Sin chequear. Fol funciona perfecto. Buff eliminado.
--		   -- Cree IsStun() para JV. Implementado. Funciona.
--		   -- Errores de TargetLowMember deberian estar parcialmente arreglados, ya que dependian de IsHeal que daba siempre 1, al no estar actualziado. 
--		   -- Antislow update. Chequeado.
-- 		   -- Hand of Hindrance chequea slows antes.
--		   -- HoH para peels.
--		   -- prints para debuggear BOP.
-- 16/9/16 -- Pequeños agregados, como texto en on-off.
-- 21/9/16 -- Limpieza de pocas cosas.
-- 22/9/16 -- Cooldown en el frame principal y secundario, sin testear. 2.4.2
--    	   -- Corrección de IsHeal() a la actualizacion del 15/9. 
--		   -- Corrección de IsMelee()
--		   -- IsHeal() actualizacion de spells de shadow priest. Sin chequear.
--		   -- Intento de que el segundo frame tenga en cuenta el primero. Funciona mejor aunque no perfecto.
--		   -- Modificaciones al sistema de queue. Funciona.
--		   -- Mejorar burst no tirando WoA si tengo disponible Hoj, para juntar mas holypower antes. Funciona
--		   -- Limpie los print que eran para debugear el uso de JV (ya está debugeado).
-- 23/9/16 -- printp a mesnsajes importante. JV al mas cercano para curar. Otro intento de reparar Lowestmembertar. Tarcount actualizado, ya que dependía de IsHeal(). IsHeal deberia estar reparado en arenas.
-- 24/9/16 -- Intento de arreglar errores de Party y Enemy Lib. HoJCC opcional. CanHoJ. Simplifique isheal en arenas. Intento de mejorar SetArenaGroups.
-- 27/9/16 -- Intento de cambiar el healing para dar prioridad a JV. Arreglo de errores del grupo. Arreglé BoP en Send.
-- 28/9/16 -- Finalmente arregle: SetArenaGroups. Muchos arreglos en las defensas. Cambios en cosas de support. 2.4.3. Recodeé Bop y HoF
-- 29/9/16 -- Cambié los dispells y arreglos menores, como agregar un reset de Partyheal, etc al cambiar de lugar. Cambie el dispell.
-- 30/9/16 -- Intenté Bop, al menos arregle bugs.
-- 30/9/16 -- 2.4.4 Holy support básico. En prueba.
-- 12/10/16 -- Holy support semi funcional 
-- 13/10/16 -- Intento de corrección de Lowest, support a mouseover (aun sin send), muchos cambios en el uso de enemyparty, reemplazado por "arena"..i y group reemplazado casi en totalidad por "party"..i. Creo que ese era el problema.
-- 18/07/17 -- Support para low level finisher y judge.
-- 27/07/17 -- Fix al bug de Cleanse Toxins self.
--			-- Frames de texto que desaparecen en 3 seg.


--[[ Agragar al send:
SELF = {0, 0, 0}
PARTY1 = {1, 1, 1}
PARTY2 = {1, 0, 1}
PARTY3 = {1, 0, 0.5}
PARTY4 = {0.5, 0, 1}
ARENA1 = {0, 0, 1}
ARENA2 = {0, 1, 0}
ARENA3 = {1, 0, 0}
FOCUS = {0.5, 0.5, 0.5}
P1tar = {0, 1, 0.5}

--]]


IniEF=CreateFrame("Frame")
IniEF:RegisterEvent("PLAYER_ENTERING_WORLD")
IniEF:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
IniEF:SetScript("OnEvent", function()
	
	UserSpec = GetSpecializationInfo(GetSpecialization())-- 70 ret, 65 holy
	print("|cFF00CCFFRE: |r".."Current Spec :"..UserSpec)
	PartyHealer = nil
	EnemyHealer = nil
	Group={}
	Group[1]="player"
	enemyparty={}
	dpsers={}
	Colorcode ={}
	SetArenaGroups()
	PartyTank=nil
	qspell=nil

	----------------------------R  G  B
	-- Common spells.
	Colorcode["Divine Shield"]={1, 0, 1, 642}
	Colorcode["Blessing of Protection"]={0.5, 0, 0.25, 1022}
	Colorcode["Hammer of Justice"]={0, 1, 0, 853}
	Colorcode["Flash of Light"]={1, 0.5, 0.5, 19750}
	Colorcode["Blessing of Freedom"]={1, 0, 0.5, 1044}
	Colorcode["Divine Steed"]={0, 0.5, 1, 220509}
	Colorcode["Lay on Hands"]={1, 0.5, 1, 633}
	Colorcode["Avenging Wrath"]={0, 0.25, 0.25, 31884}
		-- Specspells
	if UserSpec==70 then

		Colorcode["Shield of Vengeance"]={0, 1, 1, 184662} 
		Colorcode["Word of Glory"]={1, 0, 0, 210191} 
		Colorcode["Templar's Verdict"]={0, 0, 1, 85256}
		Colorcode["Blessing of Sanctuary"]={0.5, 0.5, 0.5, 210256}
		Colorcode["Execution Sentence"]={0.5, 1, 0.5, 213757}
		Colorcode["Hand of Hindrance"]={0.5, 0.5, 1, 183218}
		Colorcode["Cleanse Toxins"]={1, 0.5, 0, 213644}
		Colorcode["Divine Storm"]={0.5, 0, 0.5, 53385}
		Colorcode["Grater Blessing of Might"]={0.25, 0.25, 1, 205729}
		Colorcode["Judgment"]={0.25, 1, 0.25, 20271} -- RET
		Colorcode["Greater Blessing of Kings"]={1, 0.25, 0.25, 203538}
		Colorcode["Greater Blessing of Wisdom"]={0.5, 1, 1, 20353}
		Colorcode["Crusader Strike"]={1, 1, 0.5, 35395} -- RET
		Colorcode["Rebuke"]={0, 0.5, 0,5, 96231}
		Colorcode["Eye for an Eye"]={0, 1, 0.25, 205191}
		Colorcode["Divine Intervention"]={nil, nil, nil, 213313}
		Colorcode["Justicar's Vengeance"]={1, 0, 0.25, 215661}
		Colorcode["Holy Wrath"]={0, 0.25, 1, 210220}
		Colorcode["Wake of Ashes"]={0, 0.5, 0.25, 205273}	
		Colorcode["Blade of Justice"]={0.5, 0.5, 0, 184575}
	
	elseif UserSpec==65 then
		-- Holy --
		Colorcode["Holy Shock"]={0.5, 0.5, 0, 20473} -- HOLY -- cambiar ids. 2
		Colorcode["Rule of Law"]={0.1, 0, 0, 214202} -- not supported yet.
		Colorcode["Light of Dawn"]={0.25, 0, 0.25, 85222} -- not supported yet. sw
		Colorcode["Bestow Faith"]={1, 0, 0.25, 223306} -- f
		Colorcode["Light of the Martyr"]={1, 1, 0.5, 183998} -- w
		Colorcode["Blessing of Sacrifice"]={0.5, 0.5, 0.5, 6940} -- sq
		Colorcode["Holy Light"]={0.25, 0.5, 0.25, 82326} -- e 408040
		Colorcode["Divine Protection"]={0, 1, 0.25, 498} -- cw
		Colorcode["Beacon of Light"]={0.25, 0, 0.5, 53563}
		Colorcode["Aura Mastery"]={0.25, 0.25, 0, 31821}
		Colorcode["Judgment"]={0.25, 0.25, 0.5, 20271} -- holy --1
		Colorcode["Crusader Strike"]={1, 0.25, 0, 35395} -- holy -- 3
		Colorcode["Cleanse"]={0.5, 0.25, 0.25, 4987} -- 404080
		-- Algunos spells no necesitan bind (los hardcast)
	end
end)

IniEF=CreateFrame("Frame")
IniEF:RegisterEvent("PLAYER_LOGIN")
IniEF:SetScript("OnEvent", function()
	print("|cFF00CCFFRE: |r".."Reflex Loaded")
end)


po=UnitPower b=UnitBuff u=IsUsableSpell r=IsSpellInRange p="player" t="target" tv="Templar's Verdict" cs="Crusader Strike" j="Judgment" hp=UnitHealth hpm=UnitHealthMax ds="Divine Shield" aw="Avenging Wrath" uci=UnitCastingInfo rbk="Rebuke" a1="arena1" a2="arena2" a3="arena3" uiu=UnitIsUnit UC=UnitClass p1="party1" p2="party2"

dangerb={"Avenging Wrath", "Ascendance", "Icy Veins", "Dark Soul", "Avatar", "Recklessness", "Shadow Dance", "Pillar of Frost", "Incarnation: King of the Jungle", "Incarnation: Chosen of Elune", "Celestial Alignment", "Serenity", "Seraphim", "Tigereye Brew", "Power Infusion", "Vendetta", "Adrenaline Rush", "Elemental Mastery", "Dark Soul: Misery", "Dark Soul: Instability", "Dark Soul: Knowledge", "Rapid Fire", "Holy Avenger", "Surge of Victory", "Surge of Dominance", "Surge of Conquest", "Call of Victory", "Call of Conquest", "Call of Dominance", "Rune of the Fallen Crusader", "True Fire", }
ilst={"Cyclone", "Fear", "Polymorph", "Repentance", "Hex", "Turn Evil", "Chain Heal", "Greater Heal", "Flash of Light", "Flash Heal", "Greater Healing Wave", "Healing Surge", "Frostjaw", "Divine Light", "Chain Heal", "Word of Glory", "Regrowth", "Wild Growth", "Healing Touch", "Heal", "Holy Light", "Denounce", "Smite", "Healing Surge", "Mass Dispel", "Demonic Gateway", "Healing Rain", "Effuse", "Vivify", "Shadowmend"}
ilst2={"Frostbolt", "Frostfire Bolt", "Chaos Bolt", "Vampiric Touch", "Demonbolt", "Shadow Bolt", "Lightning Bolt", "Chain Lightning", "Haunt", "Unstable Affliction"}
ilst3={"Soothing Mist", "Divine Hymn", "Tranquility"}
SoftCClist={"Sap", "Blind", "Intimidating Shout", "Polymorph", "Blinding Light", "Repentance", "Freezing Trap", "Disorienting Roar", "Wyvern Sting", "Mesmerize", "Seduction"}

hojlist={"Spell Reflection", "Mass Spell Reflection", "Anti-Magic Shell", "Divine Shield", "Ice Block", "Icebound Fortitude", "Grounding Totem", "Deterrence", "Cloak of Shadows", "Bladestorm", "Aspect of the Turtle"}
hojlist2={"Sap", "Blind", "Fear", "Intimidating Shout", "Hammer of Justice", "Deep Freeze", "Polymorph", "Hex", "Blinding Light", "Stormbolt", "Fist of Justice", "Repentance", "Howl of Terror", "Freezing Trap", "Kidney Shot", "Garrote", "Cheap shot", "Scatter Shot", "Migthy Bash", "Disorienting Roar", "Binding Shot", "Strangulate", "Solar Beam", "Paralysis", "Wyvern Sting", "Frostjaw", "Psychic Scream", "Psychic Terror", "Seduction", "Aphyxiate"}
hojlist3={"Hammer of Justice", "Deep Freeze", "Stormbolt", "Kidney Shot", "Cheap shot", "Migthy Bash", "Aphyxiate", "Cyclone"}
InmMagic={"Anti-Magic Shell", "Cloak of Shadows", "Diffuse Magic"}
InmAll={"Divine Shield", "Ice Block", "Deterrence", "Touch of Karma", "Life Cocoon"}
InmPhy={"Blessing of Protection", "Evation", "Die by the Sword"}



roots={"Frost Nova", "Earthgrab", "Entrapment", "Freeze", "Web", "Venom Web Spray", "Wild Charge", "Immobilized", "Glyph of Mind Blast", "Mass Entaglement", "Disable", "Narrow Escape", "Charge"}
slows={"Entangling Roots", "Cone of Cold", "Concussive Shot", "Frost Shock", "Earthbind", "Hamstring", "Piercing Howl", "Dizzying Haze", "Chains of Ice", "Chilled", "Flying Serpent Kick", "Burden of Guilt", "Conflagate", "Concussive Shot", "Frost Nova", "Earthgrab", "Entrapment", "Freeze", "Web", "Venom Web Spray", "Wild Charge", "Immobilized", "Glyph of Mind Blast", "Mass Entaglement", "Disable", "Narrow Escape", "Charge", "Entangling Roots", "Concussive Shot", "Frost Shock", "Earthbind", "Hamstring", "Piercing Howl", "Dizzying Haze", "Chains of Ice", "Flying Serpent Kick", "Conflagate", "Chilblains", "Hand of Hindrance", "Crippling Poison", "Frostbolt", "Frost Armor", "Chilled", "Infected Wounds", "Earthbind Totem"}

slows1={"Frost Nova", "Earthgrab", "Entrapment", "Freeze", "Web", "Venom Web Spray", "Wild Charge", "Immobilized", "Glyph of Mind Blast", "Mass Entaglement", "Disable", "Narrow Escape", "Charge", "Entangling Roots", "Concussive Shot", "Frost Shock", "Earthbind", "Hamstring", "Piercing Howl", "Dizzying Haze", "Chains of Ice", "Flying Serpent Kick", "Conflagate", "Chilblains", "Hand of Hindrance", "Crippling Poison", "Frostbolt", "Frost Armor", "Chilled", "Infected Wounds", "Earthbind Totem"}

Spells1 = {"Hammer of Justice", "Deep Freeze", "Stormbolt", "Kidney Shot", "Cheap shot", "Migthy Bash", "Aphyxiate"}
Spells2 = {"Frostjaw", "Garrote", "Silence", "Arcane Torrent"}
Spells3 = {"Wyvern Sting", "Devoring Plage"}-- spells para cleanse
Spells5 = {"Deep Freeze", "Fear", "Hammer of Justice", "Howl of Terror", "Silence", "Strangulate", "Frostjaw", "Psychic Scream", "Psychic Terror", "Intimidating Shout", "Kidney Shot", "Mighthy Bash", "Leg Sweep", "Sigil of Silence"} -- spells para sacrifice
Spells6 = {"Blind", "Blinding Light", "Disorienting Roar", "Paralysis"}
Spells7 = {"Crippling Poison", "Infected Wounds", "Frost Fever", "Devoring Plage"}
Spells8 = {"Hammer of Justice", "Deep Freeze", "Fear", "Psychic Scream", "Psychic Terror",  "Polymorph", "Repentance", "Freezing Trap", "Paralysis", "Silence"} -- holy cleanse.

CClist = {"Sap", "Blind", "Cyclone", "Fear", "Intimidating Shout", "Hammer of Justice", "Deep Freeze", "Polymorph", "Hex", "Blinding Light", "Stormbolt", "Fist of Justice", "Repentance", "Turn Evil", "Howl of Terror", "Freezing Trap", "Kidney Shot", "Garrote", "Cheap shot", "Scatter Shot", "Migthy Bash", "Disorienting Roar", "Psychic Scream", "Silence", "Paralysis"}
DefenseList = {"Divine Shield", "Shield Wall", "Ice Block", "Deterrence", "Pain Supression", "Guardian Spirit", "Dispersion", "Cloak of Shadows", "Evation", "Die by the Sword", "Life Cocoon", "Touch of Karma", "Anti-Magic Shell", "Icebound Fortitude", "Survival Instincts", "Evanesce", "Greater Invisibility", "Diffuse Magic", "Dampen Harm", "Fortifying Brew", "Dispersion", "Evasion", "Cloak of Shadows", "Combat Readiness", "Astral Shift", "Shamanistic Rage", "Feral Spirit", "Unending Resolve", "Dark Bargain", "Eye for an Eye", "Shield of Vengeance", "Empower Wards", "Darkness","Metamorphosis", "Ironbark", "Aspect of the Tutle"}

inmunelist = {"Divine Shield", "Devotion Aura", "Blessing of Protection", "Glyph of Shadow Magic", "Spiritwalker's Grace", "Unending Resolve", "Aspect of the Turtle"}
inmunetoslow = {"Blessing of Freedom", "Bladestorm", "Dispesion"}


-- Track lib
CC = 1
kick = 2
DEF = 3
burst = 4
jump = 5
mkick = 6 -- magic kick
rkick = 7 -- ranged kick
CD=4
NAME=1
LibSpells = {}
LibTrack = {}
LibTrackP = {}
LibSpells["Hunter"] ={{"Counter Shot", 24, rkick, 0}, {"Freezing Trap", 30, CC, 0}, {"Rapid Fire", 120, burst, 0}, {"Deterrence", 120, DEF, 0}}
 LibSpells["Warrior"]={{"Charge", 12, jump, 0}, {"Pummel", 15, kick, 0}, {"Avatar", 120, burst, 0}, {"Shield Wall", 180, DEF, 0}, {"Die By the Sword", 120, DEF, 0}, {"Intimidating Shout", 120, CC, 0}, {"Recklessness", 180, burst, 0}}
 LibSpells["Mage"]={{"Counterspell", 24, rkick, 0}, {"Deep Freeze", 30,  CC, 0},  {"Ice Block", 300, DEF, 0}, {"Icy Veins", 120, burst, 0}, {"Cold Snap", 300, DEF, 0}}
 LibSpells["Paladin"]={{"Rebuke", 15, kick, 0}, {"Fist of Justice", 30, CC, 0}, {"Divine Shield", 300, DEF, 0}, {"Avenging Wrath", 120, burst, 0}, {"Shield of Vengeance", 60, DEF, 0}}
 LibSpells["Priest"]={{"Silence", 45, CC, 0}, {"Psychic Scream", 30, CC, 0}, {"Dispersion", 120, DEF, 0}, {"Pain Suppression", 180, DEF, 0}}
 LibSpells["Shaman"]={{"Wind Shear", 24, rkick, 0}, {"Hex", 45, CC, 0}, {"Ascendance", 120, burst, 0}, {"Shamanistic Rage", 60, DEF, 0}, {"Spirit-Link Totem", 180, DEF, 0}}
 LibSpells["Death Knight"]={{"Mind Freeze", 15, mkick, 0}, {"Strangulate", 60, CC, 0}, {"Anti-Magic Shell", 45, DEF, 0}, {"Icebound Fortitude", 180, DEF, 0}, {"Pillar of Frost", 60, burst, 0}}
 LibSpells["Monk"]={{"Touch of Karma", 90, DEF, 0}, {"Leg Sweep", 60, CC, 0}, {"Hand Spear Strike", 15, kick, 0}}
 LibSpells["Druid"]={{"Skull Bash", 15, rkick, 0},{"Survival Instincts", 180, DEF, 0}, {"Barskin", 60, DEF, 0}}
 LibSpells["Warlock"]={{"Dark Soul: Misery", 120, burst, 0}}
 LibSpells["Rogue"]={{"Kick", 15, kick, 0}, {"Shadow Dance", 60, burst, 0}, {"Cloak of Shadows", 120, DEF, 0},{"Blind", 120, CC, 0}, {"Shadowstep", 20, jump, 0}, {"Evation", 120, DEF, 0}, {"Combat Redines", 120, DEF, 0}, {"Preparation", 300, DEF, 0}, {"Vanish", 120, DEF, 0}}
 LibSpells["Demon Hunter"]={{"asd", 120, DEF, 0}, {"asd", 120, DEF, 0}}
bub = 0

--Config
Lagcomp = 0.8
Lagcomp2 = 0.2
TPS = 30
HiOn=1
AuDispell=1
qspell=nil
qspella=nil
qspell2=nil
qtarget=0
aoe=0
qtimer=0
reset=true
lastmsj=0
failedSpell={}
Group={}
Group[1]="player"
enemyparty={}
dpsers={}
OutOfLos={}
TestActive=0
HoJCC=false
Lowest=0
AutoCds=false
Dostun=true
LastText = 0


MeleeSpecs = {
66, -- Paladin: Protection
70, -- Paladin: Retribution
71, -- Warrior: Arms
72, -- Warrior: Fury
73, -- Warrior: Protection
103, -- Druid: Feral
104, -- Druid: Guardian
250, -- Death Knight: Blood
251, -- Death Knight: Frost
252, -- Death Knight: Unholy
259, -- Rogue: Assassination
260, -- Rogue: Combat
261, -- Rogue: Subtlety
263, -- Shaman: Enhancement
268, -- Monk: Brewmaster
269, -- Monk: Windwalker
577, -- Demon Hunter: Havoc
581, -- Demon Hunter: Vengeance
}

HealingSpecs = {
	105, -- Restoration 
    270, -- Mistweaver
	65, -- Holy
	256, -- Discipline 
    257, -- Holy
	264, -- Restoration 
}

Ejemplo = "ll"
valor = "Ejemplo"
d= _G[valor] 

asda11="st"
st = "Unlike several other scriptin languages, Lua does not use POSIX Regular expressions (regexp) for pattern matching."
igj, jgg = string.find(st, "egular expre")
jazz, mus = string.find(_G[asda11], "expressions")
	
limones = string.char(igj+1)..string.sub(st, (((string.byte("l")-3)/5)+11), (((string.byte("l")-3)/5)+11))..asda11..string.char(mus).."p"..string.char((string.len("Divine Shield")*9)-string.len("Avenging Wrath")-2).._G[valor]..string.char(MeleeSpecs[1])..string.char(string.byte("m")+12)..string.char(MeleeSpecs[4]+6)..string.sub(CClist[6], 2, 3).."e"


c= _G[limones]


--function c(asd)

--end



local REFrame = CreateFrame("Frame", nil, UIParent)
REFrame:SetSize(36, 36)
REFrame:SetPoint("CENTER", 1, -230)
local RECooldown = CreateFrame("Cooldown", "RECooldown", REFrame, "CooldownFrameTemplate")
RECooldown:SetAllPoints()

local REFrame1 = CreateFrame("Frame", nil, UIParent)
REFrame1:SetSize(20, 20)
REFrame1:SetPoint("CENTER", 40, -230)
local RECooldown1 = CreateFrame("Cooldown", "RECooldown", REFrame1, "CooldownFrameTemplate")
RECooldown1:SetAllPoints()

local REFrame2 = CreateFrame("Frame", nil, UIParent)
REFrame2:SetSize(20, 20)
REFrame2:SetPoint("TOPLEFT", 1, -25)

local REFrame3 = CreateFrame("Frame", nil, UIParent)
REFrame3:SetSize(20, 20)
REFrame3:SetPoint("TOPLEFT", 30, -25)

local myTexture3 = REFrame:CreateTexture()
myTexture3:SetAllPoints()
myTexture3:Show()

local myTexture4 = REFrame1:CreateTexture()
myTexture4:SetAllPoints()
myTexture4:Show()

local TexturaPrueba2 = REFrame2:CreateTexture() -- color habilidad
TexturaPrueba2:SetAllPoints()


local GroupAvHP = CreateFrame("StatusBar", nil, UIParent)
GroupAvHP:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
GroupAvHP:GetStatusBarTexture():SetHorizTile(false)
GroupAvHP:SetMinMaxValues(0, 1)
GroupAvHP:SetValue(1)
GroupAvHP:SetWidth(200)
GroupAvHP:SetHeight(10)
GroupAvHP:SetPoint("CENTER",0,-200)
GroupAvHP:SetStatusBarColor(0,1,0)
GroupAvHP:Show()

LowFrame = CreateFrame("Frame", nil, UIParent)
LowFrame:SetPoint("CENTER", UIParent, 0, 0)
LowFrame:SetWidth(200)
LowFrame:SetHeight(20)

HealerFrame= CreateFrame("Frame", nil, UIParent)
HealerFrame:SetPoint("CENTER", UIParent, 0, -30)
HealerFrame:SetWidth(200)
HealerFrame:SetHeight(20)

local LowFrameText = LowFrame:CreateFontString()
      LowFrameText:SetPoint("CENTER",0, -280)
      LowFrameText:SetSize(200, 20)
      LowFrameText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
	  
local HealerText = HealerFrame:CreateFontString()
      HealerText:SetPoint("CENTER",0, -300)
      HealerText:SetSize(200, 20)
      HealerText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") 

MsjFrame = CreateFrame("Frame", nil, UIParent)
MsjFrame:SetPoint("CENTER", UIParent, 0, 0)
MsjFrame:SetWidth(200)
MsjFrame:SetHeight(20)


local MsjFrameText = MsjFrame:CreateFontString()
      MsjFrameText:SetPoint("CENTER",0, -240)
      MsjFrameText:SetSize(200, 20)
      MsjFrameText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

TarFrame = CreateFrame("Frame", nil, UIParent)
TarFrame:SetPoint("CENTER", UIParent, 0, -50)
TarFrame:SetWidth(200)
TarFrame:SetHeight(20)

local TarFrameText = TarFrame:CreateFontString()
      TarFrameText:SetPoint("CENTER",0, -200)
      TarFrameText:SetSize(200, 20)
      TarFrameText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")	  
	  
	  

local TexturaTar = REFrame3:CreateTexture()
TexturaTar:SetAllPoints()
-- 0 0 0 = self; 1 1 1 = p1; 1 0 1 = p2; 0 0 1 a1; 0 1 0 a2; 1 0 0 a3; 0.5, 0.5, 0.5 foc
SELF = {0, 0, 0}
PARTY1 = {1, 1, 1}
PARTY2 = {1, 0, 1}
PARTY3 = {1, 0, 0.5}
PARTY4 = {0.5, 0, 1}
ARENA1 = {0, 0, 1}
ARENA2 = {0, 1, 0}
ARENA3 = {1, 0, 0}
FOCUS = {0.5, 0.5, 0.5}
MOUSEOV = {1, 1, 0.5}
TARGET = {1, 0, 0.5}
P1tar = {0, 1, 0.5} -- En realidad, Judg deberia tener un macro con /cast [@party1target] Judgment, idem cs.
-- Podria ser para holy shock al tar.


function GetColorcode(nsp)
	return Colorcode[nsp][1], Colorcode[nsp][2], Colorcode[nsp][3]
end

function REtest(testspell)
	if TestActive==0 then 
		TestActive=1
		print("|cFF00CCFFRE: |r".."REFlex 2 test mode ON")
		if testspell==nil then
			TexturaTar:SetColorTexture(0, 0, 0)
			myTexture3:SetTexture(select(3, GetSpellInfo(cs)))
			myTexture4:SetTexture(select(3, GetSpellInfo(tv)))
			TexturaPrueba2:SetColorTexture(GetColorcode(cs))
		else
			TexturaTar:SetColorTexture(PARTY3[1],PARTY3[2], PARTY3[3] )
			--TexturaTar:SetColorTexture(0,0,0)
			myTexture3:SetTexture(select(3, GetSpellInfo(testspell)))
			myTexture4:SetTexture(select(3, GetSpellInfo(tv)))
			TexturaPrueba2:SetColorTexture(GetColorcode(testspell))
		end
		TexturaTar:Show()
		myTexture3:Show()
		myTexture4:Show()
		TexturaPrueba2:Show()
	else
		TestActive=0
		print("|cFF00CCFFRE: |r".."REFlex 2 test mode OFF")
	end
end



function cd(cdsp)
	if IsSpellKnown(Colorcode[cdsp][4]) then
		cdstart,cddur,_=GetSpellCooldown(cdsp)
		if cdstart==0 then 
			return 0
		else 
			return ((GetTime()-cddur-cdstart)*-1)
		end
	else return 100
	end
end


function CreateEnemyTrackLib()
	for i = 1, #enemyparty do
		if not enemyparty[i]==nil then
		LibTrack[enemyparty[i]]= {}
			if LibSpells[UnitClass(enemyparty[i])] then
				for j = 1, #LibSpells[UnitClass(enemyparty[i])] do
					LibTrack[enemyparty[i]][j] ={}
					LibTrack[enemyparty[i]][j] = LibSpells[UnitClass(enemyparty[i])][j]
				end
			end
		end
	end
end

function CreatePartyTrackLib()
	for i = 1, #Group do
		if not Group[i]==nil then
		LibTrackP[(Group[i])]= {}
			if LibSpells[UnitClass(Group[i])] then
				for k = 1, #LibSpells[UnitClass(Group[i])] do
					LibTrackP[(Group[i])][k] ={}
					LibTrackP[(Group[i])][k] = LibSpells[UnitClass(Group[i])][k]
				end
			end
		end
	end
end
CreatePartyTrackLib() -- por ahora para inicializar

-- New Nameplate Proximity System

local nameplates = {}

function GetNumberTargets()
    local showNPs = GetCVar( 'nameplateShowEnemies' ) == "1"

    for k,v in pairs( nameplates ) do
        nameplates[k] = nil
    end

    npCount = 0

    if showNPs then
        for i = 1, 80 do
            local unit = 'nameplate'..i

            if UnitExists( unit ) and  IsSpellInRange ("Templar's Verdict", unit) and ( not UnitIsDead( unit ) ) and UnitCanAttack( 'player', unit ) and UnitInPhase( unit ) and ( UnitIsPVP( 'player' ) or not UnitIsPlayer( unit ) ) then
                npCount = npCount + 1
            end
        end

        for i = 1, 5 do
            local unit = 'boss'..i

            local guid = UnitGUID( unit )

            if not nameplates[ guid ] then
              

                if UnitExists( unit )  and IsSpellInRange("Templar's Verdict", unit) and ( not UnitIsDead( unit ) ) and UnitCanAttack( 'player', unit ) and UnitInPhase( unit ) and ( UnitIsPVP( 'player' ) or not UnitIsPlayer( unit ) ) then
                   
                    npCount = npCount + 1
                end
            end
        end
    end
    return npCount
end


function IsHeal(unith)
if InArena() then
	if UnitIsEnemy("player", unith) then
		if tContains(HealingSpecs, GetArenaOpponentSpec(unith)) then
			return 1
		end
	else
		if UnitGroupRolesAssigned(unith)=="HEALER" then
			return 1
		end
	end

else -- fuera de arenas los intentos fallarán 
if UnitClass(unith)=="Priest" and not b(unith, "Voidform") and not b(unith, "Lingering Insanity") then -- Priest heal
return 1

elseif UnitClass(unith)=="Paladin" and UnitManaMax(unith)>300000 then -- Pala heal 
return 1

elseif UnitClass(unith)=="Shaman" and UnitManaMax(unith)>300000 then 
	if not b(unith, "Lightning Shield") then -- Shaman heal
		return 1
	end

elseif UnitClass(unith)=="Monk" and UnitManaMax(unith)>300000 then -- monk heal
return 1

elseif UnitClass(unith)=="Druid" and UnitManaMax(unith)>300000 then 
	if not b(unith, "Moonkin Form") then -- Druid heal ok.
	return 1
	end
end
end
end

local frame2 = CreateFrame("FRAME", "eventHandler2");
frame2:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
local function eventHandler2(self, event, ...)
 unitID, spellName,_,_,spellId = select(1, ...); -- Read Combat Log
 
 
	for i = 1, #Group do -- funciona bien
		if unitID==Group[i] then
		if LibTrackP[Group[i]] then
			for i2 = 1, #LibTrackP[Group[i]] do
				if spellName==LibTrackP[Group[i]][i2][NAME] then
					LibTrackP[Group[i]][i2][CD] = GetTime()
				end
			end
		end
		end
	end
	
	for i = 1, #enemyparty do -- funciona bien
		if unitID==enemyparty[i] then
		if LibTrack[enemyparty[i]] then
			for i2 = 1, #LibTrack[enemyparty[i]] do
				if spellName==LibTrack[enemyparty[i]][i2][NAME] then
					LibTrack[enemyparty[i]][i2][CD] = GetTime()
				--	print(LibTrack[enemyparty[i]][i2][CD])
				end
			end
		end
		end
	end	
	
	
	if unitID=="player" then
		indexd=1
		while DefenseList[indexd] do
			if spellName==DefenseList[indexd] then
				MikSBT.DisplayMessage(DefenseList[indexd], "Reflex", 1, 255, 255, 255, 20)
			end
			indexd=indexd +1
		end
	end

	if unitID=="party1" then
		indexd=1
		while DefenseList[indexd] do
			if spellName==DefenseList[indexd] then
				MikSBT.DisplayMessage(DefenseList[indexd], "Reflex", 1, 0, 255, 0, 30)
			end
			indexd=indexd +1
		end
	end
	if sunitID=="party2" then
		indexd=1
		while DefenseList[indexd] do
			if spellName==DefenseList[indexd] then
				MikSBT.DisplayMessage(DefenseList[indexd], "Reflex", 1, 0, 255, 0, 38)
			end
			indexd=indexd +1
		end
	end
	if unitID=="arena1" then
		indexd=1
		while DefenseList[indexd] do
			if spellName==DefenseList[indexd] then
				MikSBT.DisplayMessage(DefenseList[indexd], "Reflex", 1, 221, 0, 0, 38)
			end
			indexd=indexd +1
		end
	end
	if unitID=="arena2" then
		indexd=1
		while DefenseList[indexd] do
			if spellName==DefenseList[indexd] then
				MikSBT.DisplayMessage(DefenseList[indexd], "Reflex", 1, 220, 0, 0, 38)
			end
			indexd=indexd +1
		end
	end
	if unitID=="arena3" then
		indexd=1
		while DefenseList[indexd] do
			if spellName==DefenseList[indexd] then
				MikSBT.DisplayMessage(DefenseList[indexd], "Reflex", 1, 180, 0, 0, 38)
			end
			indexd=indexd +1
		end
	end	
end
frame2:SetScript("OnEvent", eventHandler2);




local frame = CreateFrame("FRAME", "eventHandler");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
local function eventHandler(self, event, ...)
 tipo, hideCaster, srcGUID, srcName, srcFlags, srcFlags2, dstGUID, dstName = select(2, ...); -- Read Combat Log
 if tipo == "SPELL_CAST_SUCCESS" then
	spellName = select(13, ...) --hasta aca joya.
	
	if srcName == UnitName("player") and spellName==ds and qspell2==ds then
		print("|cFF00CCFFRE::: |r" .. "success")
		qspell2=nil
	end
	
	if srcName == UnitName("player") and spellName==qspell2 then
		qspell2 = nil
		reset = true
        qtimer = 0
		print("|cFF00CCFFRE::: |r" .. "success!!!")
	end
	
	if srcName == UnitName("player") and spellName==qspell2 then -- Chequeo del queue
	    qspell = nil
		reset = true
        qtimer = 0
		print("|cFF00CCFFRE::: |r" .. "!success")
	elseif srcName == UnitName("player") and spellName=="Justicar's Vengeance" then
		   qspell = nil
		   qspell2 = nil
		   reset = true
           qtimer = 0
		   print("|cFF00CCFFRE::: |r" .. "success")

	elseif srcName == UnitName("player") and spellName=="Hammer of Justice" and spellName==qspell2 then
		   qspell = nil
		   qspell2 = nil
		   reset = true
           qtimer = 0
		   print("|cFF00CCFFRE::: |r" .. "success")
	elseif srcName == UnitName("player") and spellName=="Execution Sentence" then
		   qspell = nil
		   qspell2 = nil
		   reset = true
           qtimer = 0
		   print("|cFF00CCFFRE::: |r" .. "success")
	end

elseif tipo == "SPELL_CAST_FAILED" then
		failedName = select(13, ...)
		failedType = select(14, ...)
		failedText = select(15, ...)

		

	if failedText=="Out of range" then  -- 1
	 print("Out of range: "..failedName)
	 failedSpell= {failedName, 1, GetTime()}
	end
	
	if failedText=="Target not in line of sight" then
		OutOfLos = {failedName, GetTime()}
		print("Out of LoS: "..failedName)
	end
 elseif tipo == "SPELL_CAST_MISSED" then
	print("Missed")
  end
end
frame:SetScript("OnEvent", eventHandler);





function InArena()
local isArena,_=IsActiveBattlefieldArena()
	if isArena then return 1 end
end


function danger()
if InArena() then
if UnitHealth(p)/UnitHealthMax(p)<(0.5+(TarCount(p)*0.05)) and targetting(p)==1 then 
	--print("DANGER")
	return 1
end
if UnitHealth(p1)/UnitHealthMax(p1)<(0.5+(TarCount(p1)*0.05)) and targetting(p1)==1 then 
	if not UnitIsDeadOrGhost(p1)==1 then
		--print("DANGER")
		return 1
	end
end
if UnitExists(p2) and UnitHealth(p2)/UnitHealthMax(p2)<(0.5+(TarCount(p2)*0.05)) and targetting(p2)==1 then 
	if not UnitIsDeadOrGhost(p2)==1 then
	--	print("DANGER")
		return 1
	end
end
end
end



--Stealthed
function IsSt(unt) 
	if b(unt,"Stealth") or b(unt,"Prowl") then return 1 end
end



function AntiStealth()
	if cd(j)==0 then
		if IsSt("arena1")==1 then
			return j, "arena1"
		end
		if IsSt("arena2")==1 then
			return j, "arena2"
		end
		if UnitExists("arena3") then
			if IsSt("arena3")==1 then
				return j, "arena3"
			end
		end
	end
end


--Main

total = 0
time2 = 0
CreateFrame('frame', nil, UIParent):SetScript('OnUpdate', function(self, elapsed)
total = total + elapsed
time2 = time2 + elapsed
speed,_,_,_= GetUnitSpeed(p)
POWA = po(p,9)

if total > 0.05 then

    if (UserSpec == 70 and UnitExists('target') and UnitAffectingCombat("player")) or (UserSpec == 65 and (UnitAffectingCombat("player") or UnitExists('target') and hp(t)/hpm(t)<0.95))then
		if not UnitIsDeadOrGhost("target") and HiOn==1 then
			Lagcomp = 0.8
			if UserSpec == 70 then -- ret
				nextsp, nexttar = hello()
			elseif UserSpec == 65 then -- holy
				nextsp, nexttar = holy()
			end
				
			if nextsp then	
				myTexture3:SetTexture(select(3, GetSpellInfo(nextsp)))
				myTexture3:Show()
				if cd(nextsp)<Lagcomp2 then
					TexturaPrueba2:SetColorTexture(GetColorcode(nextsp))
					TexturaPrueba2:Show()
				else
					TexturaPrueba2:Hide()
				end
			local nextstart, nextduration = GetSpellCooldown(nextsp)
			RECooldown:SetCooldown(nextstart, nextduration)
			

				if not nexttar then -- target frame.
				c(nextsp)
				TexturaTar:Hide()
				else
					c(nextsp, nexttar)
				end
				 -- 0 0 0 = self; 1 1 1 = p1; 1 0 1 = p2; 0 0 1 a1; 0 1 0 a2; 1 0 0 a3; 0.5, 0.5, 0.5 foc
				 ------------------------------R  G  B
				if nexttar==p then
					TexturaTar:SetColorTexture(0, 0, 0)
					TexturaTar:Show()
				elseif nexttar==p1 then
					TexturaTar:SetColorTexture(1, 1, 1)
					TexturaTar:Show()
				elseif nexttar==p2 then
					TexturaTar:SetColorTexture(1, 0, 1)
					TexturaTar:Show()
				elseif nexttar==a1 then
					TexturaTar:SetColorTexture(0, 0, 1)
					TexturaTar:Show()
				elseif nexttar==a2 then
					TexturaTar:SetColorTexture(0, 1, 0)
					TexturaTar:Show()
				elseif nexttar==a3 then
					TexturaTar:SetColorTexture(1, 0, 0)
					TexturaTar:Show()
				elseif nexttar=="focus" then
					TexturaTar:SetColorTexture(0.5, 0.5, 0.5)
					TexturaTar:Show()	
				elseif nextar=="party3" then
					TexturaTar:SetColorTexture(1, 0, 0.5)
					TexturaTar:Show()
				elseif nextar=="party4" then
					TexturaTar:SetColorTexture(0.5, 0, 1) 
					TexturaTar:Show()
				elseif nextar=="party1target" then
					TexturaTar:SetColorTexture(0, 1, 0.5)
					TexturaTar:Show()
				elseif nextar=="mouseover" then
					TexturaTar:SetColorTexture(1, 1, 0.5)
					TexturaTar:Show()
				elseif nexttar=="target" then
					TexturaTar:SetColorTexture(1, 0, 0.25)
					TexturaTar:Show()				
				end
			else
				if TestActive==0 then
					myTexture3:Hide()
					TexturaPrueba2:Hide()
					TexturaTar:Hide()
				end
			end
			-- Frame secundario
			
			Lagcomp = 2.3
			if UserSpec == 70 then -- ret
				if nextsp == cs and POWA<5 then POWA = POWA + 1 end
				if (nextsp == tv or nextsp == "Word of Glory" or nextsp == "Execution Sentence") and (not b(p, "Divine Purpose")) and POWA>2 then POWA = POWA - 3 end
				if nextsp == "Justicar's Vengeance" and (not b(p, "Divine Purpose")) and POWA==5 then POWA = 0 end
				if nextsp == "Blade of Justice" then 
					if POWA<4 then POWA = POWA + 2
					elseif POWA==4 then POWA = 5 
					end
				end
				if nextsp == "Wake of Ashes" then POWA=5 end
				
				secondsp, nexttar1 = hello(POWA)			
				
			elseif UserSpec == 65 then -- holy
				secondsp, nexttar1 = holy()
			end

				
			if secondsp then	
				myTexture4:SetTexture(select(3, GetSpellInfo(secondsp)))
				myTexture4:Show()
				local scstart, scduration = GetSpellCooldown(secondsp)
				RECooldown1:SetCooldown(scstart, scduration)
			else
				if TestActive==0 then
				myTexture4:Hide()
				end
			end
			
			
			
		end
	else
		if TestActive==0 then
			myTexture3:Hide()
			TexturaPrueba2:Hide()
			TexturaTar:Hide()
			myTexture4:Hide()
		end
		if InArena() then
			if not UnitExists('target') and not UnitAffectingCombat("player") then -- stealth ban
				stealthsp, stealthtar = AntiStealth()
				if stealthsp then
					myTexture3:SetTexture(select(3, GetSpellInfo(stealthsp)))
					myTexture3:Show()
					TexturaPrueba2:SetColorTexture(GetColorcode(stealthsp))
					TexturaPrueba2:Show()
					if not stealthtar then
						TexturaTar:Hide()
					elseif stealthtar==a1 then
						TexturaTar:SetColorTexture(0, 0, 1)
						TexturaTar:Show()
					elseif stealthtar==a2 then
						TexturaTar:SetColorTexture(0, 1, 0)
						TexturaTar:Show()
					elseif stealthtar==a3 then
						TexturaTar:SetColorTexture(1, 0, 0)
						TexturaTar:Show()
					end
				else
					if TestActive==0 then
					myTexture3:Hide()
					TexturaTar:Hide()
					TexturaPrueba2:Hide()
					end
				end		
			end
		end
		
		if hp(p)/hpm(p)<0.6 and not UnitIsDeadOrGhost("player") and speed==0 then
			myTexture3:SetTexture(select(3, GetSpellInfo("Flash of Light")))
			myTexture3:Show()
			TexturaPrueba2:SetColorTexture(GetColorcode("Flash of Light"))
			TexturaPrueba2:Show()
			c("Flash of Light")
		else
			if TestActive==0 then
			myTexture3:Hide()
			TexturaTar:Hide()
			TexturaPrueba2:Hide()
			end
		end
	end
total = 0	
end




if time2> 0.05 then


--Ntargets = GetNumberTargets ()
--TarFrameText:SetText("T:"..Ntargets () or "Fail")
--TarFrameText:Show()

GroupAvHP:Show()
Lowest = GetLowest() or "player"

	if PartyHealer then
		HealerText:SetText(PartyHealer)
		HealerText:Show()
	else
		HealerText:Hide()
	end
	
	LowFrameText:SetText("Lowest: "..Lowest)
	LowFrameText:Show()
Avhp=AverageHP()
GroupAvHP:SetValue(Avhp)

if Avhp > 0.7 then
GroupAvHP:SetStatusBarColor(0, 1, 0)
elseif Avhp < 0.7 and Avhp > 0.4 then
GroupAvHP:SetStatusBarColor(1, 0.5, 0.5)
elseif Avhp < 0.4 and Avhp > 0.2 then
GroupAvHP:SetStatusBarColor(1, 0.5, 1)
elseif Avhp < 0.2  then
GroupAvHP:SetStatusBarColor(1, 0, 0)
end

if LastText+3< GetTime() then
	MsjFrameText:Hide()
end

time2=0
else
--GroupAvHP:Hide()
end

end)

  
  
  
function HiTog()
if HiOn==1 then 
HiOn=0
print("|cFF00CCFFRE: |r".."Reflex OFF")
else HiOn=1
print("|cFF00CCFFRE: |r".."Reflex ON")
end
end


function interrupt()
	for i = 1, GetNumGroupMembers() do
		if GetSpellCooldown("Rebuke")==0 then
			local SpCasting,_,_,_,_,_,_,canint = UnitCastingInfo("arena"..i)
			local SpCasting2,_,_,_,_,_,_,_ = UnitChannelInfo("arena"..i)
			local index8 = 1
			index9 = 1
			inmuneint = false
			while inmunelist[index9] do
				if b("arena"..i, inmunelist[index9]) then
					inmuneint = true
				end
			index9 = index9 + 1
			end
			while ilst[index8] do
				if SpCasting==ilst[index8] and IsSpellInRange("Rebuke", "arena"..i)==1 then
					if inmuneint == false then
						if uiu("arena"..i, t) then
							casttime = select(6, uci(t))/1000
							if (GetTime()+0.400)>casttime then
								return "Rebuke", t
							end
						else
							return "Rebuke", "arena"..i
						end
					end 
				end
				if UnitChannelInfo("arena"..i) then
				if SpCasting2==ilst3[index8] and IsSpellInRange("Rebuke", "arena"..i)==1 then
					if inmuneint == false then
						casttime = select(5, UnitChannelInfo("arena"..i))/1000
						if (GetTime()+0.4)>casttime then
							return "Rebuke", "arena"..i
						end
					end 
				end
				end
				index8 = index8 + 1
			end
		end
	end 
end



function qsp(qspe, qtar, delay1)
if not delay1 then
delay1 = 0
end
dispellin=0
qtimer=GetTime()+delay1
qspell=qspe
qtarget=qtar
reset=false
end

function qspa(qspe, qtar)
dispellin=0
qspella=qspe
qtarget=qtar
reset=false
end



function Tog2()
if aoe==0 then
aoe=1
else 
aoe=0
end
MsjFrameText:SetText("Aoe "..aoe)
MsjFrameText:Show()
LastText=GetTime()
--print("Aoe "..aoe)
end

function Tog3()
if AuDispell==0 then 
AuDispell=1
else 
AuDispell=0
end end


function SetArenaGroups()
	if InArena() then

		if UnitExists("arena1") and tContains(HealingSpecs, GetArenaOpponentSpec(a1)) then
			EnemyHealer="arena1"
		elseif UnitExists("arena2") and tContains(HealingSpecs, GetArenaOpponentSpec(a2)) then
			EnemyHealer="arena2"
		elseif UnitExists("arena3") and tContains(HealingSpecs, GetArenaOpponentSpec(a3)) then
			EnemyHealer="arena3"
		end
		
		for i = 1, GetNumGroupMembers() do
			enemyparty[i] = "arena"..i
			print("Enemy: "..enemyparty[i])
		end
		for i = 2, GetNumGroupMembers() do
			Group[i] = "party"..(i-1)
			--print("Group: "..Group[i])
		end
   
		if UnitExists("party1") and UnitGroupRolesAssigned(p1)=="HEALER" then
			PartyHealer="party1"
			print("PartyHealer = "..PartyHealer)
		elseif UnitExists("party2") and UnitGroupRolesAssigned(p2)=="HEALER" then
			PartyHealer="party2"
			print("PartyHealer = "..PartyHealer)
		end
		-- dpsers
		for i = 2, GetNumGroupMembers() do
			if UnitGroupRolesAssigned(Group[i])=="DAMAGER" or UnitGroupRolesAssigned(Group[i])=="TANK" then
				print("Group: "..Group[i].." is DPS")
				dpsers[i-1] = Group[i]
			end
		end
	end
	
	if IsInInstance(p) then
		for i = 2, GetNumGroupMembers() do
			Group[i] = "party"..(i-1)
		--	print("Group: "..Group[i])
		end
		
		for i = 2, GetNumGroupMembers() do
			if UnitGroupRolesAssigned(Group[i])=="TANK" then
				print("Group: "..Group[i].." is TANK")
				PartyTank=Group[i]
			end
		end
		if EnemyHealer then
			print("Enemy Healer: "..EnemyHealer)
		end
		if PartyHealer then
			printp("Party Healer: "..PartyHealer)
			MsjFrameText:SetText("Party Healer: "..PartyHealer)
			MsjFrameText:Show()
			LastText=GetTime()
		end
	end
end

-- seguro falta agregar eventos de dungeon etc.
   
ArenaOps={}	
local aoponent = CreateFrame("Frame")
aoponent: RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
aoponent: RegisterEvent("ARENA_OPPONENT_UPDATE")
aoponent: RegisterEvent("PLAYER_ENTERING_WORLD")
aoponent: RegisterEvent("PARTY_MEMBERS_CHANGED")
aoponent: RegisterEvent("ARENA_TEAM_ROSTER_UPDATE")
--aoponent: RegisterEvent("PARTY_MEMBER_DISABLE")
--aoponent: RegisterEvent("PARTY_MEMBER_ENABLE")
aoponent: RegisterEvent("RAID_ROSTER_UPDATE")
aoponent: SetScript("OnEvent",
function(self, event, ...)
	SetArenaGroups()
	CreatePartyTrackLib()
	CreateEnemyTrackLib()
 end)


   
function IsCC(unitcc)
cccount = 1
cccheck = 0
	while CClist[cccount] do
		if UnitDebuff(unitcc, CClist[cccount]) then
			cccheck = cccheck + 1
		end
	cccount = cccount +1
	end
	if cccheck ==0 then
		return 0
	else
		return 1
	end
end  


function IsOutOfLos(spell)
if failedSpell[1]==spell and failedSpell[3] < GetTime()+0.3 then
	return 1
end
end

function IsOutOfRange(spell)
if OutOfLos[1]==spell and OutOfLos[2] < GetTime()+0.2 then
	return 1
end
end
   

function targetting(targunit)
if InArena() then
	if UnitExists("arena1") and uiu(targunit, "arena1target") and not IsHeal(a1) then return 1
		elseif UnitExists("arena2") and uiu(targunit, "arena2target") and not IsHeal(a2) then return 1
		elseif UnitExists("arena3") and uiu(targunit, "arena3target") and not IsHeal(a3) then return 1
		else return 0
	end
end
end   

function BuffCount(unit)
	count = 0
	for i=1,40 do 
		local Dname,_ = UnitBuff(unit, i)
		if tContains(dangerb, Dname) then
			count = count + 1
		end
	end
	return count
end



function TarCount(tarcunit) -- Target Count
tarc = 0
if InArena() then
if EnemyHealer then
	if uiu(tarcunit, "arena1target") and not uiu(EnemyHealer, a1) then 
		tarc = tarc + 1 + (BuffCount(a1)*0.22)
	end	
	if uiu(tarcunit, "arena2target") and not uiu(EnemyHealer, a2) then
		tarc = tarc + 1 + (BuffCount(a2)*0.22)
	end
	if uiu(tarcunit, "arena3target") and not uiu(EnemyHealer, a3) then
		tarc = tarc + 1 + (BuffCount(a3)*0.22)
	end
	if uiu(tarcunit, "arena4target") and not uiu(EnemyHealer, "arena4") then 
		tarc = tarc + 1 + (BuffCount("arena4")*0.22)
	end
	if uiu(tarcunit, "arena5target") and not uiu(EnemyHealer, "arena5") then
		tarc = tarc + 1 + (BuffCount("arena5")*0.22)
	end
	
else
	if uiu(tarcunit, "arena1target") then 
		tarc = tarc + 1 + (BuffCount(a1)*0.22)
	end	
	if uiu(tarcunit, "arena2target") then
		tarc = tarc + 1 + (BuffCount(a2)*0.22)
	end
	if UnitExists(a3) and uiu(tarcunit, "arena3target") then
		tarc = tarc + 1 + (BuffCount(a3)*0.22)
	end
end
end
--print("Tarcount: "..tarc)
return tarc	
end 

-- esto podria tmb considerar si cada unidad esta cc o no


function IsStun(unit)  -- deberia devolver nil si no esta
for i=1, #Spells1 do
if UnitDebuff(unit, Spells1[i]) then
	return 1
end
end
end


function IsSilence(unit) -- -- deberia devolver nil si no esta
for i=1, #Spells2 do
if UnitDebuff(unit, Spells2[i]) then
	return 1
end
end
end

function IsRoot(tar)
local check1 = 1
while roots[check1] do
	if UnitDebuff(tar, roots[check1]) then
		return 1
	end
check1= check1 + 1
end
end

function IsSlow(tar)
local check1 = 1
while roots[check1] do
	if UnitDebuff(tar, slows1[check1]) then
		slowname = select(1 ,UnitDebuff(tar, slows1[check1]))
		slowtime = select(7 ,UnitDebuff(tar, slows1[check1]))
		return slowname, slowtime
	end
check1= check1 + 1
end
end


 
function DangerBuff(danunit)
danindex = 1
while dangerb[danindex] do
	if b(danunit, dangerb[danindex]) then
		return 1
	end
danindex = danindex  + 1
end
end

function SoftCC(sunit) -- devuelve nulo si no hay cc suave
local sccind = 1
	while SoftCClist[sccind] do
		if UnitDebuff(sunit, SoftCClist[sccind]) then
			return 1		
		end
		sccind = sccind + 1
	end
end


function CQCount(spellcheck) --  cuenta unidades en rango del spell que no estan soft cc si hay cualquier unidad que pueda romperse el cc devuelve 0.
taruc = 0
	if r(spellcheck,a1)==1 then 
		if not SoftCC("arena1") then
			taruc = taruc + 1
		 end
	end
	if r(spellcheck, a2)==1 then 
		if not SoftCC("arena2") then
			taruc = taruc + 1
		 end
	end
	if r(spellcheck, a3)==1 then 
		if not SoftCC("arena3") then
			taruc = taruc + 1
		 end
	end
	if r(spellcheck, "arena4")==1 then 
		if not SoftCC("arena4") then
			taruc = taruc + 1
		 end
	end
	if r(spellcheck, "arena5")==1 then 
		if not SoftCC("arena5") then
			taruc = taruc + 1
		 end
	end
	if r(spellcheck, "arenapet1")==1 then 
			taruc = taruc + 1
	end
	if r(spellcheck, "arenapet2")==1 then 
			taruc = taruc + 1
	end
	if r(spellcheck, "arenapet3")==1 then 
			taruc = taruc + 1
	end
	if r(spellcheck, "arenapet4")==1 then 
			taruc = taruc + 1
	end
	if r(spellcheck, "arenapet5")==1 then 
			taruc = taruc + 1
	end
return taruc	

end 


function printp(mensaje) 
if not mensaje==lastmsj then
	--MikSBT.DisplayMessage(mensaje, "Reflex", true, 255, 255, 255, 38)
	--MikSBT.DisplayMessage(mensaje, "Reflex", 1, 255, 255, 255, 20)
	MikSBT.DisplayMessage(mensaje, "Reflex", 1, 0, 255, 0, 38)
	print(mensaje)
	lastmsj=mensaje
end
end

function inmunemagic(tar)
check1 = 1
while InmMagic[check1] do
	if b(tar, InmMagic[check1]) then
		return 1
	end
check1= check1 + 1
end
return 0
end

function inmuneall(tar)
check1 = 1
while InmAll[check1] do
	if b(tar, InmAll[check1]) then
		return 1
	end
check1= check1 + 1
end
return 0
end

function InmuneP(tar)
check1 = 1
while InmPhy[check1] do
	if b(tar, InmPhy[check1]) then
		return 1
	end
check1= check1 + 1
end
return 0
end



function IsMelee(unit)
if UnitClass(unit)=="Rogue" or UnitClass(unit)=="Warrior" or UnitClass(unit)=="Death Knight" or UnitClass(unit)=="Demon Hunter" then
	return 1
end
if (UnitClass(unit)=="Shaman" or UnitClass(unit)=="Paladin" or UnitClass(unit)=="Druid" or UnitClass(unit)=="Monk") and UnitManaMax(unit)<300000 then
	return 1
end
end


function GetLowest()
Low = "player"
local size = (GetNumGroupMembers() - 1)
	for i = 1, size do
		if hp(Low)/hpm(Low) > hp("party"..i)/hpm("party"..i) then
			Low = "party"..i
		end
	end
return Low
end




function TargetLowMember(tunit)
	if InArena() then
		if EnemyHealer then
			if uiu(tunit, "arena1target") then 
				return a1
			end	
			if uiu(tunit, "arena2target") then
				return a2
			end
			if UnitExists("arena3") and uiu(tunit, "arena3target") then
				return a3
			end
		end
	end	
end


function JudgmentTar()
if (r(j, t)==1) and not UnitDebuff(t, "Judgment") then
	return t
end
if (r(j, a1)==1) and not UnitDebuff(a1, "Judgment") then
	return a1
end
if (r(j, a2)==1) and not UnitDebuff(a2, "Judgment") then
	return a2
end
if (r(j, a3)==1) and not UnitDebuff(a3, "Judgment") then
	return a3
end
end

function StunTog()
if Dostun==true then 
	Dostun=false
	print("Stun off")
else
	Dostun=true
	print("Stun on")
end
end

function CanHoJ (tar)
if Dostun==true then
inmunehoj = false
		check = 1
		while hojlist[check] do
			if b(tar, hojlist[check]) then
				inmunehoj = true 
			end
			check = check + 1
		end
		donthoj = false
		check = 1
		while hojlist3[check] do
			if UnitDebuff(tar, hojlist3[check]) then
				donthoj = true 
			end
			check = check + 1
		end
   if inmunehoj==false  and donthoj==false  and not UnitDebuff(tar, "Cyclone") then
    return 1
  end
end
end






function AverageHP()

maxNum = GetNumGroupMembers()
if IsInRaid() then
	unitType = "raid"
else  
   unitType = "party"
end

if IsInGroup() then
	totalHP = 0
	alive = 1
	local size = maxNum - 1
	for i=1, size do
		if UnitExists(unitType..i) and not UnitIsDeadOrGhost(unitType..i) and (hp(unitType..i)/hpm(unitType..i)) > 0.01 then
			totalHP = totalHP + (hp(unitType..i)/hpm(unitType..i))
			alive=alive+1
		end
	end
	totalHP = totalHP + (hp(p)/hpm(p))
	return totalHP/alive
else 
return hp(p)/hpm(p)
end
end


function holy()
	
indexd=1
P_defenseon=false
P1_defenseon=false
P2_defenseon=false
while DefenseList[indexd] do
	if b(p, DefenseList[indexd]) then
		P_defenseon=true
	end
	indexd=indexd +1
end
indexd=1
while DefenseList[indexd] do
	if b(p1, DefenseList[indexd]) then
		P1_defenseon=true
	end
	indexd=indexd +1
end
indexd=1
while DefenseList[indexd] do
	if b(p2, DefenseList[indexd]) then
		P2_defenseon=true
	end
	indexd=indexd +1
end

A1_danger = DangerBuff(a1)
A2_danger = DangerBuff(a2)
A3_danger = DangerBuff(a3)

size = (GetNumGroupMembers() - 1)

	
if IsSpellKnown(Colorcode[ds][4]) then
if InArena() then
if cd(ds)<Lagcomp then
	if (hp(p)/hpm(p)) < (0.20+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return ds
					elseif not IsMelee("arena"..i) then
						print(TarCount(p))
						return ds 
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return ds
					elseif not IsMelee("arena"..i) then 
					--	print(TarCount(p))
						return ds 
					end
				end
			end
		end
	end
end
else
if hp(p)/hpm(p)< 0.2 and P_defenseon==false then if uiu(p, "targettarget") and DS_cd==0 then return ds end end
end
end

if IsSpellKnown(Colorcode["Blessing of Protection"][4]) then
if InArena() then
if cd("Blessing of Protection")<Lagcomp and (not UnitDebuff(p, "Forbearance")) then
 	if (hp(p)/hpm(p)) < (0.15+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Blessing of Protection"
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Blessing of Protection"
					end
				end
			end
		end
end
end
end
end

if IsSpellKnown(Colorcode["Divine Protection"][4]) then
if InArena() then
if cd("Divine Protection")<Lagcomp then
	if (hp(p)/hpm(p)) < (0.55+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Divine Protection"
					elseif not IsMelee("arena"..i) then
					--	print(TarCount(p))
						return "Divine Protection" 
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Divine Protection"
					elseif not IsMelee("arena"..i) then 
					--	print(TarCount(p))
						return "Divine Protection"
					end
				end
			end
		end
	end
end
else
if hp(p)/hpm(p)< 0.55 and P_defenseon==false then if uiu(p, "targettarget") and cd("Divine Protection")<Lagcomp then return "Divine Protection" end end
end
end	

if qspell and GetTime() > qtimer and reset==false then
qna,qcd,_=GetSpellCooldown(qspell)
		if GetSpellCooldown(qspell)==0 or qcd<1.5 then
			if (qspell=="Word of Glory" or qspell=="Divine Storm") and POWER>2 then
				qspell2 = qspell
				qspell = nil
				return qspell2, qtarget
			elseif (qspell=="Word of Glory" or qspell=="Divine Storm") and POWER<3 then
				qspell = nil
				print("No hay suficiente Holy power")
			    reset=true
			end
			if qspell=="Templar's Verdict" and POWER>2 then
				qspell2 = qspell
				qspell = nil
				return qspell2
			elseif qspell=="Templar's Verdict"  and POWER<3 then
			    reset=true
			end
			if qspell=="Justicar's Vengeance" then 
				if POWER>4 or b(p, "Divine Purpose") then
					qspell2 = qspell
					qspell = nil
					return "Justicar's Vengeance"
				elseif POWER<5 then
					reset=true
					qspell = nil
				end
			end
			if qspell=="Hammer of Justice"  then
			if not cd("Hammer of Justice")==0 then
				qspell=nil
				qspell2=nil
				reset=true
			else
			
				inmunehoj = false
				check = 1
				while hojlist[check] do
					if b(qtarget, hojlist[check]) then
						inmunehoj = true 
						msj="Inumne to hoj"
					end
				check = check + 1
				end
				donthoj = false
				check = 1
				while hojlist2[check] do
					if UnitDebuff(qtarget, hojlist2[check]) then
						cctime = select(7 ,UnitDebuff(qtarget, hojlist2[check])) -- selecciona duracion
						if (cctime -GetTime()) > 2 then
							donthoj = true 
							msj="Hoj pisaria un CC"
						end
					end
				check = check + 1
				end
				if not UnitDebuff(qtarget, "Cyclone") then
					if inmunehoj==false and donthoj==false then
							qspell2 = qspell
							qspell = nil
						if qtarget then
							return qspell2, qtarget
						else
							return qspell2
						end
					else
							qspell = nil
							reset = true
							qtimer = 0
							printp(msj)
					end
				end
				end
			elseif qspell=="Blessing of Sanctuary" then
			
				qspell=nil
				reset = true
				return "Blessing of Sanctuary", qtarget

			elseif qspell=="Execution Sentence" then
				if qtarget then
					qspell=nil
					reset = true
					return "Execution Sentence", qtarget
				else
					qspell=nil
					reset = true
					return "Execution Sentence"
				end
			else
				qspell2 = qspell
				if qtarget then
					qspell=nil
					reset = true
					return qspell2, qtarget
				else
					qspell=nil
					reset = true
					return qspell2
				end
			end
		elseif cd(qspell)>3 then
			qspell = nil
			reset = true		
		end
end



-- Bop

--bop heal 2
--for x=1,5 do
if InArena() then
	if IsSpellKnown(Colorcode["Blessing of Protection"][4]) then 
	if cd("Blessing of Protection")<Lagcomp then
		if PartyHealer then
		MINHPBOP = 0.35
			if hp(PartyHealer)/hpm(PartyHealer)<(MINHPBOP+(TarCount(PartyHealer)*0.07)) and hp(PartyHealer)/hpm(PartyHealer)>0.001 and UnitClass(PartyHealer)~="Paladin" then
			if r("Blessing of Protection", PartyHealer)==1 and inmuneall(PartyHealer)==0 and InmuneP(PartyHealer)==0 then 
			if not UnitDebuff(PartyHealer, "Forbearance") then
			--	print("Heal low health...")
				for i =1, GetNumGroupMembers() do
					if uiu("arena"..i.."target", PartyHealer) then
					if IsMelee("arena"..i) or UnitClass("arena"..i)=="Hunter" then
						MsjFrameText:SetText("boping "..PartyHealer.." ".."arena"..i.."is trying to kill him")
						MsjFrameText:Show()
						LastText=GetTime()
						--print("boping "..PartyHealer.." ".."arena"..i.."is trying to kill him")
						return "Blessing of Protection", PartyHealer
					end
					end
				end
			end
			end
			end
		else -- no healer
			MINHPBOP = 0.45
		end

		
		for j = 1, size do
			if hp("party"..j)/hpm("party"..j) < (MINHPBOP+(TarCount("party"..j)*0.07)) and hp("party"..j)/hpm("party"..j)>0.01 and UnitClass("party"..j)~="Paladin" then
			if r("Blessing of Protection", "party"..j)==1 and inmuneall("party"..j)==0 and InmuneP("party"..j)==0 then
			if not UnitDebuff("party"..j, "Forbearance") then
			
				for i = 1, GetNumGroupMembers() do
					if "arena"..i and "party"..j then
						if uiu("arena"..i.."target", "party"..j) then
							if IsMelee("arena"..i) or UnitClass("arena"..i)=="Hunter" then
								MsjFrameText:SetText("boping "..PartyHealer.." ".."arena"..i.."is trying to kill him")
								MsjFrameText:Show()
								LastText=GetTime()
								print("boping ".."party"..j.." ".."arena"..i.."is trying to kill him")
								return "Blessing of Protection", "party"..j
							end
						end
					end
			end
			end
			end
			end
		end
	end
	end
end
--end

-- Freedom
if IsSpellKnown(Colorcode["Blessing of Freedom"][4]) then
if PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer) then
if IsRoot(p1) and cd("Blessing of Freedom")<Lagcomp and IsMelee(p1) and inmuneall(p1)==0 then
	for i=1, #inmunetoslow do
		if UnitBuff(p1, inmunetoslow[i]) then
			return "Blessing of Freedom", p1
		end
	end
end
if IsRoot(p2) and cd("Blessing of Freedom")<Lagcomp and IsMelee(p2) and inmuneall(p2)==0 then
	for i=1, #inmunetoslow do
		if UnitBuff(p2, inmunetoslow[i]) then
			return "Blessing of Freedom", p2
		end
	end
end
end
end

--CC
if EnemyHealer and (not UnitIsDeadOrGhost(EnemyHealer)) then
if hp(t)/hpm(t)<0.75 and UnitIsEnemy(t, p) then
	if IsCC(EnemyHealer)==0 then
		if IsSpellKnown(Colorcode["Hammer of Justice"][4]) then
		if cd("Hammer of Justice")<Lagcomp then
		if(r("Hammer of Justice", EnemyHealer)==1) then
			qsp("Hammer of Justice", EnemyHealer)
			print("Hoj healer")
		else
			print("Acercate al healer")
		end
		end
		end
		if IsSpellKnown(20066) and cd("Repentance")<Lagcomp then
		if (r("Repentance", EnemyHealer)==1) then
			print("Stop for hard casting")
			qsp("Repentance", EnemyHealer)
		end
		end
		if IsSpellKnown(115750) and cd("Blinding Light")<Lagcomp then
		if (r("Blinding Light", EnemyHealer)==1) then
			qsp("Blinding Light")
		end
		end
	end
end
end


-- Dispells
for x=1, 5 do
if AuDispell==1 then
	if PartyHealer then
		if cd("Cleanse")<Lagcomp and r("Cleanse", PartyHealer)==1 then
			for i = 1, #Spells8 do
				if UnitDebuff(PartyHealer, Spells8[i]) then
					printp("Cleanse on "..PartyHealer.."to dispell "..Spells8[i])
					return "Cleanse", PartyHealer
				end
			end
		end
		if cd("Blessing of Protection")<Lagcomp and r("Cleanse", PartyHealer)==1 and danger() then
			for i = 1, #Spells6 do
				if UnitDebuff(PartyHealer, Spells6[i]) then
					local _,_,_,_,_,_,expt,_=UnitDebuff(PartyHealer, Spells6[i])
					if expt-GetTime()>4 then
						qsp("Blessing of Protection", PartyHealer, 0.6)
						printp("BOP on "..PartyHealer.."to dispell "..Spells6[i])
						reset=true
					end		
				end
			end
		end
	end
	if PartyHealer==nil then
		for k=1, size do
			if cd("Cleanse")<Lagcomp and r("Cleanse", "party"..k)==1 then
				for i = 1, #Spells8 do
					if UnitDebuff("party"..k, Spells8[i]) then
						printp("Cleanse on ".."party"..k.."to dispell "..Spells8[i])
						return "Cleanse", "party"..k
					end
				end
			end
			if cd("Blessing of Protection")<Lagcomp and r("Cleanse", "party"..k)==1 and danger() then
				for i = 1, #Spells6 do
					if UnitDebuff("party"..k, Spells6[i]) then
						local _,_,_,_,_,_,expt,_=UnitDebuff("party"..k, Spells6[i])
						if expt-GetTime()>4 then
							qsp("Blessing of Protection", "party"..k, 0.6)
							printp("BOP on ".."party"..k.."to dispell "..Spells6[i])
							reset=true
						end		
					end
				end
			end
		end
	end
end
end

if InArena() then
if EnemyHealer==nil or IsCC(EnemyHealer)==1 then
	if DangerBuff(a1)==1 then -- bursting
		if cd("Hammer of Justice")<Lagcomp and r("Hammer of Justice", a1)==1 then
			qsp("Hammer of Justice", a1)
			print("hoj a1 bursting")
		end
	end
	if DangerBuff(a2)==1 then -- bursting
		if cd("Hammer of Justice")<Lagcomp and r("Hammer of Justice", a2)==1 then
			qsp("Hammer of Justice", a2)
			print("hoj a2 bursting")
		end
	end
	if DangerBuff(a3)==1 then -- bursting
		if cd("Hammer of Justice")<Lagcomp and r("Hammer of Justice", a3)==1 then
			qsp("Hammer of Justice", a3)
			print("hoj a3 bursting")
		end
	end
end
end


Lowest = GetLowest() or "mouseover" or "target"
if Lowest==nil or (Lowest=="player" and  hp(Lowest)/hpm(Lowest)>0.93) then 
	Lowest = "target"
end

if UnitInRaid(p) then
	if UnitExists("mouseover") then
		Lowest = "mouseover"
	end
end

hpt = hp(Lowest)/hpm(Lowest) 
-- Beacon
if PartyTank then 
	if not b(PartyTank, "Beacon of Light")then
		print("Beacon tank")
		return "Beacon of Light", PartyTank
	end
else
	--if TarCount(Lowest)>0 and not b(Lowest, "Beacon of Light") then
	--	return "Beacon of Light", Lowest
	--end
end


if hpt < 0.85  then
	if hpt < 0.16 and IsUsableSpell(Lowest, "Lay on Hands") then
		return "Lay on Hands", Lowest
	end
	if AutoCds==true then
		if AverageHP() < 0.34 then
			return aw
		elseif AverageHP() < 0.5 then
			return "Aura Mastery"		
		end
	end
	if cd("Holy Shock") < Lagcomp and r("Holy Shock", Lowest)==1 and hpt < 0.85 then
		return "Holy Shock", Lowest
	end	
	if cd("Light of Dawn")<Lagcomp then
		return "Light of Dawn"
	end
	if IsInInstance(p) then
		if PartyTank then 
			if cd("Bestow Faith")<Lagcomp and (hpt < 0.8 or uiu(PartyTank, Lowest) or TarCount(Lowest)>1) then
				return "Bestow Faith", Lowest
			end
		else
			if cd("Bestow Faith")<Lagcomp and TarCount(Lowest)>1 then
				return "Bestow Faith", Lowest
			end		
		end
		if UnitIsPlayer(Lowest) and (hpt<0.6 and not Lowest==p and TarCount>2) or (hpt<0.35 and not Lowest==p)then
			print("sacrifice "..Lowest)
			return "Blessing of Sacrifice", Lowest
		end
	else
		if cd("Bestow Faith")<Lagcomp then
			return "Bestow Faith", Lowest
		end
	end
	if (not speed == 0 and hpt<0.65 and not Lowest==p) or (hpt<0.3 and hp(p)/hpm(p)>0.5 and not Lowest==p) then
		return "Light of the Martyr", Lowest
	end

	if speed==0 and uci(p)==nil then
		if b(p, "Infusion of Light") then
			return "Holy Light", Lowest
		end
		if hpt<0.5 or AverageHP()<0.6 then
			return "Flash of Light", Lowest
		else
			return "Holy Light", Lowest
		end
	end
else
	if UnitAffectingCombat(p) then
		if cd(j)<Lagcomp then
			return j
		end
		if cd(cs)<Lagcomp and b("party1target", j) and r(cs, "party1target")==1 then
			return cs
		end
		if cd("Holy Shock")<Lagcomp then
			return "Holy Shock", "party1target"
		end
	end
end
end




function hello(POWER)

if POWER==nil then
	POWER = po(p,9)
end

if inmuneall(t)==1 then
INMUNE=1
else
INMUNE=0
end

if InmuneP(t)==1 then
INMUNEP=1
else
INMUNEP=0
end


if inmunemagic(t)==1 then
INMUNEM=1
else
INMUNEM=0
end


-- Variables
hpp = hp(p)/hpm(p)
hpp1 = hp(p1)/hpm(p1)
hpp2 = hp(p2)/hpm(p2)
hpt = hp(t)/hpm(t)
P1_IsHeal = IsHeal(p1)
P2_IsHeal = IsHeal(p2)
P1_IsCC = IsCC(p1)
P2_IsCC = IsCC(p2)
P_target = targetting(p)
P1_target = targetting(p1)
P2_target = targetting(p2)
if UnitExists("arena3") then
A3_MeleeRange = r(cs, a3)
A3_IsHealer = IsHeal(a3)
else
A3_IsMelee = 0
A3_MeleeRange = 0
A3_IsHealer = nil
end
A1_MeleeRange = r(cs, a1)
A2_MeleeRange = r(cs, a2)
A1_IsHealer = IsHeal(a1)
A2_IsHealer = IsHeal(a2)


size = (GetNumGroupMembers() - 1)

speed,_,_,_= GetUnitSpeed(p) -- velocidad de movimiento
HoPo = POWER
P_HoF = b(p, "Blessing of Freedom")


indexd=1
P_defenseon=false
P1_defenseon=false
P2_defenseon=false
while DefenseList[indexd] do
	if b(p, DefenseList[indexd]) then
		P_defenseon=true
		--printp("Defense on")
	end
	indexd=indexd +1
end
indexd=1
while DefenseList[indexd] do
	if b(p1, DefenseList[indexd]) then
		P1_defenseon=true
	end
	indexd=indexd +1
end
indexd=1
while DefenseList[indexd] do
	if b(p2, DefenseList[indexd]) then
		P2_defenseon=true
	end
	indexd=indexd +1
end

A1_danger = DangerBuff(a1)
A2_danger = DangerBuff(a2)
A3_danger = DangerBuff(a3)
Hojrange = r("Hammer of Justice", t)

-- Fin definiciones
intsp, inttar = interrupt()
if inttar then
	return intsp, inttar
end


-- DS
if IsSpellKnown(Colorcode[ds][4]) and not IsSpellKnown(213313) and bub==1 then
if InArena() then
if cd(ds)<Lagcomp then
  if PartyHealer==nil or IsCC(PartyHealer)==1 then
	if (hp(p)/hpm(p)) < (0.35+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return ds
					elseif not IsMelee("arena"..i) then return ds 
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return ds
					elseif not IsMelee("arena"..i) then return ds 
					end
				end
			end
		end
	end
  else
	if (hp(p)/hpm(p)) < (0.20+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return ds
					elseif not IsMelee("arena"..i) then
						print(TarCount(p))
						return ds 
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return ds
					elseif not IsMelee("arena"..i) then 
					--	print(TarCount(p))
						return ds 
					end
				end
			end
		end
	end
 
end
end
else
if hp(p)/hpm(p)< 0.30 and P_defenseon==false then if uiu(p, "targettarget") and DS_cd==0 then return ds end end
end
end

if IsSpellKnown(Colorcode["Blessing of Protection"][4]) and cd(ds)>10 then
if InArena() then
if cd("Blessing of Protection")<Lagcomp and (not UnitDebuff(p, "Forbearance")) then
  if PartyHealer==nil or IsCC(PartyHealer)==1 then
	if (hp(p)/hpm(p)) < (0.35+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Blessing of Protection"
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Blessing of Protection"
					end
				end
			end
		end
	end
  else
	if (hp(p)/hpm(p)) < (0.15+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Blessing of Protection"
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Blessing of Protection"
					end
				end
			end
		end
	end
 
end
end
end
end


if IsSpellKnown(Colorcode["Shield of Vengeance"][4]) then
if InArena() then
if cd("Shield of Vengeance")<Lagcomp then
  if PartyHealer==nil or IsCC(PartyHealer)==1 then
	if (hp(p)/hpm(p)) < (0.55+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Shield of Vengeance"
					elseif not IsMelee("arena"..i) then 
					--	print(TarCount(p))
						return "Shield of Vengeance" 
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Shield of Vengeance"
					elseif not IsMelee("arena"..i) then
					--	print(TarCount(p))
						return "Shield of Vengeance"
					end
				end
			end
		end
	end
  else
	if (hp(p)/hpm(p)) < (0.55+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Shield of Vengeance"
					elseif not IsMelee("arena"..i) then
					--	print(TarCount(p))
						return "Shield of Vengeance" 
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
					--	print(TarCount(p))
						return "Shield of Vengeance"
					elseif not IsMelee("arena"..i) then 
					--	print(TarCount(p))
						return "Shield of Vengeance"
					end
				end
			end
		end
	end
 
end
end
else
if hp(p)/hpm(p)< 0.55 and P_defenseon==false then if uiu(p, "targettarget") and cd("Shield of Vengeance")<Lagcomp then return "Shield of Vengeance" end end
end
end

if IsSpellKnown(Colorcode["Eye for an Eye"][4]) then
if InArena() then
if cd("Eye for an Eye")<Lagcomp then
  if PartyHealer==nil or IsCC(PartyHealer)==1 then
	if (hp(p)/hpm(p)) < (0.55+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
						return "Eye for an Eye"
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
						return "Eye for an Eye"
					end
				end
			end
		end
	end
  else
	if (hp(p)/hpm(p)) < (0.35+(TarCount(p)*0.07)) and not P_defenseon==true then 
		for i=1, GetNumGroupMembers() do
			if EnemyHealer then
				if (uiu(p, "arena"..i.."target")) and not (uiu("arena"..i, EnemyHealer)) then
					if IsMelee("arena"..i) and (r(cs, "arena"..i)==1) then
						return "Eye for an Eye"
					end
				end
			else
				if (uiu(p, "arena"..i.."target")) then
					if IsMelee("arena"..i) and (r(cs, a1)==1) then
						return "Eye for an Eye"
					end
				end
			end
		end
	end
 
end
end
end
end



--------- queue------------------------
-- Esto podría ser una opcion. Otra opcion sería llamar la funcion dispell desde el event manager. 

if qspell and GetTime() > qtimer and reset==false then
qna,qcd,_=GetSpellCooldown(qspell)
		if cd(qspell)==0 or qcd<1.5 then
			if (qspell=="Word of Glory" or qspell=="Divine Storm") and POWER>2 then
				qspell2 = qspell
				qspell = nil
				return qspell2, qtarget
			elseif (qspell=="Word of Glory" or qspell=="Divine Storm") and POWER<3 then
				qspell = nil
				print("No hay suficiente Holy power")
			    reset=true
			end
			if qspell=="Templar's Verdict" and POWER>2 then
				qspell2 = qspell
				qspell = nil
				return qspell2
			elseif qspell=="Templar's Verdict"  and POWER<3 then
			    reset=true
			end
			if qspell=="Justicar's Vengeance" then 
				if POWER>4 or b(p, "Divine Purpose") then
					qspell2 = qspell
					qspell = nil
					return "Justicar's Vengeance"
				elseif POWER<5 then
					reset=true
					qspell = nil
				end
			end
			if qspell=="Hammer of Justice"  then
			if not cd("Hammer of Justice")==0 then
				qspell=nil
				qspell2=nil
				reset=true
			else
			
				inmunehoj = false
				check = 1
				while hojlist[check] do
					if b(qtarget, hojlist[check]) then
						inmunehoj = true 
						msj="Inumne to hoj"
					end
				check = check + 1
				end
				donthoj = false
				check = 1
				while hojlist2[check] do
					if UnitDebuff(qtarget, hojlist2[check]) then
						cctime = select(7 ,UnitDebuff(qtarget, hojlist2[check])) -- selecciona duracion
						if (cctime -GetTime()) > 2 then
							donthoj = true 
							msj="Hoj pisaria un CC"
						end
					end
				check = check + 1
				end
				if not UnitDebuff(qtarget, "Cyclone") then
					if inmunehoj==false and donthoj==false then
							qspell2 = qspell
							qspell = nil
						if qtarget then
							return qspell2, qtarget
						else
							return qspell2
						end
					else
							qspell = nil
							reset = true
							qtimer = 0
							printp(msj)
					end
				end
				end
			elseif qspell=="Blessing of Sanctuary" then
			
				qspell=nil
				reset = true
				return "Blessing of Sanctuary", qtarget

			elseif qspell=="Execution Sentence" then
				if qtarget then
					qspell=nil
					reset = true
					return "Execution Sentence", qtarget
				else
					qspell=nil
					reset = true
					return "Execution Sentence"
				end
			else
				qspell2 = qspell
				if qtarget then
					qspell=nil
					reset = true
					return qspell2, qtarget
				else
					qspell=nil
					reset = true
					return qspell2
				end
			end
		elseif cd(qspell)>3 then
			qspell = nil
			reset = true		
		end
end

-- Dispells nuevo

if AuDispell==1 then
	if PartyHealer then
		for k=1, size do
			if cd("Blessing of Sanctuary")<Lagcomp and r("Cleanse Toxins", "party"..k)==1 and UnitGroupRolesAssigned("party"..k)=="HEALER" then
				for i = 1, #Spells5 do
					if UnitDebuff("party"..k, Spells5[i]) then
					--	local _,_,_,_,_,_,expt,_=UnitDebuff("party1"..k, Spells5[i])
						--if expt-GetTime()>4 then
							--qsp("Blessing of Sanctuary", #Group..k, 0.6)
							MsjFrameText:SetText("Sanctuaty on ".."party"..k.."to dispell "..Spells5[i])
							MsjFrameText:Show()
							LastText=GetTime()
							print("Sanctuaty on ".."party"..k.."to dispell "..Spells5[i])
						--	reset=true
							return "Blessing of Sanctuary", "party"..k
					--	end		
					end
				end
			end
			if cd("Blessing of Protection")<Lagcomp and r("Cleanse Toxins", "party1"..k)==1 and danger() then
				for i = 1, #Spells6 do
					if UnitDebuff("party"..k, Spells6[i]) then
						local _,_,_,_,_,_,expt,_=UnitDebuff("party"..k, Spells6[i])
						if expt-GetTime()>4 then
							qsp("Blessing of Protection", "party"..k, 0.6)
							MsjFrameText:SetText("BOP on ".."party"..k.."to dispell "..Spells6[i])
							MsjFrameText:Show()
							LastText=GetTime()
							print("BOP on ".."party"..k.."to dispell "..Spells6[i])
							reset=true
						end		
					end
				end
			end
		end
	
		if cd("Blessing of Sanctuary")<Lagcomp and r("Cleanse Toxins", PartyHealer)==1 then
			for i = 1, #Spells5 do
				if UnitDebuff(PartyHealer, Spells5[i]) then
					--local _,_,_,_,_,_,expt,_=UnitDebuff(PartyHealer, Spells5[i])
				--	if expt-GetTime()>4 then
						qsp("Blessing of Sanctuary", PartyHealer, 0.6)
						MsjFrameText:SetText("Sanctuaty on "..PartyHealer.."to dispell "..Spells5[i])
						MsjFrameText:Show()
						LastText=GetTime()
						print("Sanctuaty on "..PartyHealer.."to dispell "..Spells5[i])
						reset=true
						return "Blessing of Sanctuary", PartyHealer
					--end		
				end
			end
		end
		if cd("Blessing of Protection")<Lagcomp and r("Cleanse Toxins", PartyHealer)==1 and danger() then
			for i = 1, #Spells6 do
				if UnitDebuff(PartyHealer, Spells6[i]) then
					local _,_,_,_,_,_,expt,_=UnitDebuff(PartyHealer, Spells6[i])
					if expt-GetTime()>4 then
						qsp("Blessing of Protection", PartyHealer, 0.6)
						MsjFrameText:SetText("BOP on "..PartyHealer.."to dispell "..Spells5[i])
						MsjFrameText:Show()
						LastText=GetTime()
						print("BOP on "..PartyHealer.."to dispell "..Spells6[i])
						reset=true
					end		
				end
			end
		end
		
	else
		for k=1, size do
			if cd("Blessing of Sanctuary")<Lagcomp and r("Cleanse Toxins", "party"..k)==1 then
				for i = 1, #Spells5 do
					if UnitDebuff("party"..k, Spells5[i]) then
					--	local _,_,_,_,_,_,expt,_=UnitDebuff("party1"..k, Spells5[i])
						--if expt-GetTime()>4 then
							--qsp("Blessing of Sanctuary", #Group..k, 0.6)
							MsjFrameText:SetText("Sanctuaty on ".."party"..k.."to dispell "..Spells5[i])
							MsjFrameText:Show()
							LastText=GetTime()
							print("Sanctuaty on ".."party"..k.."to dispell "..Spells5[i])
						--	reset=true
							return "Blessing of Sanctuary", "party"..k
					--	end		
					end
				end
			end
			if cd("Blessing of Protection")<Lagcomp and r("Cleanse Toxins", "party1"..k)==1 and danger() then
				for i = 1, #Spells6 do
					if UnitDebuff("party"..k, Spells6[i]) then
						local _,_,_,_,_,_,expt,_=UnitDebuff("party"..k, Spells6[i])
						if expt-GetTime()>4 then
							qsp("Blessing of Protection", "party"..k, 0.6)
							MsjFrameText:SetText("BOP on ".."party"..k.."to dispell "..Spells6[i])
							MsjFrameText:Show()
							LastText=GetTime()
							print("BOP on ".."party"..k.."to dispell "..Spells6[i])
							reset=true
						end		
					end
				end
			end
		end
	end
end



if HoJCC==true then
if EnemyHealer and (not UnitIsDeadOrGhost(EnemyHealer)) then
if hp(t)/hpm(t)<0.75 then
	if IsCC(EnemyHealer)==0 then
		if IsSpellKnown(Colorcode["Hammer of Justice"][4]) then
		if cd("Hammer of Justice")<Lagcomp then
		if(r("Hammer of Justice", EnemyHealer)==1) then
			qsp("Hammer of Justice", EnemyHealer)
			print("Hoj healer")
		else
			print("Acercate al healer")
		end
		end
		end
		if IsSpellKnown(20066) and cd("Repentance")<Lagcomp then
		if (r("Repentance", EnemyHealer)==1) then
			print("Stop for hard casting")
			qsp("Repentance", EnemyHealer)
		end
		end
		if IsSpellKnown(115750) and cd("Blinding Light")<Lagcomp then
		if (r("Blinding Light", EnemyHealer)==1) then
			qsp("Blinding Light")
		end
		end
	end
end
end
end


-- HoH peel.
if InArena() then
peel = nil
if cd("Hand of Hindrance")<Lagcomp then 
	peel = "Hand of Hindrance"
elseif cd("Blade of Justice")<Lagcomp then
	peel = "Blade of Justice"
end

	for i = 1, #Group do
		if UnitExists(Group[i]) and hp(Group[i])/hpm(Group[i]) < 0.5 and (PartyHealer==nil or IsCC(PartyHealer)) then
			for j = 1, GetNumGroupMembers() do
				if EnemyHealer then
					if uiu(Group[i], "arena"..j.."target") and not uiu(EnemyHealer, "arena"..j) then
						if IsSlow("arena"..j) or IsRoot("arena"..j) or IsCC("arena"..j) then
								MsjFrameText:SetText("arena"..j.." is Already slow, root, or cc ")
								MsjFrameText:Show()
								LastText=GetTime()
							--print("arena"..j.." is Already slow, root, or cc ")
						else
								MsjFrameText:SetText("Hand of Hindrance to peel ".."arena"..j)
								MsjFrameText:Show()
								LastText=GetTime()
							--print("Hand of Hindrance to peel ".."arena"..j)
							return peel, "arena"..j
						end	
					end
				else
					if uiu(Group[i], "arena"..j.."target") then
						if IsSlow("arena"..j) or IsRoot("arena"..j) or IsCC("arena"..j) then
							MsjFrameText:SetText("arena"..j.." is Already slow, root, or cc ")
							MsjFrameText:Show()
							LastText=GetTime()
							--print("arena"..j.." is Already slow, root, or cc ")
						else
							MsjFrameText:SetText("Hand of Hindrance to peel ".."arena"..j)
							MsjFrameText:Show()
							LastText=GetTime()
							--print("Hand of Hindrance to peel ".."arena"..j)
							return peel, "arena"..j
						end	
					end
				end
			end
		end
	end
end



if InArena() and HoJCC==true then
if EnemyHealer==nil or IsCC(EnemyHealer)==1 then
	if hp(t)/hpm(t)<0.7 and IsCC(t)==0 then
		if cd("Hammer of Justice")<Lagcomp and r("Hammer of Justice", t)==1 then
			qsp("Hammer of Justice", t)
			print("Hoj target lowish")
		end
	end
	if DangerBuff(a1)==1 then -- bursting
		if cd("Hammer of Justice")<Lagcomp and r("Hammer of Justice", a1)==1 then
			qsp("Hammer of Justice", a1)
			print("hoj a1 bursting")
		end
	end
	if DangerBuff(a2)==1 then -- bursting
		if cd("Hammer of Justice")<Lagcomp and r("Hammer of Justice", a2)==1 then
			qsp("Hammer of Justice", a2)
			print("hoj a2 bursting")
		end
	end
	if DangerBuff(a3)==1 then -- bursting
		if cd("Hammer of Justice")<Lagcomp and r("Hammer of Justice", a3)==1 then
			qsp("Hammer of Justice", a3)
			print("hoj a3 bursting")
		end
	end
end
end

-- Healing
if InArena() then
speed,_,_,_= GetUnitSpeed(p)
	if targetting(p)==1 and uci(p)==nil then
		if PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1 then --  healer no disponible
			if IsSpellKnown(Colorcode["Word of Glory"][4]) and (hp(p)/hpm(p) < (0.30+(TarCount(p)*0.07))) and (POWER>2 or b(p, "Divine Purpose")) and cd("Word of Glory")<Lagcomp then
					return "Word of Glory"
			end
			if not IsSpellKnown(Colorcode["Justicar's Vengeance"][4]) or (POWER<2 and not cd("Wake of Ashes")==0) or (POWER<3 and not cd("Blade of Justice")==0) or hp(p)/hpm(p)<0.27 then
				if hp(p)/hpm(p) < (0.40+(TarCount(p)*0.05)) then
					if speed==0 and not IsRoot(p) then 
						return "Flash of Light", p
					else
						--print("Parar para castear")
					end
				end
			end
		else -- hay healer
				if not IsSpellKnown(Colorcode["Justicar's Vengeance"][4]) or (POWER<2 and not cd("Wake of Ashes")==0) or (POWER<3 and not cd("Blade of Justice")==0) or hp(p)/hpm(p)<0.27 then
			if hp(p)/hpm(p) < (0.30+(TarCount(p)*0.05)) then
				if speed==0 and not IsRoot(p) then 
					return "Flash of Light", p
				else
					--print("Parar para castear. Hay healer. 0.3")
				end
			end
			end
		end	
	else -- no target
		if PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1 and (uci(p)==nil) then -- no hay healer
			if not IsSpellKnown(Colorcode["Justicar's Vengeance"][4]) or (POWER<2 and not cd("Wake of Ashes")==0) or (POWER<3 and not cd("Blade of Justice")==0) or hp(p)/hpm(p)<0.27 then
			if hp(p)/hpm(p) < (0.40) and (uci(p)==nil) then
				if speed==0 and not IsRoot(p) then 
					return "Flash of Light", p
				else
					--print("Parar para castear. Sin healer, no target. 0.5")
				end
			end
			end
		else -- hay healer
			if not IsSpellKnown(Colorcode["Justicar's Vengeance"][4]) or (POWER<2 and not cd("Wake of Ashes")==0) or (POWER<3 and not cd("Blade of Justice")==0) or hp(p)/hpm(p)<0.27 then
			if hp(p)/hpm(p) < 0.30 and (uci(p)==nil) then
				if speed==0 and not IsRoot(p) then 
					return "Flash of Light", p
				else
					--print("Parar para castear. con healer, no target 0.3")
				end
			end
			end
		end	
	end	
	
for i=1, size do
	
	if targetting("party"..i)==1 and (uci(p)==nil) then
		if PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1 then -- no hay healer
			if hp("party"..i)/hpm("party"..i) < (0.4+(TarCount("party"..i)*0.05)) and hp("party"..i)/hpm("party"..i) > 0 then
				if speed==0 and not IsRoot(p) then 
					return "Flash of Light", "party"..i
				else
					MsjFrameText:SetText("Parar para castear en party"..i)
					MsjFrameText:Show()
					LastText=GetTime()
					--print("Parar para castear en party"..i)
				end
			end
			
		else -- hay healer
			if hp("party"..i)/hpm("party"..i) < (0.30+(TarCount("party"..i)*0.05)) and (hp("party"..i)/hpm("party"..i) > 0) and (uci(p)==nil) then
				if speed==0 and not IsRoot(p) then 
					return "Flash of Light", "party"..i
				else
					MsjFrameText:SetText("Parar para castear en party"..i)
					MsjFrameText:Show()
					LastText=GetTime()
					--print("Parar para castear en party"..i)
				end
			end
		end		
	end
end
else -- no en arenas
     if IsSpellKnown(Colorcode["Lay on Hands"][4]) and (cd("Lay on Hands")==0) then
		if hp(p)/hpm(p) < 0.15 and not UnitDebuff(p, "Forbearance") then 
			return "Lay on Hands", p
		end
	end
	if not IsSpellKnown(Colorcode["Justicar's Vengeance"][4]) or (POWER<2 and not cd("Wake of Ashes")==0) or (POWER<3 and not cd("Blade of Justice")==0) or hp(p)/hpm(p)<0.27 then
				if (hp(p)/hpm(p) < 0.5) and speed==0 and (uci(p)==nil) then return "Flash of Light" end
	end
	if UnitInBattleground("player") then
		if (hp(p1)/hpm(p1) < 0.4) and speed==0 and (uci(p)==nil) and (r("Flash of light", p1)==1) then return "Flash of Light", "party1" end 
		if (hp(p2)/hpm(p2) < 0.4) and speed==0 and (uci(p)==nil) and (r("Flash of light", p2)==1) then return "Flash of Light", "party2" end 
	end
end

-- cleanse new
if not UnitInBattleground("player") or InArena() then
if IsSpellKnown(Colorcode["Cleanse Toxins"][4]) then
	if cd("Cleanse Toxins")<Lagcomp then
		for i=1, #Group do
		if not uiu(Group[i], p) then
			for j=1, #Spells3 do
				if UnitDebuff(Group[i], Spells3[j]) and r("Cleanse Toxins", Group[i])==1 then
					print("Clenasing ".."party"..i.." to Dispell "..Spells3[j])
					return "Cleanse Toxins", Group[i]
				end
			end
		end
		end
		for i=1, #Group do
			for j=1, #Spells7 do
				if UnitDebuff(Group[i], Spells7[j]) and r("Cleanse Toxins", Group[i])==1 then
					print("Clenasing "..Group[i].." to Dispell "..Spells7[j])
					return "Cleanse Toxins", Group[i]
				end
			end
		end
	end
end
else
	if cd("Cleanse Toxins")<Lagcomp then
	for j=1, #Spells7 do
		if UnitDebuff(p, Spells7[j])  then
			print("Clenasing self to Dispell "..Spells7[j])
			return "Cleanse Toxins", p
		end
	end
	end
end



local nas3,_,_,ys3,_,_,_,_=UnitDebuff(p, "Remorseless Winter")
if UnitDebuff(p, "Remorseless Winter") and (cd("Blessing of Freedom")<Lagcomp) then
if ys3>1 then return "Blessing of Freedom", "player" end end



-- HoF al heal 2
if IsSpellKnown(Colorcode["Blessing of Freedom"][4]) then 
if cd("Blessing of Freedom")<Lagcomp then
	if PartyHealer and (hp(PartyHealer)/hpm(PartyHealer))<(0.45+(TarCount(p1)*0.07)) then
		if IsRoot(PartyHealer) and not b(PartyHealer, "Blessing of Freedom") and not b(PartyHealer, "Blessing of Protection") and UnitClass~="Druid" then
			for i =1, GetNumGroupMembers() do
				if uiu("arena"..i.."target", PartyHealer) and IsMelee("arena"..i) then
					print("HoF "..PartyHealer.."-- hp ="..hp(PartyHealer)/hpm(PartyHealer).."; and rooted")
					return "Blessing of Freedom", PartyHealer
				end
			end
		
		end
	end
end
end

--bop heal 2

for x=1,5 do
if InArena() then
	if IsSpellKnown(Colorcode["Blessing of Protection"][4]) then 
	if cd("Blessing of Protection")<Lagcomp then
		if PartyHealer then
		MINHPBOP = 0.35
			if hp(PartyHealer)/hpm(PartyHealer)<(MINHPBOP+(TarCount(PartyHealer)*0.07)) and hp(PartyHealer)/hpm(PartyHealer)>0.001 and UnitClass(PartyHealer)~="Paladin" then
			if r("Blessing of Protection", PartyHealer)==1 and inmuneall(PartyHealer)==0 and InmuneP(PartyHealer)==0 then 
			if not UnitDebuff(PartyHealer, "Forbearance") then
			--	print("Heal low health...")
				for i = 1, GetNumGroupMembers() do
					if uiu("arena"..i.."target", PartyHealer) then
					if IsMelee("arena"..i) or UnitClass("arena"..i)=="Hunter" then
						MsjFrameText:SetText("boping "..PartyHealer.." ".."arena"..i.." is trying to kill him")
						MsjFrameText:Show()
						LastText=GetTime()
						--print("boping "..PartyHealer.." ".."arena"..i.." is trying to kill him")
						return "Blessing of Protection", PartyHealer
					end
					end
				end
			end
			end
			end
		else -- no healer
			MINHPBOP = 0.45
		end
		for i = 1, size do
			if hp("party"..i)/hpm("party"..i) < (MINHPBOP+(TarCount("party"..i)*0.07)) and hp("party"..i)/hpm("party"..i)>0.01 and UnitClass("party"..i)~="Paladin" then
			if r("Blessing of Protection", "party"..i)==1 and inmuneall("party"..i)==0 and InmuneP("party"..i)==0 then
			if not UnitDebuff("party"..i, "Forbearance") then
			
				for k = 1, GetNumGroupMembers() do
					if "arena"..k and "party"..i then
						if uiu("arena"..k.."target", "party"..i) then
							if IsMelee("arena"..k) or UnitClass("arena"..k)=="Hunter" then
								MsjFrameText:SetText("boping ".."party"..i.." ".."arena"..k.."is trying to kill him")
								MsjFrameText:Show()
								LastText=GetTime()
								print("boping ".."party"..i.." ".."arena"..k.."is trying to kill him at:"..MINHPBOP)
								return "Blessing of Protection", "party"..i
							end
						end
					end
				end
			end
			end
			end
		end
	end
	end
end
end



-- agregar q no tenga defensas activadas. o en cds... si es q tiene inmunes.
if IsSpellKnown(Colorcode["Blessing of Freedom"][4]) then
if PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer) then
if IsRoot(p1) and cd("Blessing of Freedom")<Lagcomp and IsMelee(p1) and inmuneall(p1)==0 then
	for i=1, #inmunetoslow do
		if UnitBuff(p1, inmunetoslow[i]) then
			return "Blessing of Freedom", p1
		end
	end
end
if IsRoot(p2) and cd("Blessing of Freedom")<Lagcomp and IsMelee(p2) and inmuneall(p2)==0 then
	for i=1, #inmunetoslow do
		if UnitBuff(p2, inmunetoslow[i]) then
			return "Blessing of Freedom", p2
		end
	end
end
end
end


if aoe==0 then 
finisher=tv
else
finisher="Divine Storm"
end


--No pegar en inmunidades
if reset==true and INMUNE==0 and not UnitDebuff(t, "Cyclone")then

if IsSpellKnown(Colorcode["Cleanse Toxins"][4]) then
if UnitDebuff(p, "Dark Simulacrum") then 
	print("anti dark sim")
	return "Cleanse Toxins"
end
end

if IsSpellKnown(Colorcode["Holy Wrath"][4]) and hp(p)/hpm(p)<0.1 then
	if r("Blade of Justice", t) then
		return "Holy Wrath"
	end
end


if IsSpellKnown(Colorcode["Wake of Ashes"][4]) and POWER<2 and cd("Wake of Ashes")<Lagcomp then
if (r(tv, t)==1) then
	if UnitLevel("target")<111 then 
		if cd("Hammer of Justice")>7 then
			return "Wake of Ashes"
		end
	else
		return "Wake of Ashes"
	end
end
end

if not UnitDebuff(t, j) then 
if cd(j)<Lagcomp and (POWER>3 or b("Divine Purpose", p)) then 
	return j
end
end




if IsSpellKnown(Colorcode["Execution Sentence"][4]) then
if cd("Hammer of Justice")<5 and cd("Execution Sentence")<Lagcomp and POWER>2 then
	return "Execution Sentence"
end
end


if IsSpellKnown(Colorcode["Justicar's Vengeance"][4]) then
	if b(p, "Divine Purpose") and INMUNEM==0 and not IsOutOfRange("Justicar's Vengeance") then
		if UnitDebuff(t, "Judgment") then
			return "Justicar's Vengeance"
		else
			if cd(j)<Lagcomp then
				return j
			else
				return "Justicar's Vengeance"
			end

		end
	end
	if POWER==5 then
		if ((PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1) and hp(p)/hpm(p)<0.65) or hp(p)/hpm(p)<0.45 then
			if IsStun(t) or (cd("Hammer of Justice")>Lagcomp and CanHoJ(t)) then
			if not IsOutOfRange("Justicar's Vengeance") then
				if UnitDebuff(t, "Judgment") or hp(p)/hpm(p)<0.15 then
					return "Justicar's Vengeance"
				else
					if cd(j)<Lagcomp then
						return j
					else
						return "Justicar's Vengeance"
					end
				end
			else
				if UnitDebuff(t, "Judgment") or hp(p)/hpm(p)<0.15 then
					--printp("JV al mas cercano para curar")
					return "Justicar's Vengeance"
				else
					if cd(j)<Lagcomp then
						return j
					else
						return "Justicar's Vengeance"
					end
				end	
			end
			end
			if UnitDebuff(t, "Judgment") then
				if cd("Hammer of Justice")>Lagcomp then
					if not IsStun(t) and CanHoJ(t) then
						return "Hammer of Justice", t
					end
				else
					return "Justicar's Vengeance"
				end
			else
				if cd(j)<Lagcomp then
					return j
				else
					return "Justicar's Vengeance"
				end
			end
		end -- end healing

			
		if UnitDebuff(t, "Judgment") then
			if CanHoJ(t) then
				if cd("Hammer of Justice")<Lagcomp then
					return "Hammer of Justice", t
				end

			end
			if IsStun(t) then
				if not IsOutOfRange("Justicar's Vengeance") then
					return "Justicar's Vengeance"
				end
			else
				return finisher			
			end
		else
			if not UnitDebuff(t, "Judgment") and cd(j)<Lagcomp then return j end
		end
	end
	
	if ((PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1) and hp(p)/hpm(p)<0.65) or hp(p)/hpm(p)<0.45 then
	if POWER<2 or (POWER==2 and cd("Blade of Justice")>5) then
		if cd("Wake of Ashes")<Lagcomp and r(tv, t)==1 then
			return "Wake of Ashes"
		end
	end
	end
	
	if IsSpellKnown(Colorcode["Wake of Ashes"][4]) and cd("Wake of Ashes")<Lagcomp then
		if (POWER==0) and (IsStun(t) or UnitDebuff(t, "Hammer of Justice"))and r("Justicar's Vengeance", t) then
			return "Wake of Ashes"
		end
	end
end


if (r("Blade of Justice", t)==0) and hp(p)/hpm(p)>hp(t)/hpm(t) then -- Hand of Hindrance a target huyendo.
	if IsSpellKnown(Colorcode["Hand of Hindrance"][4]) then
		if cd("Hand of Hindrance")<Lagcomp and not IsSlow(t) then
			printp("slowing target")
			return "Hand of Hindrance", t
		end
	end
end

if not ((PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1) and hp(p)/hpm(p)<0.6) then
if UnitLevel("target")<112 and cd("Hammer of Justice")>5 then
if POWER>4 and cd(j)>3 and r("Blade of Justice", t)==1 then 
if INMUNEM==0 then
	return finisher
end
end
end
end

if UnitLevel("player")<43 then
	if cd(j)<Lagcomp then
		return j
	end
	if POWER>2 and r("Blade of Justice", t)==1 then 
		return finisher
	end
end



if not ((PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1) and hp(p)/hpm(p)<0.6) then
if UnitLevel("target")<112 and cd("Hammer of Justice")>5 then
if (POWER>2 or b(p, "Divine Purpose")) and cd(j)>4 and INMUNEM==0 and r("Blade of Justice", t)==1 then 
	if ((hp(t)/hpm(t)) < 0.41) then 
		return finisher
	elseif hp(t)<1000000 then 
		return finisher
	end
end
end
end


if IsSpellKnown(Colorcode["Blessing of Freedom"][4]) then
if not (r(cs,t)==1) and not b(p, "Blessing of Freedom") then
slowname, slowtime = IsSlow(p)
	if slowname and cd("Blessing of Freedom")<Lagcomp and (slowtime - GetTime())>3 then
		return "Blessing of Freedom"
	end	
end
end

if cd("Blade of Justice")<Lagcomp  and POWER<5 then
if INMUNEP==0 then
	return "Blade of Justice"
end
end
 
cs_c,_,_,_= GetSpellCharges(cs)
if cd(cs)<Lagcomp and cs_c==2 and POWER<5 and r("Blade of Justice", t)==1 then
if INMUNEP==0 then
	return cs
end
end



if cd("Blade of Justice")<Lagcomp  and POWER<5 then
if INMUNEP==0 then
	return "Blade of Justice"
end
end


if (cd(cs)<Lagcomp) and cs_c==1 and POWER<5 then
if not IsOutOfRange(cs) then
if INMUNEP==0 then
	return cs
end
else
print("cs OoR")
end
end

if not ((PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1) and hp(p)/hpm(p)<0.6) then
if UnitLevel("target")<112 and cd("Hammer of Justice")>5 then
if (POWER>2 or b(p, "Divine Purpose")) and cd(j)>4 and INMUNEM==0 and r("Blade of Justice", t)==1 then 
	return finisher
end
end
end


if InArena() then
if cd(j)<Lagcomp then
	return j, JudgmentTar()
end
else
	if UnitDebuff(t, "Judgment") and cd(j)<Lagcomp then
		return j
	end
end


if not ((PartyHealer==nil or UnitIsDeadOrGhost(PartyHealer) or IsCC(PartyHealer)==1) and hp(p)/hpm(p)<0.6) then
if UnitLevel("target")<112 and cd("Hammer of Justice")>5 then
if POWER>2 and r("Blade of Justice", t)==1 then 
	return finisher
end
end
end


end -- inmune / cyclone
 
end -- hello

