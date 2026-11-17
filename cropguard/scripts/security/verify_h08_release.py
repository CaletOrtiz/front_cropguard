"""Inspect a locally built APK without printing credentials or binary strings."""

import argparse
import hashlib
from pathlib import Path
import re
import subprocess
import zipfile


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apk", type=Path, required=True)
    parser.add_argument("--aapt2", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    badging = subprocess.run(
        [str(args.aapt2), "dump", "badging", str(args.apk)],
        capture_output=True, text=True, check=True,
    ).stdout
    permissions = set(re.findall(
        r"^uses-permission(?:-sdk-\d+)?: name='([^']+)'", badging, re.MULTILINE,
    ))
    forbidden = {"android.permission." + name for name in (
        "CAMERA", "READ_EXTERNAL_STORAGE", "WRITE_EXTERNAL_STORAGE",
        "READ_MEDIA_IMAGES", "READ_MEDIA_VIDEO", "MANAGE_EXTERNAL_STORAGE",
    )}
    checks = {
        "APK is not debuggable": "application-debuggable" not in badging.splitlines(),
        "INTERNET retained": "android.permission.INTERNET" in permissions,
        "No camera/broad storage permissions": not permissions & forbidden,
    }
    with zipfile.ZipFile(args.apk) as apk:
        names = apk.namelist()
        libraries = [name for name in names if name.endswith("/libapp.so")]
        checks["Dart AOT library present"] = bool(libraries)
        checks["No debug kernel_blob.bin"] = not any(
            name.endswith("/kernel_blob.bin") for name in names
        )
        labels = (b"[HISTORY IMAGE]", b"[FASTAPI REQUEST]",
                  b"[FASTAPI RESPONSE ", b"[FASTAPI ERROR ")
        checks["App debug log labels absent from Dart AOT"] = all(
            not any(label in apk.read(name) for label in labels)
            for name in libraries
        )
    mapping = root / "build/app/outputs/mapping/release"
    checks["R8 mapping generated"] = (
        (mapping / "mapping.txt").is_file()
        and (mapping / "mapping.txt").stat().st_size > 0
    )
    configuration = mapping / "configuration.txt"
    checks["R8 native log removal rule included"] = (
        configuration.is_file()
        and "-assumenosideeffects class android.util.Log" in
        configuration.read_text(encoding="utf-8")
    )
    for label, passed in checks.items():
        print(f"{'PASS' if passed else 'FAIL'}: {label}")
    print("Permissions:", ", ".join(sorted(permissions)))
    print("APK SHA256:", hashlib.sha256(args.apk.read_bytes()).hexdigest())
    print("Static inspection only; device flows and runtime logs require testing.")
    return 0 if all(checks.values()) else 1


if __name__ == "__main__":
    raise SystemExit(main())
