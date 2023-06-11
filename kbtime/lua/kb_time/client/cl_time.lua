local W, H = ScrW(), ScrH()

surface.CreateFont("kb_time_01", {
    font = "Arial", 
    size = 20*(ScrH()/1080), 
    weight = 1000,
    antialias = true,
    extended = true, 
})

Kobralost_Time = {
    ["TotalTime"] = (Kobralost_Time["TotalTime"] or 0), 
    ["CurrentTime"] = (Kobralost_Time["CurrentTime"] or CurTime()),
    ["PosX"] = W*0.0,
    ["PosY"] = H*0.005,
    ["ColorBox"] = Color(0,0,0,150), 
    ["ColorText"] = Color(255,255,255,255), 
    ["ColorRectangle"] = Color(24,24,24,245),
    ["PanelLeft"] = true, 
}

function Kobralost_Time.ConvertSec(sec)
    local Years = math.floor(sec/31449600)
    if Years >= 1 then 
        sec = sec - 31449600*Years
    end     

    local Month = math.floor(sec/2678400)
    if Month >= 1 then 
        sec = sec - 2678400*Month
    end 

    local Days = math.floor(sec/86400)
    if Days >= 1 then 
        sec = sec - 86400*Days
    end 

    local Hours = math.floor(sec/3600)
    if Hours >= 1 then 
        sec = sec - 3600*Hours
    end 
    
    local Minuts = math.floor(sec/60)
    if Minuts >= 1 then 
        sec = sec - 60*Minuts
    end 

    return (Years >= 1 and Years.."y " or "")..(Month >= 1 and Month.."m " or "")..(Days >= 1 and Days.."d " or "")..(Hours >= 1 and Hours.."h " or "")..(Minuts >= 1 and Minuts.."m " or "")..(sec >=1 and sec.."s" or "")
end 

net.Receive("KBTime:SendInformation", function()
    Kobralost_Time["TotalTime"] = net.ReadUInt(32)
end)

local Rectangle = {
    [1] = {
        { x = (Kobralost_Time["PanelLeft"] and 0 or W*0.02) + Kobralost_Time["PosX"], y = H*0.012+Kobralost_Time["PosY"] },
        { x = (Kobralost_Time["PanelLeft"] and W*0.155 or W*0.135) + Kobralost_Time["PosX"], y = H*0.012+Kobralost_Time["PosY"] },
        { x = W*0.135+Kobralost_Time["PosX"], y = H*0.047+Kobralost_Time["PosY"] },
        { x = Kobralost_Time["PosX"], y = H*0.047+Kobralost_Time["PosY"] }
    },
    [2] = {
        { x = (Kobralost_Time["PanelLeft"] and 0 or W*0.02) + Kobralost_Time["PosX"], y = H*0.052+Kobralost_Time["PosY"] },
        { x = (Kobralost_Time["PanelLeft"]  and W*0.155 or  W*0.135) + Kobralost_Time["PosX"], y = H*0.052+Kobralost_Time["PosY"] },
        { x = W*0.135+Kobralost_Time["PosX"], y = H*0.087+Kobralost_Time["PosY"] },
        { x = Kobralost_Time["PosX"], y = H*0.087+Kobralost_Time["PosY"] }
    },
}

hook.Add("HUDPaint", "KBTime:HUDPaint", function()
	surface.SetDrawColor(Kobralost_Time["ColorRectangle"])
	draw.NoTexture()
	surface.DrawPoly(Rectangle[1])
    
    draw.RoundedBox(0, Kobralost_Time["PosX"], H*0.048+Kobralost_Time["PosY"], W*0.135, H*0.001, color_white)

    surface.SetDrawColor(Kobralost_Time["ColorRectangle"])
	draw.NoTexture()
	surface.DrawPoly(Rectangle[2])

    draw.RoundedBox(0, Kobralost_Time["PosX"], H*0.088+Kobralost_Time["PosY"], W*0.114, H*0.001, color_white)

    draw.DrawText("Total : "..Kobralost_Time.ConvertSec(math.Round(Kobralost_Time["TotalTime"]+(CurTime()-Kobralost_Time["CurrentTime"]))), "kb_time_01", (Kobralost_Time["PanelLeft"] and W*0.003 or W*0.12)+Kobralost_Time["PosX"], H*0.02+Kobralost_Time["PosY"], Kobralost_Time["ColorText"], Kobralost_Time["PanelLeft"] and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT)
    draw.DrawText("Session : "..Kobralost_Time.ConvertSec(math.Round(CurTime()-Kobralost_Time["CurrentTime"])), "kb_time_01", (Kobralost_Time["PanelLeft"] and W*0.003 or W*0.12)+Kobralost_Time["PosX"], H*0.06+Kobralost_Time["PosY"], Kobralost_Time["ColorText"], Kobralost_Time["PanelLeft"] and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT)
end)

function Kobralost_Time.InfoPlayer(tbl)
    local Panel = vgui.Create("DFrame")
    Panel:SetSize(ScrW()/1.5,ScrH()/1.5)
    Panel:Center()
    Panel:SetTitle("Information about the play time")
    Panel:MakePopup()
    Panel:SetDraggable(true)
    Panel:ShowCloseButton(true)

    local AppList = vgui.Create( "DListView", Panel )
    AppList:Dock( FILL )
    AppList:SetMultiSelect( false )
    AppList:AddColumn( "Name / Surname" )
    AppList:AddColumn( "SteamID" )
    AppList:AddColumn( "Total Time" )
    for k, v in pairs(tbl) do
        AppList:AddLine( v.name, v.steam_id, Kobralost_Time.ConvertSec(tonumber(v.time) or 0))
    end
end

net.Receive("KBTime:GetAdminInfo", function()
    local tbl = net.ReadTable() or {}
    Kobralost_Time.InfoPlayer(tbl)
end)
