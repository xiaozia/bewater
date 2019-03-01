local skynet    = require "skynet"
local bewater   = require "bw.bewater"
local log       = require "bw.log"
local rank_cls  = require "sys.rank.rank"

local trace = log.trace("rank.server")

local ranks = {}

local CMD = {}
function CMD.update(rank_name, k, v, data)
    local rank = ranks[rank_name]
    rank:update(k, v, data)
    return bewater.NORET
end

local server = {}
function server.start(handler)
    handler = handler or {}
    skynet.start(function()
        trace("start")
        skynet.dispatch("lua", function(_, _, cmd, ...)
            local func = assert(handler[cmd] or CMD[cmd], cmd)
            bewater.ret(func(...))
        end)
    end)
end

function server.load_rank(rank_name, rank_type, max_count, asc)
    assert(not ranks[rank_name], rank_name)
    local rank = rank_cls.new(rank_name, rank_type, max_count, asc)
    ranks[rank_name] = rank
end

function server.get_rank(rank_name)
    return ranks[rank_name]
end

function server.update(...)
    CMD.update(...)
end

return server
