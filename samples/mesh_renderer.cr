require "../src/prism"

include Prism

class MeshRenderer < GameComponent

  def initialize(@mesh : Mesh, @material : Material)
  end

  def render(transform : Transform, shader : Shader)
    shader.bind
    shader.update_uniforms(transform, @material)
    @mesh.draw
  end

  def input(transform : Transform)
  end

  def update(transform : Transform)
  end
end