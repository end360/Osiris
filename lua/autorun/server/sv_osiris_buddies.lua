util.AddNetworkString("OsirisBuddies")

net.Receive("OsirisBuddies", function(len, ply)
    if ply.lastBuddies and ply.lastBuddies + 0.1 > CurTime() then return end
    local count = net.ReadUInt(16)

    local t = {}
    for I=1, count do
        local steamid = net.ReadString()
        t[steamid] = {
            phys = net.ReadBool(),
            grav = net.ReadBool(),
            tool = net.ReadBool(),
            use  = net.ReadBool(),
            dmg  = net.ReadBool()
        }
    end

    ply.Buddies = t
    ply.lastBuddies = CurTime()
end)
