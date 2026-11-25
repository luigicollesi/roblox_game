--!nonstrict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Catalog=require(Shared.economy.Catalog)
local Rules=require(Shared.economy.Rules)
local Engine=require(script.Parent.Parent.economy.Engine)
local Service={}
function Service.start(remote, locations)
    local rng=Random.new()
    local economy=Engine.new(Catalog,Rules,os.time,function(a,b) return rng:NextInteger(a,b) end)
    local last={}
    local quotes={}
    Players.PlayerRemoving:Connect(function(p) last[p]=nil; quotes[p]=nil end)
    remote.OnServerInvoke=function(player,action,id,token)
        if player.Parent~=Players then return {ok=false,message="Desconectado."} end
        local now=os.clock()
        if now-(last[player] or -math.huge)<0.12 then return {ok=false,message="Aguarde e sincronize."} end
        last[player]=now
        local location=locations.getLocation(player)
        if not location then return {ok=false,message="Localização indisponível."} end
        local profile=economy.profile(player.UserId)
        local studio=RunService:IsStudio()
        local ok,message=true,""
        local q=quotes[player]
        if action=="act" then
            if type(id)~="string" or #id>180 or type(token)~="number" or not q or q.token~=token or q.location~=location then
                ok,message=false,"Solicitação inválida. Sincronize."
            elseif not q.actions[id] then
                ok,message=false,"Ação não oferecida."
            else
                ok,message=economy.execute(profile,location,studio,id,q.revision,q.marketRevision,q.actions[id])
            end
        elseif action~="view" then
            return {ok=false,message="Solicitação inválida."}
        end
        local view=economy.view(profile,location,studio)
        view.profile.displayName=player.DisplayName
        view.profile.username=player.Name
        local actions={}
        for _,row in ipairs(view.actions) do if row.enabled then actions[row.id]=row.title end end
        local nextToken=(q and q.token or 0)+1
        quotes[player]={token=nextToken,location=location,revision=view.revision,marketRevision=view.marketRevision,actions=actions}
        return {ok=ok,message=message,token=nextToken,view=view}
    end
end
return Service
