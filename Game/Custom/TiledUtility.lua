local TiledUtils = {}

function TiledUtils.drawTileObjectLayer(gameMap, layerName, elapsed)
    elapsed = elapsed or 0
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

                    if tile.animation then
                        if not tile.animation.totalDuration then
                            tile.animation.totalDuration = 0
                            for _, frame in ipairs(tile.animation) do
                                tile.animation.totalDuration = tile.animation.totalDuration + frame.duration
                            end
                        end
                        
                        local currentTime = (elapsed * 1000) % tile.animation.totalDuration
                        local accumulatedTime = 0
                        
                        for _, frame in ipairs(tile.animation) do
                            accumulatedTime = accumulatedTime + frame.duration
                            if currentTime < accumulatedTime then
                                -- Convert local tileid to global gid
                                local globalId = tileset.firstgid + frame.tileid
                                local frameTile = gameMap.tiles[globalId]
                                if frameTile and frameTile.quad then
                                    quad = frameTile.quad
                                end
                                break
                            end
                        end
                    end

                    love.graphics.draw(img, quad, x, y)
                end
            end
        end
    end
end

function TiledUtils.drawTileObjectLayers(gameMap, layerNames, elapsed)
    for _, layerName in ipairs(layerNames) do
        TiledUtils.drawTileObjectLayer(gameMap, layerName, elapsed)
    end
end

return TiledUtils