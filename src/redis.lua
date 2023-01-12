local redis = require "resty.redis"
local red = redis:new()

red:set_timeouts(1000, 1000, 1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

-- connect via ip address directly
local ok, err = red:connect("127.0.0.1", 6379)

-- or connect via hostname, need to specify resolver just like above
-- local ok, err = red:connect("redis.openresty.com", 6379)

if not ok then
    ngx.say("<div>failed to connect: ", err, "</div>")
    return
end

red:auth("dev")

ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("<div>failed to set dog: ", err, "</div>")
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
    ngx.say("<div>failed to get dog: ", err, "</div>")
    return
end

if res == ngx.null then
    ngx.say("<div>dog not found.</div>")
    return
end

ngx.say("<div>dog: ", res, "</div>")

red:init_pipeline()
red:set("cat", "Marry")
red:set("horse", "Bob")
red:get("cat")
red:get("horse")
local results, err = red:commit_pipeline()
if not results then
    ngx.say("<div>failed to commit the pipelined requests: ", err, "</div>")
    return
end

for i, res in ipairs(results) do
    if type(res) == "table" then
        if res[1] == false then
            ngx.say("<div>failed to run command ", i, ": ", res[2], "</div>")
        else
            -- process the table value
        end
    else
        -- process the scalar value
    end
end

-- put it into the connection pool of size 100,
-- with 10 seconds max idle time
local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("<div>failed to set keepalive: ", err, "</div>")
    return
end

-- or just close the connection right away:
-- local ok, err = red:close()
-- if not ok then
--     ngx.say("failed to close: ", err)
--     return
-- end