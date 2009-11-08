require 'java'

module Render

SwingUtilities = javax.swing.SwingUtilities
Color = java.awt.Color
Dimension = java.awt.Dimension
JFrame = javax.swing.JFrame
BasicStroke = java.awt.BasicStroke
RenderingHints = java.awt.RenderingHints

class Canvas < javax.swing.JPanel
  def initialize
    super
    @ops = []
    @rendering_hints = RenderingHints.new(RenderingHints::KEY_ANTIALIASING, RenderingHints::VALUE_ANTIALIAS_ON)
  end

  def getPreferredSize
    Dimension.new(WINDOW_WIDTH, WINDOW_HEIGHT)
  end

  def paintComponent(gc)
    super(gc)
    state = State.new
    gc.set_rendering_hints @rendering_hints
    @ops.each { |op| op.render(state, gc) }
  end

  def draw(op)
    @ops << op
  end

  class State
    attr_reader :gc
    attr_accessor :stroke_color, :fill_color
    attr_accessor :stroke_width

    def initialize
      @stroke_color = nil
      @fill_color = nil
      @stroke_width = 1
    end
  end

  class Clear
    def initialize(color)
      @color = color
    end

    def render(state, gc)
      gc.set_color @color
      gc.fill_rect 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT
    end
  end

  class Shape
    def initialize(fill_shape, stroke_shape)
      @fill_shape = fill_shape
      @stroke_shape = stroke_shape
    end

    def render(state, gc)
      if @fill_shape and state.fill_color
        gc.set_color state.fill_color
        gc.fill(@fill_shape)
      end
      if @stroke_shape and state.stroke_color
        gc.set_color state.stroke_color
        gc.set_stroke BasicStroke.new(state.stroke_width)
        saved_transform = gc.get_transform
        begin
          gc.translate(0.5, 0.5) if (state.stroke_width & 1).nonzero?
          gc.draw(@stroke_shape)
        ensure
          gc.set_transform saved_transform
        end
      end
    end
  end

  class Oval < Shape
    def initialize(cx, cy, rx, ry)
      rx += 0.5
      ry += 0.5
      shape = java.awt.geom.Ellipse2D::Double.new(cx, cy, rx, ry)
      super(shape, shape)
    end
  end

  class Line < Shape
    def initialize(x0, y0, x1, y1)
      shape = java.awt.geom.Line2D::Double.new(x0, y0, x1, y1)
      super(nil, shape)
    end
  end

  class StrokeColor
    def initialize(color)
      @color = color
    end

    def render(state, gc)
      state.stroke_color = @color
    end
  end

  class StrokeWidth
    def initialize(width)
      @width = width
    end

    def render(state, gc)
      state.stroke_width = @width
    end
  end

  class DisableStroke
    def render(state, gc)
      state.stroke_color = nil
    end
  end

  class FillColor
    def initialize(color)
      @color = color
    end

    def render(state, gc)
      state.fill_color = @color
    end
  end

  class DisableFill
    def render(state, gc)
      state.fill_color = nil
    end
  end
end

class SwingContext
  def initialize(title)
    @window = JFrame.new(title)
    @window.set_default_close_operation JFrame::EXIT_ON_CLOSE

    @canvas = Canvas.new
    @window.add(@canvas)
    @window.pack

    @window.set_resizable false
    @window.set_visible true
  end

  def rgb(r, g, b)
    Color.new(r, g, b)
  end

  def black
    rgb(0, 0, 0)
  end

  def white
    rgb(255, 255, 255)
  end

  def background(color)
    @canvas.draw Canvas::Clear.new(color)
  end

  def oval(cx, cy, rx, ry)
    @canvas.draw Canvas::Oval.new(cx, cy, rx, ry)
  end

  def line(x0, y0, x1, y1)
    @canvas.draw Canvas::Line.new(x0, y0, x1, y1)
  end

  def stroke(color)
    @canvas.draw Canvas::StrokeColor.new(color)
  end

  def fill(color)
    @canvas.draw Canvas::FillColor.new(color)
  end

  def strokewidth(width)
    @canvas.draw Canvas::StrokeWidth.new(width)
  end

  def nostroke
    @canvas.draw Canvas::DisableStroke.new
  end

  def nofill
    @canvas.draw Canvas::DisableFill.new
  end
end

def self.run_in_event_thread
  if SwingUtilities.event_dispatch_thread?
    yield
  else
    exception = nil
    SwingUtilities.invoke_and_wait do
      begin
        yield
      rescue Exception, e
        exception = e
      end
    end
    raise exception if exception
  end
end

end

def render(title, &block)
  raise ArgumentError, "no block given" unless block
  Render.run_in_event_thread do
    Render::SwingContext.new(title).instance_eval(&block)
  end
end
