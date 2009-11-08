module Render
  WINDOW_HEIGHT = 300
  WINDOW_WIDTH = 300
end

begin
  require 'render-swing'
rescue LoadError
  require 'render-shoes'
end
