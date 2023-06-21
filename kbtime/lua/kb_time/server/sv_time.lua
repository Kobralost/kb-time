util.AddNetworkString("KBTime:SendInformation")
util.AddNetworkString("KBTime:GetAdminInfo")

--[[ Mysql Connection ]]
if Kobralost_Time.Mysql then 
    require( "mysqloo" )
    Kobralost_Time.db = mysqloo.connect( "host", "user", "password", "database" )
    function Kobralost_Time.db:onConnectionFailed(_, error)
        Kobralost_Time.db:connect()
    end
    Kobralost_Time.db:connect()
end 

-- [[ Query for Mysqloo or Sqlite ]]
function Kobralost_Time.SQLQuery(query, callBack)
    if Kobralost_Time.Mysql then
        local KBQuery = Kobralost_Time.db:query(query)
        function KBQuery:onSuccess(tbl,data)
            if callBack then
                callBack(tbl)
            end
        end
        KBQuery:start()
    else
        local SQLQuery = sql.Query(query) or {}
        if callBack then 
            callBack(SQLQuery) 
        end
    end
end

local PLAYER = FindMetaTable("Player")

function PLAYER:KBTimeUpdateInformation(sec)
    Kobralost_Time.SQLQuery("UPDATE kbtime_player SET time = "..sec.." WHERE steam_id = '"..self:SteamID64().."'")
end 

hook.Add("Initialize", "KBTime:Initialize", function()
    Kobralost_Time.SQLQuery("CREATE TABLE IF NOT EXISTS kbtime_player(steam_id TEXT, name TEXT, time INT DEFAULT 0)")
end)

hook.Add("PlayerDisconnect", "KBTime:PlayerDisconnect", function(ply)
    ply:KBTimeUpdateInformation(ply.KBTime["Time"]+(os.time()-ply.KBTime["CurTime"]))
end)

hook.Add("ShutDown", "KBTime:ShutDown", function()
    for k,v in pairs(player.GetAll()) do 
        if not IsValid(v) or not v:IsPlayer() then continue end 
        
        v:KBTimeUpdateInformation(v.KBTime["Time"]+(os.time()-v.KBTime["CurTime"]))
    end 
end)

hook.Add("PlayerInitialSpawn", "KBTime:PlayerInitialSpawn", function(ply)
    timer.Simple(0, function()
        if not IsValid(ply) or not ply:IsPlayer() then return end 
        if not istable(ply.KBTime) then ply.KBTime = {} end 
        
        Kobralost_Time.SQLQuery("SELECT * FROM kbtime_player WHERE steam_id = '"..ply:SteamID64().."'", function(tbl)
            -- [[ Initialize table of the player ]]
            if #tbl == 0 then 
                Kobralost_Time.SQLQuery("INSERT INTO kbtime_player ( steam_id, name ) VALUES ('"..ply:SteamID64().."','"..ply:Name().."')")
                ply.KBTime["Time"] = 0 
            else 
                ply.KBTime["Time"] = tonumber(tbl[1]["time"])
            end 

            ply.KBTime["CurTime"] = os.time()

            net.Start("KBTime:SendInformation")
                net.WriteUInt(ply.KBTime["Time"], 32)
            net.Send(ply)
            
            -- [[ Synchronise Time with the client and prevent crash ]] 
            timer.Create("kb_time_prevent:"..ply:EntIndex(), 240, 0, function()
                if not IsValid(ply) or not ply:IsPlayer() then return end 
                
                ply:KBTimeUpdateInformation(ply.KBTime["Time"]+(os.time()-ply.KBTime["CurTime"]))
            end)
        end) 
    end) 
end)

hook.Add("PlayerSay", "KBTime:PlayerSay", function( ply, text, team )
    if IsValid(ply) and ply:IsPlayer() then 
        if string.lower( text ) == "/kbtime" then
            if not Kobralost_Time.Rank[ply:GetUserGroup()] then return end 

            Kobralost_Time.SQLQuery("SELECT * FROM kbtime_player", function(tbl)
                net.Start("KBTime:GetAdminInfo")
                    net.WriteTable(tbl)
                net.Send(ply)  
            end )
        end 
    end
end)

hook.Add("playerCanChangeTeam", "KBTime:playerCanChangeTeam", function(ply, t)
    if isnumber(Kobralost_Time.JobTime[team.GetName(t)]) && ply.KBTime["Time"] < Kobralost_Time.JobTime[team.GetName(t)] then 
        DarkRP.notify(ply, 1, 5, "You don't have enought time for take this job !")
        return false 
    end 
end)

