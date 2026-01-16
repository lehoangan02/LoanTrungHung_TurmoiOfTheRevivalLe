local MusicEnum = require("Game.Music.MusicEnum")

local MusicManager = {}
MusicManager.__index = MusicManager

local instance = nil

function MusicManager:getInstance()
    if instance == nil then
        instance = setmetatable({}, MusicManager)
    end
    return instance
end

function MusicManager:playBackgroundMusic(track)
    if track == MusicEnum.Test then
        love.audio.stop()
        self.music = love.audio.newSource("Resources/Music/I hate these classes (学科嫌い 1913) Japanese Students' Battle Hymn of the Republic.mp3", "stream")
        love.audio.play(self.music)
    end
    if track == MusicEnum.Sakura_Cherry_Blossom then
        love.audio.stop()
        self.music = love.audio.newSource("Resources/Music/Sakura Cherry BlossomsTraditional Music of Japan, Classical Koto Music 日本の伝統音楽.mp3", "stream")
        love.audio.play(self.music)
    end
end

return MusicManager