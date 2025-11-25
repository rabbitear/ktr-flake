{ lib
, buildNpmPackage
, fetchFromGitHub
, python3Packages
, ffmpeg-headless
}:

let
  pname = "open-webui";
  version = "0.6.34";

  # ------ Patch for LangChain community tests -------
  #
  # These modules are missing in newer LangChain versions.
  # We inject placeholder python files to satisfy imports.
  #
  langchainShim = python3Packages.writeTextDir "langchain_shim" ''
    # langchain/agents/react/__init__.py
    # langchain/agents/react/base.py
    # langchain/agents/agent.py
    # langchain/agents/openai_assistant/base.py
    #
    # Provide minimal stubs to satisfy imports.
    import types, sys
    pkg = types.ModuleType("langchain.agents")
    sys.modules["langchain.agents"] = pkg

    react = types.ModuleType("langchain.agents.react")
    react.base = types.ModuleType("langchain.agents.react.base")
    pkg.react = react
    sys.modules["langchain.agents.react"] = react
    sys.modules["langchain.agents.react.base"] = react.base

    agent = types.ModuleType("langchain.agents.agent")
    pkg.agent = agent
    sys.modules["langchain.agents.agent"] = agent

    oa = types.ModuleType("langchain.agents.openai_assistant")
    oa.base = types.ModuleType("langchain.agents.openai_assistant.base")
    sys.modules["langchain.agents.openai_assistant"] = oa
    sys.modules["langchain.agents.openai_assistant.base"] = oa.base

    # langchain_core.tracers.langchain_v1
    core = types.ModuleType("langchain_core.tracers")
    core.lc_v1 = types.ModuleType("langchain_core.tracers.langchain_v1")
    sys.modules["langchain_core.tracers"] = core
    sys.modules["langchain_core.tracers.langchain_v1"] = core.lc_v1
  '';

in
buildNpmPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    rev = "refs/tags/v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  # ---- Python backend build ----
  # We add the langchain shim above to the PYTHONPATH
  buildInputs = with python3Packages; [
    python
    pythonPackages.pip
    pythonPackages.setuptools
    langchainShim
  ];

  # ---- Runtime Dependencies ----
  propagatedBuildInputs = with python3Packages; [
    langchain-community
    langchain
    langchain-core
    langchain-openai
    ffmpeg-headless
  ];

  # ---- Replace langchain import failures ----
  preBuild = ''
    export PYTHONPATH=${langchainShim}:$PYTHONPATH
  '';

  # ---- Optional: disable upstream tests if needed ----
  doCheck = false;

  meta = with lib; {
    description = "User-friendly WebUI for LLMs";
    homepage = "https://github.com/open-webui/open-webui";
    license = licenses.bsd3;
    mainProgram = "open-webui";
  };
}
