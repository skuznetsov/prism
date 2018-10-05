require "./game_component"
require "../core/vector3f"
require "../rendering/shader"

module Prism

  class BaseLight < GameComponent

    getter color, intensity, shader
    setter color, intensity, shader

    @shader : Shader?

    def initialize(@color : Vector3f, @intensity : Float32)
    end

    def add_to_rendering_engine(rendering_engine : RenderingEngine)
      rendering_engine.add_light(self)
    end

  end

end