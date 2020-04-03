require "lib_gl"
require "prism-core"
require "annotation"
require "./game_object"

module Prism
  # The game interace.
  # A game must inherit this class in order to be used by the engine.
  abstract class GameEngine < Prism::Core::Engine
    @root : GameObject = GameObject.new
    @engine : RenderingEngine?
    property engine

    @[Override]
    def startup
      self.init
    end

    # Games should implement this to start their game logic
    abstract def init

    # Gives input state to the game
    @[Override]
    def tick(tick : Prism::Core::Tick, input : Prism::Core::Input)
      @root.input_all(tick.frame_time.to_f32, input)
      @root.update_all(tick.frame_time.to_f32)
    end

    # Renders the game's scene graph
    @[Override]
    def render
      if engine = @engine
        engine.render(@root)
      end
    end

    # Adds an object to the game's scene graph
    def add_object(object : GameObject)
      @root.add_child(object)
    end

    # Registers the engine with the game
    def engine=(@engine : RenderingEngine)
      @root.engine = @engine.as(RenderingEngine)
    end
  end
end