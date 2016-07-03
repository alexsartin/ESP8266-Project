--Manda IP para o data.sparkfun.com
uart.write(0,"7\n")
uart.write(0,"9A000A255A000\n")
sv=net.createConnection(net.TCP, 0) 
--conn:on("receive", function(conn, payload) print(payload) end)
sv:connect(80,'54.86.132.254') 
sv:send("GET /input/yApWryoE4yFGwbM473vn?private_key=4WglxyaMdyUPeJwkNWEv&name=ESP1&mac="..(wifi.sta.getmac() or "?").."&ip="..(wifi.sta.getip() or "?").." HTTP/1.1\r\n")
sv:send("Host: data.sparkfun.com\r\nAccept: */*\r\n")
sv:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n")
sv:on("sent",function(sv)
    sv:close()
    sv=nil
    collectgarbage()
end)