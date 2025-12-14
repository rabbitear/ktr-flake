{ pkgs, lib, ... }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "blender-mcp";
  version = "1.4.0";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "ahujasid";
    repo = "blender-mcp";
    rev = "9cefe8e6ab578ed293cbca564f8794274249fe41";
    sha256 = "0b5m9mb3pnh7agxrkcmk5z83js1lddp0mg7wd4x8d393h5i3fya1";
  };

  build-system = with pkgs.python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with pkgs.python3Packages; [
    mcp
    supabase
    tomli
  ];

  # Skip tests
  doCheck = false;

  pythonImportsCheck = [ "blender_mcp" ];

  meta = with lib; {
    description = "Blender integration through the Model Context Protocol";
    homepage = "https://github.com/ahujasid/blender-mcp";
    license = licenses.mit;
    maintainers = [ ];
  };
}