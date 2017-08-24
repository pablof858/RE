--*********************************************************************************************************
--                      *********************** Initilization ******************************
--*********************************************************************************************************
local func = _DevPad:FindScripts("Functions")
local const =  _DevPad:FindScripts("Constants")
func()
const()
func:updateDeathThreats()
local healPercent = 60 
local interrupts = {96231, 853} -- rebuke, Hammer of justice


local selflesshealer = select(4, func:unitBuffID("player", 114250)) == 3
local Holy_Avenger = func:unitBuffID("player", 105809)
local guardian = func:haveBuff("player", 86698)
local HP = UnitPower("player", 9)
local inquisition = func:haveBuff("player", 84963, 2)
local immunePhysical = func:phycicalImmunity("target")
local immuneSpell = func:magicImmunity("target")
if UnitGUID("target") ~= nil then 
  targetHP =  100 * UnitHealth("target") / UnitHealthMax("target")
else
  targetHP = 100
end

local playerHP = 100 * UnitHealth("player") / UnitHealthMax("player")
local playerMP = 100 * UnitMana("player") / UnitManaMax("player")
local prefix = "party"
if UnitInRaid("player") or IsActiveBattlefieldArena() then prefix = "raid" end
local size = GetNumGroupMembers()
if size  <= 1 then
  size = 1
  prefix = "player"
end
local HP_cap = 5
if Holy_Avenger then
  HP_cap = 3
end

local flag = { "Alliance Flag", "Horde Flag", "Netherstorm Flag" }

for _,v in ipairs(flag) do oexecute("InteractUnit('" .. v.. "')") end -- auto return flag



--*********************************************************************************************************
--                    *********************** support and buffs ******************************
--*********************************************************************************************************
if playerHP < 20 + 5 * func.hardOnMe[1] and playerHP < targetHP + 5
and func:oSpellAvailable(642) then
  func:oCastSpellByID(642, "player") -- Divine Shield
  return true
end

if (func.hardOnMe[3] > 0 and playerHP < 80) or (func.hardOnMe[5] > 0 and PlayerHP < 50)
and func:oSpellAvailable(498) then
  func:oCastSpellByID(498, "player") -- Divine Protection
  return true
end

if targetHP < 35 and func.lowestMember[1] - targetHP > 5 and func:interrupt(interrupts, true)then 
  return true
elseif func:interrupt(interrupts) then
  return true -- interrupt
end 


for i = 1, #func.hardOnGroup do
  local member = prefix
  if #func.hardOnGroup > 1 then
    member = prefix .. tostring(i)
  end
  local memberHP = 100*UnitHealth(member) / UnitHealthMax(member)
  if memberHP < 30 and func:dist("player", member) < 40 and func:oSpellAvailable(31821) then
    func:oCastSpellByID(31821, "player") -- devotion aura (off gcd)
  end
  
  if selflesshealer and memberHP <= healPercent and func:spellCheckFriendly(19750, member) then
    func:oCastSpellByID(19750, member)  -- flash of light (selfless healer)
    return true
  end
  if memberHP <= healPercent and ( targetHP > 25 or playerHP < targetHP + 10)
  and HP >= 3 and func:spellCheckFriendly(85673, member) then
    func:oCastSpellByID(85673, member) -- word of glory
    return true
  end
  if func:spellCheckFriendly(6940, member) and func.lowestMember[1] < 50 
  and func.lowestMember[2] ~= UnitGUID("player")then
    if (func:haveDebuff(member, 4, const.magicDespell) and not func:haveDebuff(member, 30108)) 
    or (memberHP < 30 and playerHP > memberHP + 10) then
      func:oCastSpellByID(6940, member) -- hand of sacrafice
      return true
    end
  end
  
  
  
  
  if func:spellCheckFriendly(4987, member) then  -- cleanse 
    if func:haveDebuff(member, 2944) then  -- devouring plague
      func:oCastSpellByID(4987, member)
      return true
    end
    if func:haveDebuff(member, 55078) and func:haveDebuff(member, 55095) then -- frost fever / blood plague
      func:oCastSpellByID(4987, member)
      return true
    end
    if func:haveDebuff(member, 2818) then -- deadly poison 
      func:oCastSpellByID(4987, member)
      return true
    end
  end
  
  if UnitGUID("player") ~= UnitGUID(member) or not func:oSpellAvailable(642) then 
    if memberHP <= 45 + 10 * func.hardOnGroup[i][2]
    and not func:haveDebuff(member, 25771) 
    and func:spellCheckFriendly(1022, member)
    and func:haveDebuff(member, {115798,115804,81326,113746,8050,1943})
    and not func:haveDebuff(member, const.immunePhysical) then 
      func:oCastSpellByID(1022, member) -- hand of protection
      return true
    end
    if func:dist(member, member.."target") > 7 
    and not func:haveBuff(member, 1044)
    and not func:haveBuff(member, 1022)
    and func:spellCheckFriendly(1044, member)
    and (func:haveDebuff(member, const.root) or func:haveDebuff(member, const.snare)) then 
      func:oCastSpellByID(1044, member) -- hand of freedom
      return true
    end
  end
