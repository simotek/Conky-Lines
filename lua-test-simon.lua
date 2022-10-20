-- https://stackoverflow.com/questions/42945538/copas-looping-issue-while-connecting-the-server

local copas     = require'copas'
local new_lock  = require('copas.lock').new
local websocket = require'websocket'
local json      = require'cjson'

local lock = new_lock()

local last_data = ""

local function init ()
  client = websocket.client.copas({timeout=2})

  local ok,err = client:connect('ws://172.16.0.101:20101')
  if not ok then
    print('could not connect',err)
  end
  print('connected')

  while true do
    local message,opcode = client:receive()
    if message then
      local ok,err,wait = lock:get()
      if ok then
        last_data = message
	lock:release()
      else
        print('Couldnt take lock skipping msg')
      end
    else
      -- be more graceful here
      print('connection closed')
      break
    end
  end
end

copas.addthread (init)

-- Use our own "Event loop" instead
--copas.loop()

local socket = require 'socket'
while true do
  copas.step()
  local ok,err,wait = lock:get()
      if ok then
        print(last_data)
        lock:release()
      else
        print('Couldnt take lock skipping print')
      end

  socket.sleep(2)
end
