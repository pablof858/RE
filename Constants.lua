local const = ...;
if const.ccDebuffs then
  return
end

const.magicDespell = {
  --    47476, --strangulate
  1499, -- freezing trap
  --    34490, -- silencing shot
  118, -- polymorph
  11129, -- combustion
  44572, -- deep freeze
  583, -- hammer of justice
  20066, -- repentance
  8122, -- psychic scream
  605, -- mind controll
  --    64044, -- psychic horror
  48181,  -- haunt
  5782, -- fear
  --    24259, -- spell lock 
  5484 --howl of terror
}
const.ccDebuffs = {
  -- Death Knight
  108194,        -- Asphyxiate
  115001,        -- Remorseless Winter
  -- Death Knight Ghoul
  91800,        -- Gnaw
  91797,        -- Monstrous Blow (Dark Transformation)
  -- Druid
  102795,        -- Bear Hug
  33786,        -- Cyclone
  99,        -- Disorienting Roar
  2637,        -- Hibernate
  22570,        -- Maim
  5211,        -- Mighty Bash
  9005,        -- Pounce
  --[dontknow] = "Snare",        -- Wild Mushroom: Detonate
  -- Druid Symbiosis
  110698,        -- Hammer of Justice (Paladin)
  113004,        -- Intimidating Roar [Fleeing in fear] (Warrior)
  113056,        -- Intimidating Roar [Cowering in fear] (Warrior)
  -- Hunter
  117526,        -- Binding Shot
  3355,        -- Freezing Trap
  1513,        -- Scare Beast
  19503,        -- Scatter Shot
  19386,        -- Wyvern Sting
  -- Hunter Pets
  90337,        -- Bad Manner (Monkey)
  24394,        -- Intimidation
  50519,        -- Sonic Blast (Bat)
  56626,        -- Sting (Wasp)
  -- Mage
  118271,        -- Combustion Impact
  44572,        -- Deep Freeze
  31661,        -- Dragon's Breath
  118,        -- Polymorph
  61305,        -- Polymorph: Black Cat
  28272,        -- Polymorph: Pig
  61721,        -- Polymorph: Rabbit
  61780,        -- Polymorph: Turkey
  28271,        -- Polymorph: Turtle
  82691,        -- Ring of Frost
  -- Monk
  123393,        -- Breath of Fire (Glyph of Breath of Fire)
  126451,        -- Clash
  122242,        -- Clash (not sure which one is right)
  119392,        -- Charging Ox Wave
  119381,        -- Leg Sweep
  115078,        -- Paralysis
  -- Paladin
  105421,        -- Blinding Light
  115752,        -- Blinding Light (Glyph of Blinding Light)
  105593,        -- Fist of Justice
  853,        -- Hammer of Justice
  119072,        -- Holy Wrath
  20066,        -- Repentance
  10326,        -- Turn Evil
  -- Priest
  113506,        -- Cyclone (Symbiosis)
  605,        -- Dominate Mind
  64044,        -- Psychic Horror
  8122,        -- Psychic Scream
  113792,        -- Psychic Terror (Psyfiend)
  9484,        -- Shackle Undead
  87204,        -- Sin and Punishment
  -- Rogue
  2094,        -- Blind
  1833,        -- Cheap Shot
  1776,        -- Gouge
  408,        -- Kidney Shot
  113953,        -- Paralysis (Paralytic Poison)
  6770,        -- Sap
  -- Shaman
  76780,        -- Bind Elemental
  77505,        -- Earthquake
  51514,        -- Hex
  118905,        -- Static Charge (Capacitor Totem)
  -- Shaman Primal Earth Elemental
  118345,        -- Pulverize
  -- Warlock
  710,        -- Banish
  111397,        -- Blood Fear - is this actually used? please test
  54786,        -- Demonic Leap (Metamorphosis)
  --5782,        -- Fear
  118699,        -- Fear
  5484,        -- Howl of Terror
  6789,        -- Mortal Coil
  30283,        -- Shadowfury
  104045,        -- Sleep (Metamorphosis)
  -- Warlock Pets
  89766,        -- Axe Toss (Felguard/Wrathguard)
  115268,        -- Mesmerize (Shivarra)
  6358,        -- Seduction (Succubus)
  -- Warrior
  7922,        -- Charge Stun
  --96273,        -- Charge Stun?
  118895,        -- Dragon Roar
  5246,        -- Intimidating Shout (Cowering in fear)
  20511,        -- Intimidating Shout (Cowering in fear)
  --97933,        -- Intimidating Shout (Cowering in fear) - used?
  --97934,        -- Intimidating Shout (Intimidated) - used?
  --46968,        -- Shockwave?
  132168,        -- Shockwave
  105771,        -- Warbringer
  -- Other
  30217,        -- Adamantite Grenade
  67769,        -- Cobalt Frag Bomb
  30216,        -- Fel Iron Bomb
  107079,        -- Quaking Palm
  13327,        -- Reckless Charge
  20549        -- War Stomp
}
const.root = {
  -- Death Knight
  96294,     -- Chains of Ice (Chilblains)
  -- Death Knight Ghoul
  91807,     -- Shambling Rush (Dark Transformation)
  -- Druid
  339,     -- Entangling Roots
  45334,     -- Immobilized (Wild Charge - Bear)
  102359,     -- Mass Entanglement
  -- Druid Symbiosis
  110693,     -- Frost Nova (Mage)
  -- Hunter
  19185,     -- Entrapment
  128405,     -- Narrow Escape
  -- Hunter Pets
  50245,     -- Pin (Crab)
  54706,     -- Venom Web Spray (Silithid)
  4167,     -- Web (Spider)
  -- Mage
  122,     -- Frost Nova
  111340,     -- Ice Ward
  -- Mage Water Elemental
  33395,     -- Freeze
  -- Monk
  116706,     -- Disable
  113275,     -- Entangling Roots (Symbiosis)
  123407,     -- Spinning Fire Blossom
  -- Paladin
  -- Priest
  113275,     -- Entangling Roots (Symbiosis)
  87194,     -- Glyph of Mind Blast
  114404,     -- Void Tendril's Grasp
  -- Rogue
  115197,     -- Partial Paralysis (is this actually used?)
  -- Shaman
  64695,     -- Earthgrab (Earthgrab Totem)
  63685,     -- Freeze (Frozen Power)
  -- Warlock
  -- Warlock Pets
  -- Warrior
  107566,     -- Staggering Shout
  -- Other
  39965,     -- Frost Grenade
  55536,     -- Frostweave Net
  13099     -- Net-o-Matic
}
const.hardCC= {
  20066, -- repent
  37506, --Scatter
  79092, -- Hungaring cold
  90337, -- monkey stun
  1499, -- trap
  6770, -- sap
  33786, -- cyclone
  2094, -- blind
  31661, -- Dragons breath
  6358, -- seduction
  51514, -- hex
  6770,        -- Sap
  113506,        -- Cyclone (Symbiosis)
  642, -- bubble
  45438, -- iceblock
  19263, --deterrance
  1022, -- hand of protection
  3355        -- Freezing Trap
}
const.attentionBuffs = {
  -- Death Knight
  51271, -- pillar of frost
  46584, -- raise dead
  49016, -- unholy Frenzy
  
  -- Druid
  50334, --"Berserk"
  124974, -- natures vigil
  -- Hunter
  3045, -- rapid fire
  -- Mage,
  12472, --"Icy Veins",
  55342, -- mirror image
  -- Monk
  123904, -- invoke xuen, the white tiger
  -- Paladin
  86669,--"Guardian of Ancient Kings",
  86698,
  86659,
  31884, -- avenging wrath
  105809, -- holy avenger
  -- Priest
  -- Rogue
  121471, -- shadow blades
  79140, -- vendetta
  51713, -- shadow dance
  
  -- Shaman
  114049, --"Ascendance",
  16166, --"Elemental Mastery"
  79206, -- spirit walkers grace
  
  -- Warlock
  113858, -- dark soul destro
  113861, -- dark soul demo
  113860, -- dark soul aflic
  103958, -- meta
  108501, -- double demon
  
  -- Warrior
  107574, --"Avatar",
  1719 --"Recklessness"
  -- Other
}
const.healingInterrupt = {
  5185, -- healing touch
  8936, -- regrowth
  50464, -- nourish
  331, -- healing wave
  1064, -- Chain Heal        (cast)
  77472, -- Greater Healing Wave    (cast)
  8004, -- Healing Surge        (cast)
  73920, -- Healing Rain        (cast)
  8936, -- Regrowth        (cast)
  2061, -- Flash Heal        (cast)
  2060, -- Greater Heal        (cast)
  5185, -- Healing Touch        (cast)
  596, -- Prayer of Healing    (cast)
  19750, -- Flash of Light    (cast)
  635 -- Holy Light        (cast)
  
}
const.healingChannel = {
  115175, -- Soothing Mist    (channeling cast)
  64843, -- Divine Hymn        (channeling cast)
  740, -- tranquility
  47540 -- penance
}


