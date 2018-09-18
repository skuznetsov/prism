require "./vector3f"
require "./mesh"
require "./vertex"
require "./texture"
require "lib_gl"
require "./lib_tools"

module Prism
  class ResourceLoader

    def self.load_texture(file_name : String) : Texture
      ext = File.extname(file_name)

      # read texture data
      path = File.join(File.dirname(PROGRAM_NAME), "/res/textures/", file_name)
      data = LibTools.load_png(path, out width, out height, out num_channels)

      # create texture
      LibGL.gen_textures(1, out id)
      LibGL.bind_texture(LibGL::TEXTURE_2D, id)

      # set the texture wrapping/filtering options
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_S, LibGL::REPEAT)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_T, LibGL::REPEAT)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::LINEAR)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, LibGL::LINEAR)

      if data
        LibGL.tex_image_2d(LibGL::TEXTURE_2D, 0, LibGL::RGB, width, height, 0, LibGL::RGB, LibGL::UNSIGNED_BYTE, data)
        LibGL.generate_mipmap(LibGL::TEXTURE_2D)
        # TODO: free image data from stbi. see LibTools.
      else
        puts "Error: Failed to load texture data from #{path}"
        exit 1
      end
      Texture.new(id)
    end

    # Loads a shader from the disk
    def self.load_shader(file_name : String) : String
      path = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", file_name)
      return File.read(path)
    end

    # Loads a mesh from the disk
    def self.load_mesh(file_name : String) : Mesh
      ext = File.extname(file_name)
      unless ext === ".obj"
        puts "Error: File format not supported for mesh data: #{ext}"
        exit 1
      end

      verticies = [] of Vertex
      indicies = [] of LibGL::Int

      path = File.join(File.dirname(PROGRAM_NAME), "/res/models/", file_name)
      File.each_line(path) do |line|
        tokens = line.split(" ", remove_empty: true)
        if tokens.size === 0 || tokens[0] === "#"
          next
        elsif tokens[0] === "v"
          v = Vector3f.new(tokens[1].to_f32, tokens[2].to_f32, tokens[3].to_f32)
          verticies.push(Vertex.new(v))
        elsif tokens[0] === "f"
          indicies.push(tokens[1].split("/")[0].to_i32 - 1);
          indicies.push(tokens[2].split("/")[0].to_i32 - 1);
          indicies.push(tokens[3].split("/")[0].to_i32 - 1);

          if tokens.size > 4
            indicies.push(tokens[1].split("/")[0].to_i32 - 1);
            indicies.push(tokens[3].split("/")[0].to_i32 - 1);
            indicies.push(tokens[4].split("/")[0].to_i32 - 1);
          end
        end
      end

      res = Mesh.new
      res.add_verticies(verticies, indicies)
      return res
    end
  end
end
