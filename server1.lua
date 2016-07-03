--Starts TCP/UDP communication server PORT:8080
--Broadcast UDP
local u=net.createServer(net.UDP, 60)
u:on("receive", function(conn, pl)
    --Data received from UDP conn
    u:send(wifi.sta.getip() or "?")
end)
u:listen(8080)

--TCP server
local sv=net.createServer(net.TCP, 60)
sv:listen(80, function(conn)

    --Data received from TCP conn
    conn:on("receive", function(conn, pl)
        local _, _, param, value = string.find(pl, "(.+):(.+)")
        --Attempt to Connect saved WIFIs: WIFI:RETRY
        --Try to connect to specifc WIFI: WIFI:SSID-PWD&
        --Try to connect  and  save WIFI: WIFI:SSID-PWD&1
        if param == "WIFI" then
            if value == "RETRY" then
                node.restart()
            else
                local _, _, ssid = string.find(value, "(.+)-")
                local _, _,  psw = string.find(value, "-(.+)&")
                local _, _, value= string.find(value, "&(%d)")
                uart.write(0,"#Connecting\n")
                wifi.sta.config(ssid, (psw or "") )
                tmr.alarm(0, 4000, 0, function() 
                    if wifi.sta.status()==5 then
                        conn:send("#Connected\n")
                        if value and file.open("wifi", "a") then
                            file.write(ssid)
                            file.write("&")
                            file.writeline( (psw or "") )
                            file.close()
                        end
                    else
                        conn:send("#Failed\n")   
                    end
                    psw=nil ssid=nil    collectgarbage()
                end)
            end
        --Send command from TCP to lua interpretor
        elseif param == "*" then
            node.input(value) 
        end

        --Decodifica HTTP request (GET/POST/HEAD)
        --local _, _, method, path, vars = string.find(pl, "([A-Z]+) (.+)?(.+) HTTP");
        local _, _, _, _, vars = string.find(pl, "([A-Z]+) (.+)?(.+) HTTP");
        
        if (vars ~= nil)then
            local _,_,_,dado=string.find(vars, "(%w+)=(.+)&*")
            uart.write(0,dado)
            uart.write(0,"\n")
            vars=nil
            dado=nil
        end

        --Send serial->TCP conn
        uart.on("data", "\n", function(pl)
            conn:send("HTTP/1.1 200 OK\r\nAccess-Control-Allow-Origin: *\r\nContent-Type: application/json\r\ncharset=UTF-8\r\nContent-Length: ")
            conn:send(string.len(pl))
            conn:send("\r\nConnection: close\r\n\r\n")
            conn:send(pl)
        end, 0)
    end)
    
    --Send interpretor response back to TCP conn
    --To save heap try moving this pice of code!! it works!
    --node.output( local function(str) conn:send(str) end, 0 ) 
    
    conn:on("disconnection", function(conn)
        --Disable lua interpretor -> TCP conn
        --node.output(nil)
        --Disable uart -> TCP conn
        uart.on("data")
    end)
end)
tmr.alarm(1, 4000, 0, function() 
    uart.write(0,"8A000A255A000\n")
end)