const.interruptSpells = { 
  --116, -- frostbolt
  --2637, -- hybernate
  5185, -- healing touch
  8936, -- regrowth
  50464, -- nourish
  -- 9484, -- shackle undead 
  331, -- healing wave
  51505, -- lava burst
  --403,-- lightning bolt
  5782, -- fear
  1120, -- drain soul
  30108, -- unstable affliction
  33786, -- Cyclone        (cast)
  28272, -- Pig Poly        (cast)
  118, -- Sheep Poly        (cast)
  61305, -- Cat Poly        (cast)
  61721, -- Rabbit Poly        (cast)
  61780, -- Turkey Poly        (cast)
  28271, -- Turtle Poly        (cast)
  51514, -- Hex            (cast)
  51505, -- Lava Burst        (cast)
  --339, -- Entangling Roots    (cast)
  30451, -- Arcane Blast        (cast)
  605, -- Dominate Mind        (cast)
  20066, --Repentance        (cast)
  116858, --Chaos Bolt        (cast)
  113092, --Frost Bomb        (cast)
  8092, --Mind Blast        (cast)
  11366, --Pyroblast        (cast)
  48181, --Haunt            (cast)
  102051, --Frost Jaw        (cast)
  1064, -- Chain Heal        (cast)
  77472, -- Greater Healing Wave    (cast)
  8004, -- Healing Surge        (cast)
  73920, -- Healing Rain        (cast)
  51505, -- Lava Burst        (cast)
  8936, -- Regrowth        (cast)
  2061, -- Flash Heal        (cast)
  2060, -- Greater Heal        (cast)
  32375, -- Mass Dispel        (cast)
  2006, -- Resurrection        (cast)
  5185, -- Healing Touch        (cast)
  596, -- Prayer of Healing    (cast)
  19750, -- Flash of Light    (cast)
  635, -- Holy Light        (cast)
  7328, -- Redemption        (cast)
  2008, -- Ancestral Spirit    (cast)
  50769, -- Revive        (cast)
  --2812, -- Denounce        (cast)
  82327, -- Holy Radiance        (cast)
  10326, -- Turn Evil        (cast)
  82326, -- Divine Light        (cast)
  82012, -- Repentance        (cast)
  116694, -- Surging Mist        (cast)
  124682, -- Enveloping Mist    (cast)
  115151, -- Renewing Mist    (cast)
  115310, -- Revival        (cast)
  --126201, -- Frost Bolt        (cast)
  --44614, -- Frostfire Bolt    (cast)
  133, -- Fireball        (cast)
  --1513, -- Scare Beast        (cast)
  982, -- Revive Pet        (cast)
  111771, -- Demonic Gateway            (cast)
  --118297, -- Immolate                (cast)
  124465, -- Vampiric Touch            (cast)
  32375 -- Mass Dispel                (cast) 
}
const.interruptChannel = { 
  1120, -- Drain Soul        (channeling cast)
  12051, -- Evocation        (channeling cast)
  115294, -- Mana Tea        (channeling cast)
  115175, -- Soothing Mist    (channeling cast)
  64843, -- Divine Hymn        (channeling cast)
  740, -- tranquility
  47540, -- penance
  64901 -- Hymn of Hope        (channeling cast)
  
}
const.interruptId = {
  102060, --Disrupting Shout
  106839, --Skull Bash
  80964, --Skull Bash
  115781, --Optical Blast
  119898,  -- fel hunter scilence
  116705, --Spear Hand Strike
  1766, --Kick
  19647, --Spell Lock
  2139, --Counterspell
  47476, --Strangulate
  47528, --Mind Freeze
  57994, --Wind Shear
  6552, --Pummel
  96231 --Rebuke    
}
const.immuneSpell = {
  -- Death Knight
  48707,  -- Anti-Magic Shell
  -- Druid Symbiosis
  110617, -- Deterrence (Hunter)
  110715, -- Dispersion (Priest)
  110700, -- Divine Shield (Paladin)
  110696, -- Ice Block (Mage)
  110570, -- Anti-Magic Shell (Death Knight)
  110788, -- Cloak of Shadows (Rogue)
  113002, -- Spell Reflection (Warrior)
  33786, -- cyclone
  -- Hunter
  19263,  -- Deterrence
  -- Mage
  45438,  -- Ice Block
  115760, -- Glyph of Ice Block
  -- Monk
  131523, -- Zen Meditation
  12247, -- touch-of-karma
  -- Paladin
  642,    -- Divine Shield
  -- Priest
  47585,  -- Dispersion
  -- Rogue
  31224,  -- Cloak of Shadows
  -- Shaman
  8177,   -- Grounding Totem
  -- Warrior
  23930,   -- spell reflection
  114028  --  mass spell reflection
}
const.immunePhysical = {
  -- Death Knight
  -- Druid Symbiosis
  110617, -- Deterrence (Hunter)
  110715, -- Dispersion (Priest)
  110700, -- Divine Shield (Paladin)
  110696, -- Ice Block (Mage)
  33786, -- cyclone
  -- Hunter
  19263,  -- Deterrence
  -- Mage
  45438,  -- Ice Block
  115760, -- Glyph of Ice Block
  -- Monk
  12247, -- touch-of-karma
  -- Paladin
  642,    -- Divine Shield
  -- Priest
  47585  -- Dispersion
  -- Rogue
  -- Shaman
  
}

