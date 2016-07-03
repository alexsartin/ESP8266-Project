uart.setup(0,57600,8,0,1,1)
wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid="_RGB Globe_",pwd="alexjess"})
uart.write(0,"7\n")
uart.write(0,"8A000A000A100\n")
tmr.alarm(0, 3500, 0, function() 
	if wifi.sta.status()~=5 then
        uart.write(0,"7\n")
        uart.write(0,"9A000A000A255\n")
		dofile("connect.lc")
	else
        dofile("Update.lc") -- esse executa dofile("server1.lc")
        tmr.alarm(1, 1500, 0, function()
            print("\nReady")
            dofile("server1.lc")
        end)
    end
end)