local discordia = require("discordia")
local client = discordia.Client()
local json = require('json')
local coro = require('coro-http')
local wait = {}
local timer =  require('timer')
local s = [[
          **Commands:**
help - `Shows this message.`
hello - `Simple Greeting.`
ping - `Ping Command.`
chucknorris - `A Chuck Norris Joke (don't get why I did that)`
smart - `Your smart meter.`
payday - `Get some money. It has a 30 minute cooldown.`
bal - `Your money balance.`
work - `Work to get some money!`
          ]] 
-- Ignore the variable s, lol

function ChuckNorris(message)
    coroutine.wrap(function()
        local link = "https://api.chucknorris.io/jokes/random"
        local result, body = coro.request("GET", link)
        body = json.parse(body)
        message:reply{
            embed = {
                title = "**Here's a Chuck Norris Joke!**";
                fields = {
                    {name = "Chuck Norris"; value = body["value"]; inline = false};
                };
                color = discordia.Color.fromRGB(22,27,154).value;
            };
        }
    end)()
end

function IsCooldown(id, c)
    for i,v in pairs(wait) do
        if type(v) == "table" then
            if v.memberid == id then
                if v.cmd == c then
                    return true, v
                end
            end
        end
    end
    return false
end
client:on("messageCreate", function(message)
    local content = message.content
    local member = message.member
    local memberid = message.member.id
    if content:lower() == "lping" then
        message:reply{
            embed = {
                title = "**You Pinged?**";
                fields = {
                    {name = "Your Ping:"; value = ":ping_pong: Pong!"; inline = false};
                };
                color = discordia.Color.fromRGB(22,27,154).value;
            };
        }
    end

    if content:lower() == "lhello" then
        message:reply{
            embed = {
                title = "**LuaBot**";
                fields = {
                    {name = "**You said something?**"; value = ":wave: Hello to you back!"; inline = false};
                };
                color = discordia.Color.fromRGB(22,27,154).value;
            };
        }
    end

    if content:lower() =="lhelp" then
        message:reply{
            embed = {
                title = "**My Prefix is:** l";
                fields = {
                    {name = "**Look below for my commands!**"; value = s; inline = false};
                };
                color = discordia.Color.fromRGB(22,27,154).value;
            };
        }
    end

    if content:lower() == "lchucknorris" then
        ChuckNorris(message)
    end

    if content:lower():sub(1,#"lpayday") == "lpayday" then
        local isCool, Table = IsCooldown(memberid, "payday")
        if isCool == false then
            local open = io.open("eco.json", "r")
            local parse = json.parse(open:read())
            local earned = math.random(5,10)
            table.insert(wait, {memberid = member.id, cmd = "payday", time = 1800})
            open:close()
            if parse[memberid] then
                parse[memberid] = parse[memberid] + earned
            else
                parse[memberid] = earned
            end
            message:reply{
                embed = {
                    title = "**Have some money!**";
                    fields = {
                        {name = "Here is your money :moneybag:!"; value = message.member.username.. " has just received $" ..earned.."!" ; inline = false};
                    };
                    color = discordia.Color.fromRGB(22,27,154).value;
                };
            }
            open = io.open("eco.json", "w")
            open:write(json.stringify(parse))
            open:close()
        elseif Table ~= nil then
            message:reply{
                embed = {
                    title = "**You are on cooldown. :slight_frown:**";
                    fields = {
                        {name = "**Hey, you can't have too much money at a time! :angry:**"; value =  message.member.username.. " sorry, but you still have to wait "..Table.time.." seconds." ; inline = false};
                    };
                    color = discordia.Color.fromRGB(22,27,154).value;
                };
            }
        end
    end

    if content:lower():sub(1,#"lwork") == "lwork" then
        local isCool, Table = IsCooldown(memberid, "payday")
        if isCool == false then
            local open = io.open("eco.json", "r")
            local parse = json.parse(open:read())
            local earned = math.random(5,100)
            table.insert(wait, {memberid = member.id, cmd = "payday", time = 600})
            open:close()
            if parse[memberid] then
                parse[memberid] = parse[memberid] + earned
            else
                parse[memberid] = earned
            end
            message:reply{
                embed = {
                    title = "**You worked!**";
                    fields = {
                        {name = "Here is your money :moneybag:!"; value = message.member.username.. " has just got $" ..earned.." from working!" ; inline = false};
                    };
                    color = discordia.Color.fromRGB(22,27,154).value;
                };
            }
            open = io.open("eco.json", "w")
            open:write(json.stringify(parse))
            open:close()
        elseif Table ~= nil then
            message:reply{
                embed = {
                    title = "**You are on cooldown. :slight_frown:**";
                    fields = {
                        {name = "**You can't work, wait 10m.**"; value =  message.member.username.. " sorry, but you still have to wait "..Table.time.." seconds to work." ; inline = false};
                    };
                    color = discordia.Color.fromRGB(22,27,154).value;
                };
            }
        end
    end

    if content:lower():sub(1,#"lbal") == "lbal" then
        local open = io.open("eco.json", "r")
        local parse = json.parse(open:read())
        open:close()
        message:reply{
            embed = {
                title = "**:moneybag: Your bank balance! :moneybag:**";
                fields = {
                    {name = "**Want to see how much money you have?**"; value =  message.member.username.. " has $ "..(parse[memberid] or 0) ; inline = false};
                };
                color = discordia.Color.fromRGB(22,27,154).value;
            };
        }
    end
    if content:lower():sub(1,#"lsmart") == "lsmart" then
        local mentioned = message.mentionedUsers
        if #mentioned == 1 then
            local member = message.guild:getMember(mentioned[1][1])
            message:reply{
                embed = {
                    title = "**:brain: Smartness Detected! :brain:**";
                    fields = {
                        {name = "**What is your brainpower? :thinking:**"; value = member.username.." has "..math.random(1,100).."% brainpower! :brain:" ; inline = false};
                    };
                    color = discordia.Color.fromRGB(22,27,154).value;
                };
            }

        elseif #mentioned == 0 then
            message:reply{
                embed = {
                    title = "**:brain: Smartness Detected! :brain:**";
                    fields = {
                        {name = "**What is your brainpower? :thinking:**"; value = message.member.username.." has "..math.random(1,100).."% brainpower! :brain:" ; inline = false};
                    };
                    color = discordia.Color.fromRGB(22,27,154).value;
                };
            }   
        end 
    end
end)

timer.setInterval(1000, function()
    for i,v in pairs(wait) do
        if type(v) == "table" then
            if v.time > 0 then
                wait[i].time = wait[i].time - 1
            else
                wait[i] = nil
            end
        end
    end
end)

client:run("Bot "..io.open('./login.txt'):read())
