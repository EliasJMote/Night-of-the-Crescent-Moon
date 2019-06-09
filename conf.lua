function love.conf(t)
  gameVersion = "0.0.1"
  local scale = 1
  t.title = "Night of the Crescent Moon Ver " .. gameVersion
  t.version = "11.1"
  t.window.width = 640 * scale
  t.window.height = 360 * scale
  t.console = false
end