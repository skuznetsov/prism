require "./obj_index"

module Prism::Core::Model
  # Represents an OBJ model.
  # This class can load and parses OBJ models
  class OBJModel
    @verticies : Array(Vector3f)
    @textures : Array(Vector2f)
    @normals : Array(Vector3f)
    @indicies : Array(OBJIndex)
    @has_tex_coords : Bool
    @has_normals : Bool

    def initialize(file_name : String)
      @verticies = [] of Vector3f
      @textures = [] of Vector2f
      @normals = [] of Vector3f
      @indicies = [] of OBJIndex
      @has_tex_coords = false
      @has_normals = false

      File.each_line(file_name) do |line|
        tokens = line.split(" ", remove_empty: true)
        if tokens.size === 0 || tokens[0] === "#"
          next
        elsif tokens[0] === "v"
          # verticies
          @verticies.push(Vector3f.new(tokens[1].to_f32, tokens[2].to_f32, tokens[3].to_f32))
        elsif tokens[0] === "vt"
          # vertex textures
          @textures.push(Vector2f.new(tokens[1].to_f32, tokens[2].to_f32))
        elsif tokens[0] === "vn"
          # vertex normals
          @normals.push(Vector3f.new(tokens[1].to_f32, tokens[2].to_f32, tokens[3].to_f32))
        elsif tokens[0] === "f"
          # faces
          0.upto(tokens.size - 4) do |i|
            @indicies.push(parse_obj_index(tokens[1]))
            @indicies.push(parse_obj_index(tokens[2 + i]))
            @indicies.push(parse_obj_index(tokens[3 + i]))
          end
        end
      end
    end

    def to_indexed_model : IndexedModel
      result = IndexedModel.new
      normal_model = IndexedModel.new
      result_index_map = {} of OBJIndex => Int32
      normal_index_map = {} of Int32 => Int32
      index_map = {} of Int32 => Int32

      0.upto(@indicies.size - 1) do |i|
        current_index = @indicies[i]
        current_position = @verticies[current_index.vertex_index]
        current_tex_coord = Vector2f.new(0f32, 0f32)
        current_normal = Vector3f.new(0f32, 0f32, 0f32)

        if @has_tex_coords
          # TRICKY: blender starts from the bottom left of the texture, so we have to move it to the top left for OpenGL.
          tmp = @textures[current_index.tex_coord_index]
          current_tex_coord = Vector2f.new(tmp.x, 1 - tmp.y)
        end

        if @has_normals
          current_normal = @normals[current_index.normal_index]
        end

        # get the mesh
        model_vertex_index = -1
        if result_index_map.has_key?(current_index)
          model_vertex_index = result_index_map[current_index]
        end

        if model_vertex_index == -1
          model_vertex_index = result.positions.size
          result_index_map[current_index] = model_vertex_index

          result.positions.push(current_position)
          result.tex_coords.push(current_tex_coord)
          if @has_normals
            result.normals.push(current_normal)
          end
        end

        # get the normals
        normal_model_index = -1
        if normal_index_map.has_key?(current_index.vertex_index)
          normal_model_index = normal_index_map[current_index.vertex_index]
        end

        if normal_model_index == -1
          normal_model_index = normal_model.positions.size
          normal_index_map[current_index.vertex_index] = normal_model_index

          normal_model.positions.push(current_position)
          normal_model.tex_coords.push(current_tex_coord)
          normal_model.normals.push(current_normal)
        end

        result.indicies.push(model_vertex_index)
        normal_model.indicies.push(normal_model_index)

        # map normals to the model
        index_map[model_vertex_index] = normal_model_index
      end

      unless @has_normals
        normal_model.calc_normals

        0.upto(result.positions.size - 1) do |i|
          result.normals.push(normal_model.normals[index_map[i]])
        end
      end

      return result
    end

    private def parse_obj_index(token : String) : OBJIndex
      values = token.split("/")

      result = OBJIndex.new
      result.vertex_index = values[0].to_i32 - 1

      if values.size > 1
        @has_tex_coords = true
        result.tex_coord_index = values[1].to_i32 - 1

        if values.size > 2
          @has_normals = true
          result.normal_index = values[2].to_i32 - 1
        end
      end

      return result
    end
  end
end
