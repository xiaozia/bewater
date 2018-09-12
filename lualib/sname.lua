-- 一些通用服务名, 第一次引用的自动创建
local skynet = require "skynet.manager"
local reg = {
    WEB = "web/webclient",
    PROTO = "proto_env",
    REDIS = "db/redisd",
    MONGO = "db/mongod",
    MYSQL = "db/mysqld",
    ALERT = "alert",    -- 警报服务
    REPORT = "report",  -- 自动向monitor发送报告
    GM = "gm", 
    OP = "operate",     -- 离线操作
}

local M = {}
setmetatable(M, {
    __index = function (t, k)
        local name = assert(reg[k], string.format("sname %s not exist", k))
        return skynet.uniqueservice(name)
    end,
    __newindex = function ()
        assert("cannot overwrite sname")
    end
})

return M
