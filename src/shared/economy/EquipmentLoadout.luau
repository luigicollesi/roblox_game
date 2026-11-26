--!nonstrict
local Sets=require(script.Parent.ArmorSets)
local Specials=require(script.Parent.SpecialEffects)
local L={}
L.slots={"head","torso","legs","feet"}
L.labels={head="Cabeça",torso="Torso",legs="Calça",feet="Pés"}
function L.aggregate(items)
    local out=Specials.loadout(items)
    out.attackPct=0;out.speedPct=0;out.defensePct=0;out.magicDefensePct=0;out.slashPct=0;out.piercePct=0;out.bluntPct=0
    out.defense=0;out.magicDefense=0;out.weight=0;out.resistances={slash=0,pierce=0,blunt=0}
    out.sets={}
    local counts,usedSlots={},{}
    local keys={"attackPct","speedPct","defensePct","magicDefensePct","slashPct","piercePct","bluntPct","health","mana","magicDamagePct"}
    for _,item in ipairs(items) do
        if item.current>0 then
            out.defense+=item.defense or 0;out.magicDefense+=item.magicDefense or 0;out.weight+=item.weight or 0
            for k in pairs(out.resistances) do out.resistances[k]+=(item.resistances and item.resistances[k] or 0) end
            if item.armorSlot and item.setId and Sets[item.setId] and not usedSlots[item.armorSlot] then
                usedSlots[item.armorSlot]=true
                counts[item.setId]=(counts[item.setId] or 0)+1
            end
        end
    end
    local ids={}
    for id in pairs(counts) do table.insert(ids,id) end
    table.sort(ids)
    local function apply(b,id)
        for _,key in ipairs(keys) do out[key]+=b[key] or 0 end
        for _,effect in ipairs(b.effects or {}) do
            Specials.addEffect(out,effect,"set:"..id,nil)
        end
    end
    for _,id in ipairs(ids) do
        local def=Sets[id];local n=counts[id]
        table.insert(out.sets,{id=id,name=def.name,count=n,twoActive=n>=2,fourActive=n==4})
        if n>=2 then apply(def.two,id) end
        if n==4 then apply(def.four,id) end
    end
    out.attackPct=math.min(60,out.attackPct);out.magicDamagePct=math.min(60,out.magicDamagePct)
    out.defense=math.floor(out.defense*(100+out.defensePct)/100)
    out.magicDefense=math.floor(out.magicDefense*(100+out.magicDefensePct)/100)
    for _,key in ipairs({"slash","pierce","blunt"}) do out.resistances[key]=math.floor(out.resistances[key]*(100+out[key.."Pct"])/100) end
    return out
end
return L
