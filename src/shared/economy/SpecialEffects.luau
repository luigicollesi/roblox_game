--!nonstrict
-- Pure combat contracts. No combat state or turn runner is introduced here.
local S={}
local spells={
    phoenix_fire={id="phoenix_fire",name="Chamas da Fênix",manaCost=70,cooldown=3,kind="damage",base=160,targets=3,damageType="arcane"},
    mercy_wave={id="mercy_wave",name="Onda da Misericórdia",manaCost=85,cooldown=4,kind="heal",base=100,targets=3},
    firmament_cut={id="firmament_cut",name="Corte do Firmamento",manaCost=45,cooldown=2,kind="damage",base=110,targets=1,damageType="arcane"},
}
function S.spell(id)
    local spell=spells[id]
    return spell and table.clone(spell) or nil
end
function S.stats(recipe,quality)
    local b=recipe.bonuses
    if not b then return nil end
    assert(recipe.tier=="relic","Special bonuses restricted to relics")
    local pct=({100,115,135})[quality]
    local effect=table.clone(recipe.effect)
    if effect.kind=="spell" then effect.spell=assert(S.spell(effect.spellId)) end
    return {health=math.floor(b.health*pct/100),mana=math.floor(b.mana*pct/100),
        magicDamagePct=math.floor(b.magicDamagePct*pct/100),effect=effect}
end
-- Only usable equipped items. Identical models count once, at highest quality.
function S.loadout(items)
    local best={}
    for _,item in ipairs(items) do
        if item.current>0 and item.special and (not best[item.recipeId] or item.quality>best[item.recipeId].quality) then best[item.recipeId]=item end
    end
    local out={health=0,mana=0,magicDamagePct=0,armorPct=0,spells={},effects={}}
    local spellIds={}
    local ids={}
    for id in pairs(best) do table.insert(ids,id) end
    table.sort(ids)
    for _,id in ipairs(ids) do
        local item=best[id]
        local s=item.special
        out.health+=s.health;out.mana+=s.mana;out.magicDamagePct+=s.magicDamagePct
        local e=s.effect
        table.insert(out.effects,{sourceRecipeId=id,sourceUid=item.uid,effect=e})
        if e.kind=="manaArmor" then out.armorPct=math.max(out.armorPct,e.percent) end
        if e.kind=="spell" and not spellIds[e.spellId] then
            spellIds[e.spellId]=true;table.insert(out.spells,table.clone(e.spell))
        end
    end
    out.magicDamagePct=math.min(60,out.magicDamagePct)
    return out
end
-- Apply once to raw magical damage before defense; never to healing or physical damage.
function S.magicDamage(raw,pct)
    return math.floor(math.max(0,raw)*(100+math.clamp(pct,0,60))/100)
end
-- Damage must be actual HP removed, after defense, barrier and overkill.
-- Called once per attack action for the source weapon; caller must exclude proc damage.
function S.lifeHeal(effect,actualHpLost,missingHp)
    if not effect or effect.kind~="lifesteal" then return 0 end
    return math.min(math.max(0,missingHp),math.floor(math.max(0,actualHpLost)*effect.percent/100))
end
-- Opening barrier is created once per encounter; never refreshed by equipping.
function S.openingBarrier(loadout,maxMana)
    return math.floor(math.max(0,maxMana)*loadout.armorPct/100)
end
-- Called after first successful primary hit only. A proc cannot proc again.
-- roll is supplied by authoritative server RNG (integer 1..100).
function S.followup(effect,firstRawHit,roll,eligible,alreadyRolled)
    if not effect or effect.kind~="followup" or not eligible or alreadyRolled or firstRawHit<=0 or roll<1 or roll>100 or roll%1~=0 then return 0 end
    if roll>effect.chancePct then return 0 end
    return math.floor(firstRawHit*effect.damagePct/100)
end
return S
