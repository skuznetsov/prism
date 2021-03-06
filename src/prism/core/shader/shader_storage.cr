require "baked_file_system"

module Prism::Core::Shader
  # Embeds the default shaders at compile time.
  class ShaderStorage
    extend BakedFileSystem

    bake_folder "./default_shaders"
  end
end
