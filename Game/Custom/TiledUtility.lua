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

function TiledUtils.drawTileObject(gameMap, obj, elapsed)
    if not obj or not obj.gid or obj.visible == false then return end

    local bit = bit or bit32
    local gid = obj.gid
    local FLIP_H = 0x80000000
    local FLIP_V = 0x40000000
    local FLIP_D = 0x20000000

    local flipH, flipV, flipD = false, false, false
    if bit then
        flipH = bit.band(gid, FLIP_H) ~= 0
        flipV = bit.band(gid, FLIP_V) ~= 0
        flipD = bit.band(gid, FLIP_D) ~= 0
        gid = bit.band(gid, bit.bnot(FLIP_H + FLIP_V + FLIP_D))
    end

    local tile = gameMap.tiles[gid]
    if not tile then return end

    local tileset = gameMap.tilesets[tile.tileset]
    if not tileset then return end

    local quad = tile.quad
    local img = tileset.image

    if tile.animation then
        if not tile.animation.totalDuration then
            tile.animation.totalDuration = 0
            for _, frame in ipairs(tile.animation) do
                tile.animation.totalDuration = tile.animation.totalDuration + frame.duration
            end
        end

        local currentTime = ((elapsed or 0) * 1000) % tile.animation.totalDuration
        local accumulatedTime = 0
        for _, frame in ipairs(tile.animation) do
            accumulatedTime = accumulatedTime + frame.duration
            if currentTime < accumulatedTime then
                local globalId = tileset.firstgid + frame.tileid
                local frameTile = gameMap.tiles[globalId]
                if frameTile and frameTile.quad then
                    quad = frameTile.quad
                end
                break
            end
        end
    end

    local tileW = obj.width  or tileset.tilewidth
    local tileH = obj.height or tileset.tileheight

    local x = obj.x
    local y = obj.y
    local r = math.rad(obj.rotation or 0)

    local sx = flipH and -1 or 1
    local sy = flipV and -1 or 1

    local ox, oy = 0, tileH

    love.graphics.draw(img, quad, x, y, r, sx, sy, ox, oy)
end

return TiledUtils