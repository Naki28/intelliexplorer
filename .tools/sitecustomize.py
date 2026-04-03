import os
import ssl


if os.environ.get("INTELLIEXPLORER_INSECURE_PYTHON_TLS") == "1":
    ssl._create_default_https_context = ssl._create_unverified_context