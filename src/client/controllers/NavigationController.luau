--!strict
local Controller = {}
export type Snapshot = {locationId: string, revision: number}
export type View = {snapshot: Snapshot?, busy: boolean, message: string}
local messages = {
	INVALID_ROUTE = "Não existe uma rota direta para esse local.",
	INVALID_REQUEST = "Solicitação inválida.",
	STALE = "Sua localização foi sincronizada. Tente novamente.",
	RATE_LIMIT = "Aguarde um instante e tente novamente.",
	DISCONNECTED = "Conexão indisponível.",
}
function Controller.new(remote: RemoteFunction, render: (View) -> ())
	local snapshot: Snapshot? = nil
	local busy = false
	local generation = 0
	local function emit(message: string)
		render({snapshot = snapshot, busy = busy, message = message})
	end
	local function request(action: string, destination: string?)
		if busy then return end
		if action == "move" and not snapshot then return end
		generation += 1
		local token = generation
		local revision = if snapshot then snapshot.revision else nil
		busy = true
		emit("Carregando...")
		task.delay(10, function()
			if generation ~= token or not busy then return end
			generation += 1
			busy = false
			-- Resultado de uma requisição atrasada pode ter sido aplicado no servidor.
			-- Exigir snapshot evita navegar a partir de uma posição desatualizada.
			snapshot = nil
			emit("Sem resposta do servidor. Reconecte a navegação.")
		end)
		task.spawn(function()
			local success, result = pcall(function()
				return remote:InvokeServer(action, destination, revision)
			end)
			if generation ~= token then return end
			busy = false
			if not success or type(result) ~= "table"
				or type(result.locationId) ~= "string" or type(result.revision) ~= "number" then
				snapshot = nil
				emit("Não foi possível sincronizar. Tente novamente.")
				return
			end
			snapshot = {locationId = result.locationId, revision = result.revision}
			emit(if result.ok then "" else (messages[result.code] or "Não foi possível navegar."))
		end)
	end
	return {
		refresh = function() request("snapshot", nil) end,
		move = function(destination: string) request("move", destination) end,
	}
end
return Controller
