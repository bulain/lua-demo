local cjson = require "cjson"
local mysql = require "resty.mysql"
local db, err = mysql:new()
if not db then
    ngx.say("<div>failed to instantiate mysql: ", err,"</div>")
    return
end

db:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a mysql server:
--     local ok, err, errcode, sqlstate =
--           db:connect{
--              path = "/path/to/mysql.sock",
--              database = "ngx_test",
--              user = "ngx_test",
--              password = "ngx_test" }

local ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "ngx_dev",
    user = "ngx_dev",
    password = "dev",
    charset = "utf8",
    max_packet_size = 1024 * 1024,
}

if not ok then
    ngx.say("<div>failed to connect: ", err, ": ", errcode, " ", sqlstate, "</div>")
    return
end

ngx.say("<div>connected to mysql.</div>")

local res, err, errcode, sqlstate =
db:query("drop table if exists cats")
if not res then
    ngx.say("<div>bad result: ", err, ": ", errcode, ": ", sqlstate, ".</div>")
    return
end

res, err, errcode, sqlstate =
db:query("create table cats "
        .. "(id serial primary key, "
        .. "name varchar(5))")
if not res then
    ngx.say("<div>bad result: ", err, ": ", errcode, ": ", sqlstate, ".</div>")
    return
end

ngx.say("table cats created.")

res, err, errcode, sqlstate =
db:query("insert into cats (name) "
        .. "values (\'Bob\'),(\'\'),(null)")
if not res then
    ngx.say("<div>bad result: ", err, ": ", errcode, ": ", sqlstate, ".</div>")
    return
end

ngx.say("<div>result: ", cjson.encode(res),"</div>")
ngx.say("<div>",res.affected_rows, " rows inserted into table cats ",
        "(last insert id: ", res.insert_id, ")</div>")

-- run a select query, expected about 10 rows in
-- the result set:
res, err, errcode, sqlstate =
db:query("select * from cats order by id asc", 10)
if not res then
    ngx.say("<div>bad result: ", err, ": ", errcode, ": ", sqlstate, ".</div>")
    return
end


ngx.say("<div>result: ", cjson.encode(res),"</div>")

-- put it into the connection pool of size 100,
-- with 60 seconds max idle timeout
local ok, err = db:set_keepalive(60000, 100)
if not ok then
    ngx.say("<div>failed to set keepalive: ", err, "</div>")
    return
end

-- or just close the connection right away:
--local ok, err = db:close()
--if not ok then
--    ngx.say("failed to close: ", err)
--    return
--end