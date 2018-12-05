local skynet    = require "skynet.manager"
local mysql     = require "skynet.db.mysql"
local bewater   = require "bewater"
local util      = require "util"
local Conf      = require "conf"

local mod = ...

if mod == "agent" then

local db
skynet.start(function()
    local function on_connect(_db)
        _db:query("set charset utf8")
    end
    db=mysql.connect({
        host=Conf.mysql.host,
        port=Conf.mysql.port,
        database=Conf.mysql.name,
        user=Conf.mysql.user,
        password=Conf.mysql.password,
        max_packet_size = 1024 * 1024,
        on_connect = on_connect
    })
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = assert(db[cmd])
        local ret = f(db, ...)
        assert(not ret.err,string.format("mysql error:%s\n%s", table.pack(...)[1], util.dump(ret)))
        bewater.ret(ret)
    end)
end)

else

skynet.start(function()
    local preload = Conf.preload or 10
    local agent = {}
    for i = 1, preload do
        agent[i] = skynet.newservice(SERVICE_NAME, "agent")
    end
    local balance = 1
    skynet.dispatch("lua", function(_,_, ...)
        balance = balance + 1
        if balance > #agent then
            balance = 1
        end
        local ret = skynet.call(agent[balance], "lua", ...)
        bewater.ret(ret)
    end)
end)

end
