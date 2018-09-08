require "./vector3f"
require "matrix"
require "./matrix4f"

module Prism

  class Transform

    # projection variables
    @z_near : Float32?
    @z_far : Float32?
    @width : Float32?
    @height : Float32?
    @fov : Float32?

    # transformation variables
    @translation : Vector3f
    @rotation : Vector3f
    @scale : Vector3f

    getter translation
    setter translation
    getter rotation
    setter rotation
    getter scale
    setter scale

    def initialize()
      @translation = Vector3f.new(0, 0, 0)
      @rotation = Vector3f.new(0, 0, 0)
      @scale = Vector3f.new(1, 1, 1)
    end

    # additional setter in case I don't want to create a vector before hand.
    def translation(x : Float32, y : Float32 , z : Float32)
      @translation = Vector3f.new(x, y, z)
    end

    def rotation(x : Float32, y : Float32 , z : Float32)
      @rotation = Vector3f.new(x, y, z)
    end

    def scale(x : Float32, y : Float32 , z : Float32)
      @scale = Vector3f.new(x, y, z)
    end

    def set_projection(@fov, @width, @height, @z_near, @z_far)
    end

    def get_transformation : Matrix4f
      trans = Matrix4f.new
      trans.init_translation(@translation.x, @translation.y, @translation.z)

      rot = Matrix4f.new
      rot.init_rotation(@rotation.x, @rotation.y, @rotation.z)

      scl = Matrix4f.new
      scl.init_scale(@scale.x, @scale.y, @scale.z)

      return trans * (rot * scl)
    end

    def get_projected_transformation : Matrix4f

      fov = @fov
      width = @width
      height = @height
      z_near = @z_near
      z_far = @z_far

      trans = get_transformation()

      if fov && width && height && z_near && z_far
        proj = Matrix4f.new
        proj.init_projection(fov, width, height, z_near, z_far)
        return proj * trans
      else
        return trans
      end
    end

  end

end
