{
  lib,
  buildNpmPackage,
  python3Packages,
  fetchurl,
  ffmpeg-headless,
  src,
}:
let
  pname = "open-webui-dev";
  version = "dev";

  frontend = buildNpmPackage rec {
    pname = "open-webui-dev-frontend";
    inherit version src;

    pyodideVersion = "0.28.2";
    pyodide = fetchurl {
      hash = "sha256-MQIRdOj9yVVsF+nUNeINnAfyA6xULZFhyjuNnV0E5+c=";
      url = "https://github.com/pyodide/pyodide/releases/download/${pyodideVersion}/pyodide-${pyodideVersion}.tar.bz2";
    };

    npmDepsHash = "sha256-CEjWmDcHHr0PeltETi5uIdoQ2C2Twmg+gDBZT5myo/E=";

    npmFlags = [
      "--force"
      "--legacy-peer-deps"
    ];

    postPatch = ''
      substituteInPlace package.json \
        --replace-fail "npm run pyodide:fetch && vite build" "vite build"
    '';

    propagatedBuildInputs = [
      ffmpeg-headless
    ];

    env.CYPRESS_INSTALL_BINARY = "0";
    env.ONNXRUNTIME_NODE_INSTALL_CUDA = "skip";
    env.NODE_OPTIONS = "--max-old-space-size=8192";

    preBuild = ''
      tar xf ${pyodide} -C static/
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -a build $out/share/open-webui

      runHook postInstall
    '';
  };
in
python3Packages.buildPythonApplication rec {
  inherit pname version src;
  pyproject = true;

  build-system = with python3Packages; [ hatchling ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', build = "open_webui/frontend"' ""
  '';

  env.HATCH_BUILD_NO_HOOKS = true;

  pythonRelaxDeps = true;

  dependencies =
    with python3Packages;
    [
      accelerate
      aiocache
      aiofiles
      aiohttp
      alembic
      anthropic
      apscheduler
      argon2-cffi
      asgiref
      async-timeout
      authlib
      azure-ai-documentintelligence
      azure-identity
      azure-storage-blob
      bcrypt
      beautifulsoup4
      black
      boto3
      chromadb
      cryptography
      ddgs
      docx2txt
      einops
      extract-msg
      fake-useragent
      fastapi
      faster-whisper
      firecrawl-py
      fpdf2
      ftfy
      google-api-python-client
      google-auth-httplib2
      google-auth-oauthlib
      google-cloud-storage
      google-genai
      google-generativeai
      googleapis-common-protos
      httpx
      iso-639
      itsdangerous
      langchain
      langchain-community
      langdetect
      ldap3
      loguru
      markdown
      mcp
      nltk
      onnxruntime
      openai
      opencv-python-headless
      openpyxl
      opensearch-py
      opentelemetry-api
      opentelemetry-sdk
      opentelemetry-exporter-otlp
      opentelemetry-instrumentation
      opentelemetry-instrumentation-fastapi
      opentelemetry-instrumentation-sqlalchemy
      opentelemetry-instrumentation-redis
      opentelemetry-instrumentation-requests
      opentelemetry-instrumentation-logging
      opentelemetry-instrumentation-httpx
      opentelemetry-instrumentation-aiohttp-client
      oracledb
      pandas
      passlib
      peewee
      peewee-migrate
      pgvector
      pillow
      psutil
      pyarrow
      pycrdt
      pydub
      pyjwt
      pymdown-extensions
      pymysql
      pypandoc
      pypdf
      python-dotenv
      python-jose
      python-multipart
      python-pptx
      python-socketio
      pytube
      pyxlsb
      rank-bm25
      rapidocr-onnxruntime
      redis
      requests
      restrictedpython
      sentence-transformers
      sentencepiece
      soundfile
      starlette-compress
      starsessions
      tencentcloud-sdk-python
      tiktoken
      transformers
      unstructured
      uvicorn
      validators
      xlrd
      youtube-transcript-api
    ]
    ++ pyjwt.optional-dependencies.crypto
    ++ starsessions.optional-dependencies.redis;

  pythonImportsCheck = [ "open_webui" ];

  makeWrapperArgs = [ "--set FRONTEND_BUILD_DIR ${frontend}/share/open-webui" ];

  meta = {
    description = "Open-WebUI development version";
    homepage = "https://github.com/SleekCodeOrg/open-webui";
    mainProgram = "open-webui";
  };
}
