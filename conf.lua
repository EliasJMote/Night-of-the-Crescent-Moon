function love.conf(t)
  gameVersion = "1.0.0"
  local scale = 2
  t.title = "Night of the Crescent Moon Ver " .. gameVersion
  t.version = "11.1"
  t.window.width = 640 * scale
  t.window.height = 360 * scale
  t.console = false
end