const.snare = {
  -- Death Knight
  45524,     -- Chains of Ice
  50435,     -- Chilblains
  --43265,     -- Death and Decay (Glyph of Death and Decay) - no way to distinguish between glyphed spell and normal.
  115000,     -- Remorseless Winter
  -- Death Knight Ghoul
  -- Druid
  50259,     -- Dazed (Wild Charge - Cat)
  58180,     -- Infected Wounds
  61391,     -- Typhoon
  127797,     -- Ursol's Vortex
  --[dontknow] = "Snare",     -- Wild Mushroom: Detonate
  -- Druid Symbiosis
  -- Hunter
  35101,     -- Concussive Barrage
  5116,     -- Concussive Shot
  61394,     -- Frozen Wake (Glyph of Freezing Trap)
  13810,     -- Ice Trap
  -- Hunter Pets
  50433,     -- Ankle Crack (Crocolisk)
  54644,     -- Frost Breath (Chimaera)
  -- Mage
  11113,     -- Blast Wave - gone?
  121288,     -- Chilled (Frost Armor)
  120,     -- Cone of Cold
  116,     -- Frostbolt
  44614,     -- Frostfire Bolt
  113092,     -- Frost Bomb
  31589,     -- Slow
  -- Mage Water Elemental
  -- Monk
  116095,     -- Disable
  118585,     -- Leer of the Ox
  123727,     -- Dizzying Haze
  123586,     -- Flying Serpent Kick
  -- Paladin
  110300,     -- Burden of Guilt
  63529,     -- Dazed - Avenger's Shield
  20170,     -- Seal of Justice
  -- Priest
  15407,     -- Mind Flay
  -- Rogue
  3409,     -- Crippling Poison
  26679,     -- Deadly Throw
  119696,     -- Debilitation
  -- Shaman
  3600,     -- Earthbind (Earthbind Totem)
  77478,     -- Earthquake (Glyph of Unstable Earth)
  8034,     -- Frostbrand Attack
  8056,     -- Frost Shock
  51490,     -- Thunderstorm
  -- Shaman Primal Earth Elemental
  -- Warlock
  18223,     -- Curse of Exhaustion
  47960,     -- Shadowflame
  -- Warlock Pets
  -- Warrior
  1715,     -- Hamstring
  12323,     -- Piercing Howl
  -- Other
  1604     -- Dazed - lots of daze effects. try to find the right one.
}

