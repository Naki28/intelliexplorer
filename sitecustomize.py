import os
import ssl


# Local-only workaround for environments that inject a self-signed TLS certificate.
# This lets Mozilla bootstrap/download steps proceed on this machine.
os.environ.setdefault("PYTHONHTTPSVERIFY", "0")
ssl._create_default_https_context = ssl._create_unverified_context