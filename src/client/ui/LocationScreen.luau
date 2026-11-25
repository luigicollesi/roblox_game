--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Shared.world.WorldRegistry)
local Assets = require(ReplicatedStorage.Shared.config.Assets)
local Controller = require(script.Parent.Parent.controllers.NavigationController)
type View = Controller.View
local Screen = {}
local EconomyScreen = require(script.Parent.EconomyScreen)
local Catalog = require(ReplicatedStorage.Shared.economy.Catalog)
local colors = { bg = Color3.fromRGB(25, 25, 25), panel = Color3.fromRGB(43, 43, 43), text = Color3.fromRGB(245, 245, 245), muted = Color3.fromRGB(185, 185, 185) }
local labels = {street = "Rua", district = "Distrito", gate = "Portão", establishment = "Estabelecimento", room = "Área interna"}
local function label(parent: Instance, text: string, size: number, height: number): TextLabel
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Size = UDim2.new(1, 0, 0, height)
	item.Font = Enum.Font.Gotham
	item.Text = text
	item.TextColor3 = colors.text
	item.TextSize = size
	item.TextWrapped = true
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.Parent = parent
	return item
end
local function button(parent: Instance, text: string, enabled: boolean, callback: () -> ())
	local item = Instance.new("TextButton")
	item.Size = UDim2.new(1, 0, 0, 48)
	item.BackgroundColor3 = colors.panel
	item.TextColor3 = if enabled then colors.text else colors.muted
	item.Font = Enum.Font.Gotham
	item.TextSize = 16
	item.TextWrapped = true
	item.Text = text
	item.AutoButtonColor = enabled
	item.Active = enabled
	item.Selectable = enabled
	item.Parent = parent
	if enabled then item.Activated:Connect(callback) end
	return item
end
function Screen.mount(playerGui: PlayerGui, remote: RemoteFunction)
	local previous = playerGui:FindFirstChild("ValdoriaUI")
	if previous then previous:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "ValdoriaUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 10
	gui.Parent = playerGui
	local root = Instance.new("Frame")
	root.BackgroundColor3 = colors.bg
	root.BorderSizePixel = 0
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = gui
	local header = label(root, "Valdória | Navegação", 20, 44)
	header.Position = UDim2.fromOffset(12, 0)
	header.Size = UDim2.new(1, -154, 0, 44)
	local canOpenProfile = false
	local profileButton = button(root, "Meu perfil", true, function()
		if canOpenProfile then EconomyScreen.open(gui, root, "profile") end
	end)
	profileButton.Position = UDim2.new(1, -138, 0, 2)
	profileButton.Size = UDim2.fromOffset(126, 40)
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.fromOffset(0, 44)
	scroll.Size = UDim2.new(1, 0, 1, -44)
	scroll.CanvasSize = UDim2.fromOffset(0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = 6
	scroll.Parent = root
	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -30, 0, 0)
	content.Position = UDim2.fromOffset(12, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Parent = scroll
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content
	local order = 0
	local function add(item: GuiObject)
		order += 1
		item.LayoutOrder = order
	end
	local nav: {refresh: () -> (), move: (string) -> ()}
	local function render(view: View)
		canOpenProfile = view.snapshot ~= nil and not view.busy
		profileButton.Active = canOpenProfile
		profileButton.AutoButtonColor = canOpenProfile
		for _, child in content:GetChildren() do if child ~= layout then child:Destroy() end end
		order = 0
		scroll.CanvasPosition = Vector2.zero
		local snapshot = view.snapshot
		local node = if snapshot then Registry.get(snapshot.locationId) else nil
		if not node then
			add(label(content, if view.message ~= "" then view.message else "Sincronizando localização...", 16, 58))
			local retry = button(content, "Reconectar navegação", not view.busy, function() nav.refresh() end)
			add(retry)
			return
		end
		add(label(content, Registry.breadcrumb(node.id), 14, 52))
		add(label(content, node.name, 24, 58))
		add(label(content, labels[node.kind], 15, 24))
		local asset = (Assets :: any)[node.assetKey]
		local placeholder = Instance.new("Frame")
		placeholder.BackgroundColor3 = colors.panel
		placeholder.BorderSizePixel = 0
		placeholder.Size = UDim2.new(1, 0, 0, 126)
		placeholder.Parent = content
		add(placeholder)
		local caption = label(placeholder, "Imagem genérica: " .. asset.label, 16, 126)
		caption.TextXAlignment = Enum.TextXAlignment.Center
		caption.TextColor3 = colors.muted
		if asset.image ~= "" then
			local image = Instance.new("ImageLabel")
			image.Size = UDim2.fromScale(1, 1)
			image.BackgroundTransparency = 1
			image.Image = asset.image
			image.ScaleType = Enum.ScaleType.Fit
			image.Parent = placeholder
			local function update() caption.Visible = not image.IsLoaded end
			image:GetPropertyChangedSignal("IsLoaded"):Connect(update)
			update()
		end
		if view.message ~= "" then add(label(content, view.message, 15, 42)) end
		local function serviceName(id: string): string?
			local shop = Catalog.shops[id]
			if shop then return if shop.market then "Comprar e vender" else "Comprar produtos" end
			if id == Catalog.learnLocation then return "Aprender receitas" end
			if id == Catalog.trainingLocation then return "Treinar" end
			for _, station in pairs(Catalog.stations) do
				if station.location == id then return "Produzir e reparar" end
			end
			return nil
		end
		local service = serviceName(node.id)
		local economicLocation = service ~= nil
		if service then
			add(button(content, service, not view.busy, function() EconomyScreen.open(gui, root, "services") end))
		end
		add(label(content, "Locais conectados", 18, 32))
		for _, id in node.connections do
			local destination = assert(Registry.get(id))
			local title = destination.name .. "  |  " .. labels[destination.kind]
			if id == node.parentId then title = "Sair para " .. destination.name end
			local available = serviceName(id)
			if available then title ..= " — " .. available end
			local item = button(content, title, not view.busy, function() nav.move(id) end)
			add(item)
		end
		if node.kind == "gate" then
			add(label(content, "O exterior da capital ainda não está disponível.", 15, 52))
		elseif not economicLocation and (node.kind == "establishment" or node.kind == "room") then
			add(label(content, "Serviços ainda não implementados.", 15, 38))
		end
		add(button(content, "Sincronizar localização", not view.busy, function() nav.refresh() end))
	end
	nav = Controller.new(remote, render)
	nav.refresh()
end
return Screen
