require "lib_gl"
require "./game_object"
require "../rendering/basic_shader"
require "../rendering/camera"
require "cryst_glut"
require "./math"
require "./vector3f"
require "../rendering/forward_ambient"
require "../rendering/forward_directional"
require "../rendering/directional_light"
require "../rendering/base_light"
require "../rendering/point_light"
require "../rendering/attenuation"

module Prism

  class RenderingEngine

    @main_camera : Camera
    @ambient_light : Vector3f
    @directional_light : DirectionalLight
    @directional_light2 : DirectionalLight
    @point_light : PointLight

    getter main_camera, ambient_light, directional_light, point_light
    setter main_camera

    def initialize(window : CrystGLUT::Window)
      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)

      LibGL.front_face(LibGL::CW)
      LibGL.cull_face(LibGL::BACK)
      LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)

      LibGL.enable(LibGL::DEPTH_CLAMP)

      LibGL.enable(LibGL::TEXTURE_2D)

      @main_camera = Camera.new(to_rad(70.0), window.get_width.to_f32/window.get_height.to_f32, 0.01f32, 1000.0f32)
      @ambient_light = Vector3f.new(0.2, 0.2, 0.2)
      @directional_light = DirectionalLight.new(BaseLight.new(Vector3f.new(0,0,1), 0.4), Vector3f.new(1,1,1))
      @directional_light2 = DirectionalLight.new(BaseLight.new(Vector3f.new(1,0,0), 0.4), Vector3f.new(-1,1,-1))
      @point_light = PointLight.new(BaseLight.new(Vector3f.new(0,1,0), 0.4), Attenuation.new(0,0,1), Vector3f.new(5, 0, 5), 100.0)
    end

    def render(object : GameObject)
      clear_screen

      forward_ambient = ForwardAmbient.instance
      forward_directional = ForwardDirectional.instance
      forward_point = ForwardPoint.instance
      forward_ambient.rendering_engine = self
      forward_directional.rendering_engine = self
      forward_point.rendering_engine = self

      object.render(forward_ambient)

      LibGL.enable(LibGL::BLEND)
      LibGL.blend_func(LibGL::ONE, LibGL::ONE)
      LibGL.depth_mask(LibGL::FALSE)
      LibGL.depth_func(LibGL::EQUAL)

      object.render(forward_directional)

      temp = @directional_light
      @directional_light = @directional_light2
      @directional_light2 = temp

      object.render(forward_directional)

      temp = @directional_light
      @directional_light = @directional_light2
      @directional_light2 = temp

      object.render(forward_point)

      LibGL.depth_func(LibGL::LESS)
      LibGL.depth_mask(LibGL::TRUE)
      LibGL.disable(LibGL::BLEND)

      # shader = BasicShader.instance
      # shader.rendering_engine = self
      #
      # object.render(BasicShader.instance)
    end

    # temporary hack
    def input(delta : Float32, input : Input)
      @main_camera.input(delta, input)
    end

    private def clear_screen
      # TODO: stencil buffer
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)
    end

    # Enable/disables textures
    private def set_textures(enabled : Boolean)
      if enabled
        LibGL.enable(LibGL::TEXTURE_2D)
      else
        LibGL.disable(LibGL::TEXTURE_2D)
      end
    end

    def flush
      LibGL.flush()
    end

    # Returns which version of OpenGL is available
    def get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end

    private def set_clear_color(color : Vector3f)
      LibGL.clear_color(color.x, color.y, color.z, 1.0);
    end

    private def unbind_textures
      LibGL.bind_texture(LibGL::TEXTURE_2D, 0)
    end

  end

end
