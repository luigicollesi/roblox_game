--!nonstrict
-- All values describe a single attack action, not extra turns.
-- hits: consecutive hits on primary target; targets: maximum distinct enemies.
-- splash: percentage of total primary damage to each additional target, as a single hit.
local Attack={}
local defaults={
    sword={hits=1,targets=1,splash=0},
    greatsword={hits=1,targets=3,splash=45},
    shortkatana={hits=2,targets=1,splash=0},
    longkatana={hits=2,targets=2,splash=35},
    knife={hits=1,targets=1,splash=0},
    dagger={hits=2,targets=1,splash=0},
    smallshield={hits=0,targets=0,splash=0},
    largeshield={hits=0,targets=0,splash=0},
    staff={hits=1,targets=3,splash=40},
    wand={hits=2,targets=1,splash=0},
    axe={hits=1,targets=2,splash=40},
    greataxe={hits=1,targets=3,splash=55},
    mace={hits=1,targets=1,splash=0},
    warhammer={hits=1,targets=2,splash=50},
    spear={hits=1,targets=2,splash=30},
    halberd={hits=1,targets=3,splash=45},
}
local overrides={
    sword_watch={hits=1,targets=1,splash=0},
    sword_rose={hits=2,targets=1,splash=0},
    sword_dawn={hits=2,targets=1,splash=0},
    greatsword_sky={hits=2,targets=2,splash=40},
    shortkatana_moon={hits=3,targets=1,splash=0},
    longkatana_night={hits=1,targets=3,splash=50},
    dagger_shadow={hits=3,targets=1,splash=0},
    dagger_star={hits=3,targets=1,splash=0},
    axe_raider={hits=1,targets=3,splash=35},
    greataxe_berserk={hits=2,targets=2,splash=50},
    warhammer_thunder={hits=1,targets=3,splash=40},
    spear_silver={hits=2,targets=1,splash=0},
    staff_ember={hits=1,targets=3,splash=50},
    staff_tide={hits=1,targets=4,splash=30},
    staff_bloom={hits=1,targets=1,splash=0},
    wand_frost={hits=1,targets=2,splash=40},
    wand_star={hits=3,targets=1,splash=0},
}
-- Exact integer distribution preserves total damage, with remainders assigned first.
function Attack.split(total,hits)
    local out={}
    if hits==0 then return out end
    local base=math.floor(total/hits)
    local remainder=total%hits
    for i=1,hits do out[i]=base+(i<=remainder and 1 or 0) end
    return out
end
function Attack.stats(recipe,recipeId,damage,magic)
    local p=recipe.attack or overrides[recipeId or ""] or defaults[recipe.category]
    assert(p,"Missing attack profile: "..recipe.category)
    local total=damage+magic
    local hits=p.hits
    if hits>0 then hits=math.min(hits,total) end
    local secondary=p.targets>1 and math.floor(total*p.splash/100) or 0
    return {hits=hits,targets=p.targets,splashPct=p.splash,
        primaryDamage=total,hitDamage=Attack.split(total,hits),secondaryDamage=secondary,
        maxActionDamage=total+math.max(0,p.targets-1)*secondary}
end
return Attack
