--!nonstrict
-- Executed by the server in Studio; deterministic clock and RNG, isolated test economy.
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local C=require(Shared.economy.Catalog)
local R=require(Shared.economy.Rules)
local Registry=require(Shared.world.WorldRegistry)
local Engine=require(script.Parent.Parent.economy.Engine)
local Tests={}
function Tests.run()
    local function count(t) local n=0;for _ in pairs(t) do n+=1 end;return n end
    assert(count(C.materials)==55 and count(C.recipes)==118 and count(C.processing)==29)
    for location in pairs(C.shops) do assert(Registry.get(location),location) end
    for _,station in pairs(C.stations) do assert(Registry.get(station.location)) end
    assert(Registry.get(C.learnLocation) and Registry.get(C.trainingLocation))
    local namedCount=0
    local families={}
    for recipeId,recipe in pairs(C.recipes) do
        families[recipe.category]=true
        if recipe.named then namedCount+=1;assert(recipe.description and recipe.damageType) end
        local prev=nil
        for quality=1,3 do
            local stats=R.stats(recipe,quality,recipeId)
            local a=stats.attack
            local sum=0;for _,hit in ipairs(a.hitDamage) do assert(hit>0);sum+=hit end
            assert(sum==a.primaryDamage and #a.hitDamage==a.hits)
            assert(a.maxActionDamage==sum+math.max(0,a.targets-1)*a.secondaryDamage)
            assert(a.targets<=4 and a.hits<=3 and a.splashPct<=100)
            if recipe.category=="smallshield" or recipe.category=="largeshield" then assert(a.hits==0 and a.targets==0 and sum==0) else assert(a.hits>=1 and a.targets>=1) end
            assert(stats.damage==stats.baseDamage+stats.damageBonus+stats.qualityDamageBonus)
            assert(stats.magic==stats.baseMagic+stats.magicBonus+stats.qualityMagicBonus)
            if prev then assert(stats.damage>=prev.damage and stats.defense>=prev.defense and stats.magic>=prev.magic and stats.maximum>prev.maximum) end
            prev=stats
        end
        assert(C.stations[recipe.station])
        for id,q in pairs(recipe.inputs) do assert(C.materials[id] and not C.materials[id].raw and q>0) end
        for id,q in pairs(recipe.repair) do assert(recipe.inputs[id]==q) end
        if recipe.category=="staff" or recipe.category=="wand" then assert(recipe.force==0) end
    end
    assert(namedCount==58 and count(families)==16)
    assert(R.stats(C.recipes.sword_watch,1).damage==12)
    assert(R.stats(C.recipes.sword_watch,3).damage==16)
    assert(R.stats(C.recipes.staff_ember,1).magic==33)
    assert(C.recipes.sword_iron.inputs.iron==3 and C.recipes.sword_iron.power==10)
    local fast=R.stats(C.recipes.dagger_comet,1,"dagger_comet").attack
    assert(fast.hits==3 and fast.targets==1 and fast.primaryDamage==33 and fast.hitDamage[1]==11)
    local area=R.stats(C.recipes.greatsword_eclipse,1,"greatsword_eclipse").attack
    assert(area.hits==1 and area.targets==3 and area.secondaryDamage==52 and area.maxActionDamage==184)
    assert(R.stats(C.recipes.staff_constellation,1,"staff_constellation").attack.maxActionDamage==235)
    assert(R.stats(C.recipes.sword_recruit,1,"sword_recruit").damage==4)
    local function materialCost(recipe)
        local total=0;for id,q in pairs(recipe.inputs) do total+=C.materials[id].price*q end
        return total
    end
    assert(materialCost(C.recipes.sword_recruit)<30)
    assert(materialCost(C.recipes.greatsword_eclipse)>3000)
    for m=0,100 do
        local p=R.chances(m);assert(p[1]+p[2]+p[3]==100)
        for n=1,100 do local r=R.roll(m,n);assert(r>=1 and r<=3 and (m>=10 or r==1) and (m>=50 or r~=3)) end
    end
    assert(R.retail(101)==112 and R.used(200,70,100)==140)
    assert(R.repairUnits(3,75,100)==1 and R.repairUnits(6,50,100)==2 and R.repairUnits(8,25,100)==3)
    assert(R.repairUnits(3,100,100)==0 and R.serviceFee(21)==5)
    local now=1000
    local E=Engine.new(C,R,function() return now end,function(_,b) return b end)
    local p=E.profile(1);local other=E.profile(2)
    local market="valdoria.comercial.mercado.salao_comercial"
    local forge=C.stations.forge.location
    local shop="valdoria.artesanal.ferraria.salao_de_vendas"
    local function action(profile,loc,id,expected,studio)
        local v,h=E.view(profile,loc,studio==true)
        local row=h[id]
        local ok=E.execute(profile,loc,studio==true,id,v.revision,v.marketRevision,row and row.title or "")
        assert(ok==expected,id.." expected "..tostring(expected))
    end
    local Model=require(Shared.economy.ViewModel)
    local marketView=E.view(p,market,false)
    assert(marketView.shop.canSell and #marketView.profile.materials==0 and #marketView.profile.equipment==0)
    local purchases=0
    for _,row in ipairs(marketView.actions) do
        if Model.matchesProduct(row,"Comprar","all") then
            purchases+=1;assert(row.product.name and row.product.price>=0 and row.product.quantity>=1)
            if row.product.kind=="equipment" then
                assert(row.product.maximum>0 and row.product.current<=row.product.maximum and row.product.rarity)
            end
        end
    end
    assert(purchases==346)
    local acceptAll=function() return true end
    local cards=Model.productCards(marketView.actions,"Comprar","all",acceptAll)
    assert(#cards==291)
    assert(#Model.productCards(marketView.actions,"Comprar","raw",acceptAll)==26)
    assert(#Model.productCards(marketView.actions,"Comprar","processed",acceptAll)==29)
    assert(#Model.productCards(marketView.actions,"Comprar","equipment",acceptAll)==236)
    assert(#Model.productCards(marketView.actions,"Vender","all",acceptAll)==0)
    for _,card in ipairs(cards) do assert(#card.actions==(card.product.kind=="equipment" and 1 or 2)) end
    assert(#Model.serviceTabs(marketView)==2 and Model.serviceTabs(marketView)[1]=="Comprar")
    local normalShop=E.view(p,shop,false)
    assert(normalShop.shop and not normalShop.shop.canSell and #Model.serviceTabs(normalShop)==1)
    assert(#Model.serviceTabs(E.view(p,"valdoria.central",false))==0)
    local startMoney=p.coins
    local startBudget=E.budget
    local startStock=E.stock.iron_ore
    action(p,market,"buy:iron_ore:5",true)
    assert(p.materials.iron_ore==5 and E.stock.iron_ore==startStock-5)
    local owned=E.view(p,market,false)
    assert(owned.profile.materialUnits==5 and owned.profile.materials[1].quantity==5)
    assert(owned.profile.equipmentCount==0)
    assert(p.coins+E.budget==startMoney+startBudget)
    action(p,market,"sell:iron_ore:5",true)
    assert(p.coins==startMoney and E.budget==startBudget and E.stock.iron_ore==startStock)
    assert(other.coins==1200 and other.materials.iron_ore==nil)
    action(p,shop,"buy:iron_ore:5",true)
    local afterShop=p.coins
    action(p,shop,"sell:iron_ore:5",false)
    assert(p.coins==afterShop and p.materials.iron_ore==5)
    action(p,market,"sell:iron_ore:5",true)
    assert(p.coins<startMoney)
    action(p,"valdoria.central","buy:iron:1",false)
    action(p,"valdoria.central","learn:sword_iron",false)
    action(p,forge,"process:iron:1",false)
    action(p,market,"buy:iron_ore:5",true)
    action(p,forge,"rent:smelt",true)
    action(p,forge,"process:iron:1",true)
    assert(p.materials.iron_ore==3 and p.job and not p.materials.iron)
    action(p,forge,"process:iron:1",false)
    now+=8;E.finish(p);E.finish(p)
    assert(p.materials.iron==1 and p.job==nil)
    action(p,forge,"craft:sword_iron:1",false)
    action(p,C.learnLocation,"learn:sword_iron",true)
    action(p,C.learnLocation,"learn:sword_iron",false)
    action(p,forge,"rent:forge",true)
    action(p,market,"buy:iron:5",true)
    action(p,market,"buy:iron:5",true)
    action(p,market,"buy:oak:5",true)
    for i=1,3 do
        action(p,forge,"craft:sword_iron:1",true)
        now+=C.recipes.sword_iron.seconds;E.finish(p);E.finish(p)
        assert(p.mastery.sword_iron==i*5 and count(p.items)==i)
    end
    local common,superior=0,0
    local uid
    for id,item in pairs(p.items) do
        if item.rarity==1 then common+=1;uid=id elseif item.rarity==2 then superior+=1 end
    end
    assert(common==2 and superior==1)
    local v,h=E.view(p,market,false)
    action(other,market,"buy:pine_log:1",true)
    local ok=E.execute(p,market,false,"buy:pine_log:1",v.revision,v.marketRevision,h["buy:pine_log:1"].title)
    assert(not ok)
    action(p,market,"wear:"..uid,false,false)
    action(p,market,"wear:"..uid,true,true)
    local worn=p.items[uid]
    assert(worn.current<worn.maximum)
    local mastery=p.mastery.sword_iron
    local qty=R.repairUnits(3,worn.current,worn.maximum)
    local before=p.materials.iron
    action(p,forge,"repair:"..uid,true)
    assert(worn.current==worn.maximum and p.materials.iron==before-qty and p.mastery.sword_iron==mastery)
    action(p,forge,"repair:"..uid,false)
    action(p,market,"wear:"..uid,true,true)
    local cash=p.coins;local stock=E.stock.iron
    action(p,forge,"fullrepair:"..uid,true)
    assert(worn.current==worn.maximum and E.stock.iron<stock and p.coins<cash)
    action(p,market,"main:"..uid,true)
    action(p,market,"sellitem:"..uid,false)
    action(p,market,"unequip:"..uid,true)
    action(p,shop,"sellitem:"..uid,false)
    action(p,market,"sellitem:"..uid,true)
    assert(not p.items[uid] and E.marketItems[uid])
    -- Fixture for equipment rules (no need to buy expensive weapons).
    p.items.heavy={uid="heavy",recipe="greatsword_adamantite",rarity=1,current=100,maximum=100}
    p.items.light={uid="light",recipe="greatsword_mithril",rarity=1,current=100,maximum=100}
    p.items.shield={uid="shield",recipe="smallshield_pine",rarity=1,current=100,maximum=100}
    action(p,market,"main:heavy",false)
    action(p,market,"off:shield",true)
    action(p,market,"main:light",true)
    assert(p.main=="light" and p.off==nil)
    local equipped=E.view(p,market,false)
    assert(equipped.profile.main=="light" and equipped.profile.off==nil)
    action(p,market,"off:shield",false)
    action(p,market,"unequip:light",true)
    action(p,market,"off:shield",true)
    -- Separate mastery for named variants; no mastery inherited from iron sword.
    local variant=E.profile(3)
    action(variant,C.learnLocation,"learn:sword_watch",true)
    assert(variant.mastery.sword_watch==0 and variant.mastery.sword_iron==nil)
    action(variant,market,"buy:iron:5",true)
    action(variant,market,"buy:oak:1",true)
    action(variant,market,"buy:leather:1",true)
    action(variant,forge,"rent:forge",true)
    action(variant,forge,"craft:sword_watch:1",true)
    now+=C.recipes.sword_watch.seconds;E.finish(variant)
    assert(variant.mastery.sword_watch==5 and count(variant.items)==1)
    local produced=E.view(variant,forge,false).profile.equipment[1]
    assert(produced.name=="Lâmina da Vigília" and produced.rarity=="Comum" and produced.damage==12 and produced.maximum==120)
    assert(variant.mastery.sword_iron==nil and p.mastery.sword_iron==mastery)
    now+=301
    action(p,forge,"craft:sword_iron:1",false)
    assert(p.coins>=0 and E.budget>=0 and other.items[uid]==nil)
    print("[Valdória] Testes de economia: OK (catálogo, preços, produção, maestria, reparo, equipamento e isolamento).")
end
return Tests
