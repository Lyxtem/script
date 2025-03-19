local HttpService = game:GetService('HttpService')
local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local Players = game:GetService('Players')

-- Configuración
local webhookURL = "https://discord.com/api/webhooks/1351745157170597920/wGPPiyfqwaIqcOcqgslQ4RRPMFl9jRrIMoHLkUeQIt9Ck4xKgDQHumbReBNo5ZqQmy5m" -- Cambia esto por tu webhook de Discord
local player = Players.LocalPlayer

-- Función para enviar mensajes a Discord
local function sendToWebhook(message)
    local payload = HttpService:JSONEncode({content = message})

    if HttpRequest then
        local success, response = pcall(function()
            return HttpRequest({
                Url = webhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)

        if success then
            print("Mensaje enviado a Discord: " .. message)
        else
            warn("Error al enviar mensaje:", response)
        end
    else
        warn("HttpRequest no está disponible en este ejecutor.")
    end
end

-- Enviar mensaje de inicio
sendToWebhook("✅ **El script de stock se ha ejecutado correctamente en Blox Fruits.**")

-- Esperar a que cargue la interfaz del jugador
local success, playerGui = pcall(function()
    return player:WaitForChild('PlayerGui', 10) -- Espera 10 segundos máximo
end)

if not success or not playerGui then
    sendToWebhook("⚠️ **Error: No se encontró la interfaz del jugador.**")
    return
end

-- Buscar la tienda de frutas en la interfaz
local success, main = pcall(function()
    return playerGui:WaitForChild('Main', 10)
end)

if not success or not main then
    sendToWebhook("⚠️ **Error: No se encontró la tienda de frutas.**")
    return
end

local fruitShop = main:FindFirstChild('FruitShop')
if not fruitShop then
    sendToWebhook("⚠️ **Error: No se encontró la sección de la tienda de frutas.**")
    return
end

local left = fruitShop:FindFirstChild('Left')
local center = left and left:FindFirstChild('Center')
local scrollingFrame = center and center:FindFirstChild('ScrollingFrame')
local container = scrollingFrame and scrollingFrame:FindFirstChild('Container')

if not container then
    sendToWebhook("⚠️ **Error: No se encontró la lista de frutas en stock.**")
    return
end

-- Función para obtener el stock actual
local function getCurrentStock()
    local stock = {}
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA('Frame') and child:FindFirstChild('Price') then
            local fruitName = child.Name
            local price = child.Price.Text

            if fruitName and price then
                stock[fruitName] = price
            end
        end
    end
    return stock
end

-- Función para detectar cambios en el stock
local previousStock = {}

local function checkForChanges()
    while true do
        local currentStock = getCurrentStock()

        -- Compara con el stock anterior
        if HttpService:JSONEncode(currentStock) ~= HttpService:JSONEncode(previousStock) then
            -- Construir mensaje de stock
            local message = "**📦 Stock Actual de Frutas en Blox Fruits:**\n"
            for fruit, price in pairs(currentStock) do
                message = message .. string.format("🍏 **%s**: 💰 %s\n", fruit, price)
            end

            -- Enviar al webhook
            sendToWebhook(message)
            previousStock = currentStock
        else
            print("No hay cambios en el stock.")
        end

        wait(300) -- Verifica cada 5 minutos
    end
end

-- Enviar stock inicial y empezar a monitorear cambios
previousStock = getCurrentStock()
sendToWebhook("📜 **Cargando stock inicial...**")
sendToWebhook(HttpService:JSONEncode(previousStock)) -- Enviar stock inicial
checkForChanges()