const.stun = {
  -- Death Knight
  108194,     -- Asphyxiate
  115001,     -- Remorseless Winter
  -- Death Knight Ghoul
  91800,     -- Gnaw
  91797,     -- Monstrous Blow (Dark Transformation)
  -- Druid
  102795,     -- Bear Hug
  33786,     -- Cyclone
  99,     -- Disorienting Roar
  2637,     -- Hibernate
  22570,     -- Maim
  5211,     -- Mighty Bash
  9005,     -- Pounce
  --[dontknow] = "Snare",     -- Wild Mushroom: Detonate
  -- Druid Symbiosis
  110698,     -- Hammer of Justice (Paladin)
  113004,     -- Intimidating Roar [Fleeing in fear] (Warrior)
  113056,     -- Intimidating Roar [Cowering in fear] (Warrior)
  -- Hunter
  117526,     -- Binding Shot
  3355,     -- Freezing Trap
  1513,     -- Scare Beast
  19503,     -- Scatter Shot
  19386,     -- Wyvern Sting
  -- Hunter Pets
  90337,     -- Bad Manner (Monkey)
  24394,     -- Intimidation
  50519,     -- Sonic Blast (Bat)
  56626,     -- Sting (Wasp)
  -- Mage
  118271,     -- Combustion Impact
  44572,     -- Deep Freeze
  31661,     -- Dragon's Breath
  118,     -- Polymorph
  61305,     -- Polymorph: Black Cat
  28272,     -- Polymorph: Pig
  61721,     -- Polymorph: Rabbit
  61780,     -- Polymorph: Turkey
  28271,     -- Polymorph: Turtle
  82691,     -- Ring of Frost
  -- Monk
  123393,     -- Breath of Fire (Glyph of Breath of Fire)
  126451,     -- Clash
  122242,     -- Clash (not sure which one is right)
  119392,     -- Charging Ox Wave
  119381,     -- Leg Sweep
  115078,     -- Paralysis
  -- Paladin
  105421,     -- Blinding Light
  115752,     -- Blinding Light (Glyph of Blinding Light)
  105593,     -- Fist of Justice
  853,     -- Hammer of Justice
  119072,     -- Holy Wrath
  20066,     -- Repentance
  10326,     -- Turn Evil
  -- Priest
  113506,     -- Cyclone (Symbiosis)
  605,     -- Dominate Mind
  64044,     -- Psychic Horror
  8122,     -- Psychic Scream
  113792,     -- Psychic Terror (Psyfiend)
  9484,     -- Shackle Undead
  87204,     -- Sin and Punishment
  -- Rogue
  2094,     -- Blind
  1833,     -- Cheap Shot
  1776,     -- Gouge
  408,     -- Kidney Shot
  113953,     -- Paralysis (Paralytic Poison)
  6770,     -- Sap
  -- Shaman
  76780,     -- Bind Elemental
  77505,     -- Earthquake
  51514,     -- Hex
  118905,     -- Static Charge (Capacitor Totem)
  -- Shaman Primal Earth Elemental
  118345,     -- Pulverize
  -- Warlock
  710,     -- Banish
  111397,     -- Blood Fear - is this actually used? please test
  54786,     -- Demonic Leap (Metamorphosis)
  --5782,     -- Fear
  118699,     -- Fear
  5484,     -- Howl of Terror
  6789,     -- Mortal Coil
  30283,     -- Shadowfury
  104045,     -- Sleep (Metamorphosis)
  -- Warlock Pets
  89766,     -- Axe Toss (Felguard/Wrathguard)
  115268,     -- Mesmerize (Shivarra)
  6358,     -- Seduction (Succubus)
  -- Warrior
  7922,     -- Charge Stun
  --96273,     -- Charge Stun?
  118895,     -- Dragon Roar
  5246,     -- Intimidating Shout (Cowering in fear)
  20511,     -- Intimidating Shout (Cowering in fear)
  --97933,     -- Intimidating Shout (Cowering in fear) - used?
  --97934,     -- Intimidating Shout (Intimidated) - used?
  --46968,     -- Shockwave?
  132168,     -- Shockwave
  105771,     -- Warbringer
  -- Other
  30217,     -- Adamantite Grenade
  67769,     -- Cobalt Frag Bomb
  30216,     -- Fel Iron Bomb
  107079,     -- Quaking Palm
  13327,     -- Reckless Charge
  20549     -- War Stomp
}

