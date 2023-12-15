{
  description = "A collection of project development flakes";

  outputs = {...}: {
    templates = {
      spectec = {
        path = ./spectec;
        description = "SpecTec";
      };

      shader-rs = {
        path = ./shader-rs;
        description = "Shader Rust";
      };
    };
  };
}
