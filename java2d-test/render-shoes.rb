require 'shoes'

def render(title, &block)
  raise ArgumentError, "No block given" unless block
  Shoes.app :title => title, :width => Render::WINDOW_WIDTH, :height => Render::WINDOW_HEIGHT, :resizable => false do
    self.instance_eval(&block)
  end
end
