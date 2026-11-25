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
    assert(count(C.materials)==55 and count(C.recipes)==60 and count(C.processing)==29)
    for location in pairs(C.shops) do assert(Registry.get(location),location) end
    for _,station in pairs(C.stations) do assert(Registry.get(station.location)) end
    assert(Registry.get(C.learnLocation) and Registry.get(C.trainingLocation))
    for _,recipe in pairs(C.recipes) do
        assert(C.stations[recipe.station])
        for id,q in pairs(recipe.inputs) do assert(C.materials[id] and not C.materials[id].raw and q>0) end
        for id,q in pairs(recipe.repair) do assert(recipe.inputs[id]==q) end
        if recipe.category=="staff" or recipe.category=="wand" then assert(recipe.force==0) end
    end
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
    assert(purchases==230)
    local acceptAll=function() return true end
    local cards=Model.productCards(marketView.actions,"Comprar","all",acceptAll)
    assert(#cards==175)
    assert(#Model.productCards(marketView.actions,"Comprar","raw",acceptAll)==26)
    assert(#Model.productCards(marketView.actions,"Comprar","processed",acceptAll)==29)
    assert(#Model.productCards(marketView.actions,"Comprar","equipment",acceptAll)==120)
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
    now+=301
    action(p,forge,"craft:sword_iron:1",false)
    assert(p.coins>=0 and E.budget>=0 and other.items[uid]==nil)
    print("[Valdória] Testes de economia: OK (catálogo, preços, produção, maestria, reparo, equipamento e isolamento).")
end
return Tests
