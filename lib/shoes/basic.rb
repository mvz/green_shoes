class Shoes
  class Basic
    include Mod
    def initialize args
      @initials = args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      (@app.order << self) unless @noorder or self.is_a?(EditBox) or self.is_a?(EditLine)
      (@app.cslot.contents << self) unless @nocontrol or @app.cmask
      (@app.cmask.contents << self) if @app.cmask
      @parent = @app.cslot
      
      Basic.class_eval do
        attr_accessor *args.keys
      end

      # FIXME: size_request is a bit bizarre. Override?
      if @real and !self.is_a?(TextBlock)
	r = Gtk::Requisition.new
	@real.size_request r
	@width, @height = r[:width], r[:height]
      end

      set_margin
      @width += (@margin_left + @margin_right)
      @height += (@margin_top + @margin_bottom)

      @proc = nil
      [:app, :real].each{|k| args.delete k}
      @args = args
      @hided, @shows, @hovered = false, true, false
    end

    attr_reader :parent,  :args, :shows, :initials
    attr_accessor :hided

    def move x, y
      @app.cslot.contents -= [self]
      @app.canvas.move @real, x, y
      move3 x, y
      self
    end

    def move2 x, y
      unless @hided
        remove
        @app.canvas.put @real, x, y
      end
      move3 x, y
    end

    def move3 x, y
      @left, @top = x, y
    end

    def remove
      @app.canvas.remove @real unless @hided
    end

    def hide
      @app.shcs.delete self
      @app.shcs << self
      @shows = false
      self
    end

    def show
      @app.shcs.delete self
      @app.shcs << self
      @shows = true
      self
    end

    def toggle
      @app.shcs.delete self
      @app.shcs << self
      @shows = !@shows
      self
    end

    def clear
      @app.mccs.delete(self); @app.mrcs.delete(self); @app.mmcs.delete(self)
      case self
        when Button, EditLine, EditBox, ListBox
          @app.cslot.contents.delete self
          remove
        else @real.clear
      end
    end

    def positioning x, y, max
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move3 x + parent.margin_left, max.top + parent.margin_top
        max = self if max.height < @height
      else
        move3 parent.left + parent.margin_left, max.top + max.height + parent.margin_top
        max = self
      end
      max
    end

    def fix_size
      flag = false
      set_margin
      case self
      when EditBox, Button
        if 0 < @initials[:width] and @initials[:width] <= 1.0
          @width = @parent.width * @initials[:width] - @margin_left - @margin_right
          flag = true
        end
        if 0 < @initials[:height] and @initials[:height] <= 1.0
          @height = @parent.height * @initials[:height] - @margin_top - @margin_bottom
          flag = true
        end
      when EditLine, ListBox
        if 0 < @initials[:width] and @initials[:width] <= 1.0
          @width = @parent.width * @initials[:width] - @margin_left - @margin_right
          @height = 26
          flag = true
        end
      else
      end
      if flag
        @real.set_size_request @width, @height
        move @left, @top
      end
    end
  end

  class Image < Basic; end
  class Button < Basic
    def click &blk
      real.signal_connect "clicked", &blk if blk
    end
  end
  class ToggleButton < Button
    def checked?
      real.active?
    end
    
    def checked=(tof)
      real.active = tof
    end
  end
  class Check < ToggleButton; end
  class Radio < ToggleButton; end

  class Pattern < Basic
    def move2 x, y
      return if @hided
      clear if @real
      @left, @top, @width, @height = parent.left, parent.top, parent.width, parent.height
      @width = @args[:width] unless @args[:width].zero?
      @height = @args[:height] unless @args[:height].zero?
      m = self.class.to_s.downcase[7..-1]
      args = eval "{#{@args.keys.map{|k| "#{k}: @#{k}"}.join(', ')}}"
      args = [@pattern, args.merge({create_real: true, nocontrol: true})]
      pt = @app.send(m, *args)
      @real = pt.real
      @width, @height = 0, 0
    end
  end
  class Background < Pattern; end
  class Border < Pattern; end

  class ShapeBase < Basic; end
  class Shape < ShapeBase; end
  class Rect < ShapeBase; end
  class Oval < ShapeBase; end
  class Line < ShapeBase; end
  class Star < ShapeBase; end
  
  class TextBlock < Basic
    def initialize args
      super
      @app.mlcs << self  unless @real
    end

    def text
      @args[:markup].gsub(/\<.*?>/, '')
    end
    
    def text= s
      style markup: s
    end

    alias :replace :text=

    def positioning x, y, max
      self.text = @args[:markup]
      super
    end
    
    def move2 x, y
      self.text = @args[:markup]
      super
    end
  end
  
  class Banner < TextBlock; end
  class Title < TextBlock; end
  class Subtitle < TextBlock; end
  class Tagline < TextBlock; end
  class Caption < TextBlock; end
  class Para < TextBlock; end
  class Inscription < TextBlock; end

  class EditLine < Basic
    def text
      @real.get_text
    end
    
    def text=(s)
      @real.text = s
    end

    def move2 x, y
      @app.canvas.move @real, x, y
      move3 x, y
    end
  end

  class EditBox < Basic
    def text
      @textview.buffer.text
    end
    
    def text=(s)
      @textview.buffer.text = s
    end

    def move2 x, y
      @app.canvas.move @real, x, y
      move3 x, y
    end
  end
  
  class ListBox < Basic
    def text
      @items[@real.get_active]
    end
  end

  class Progress < Basic
    def fraction
      real.fraction
    end

    def fraction= n
      real.fraction = n
    end
  end
end
