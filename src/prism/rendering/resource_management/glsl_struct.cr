module Prism
  # Represents a struct in GLSL
  struct GLSLStruct
    getter name, properties

    def initialize(@name : String, @properties : Array(GLSLProperty))
    end
  end

  # A property of a `GLSLStruct`
  struct GLSLProperty
    getter name, prop_type

    def initialize(@name : String, @prop_type : String)
    end
  end
end
