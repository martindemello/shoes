require 'render'

render("clock") do
  @radius, @centerx, @centery = 90, 126, 140

  background rgb(230, 240, 200)
  fill white
  stroke black
  strokewidth 4
  oval @centerx - 102, @centery - 102, 204, 204

  fill black
  nostroke
  oval @centerx - 5, @centery - 5, 10, 10

  stroke black
  strokewidth 1
  line(@centerx, @centery - 102, @centerx, @centery - 95)
  line(@centerx - 102, @centery, @centerx - 95, @centery)
  line(@centerx + 95, @centery, @centerx + 102, @centery)
  line(@centerx, @centery + 95, @centerx, @centery + 102)
end
