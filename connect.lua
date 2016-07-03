--Script to connect to wifi with credentials 
--saved in wifi.lua as folow: SSID&PSW
wifi.sta.disconnect()
file.open("wifi")

tmr.alarm(0, 3500, 1, function() 
    local ssid=file.read('&')
    local psw=file.readline()
    if wifi.sta.status()==5 then
        tmr.stop(0)
        --print("Connected")
        uart.write(0,"8A200A200A200\n")
        node.restart()      
    elseif not ssid then
        tmr.stop(0)
        --print("fail")
        uart.write(0,"9A255A000A000\n")
        ssid=nil    psw=nil     file.close()
        collectgarbage()
        dofile("server1.lc")
    elseif ssid then
        ssid=string.sub(ssid,1,-2)
        psw=string.sub(psw or "",1,-2)
        --print("["..ssid.."]["..psw.."]")
        wifi.sta.config(ssid, psw)
    end
end)
