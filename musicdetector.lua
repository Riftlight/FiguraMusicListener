
local promise = require("Promise")

config:setName("API_Key")
local API_KEY = config:load("1") or error("No API key found. Put one in the config file with name API_Key and key '1'")
local user = "Riftlight" -- CHANGE TO YOUR LASTFM USERNAME
local limit = "1"
local result

local tPath = models.model.World.Camera.text

local musicTask = tPath:newText("textTask")

-- num from string
local function stringHash(s)
    local hash = 0
    for i = 1, #s do -- loop through every char of string
        local byte = s:byte(i) -- get the byte value of the current char
        hash = (hash * 31 + byte) % 0xFFFFFFFF -- 31 is used for multiplier as it's small, prime, hence distributes well. byte is added to the hash, and it's wrapped around the 32-bit unsigned-integer range
    end
    return hash
end

-- string to rgb
local function stringToColor(s)
    local hash = stringHash(s)

    -- Convert the hash to RGB values
    local r = (hash % 256)/255 -- self-explanatory; least significant byte
    local g = (math.floor(hash / 256) % 256)/255 -- bit-shifted by 8 to the right
    local b = (math.floor(hash / 65536) % 256)/255 -- bit-shifted by 16 to the right

    return vec(r, g, b)
end
local isNow = false
function pings.updateSong(album, artist, song, now)
    song = song:gsub("\"", "\\\"")
    album = album:gsub("\"", "\\\"")
    artist = artist:gsub("\"", "\\\"")
    isNow = now
    if player:isLoaded() and now then
        local songHex = vectors.rgbToHex(stringToColor(song))
        local artistHex = vectors.rgbToHex(stringToColor(artist))
        local albumHex = vectors.rgbToHex(stringToColor(album))
        musicTask
            :setVisible(true)
            :alignment("CENTER")
            :setWidth(200)
            :setOutline(true)
            :setScale(0.25)
        if album:lower():find(song:lower(), 1, true) or album:lower():find(artist:lower(), 1, true) then
            musicTask:setText('[{"text":"Listening to:"},{"text":"\n' .. song .. '","color":"#' .. songHex .. '"},{"text":" by "},{"text":"' .. artist .. '", "color":"#'.. artistHex..'"}]')
        else
            musicTask:setText('[{"text":"Listening to:"},{"text":"\n' .. song .. '","color":"#' .. songHex .. '"},{"text":" on "},{"text":"' .. album .. '","color":"#'.. albumHex ..'"},{"text":"\nby "},{"text":"' .. artist .. '", "color":"#'.. artistHex..'"}]')
        end
        if now and album:lower():find(song:lower(), 1, true) or album:lower():find(artist:lower(), 1, true) then
            nameplate.CHAT:setText(toJson({
                text = "${name}",
                color = "#7b50d9",
                hoverEvent = {
                    action = "show_text",
                    contents = {{
                            text = "Listening to:",},{
                            text = "\n" .. song,
                            color = "#" .. songHex
                        },{
                            text = " by "
                        },{
                            text = artist,
                            color = "#" .. artistHex
                        }
                    }
                }
            }))
        elseif now then
            nameplate.CHAT:setText(toJson({
                text = "${name}",
                color = "#7b50d9",
                hoverEvent = {
                    action = "show_text",
                    contents = {{
                            text = "Listening to:",
                        },{
                            text = "\n" .. song,
                            color = "#" .. songHex
                        },{
                            text = " by "
                        },{
                            text = artist,
                            color = "#" .. artistHex
                        }, {
                            text = "\non "
                        },{
                            text = album,
                            color = "#" .. albumHex
                        }
                    }
                }
            }))
        end
    end

    if player:isLoaded() and not now then
        nameplate.CHAT:setText('{"text":"${name}","color":"#7b50d9"}')
        musicTask:setVisible(false)
    end
end

local song
local oldSong
local playing
local oldPlaying
function events.tick()
    if world.getTime() % 60 == 0 then
        if host:isHost() then
            promise.awaitGet("https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=" ..
            user .. "&limit=" .. limit .. "&api_key=" .. API_KEY .. "&format=json")
                :thenJson(function(json) result = json end)
        end
    end
    if result ~= nil and not result["error"] then
        song = result["recenttracks"]["track"][1]["name"]
        playing = result["recenttracks"]["track"][1]["@attr"] ~= nil
    end
    if result ~= nil and not result["error"] and (song ~= oldSong or song == nil or playing ~= oldPlaying or playing == nil) then -- if no web request has been made and the web request didnt fail and ((song was just init'd or has changed) or (playing was just init'd or has changed))
        local album = result["recenttracks"]["track"][1]["album"]["#text"]
        local artist = result["recenttracks"]["track"][1]["artist"]["#text"]
        pings.updateSong(album, artist, song, playing)
    end

    oldPlaying = playing
    oldSong = song

end


local function returnNow() 
    return isNow
end

local function returnDimensions()
    return client.getTextDimensions(musicTask:getText() or "", 200, true)
end

function events.world_render(delta)
    if not player:isLoaded() then return end
    if renderer:isFirstPerson() or not isNow or not client:isHudEnabled() then models.model.World:setVisible(false) return end
    models.model.World:setVisible(true)
    models.model.World:setPos(player:getPos(delta).x*16, player:getPos(delta).y*16 + player:getEyeHeight()*16 + 6 + 16*returnDimensions().y / 64, player:getPos(delta).z*16)
end

return {["returnNow"] = returnNow, ["returnDimensions"] = returnDimensions}