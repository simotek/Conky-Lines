require 'cairo'

copas     = require'copas'
new_lock  = require('copas.lock').new
websocket = require'websocket'

addresses = {}
table.insert(addresses,"ws://172.16.0.101:20101")
table.insert(addresses,"ws://172.16.0.104:20101")
table.insert(addresses,"ws://172.16.0.161:20101")
table.insert(addresses,"ws://172.16.1.7:20101")


lock = new_lock()
last_data = {}

function init (connection)
  print ("Thread Init")
  local client = websocket.client.copas({timeout=30})
  local ok,err = client:connect(connection)
  if not ok then
    last_data[connection] = "could not connect"
  else
    last_data[connection] = "connected"
  end
  print('connected')

  while true do
    if client.state == "OPEN" then
        local message,opcode = client:receive()
        if message then
            local ok,err,wait = lock:get()
            if ok then
                last_data[connection] = message
                lock:release()
            else
                print('Couldnt take lock skipping msg')
                local ok,err,wait = lock:get()
                if ok then
                    last_data[connection] = "Disconnected"
                    lock:release()
                end
            end
        end
    else
        local ok,err,wait = lock:get()
        if ok then
            last_data[connection] = "Disconnected"
            lock:release()
        end
        local ok,err = client:connect(connection)
    end
  end
end

function shutdown()
    client:close(1000,'Client shutdown')
    print('closing connection')
end

function conky_remote_init()
    for i, addr in ipairs(addresses) do
        copas.addthread (init, addr)
    end
end

function conky_remote_shutdown()
    -- This doesn't actually work atm
    --copas.addthread (shutdown)
end

function conky_remote_loop()

    if conky_window == nil then return end

    copas.step()

    local print_data="Error"

    local ok,err,wait = lock:get()
      if ok then
        print_data = last_data
        lock:release()
      else
        print('Couldnt take lock skipping print')
      end

    local w=conky_window.width
    local h=conky_window.height
    local cs=cairo_xlib_surface_create(conky_window.display,
            conky_window.drawable, conky_window.visual, w, h)
    cr=cairo_create(cs)

    cairo_select_font_face (cr, "Play", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size (cr, 10)
    cairo_set_source_rgba (cr,1,1,1,1)
    for i, addr in ipairs(addresses) do
        cairo_move_to (cr,50,14*i+60)
        cairo_show_text (cr,print_data[addr])
    end
    cairo_stroke (cr)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
	updates=nil
	updates_gap=nil
end

