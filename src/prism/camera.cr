require "./vector3f"
require "./timer"

module Prism

  class Camera

    Y_AXIS = Vector3f.new(0, 1, 0)

    @mouse_locked = false

    getter pos, forward, up
    setter pos, forward, up

    def initialize
      initialize(Vector3f.new(0, 0, 0), Vector3f.new(0, 0, 1), Vector3f.new(0, 1, 0))
    end

    def initialize(@pos : Vector3f, @forward : Vector3f, @up : Vector3f)
      @up.normalize
      @forward.normalize
    end

    def input(input : Input)
      center_position = input.get_center
      sensitivity = 0.5f32
      delta = Timer.get_delta

      return unless delta

      mov_amt = 10 * delta

      # un-lock the cursor
      if input.get_key(Input::ESCAPE)
        input.set_cursor(true)
        @mouse_locked = false
      end

      if @mouse_locked
        delta_pos = input.get_mouse_position - center_position

        rot_y = delta_pos.x != 0
        rot_x = delta_pos.y != 0

        if rot_y
          rotate_y(delta_pos.x * sensitivity)
        end
        if rot_x
          rotate_x(delta_pos.y * sensitivity)
        end

        if rot_y || rot_x
          input.set_mouse_position(center_position)
        end
      end

      # lock the cursor
      if input.get_mouse_down(0)
        input.set_mouse_position(center_position)
        input.set_cursor(false)
        @mouse_locked = true
      end

      # move
      if input.get_key(Input::KEY_W)
        move(forward, mov_amt)
      end
      if input.get_key(Input::KEY_S)
        move(forward, -mov_amt)
      end
      if input.get_key(Input::KEY_A)
        move(left, mov_amt)
      end
      if input.get_key(Input::KEY_D)
        move(right, mov_amt)
      end


    end

    # moves the camera
    def move(direction : Vector3f, amount : Float32)
      @pos = @pos + direction * amount # TODO: double check operator logic in Vector3f
    end

    # rotates around the y axis
    def rotate_y(angle : Float32)
      h_axis = Y_AXIS.cross(@forward)
      h_axis.normalize

      @forward.rotate(angle, Y_AXIS)
      @forward.normalize

      @up = @forward.cross(h_axis)
      @up.normalize
    end

    # rotates around the x axis
    def rotate_x(angle : Float32)
      h_axis = Y_AXIS.cross(@forward)
      h_axis.normalize

      @forward.rotate(angle, h_axis)
      @forward.normalize

      @up = @forward.cross(h_axis)
      @up.normalize
    end

    # returns the left direction
    def left : Vector3f
      l = @forward.cross(@up)
      l.normalize
      return l
    end

    # returns the right direction
    def right : Vector3f
      r = @up.cross(@forward)
      r.normalize
      return r
    end

  end

end