end

if not inquisition and HP >= 3 then
  func:oCastSpellByID(84963, "player") -- inquisition
  return true
end


--*********************************************************************************************************
--                    *********************** Offencive Spells ******************************
--*********************************************************************************************************

if HP >= HP_cap and func:spellCheck(85256, "target") then -- max Holy power
  --oface("target")
  func:oCastSpellByID(85256, "target") -- Templar's Verdict
  return true
end

if (Holy_Avenger or targetHP <= 20) and not immuneSpell and func:spellCheck(24275, "target") then
  --oface("target")
  func:oCastSpellByID(24275, "target") -- Hammer of Wrath
  return true
end


if not immuneSpell and func:spellCheck(879,"target") then
  --oface("target")
  func:oCastSpellByID(879, "target") -- exorsism
  return true
end

if not immunePhysical and func:spellCheck(35395, "target") then
  --oface("target")
  if not func:haveDebuff("target", 115789) or targetHP < 20 then
    func:oCastSpellByID(35395, "target")  -- crusader strike
  else
    func:oCastSpellByID(53595, "target") -- Hammer of the Righteous (for debuff)
  end
  return true
end

if not immuneSpell and func:spellCheck(20271, "target") then
  func:oCastSpellByID(20271, "target")  -- judgement
  return true
end

if HP >= 3 and func:spellCheck(85256, "target") then -- templar's verdict filler
  --oface("target")
  func:oCastSpellByID(85256, "target") -- Templar's Verdict
  return true
end

if func:dist("player", "playertarget") > 7   then
  
  local snares = 0
  for i = 1, #const.root do
    if func:haveDebuff("player", const.root[i]) then
      snares = snares + 1
    end
  end
  for i = 1, #const.snare do
    if func:haveDebuff("player", const.snare[i]) then
      snares = snares + 1
    end
  end
  
  if snares > 0 then
    if(Holy_Avenger or guardian and func:oSpellAvailable(1044))
    or func:haveBuff("player", {2484, 80018})
    or snares > 1 then
      func:oCastSpellByID(121783, "player") -- hand of freedom
      return true
    end
    
    if func:oSpellAvailable(121783) then
      func:oCastSpellByID(121783, "player") -- Emancipate
      return true
    end
  end
end

local playerSeal = GetShapeshiftForm()

if playerSeal ~= 1 then
  func:oCastSpellByID(31801, "player")
  return true
end

if not func:haveBuff("player", {116956, 19740}) then -- grace of air / BoM
  func:oCastSpellByID(19740, "player")
  return true
end

if not func:haveBuff("player",19740, 0,"PLAYER") and not func:haveBuff("player" ,{1126, 115921, 20217}) then
  func:oCastSpellByID(20217, "player")
  return true
end














