require "../src/prism"
require "./tween.cr"
require "./obstacle.cr"

include Prism

class Door < GameComponent
    include Obstacle

    # NOTE: add top and bottom face if you need hight less than 1
    LENGTH = 1f32
    WIDTH = 0.125f32
    HEIGHT = 1f32
    TIME_TO_OPEN = 1f32
    SIZE = Vector3f.new(LENGTH, HEIGHT, WIDTH)

    @@mesh : Mesh?

    @material : Material
    @is_opening : Bool
    @close_position : Vector3f?
    @open_position: Vector3f?
    @open_movement : Vector3f
    @tween : Tween?

    def initialize(@material, @open_movement)
        @is_opening = false

        if @@mesh == nil
            # create new mesh

            verticies = [
                Vertex.new(Vector3f.new(0, 0, 0), Vector2f.new(0.5, 1)),
                Vertex.new(Vector3f.new(0, HEIGHT, 0), Vector2f.new(0.5, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, 0), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, 0, 0), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(0, 0, 0), Vector2f.new(0.73, 1)),
                Vertex.new(Vector3f.new(0, HEIGHT, 0), Vector2f.new(0.73, 0.75)),
                Vertex.new(Vector3f.new(0, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(0, 0, WIDTH), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(0, 0, WIDTH), Vector2f.new(0.5, 1)),
                Vertex.new(Vector3f.new(0, HEIGHT, WIDTH), Vector2f.new(0.5, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, 0, WIDTH), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(LENGTH, 0, 0), Vector2f.new(0.73, 1)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, 0), Vector2f.new(0.73, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, 0, WIDTH), Vector2f.new(0.75, 1))
            ]
            indicies = [
                0, 1, 2,
                0, 2, 3,

                6, 5, 4,
                7, 6, 4,

                10, 9, 8,
                11, 10, 8,

                12, 13, 14,
                12, 14, 15
            ]
            @@mesh = Mesh.new(verticies, indicies, true)
        end
    end

    def position
        self.transform.pos
    end

    def size
        SIZE
    end

    # Returns the door as an obstacle
    # TODO: perhaps game objects should have this as an empty method or maybe an abstract method.
    # def as_obstacle : Obstacle
    #     Obstacle.new(self.transform.pos, Vector3f.new(LENGTH, HEIGHT, WIDTH))
    # end

    # Returns or generates the door tween
    private def get_tween(delta : Float32, key_frame_time : Float32) : Tween
        if tween = @tween
            return tween
        else
            tween = Tween.new(delta, key_frame_time)
            @tween = tween
            return tween
        end
    end

    # Resets the tween progress to the beginning
    private def reset_tween
        if tween = @tween
            tween.reset
        end
    end

    private def get_open_position : Vector3f
        if position = @open_position
            return position
        else
            position = self.transform.pos - @open_movement
            @open_position = position
            return position
        end
    end

    private def get_close_position : Vector3f
        if position = @close_position
            return position
        else
            position = self.transform.pos
            @close_position = position
            return position
        end
    end

    # Opens the door
    def open
        return if @is_opening
        reset_tween
        @is_opening = true
    end

    def input(delta : Float32, input : Input)
        # just open all the doors for now
        if input.get_key_down(Input::KEY_E)
            self.open
        end
    end

    def update(delta : Float32)
        close_position = self.get_close_position
        open_position = self.get_open_position

        if @is_opening
            tween = get_tween(delta, TIME_TO_OPEN)
            lerp_factor = tween.step
            self.transform.pos = self.transform.pos.lerp(open_position, lerp_factor)
            if lerp_factor == 1
                @is_opening = false
            end
        end
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
        if mesh = @@mesh
            shader.bind
            shader.update_uniforms(self.transform, @material, rendering_engine)
            mesh.draw
        else
            puts "Error: The door mesh has not been created"
            exit 1
        end
    end

end