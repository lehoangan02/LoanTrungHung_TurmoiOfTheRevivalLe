local TiledUtils = {}

function TiledUtils.drawTileObjectLayer(gameMap, layerName)
    local objectLayer = gameMap.layers[layerName]
    if not objectLayer then return end
    
    for _, obj in ipairs(objectLayer.objects) do
        if obj.gid and obj.visible ~= false then
            local tile = gameMap.tiles[obj.gid]
            if tile then
                local tileset = gameMap.tilesets[tile.tileset]
                
                if tileset then
                    local quad = tile.quad
                    local img = tileset.image
                    local x = obj.x
                    local y = obj.y

                    love.graphics.draw(img, quad, x, y)
                end
            end
        end
    end
end

-- Draw multiple tile object layers at once
function TiledUtils.drawTileObjectLayers(gameMap, layerNames)
    for _, layerName in ipairs(layerNames) do
        TiledUtils.drawTileObjectLayer(gameMap, layerName)
    end
end

return TiledUtils