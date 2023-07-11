Kobralost_Time = Kobralost_Time or {}

Kobralost_Time.Mysql = false 

Kobralost_Time.Rank = {
    ["superadmin"] = true,
    ["admin"] = true, 
}

Kobralost_Time.JobTime = {
    ["Civil Protection"] = 10000,
}

if SERVER then 
    include("kb_time/server/sv_time.lua")
    AddCSLuaFile("kb_time/client/cl_time.lua")
else     
    include("kb_time/client/cl_time.lua")
end 
