
#!/usr/bin/env python3
import argparse, json, sys, gzip, datetime, pathlib

try:
    from jsonschema import validate, Draft202012Validator
except ImportError:
    print("Install dependencies first:  pip install jsonschema")
    sys.exit(2)

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def gzipped_size_bytes(obj) -> int:
    data = json.dumps(obj, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    return len(gzip.compress(data))

def main():
    ap = argparse.ArgumentParser(description="Validate and size-check Remote Config template.")
    ap.add_argument("template", help="Path to RC JSON template to validate")
    ap.add_argument("--schema", default="config.schema.json", help="Path to JSON Schema")
    ap.add_argument("--bump", action="store_true", help="Auto-bump meta_config_version to current ISO-8601")
    ap.add_argument("--write", action="store_true", help="Write the (possibly bumped) template back to disk")
    ap.add_argument("--max-bytes", type=int, default=16_384, help="Max gzipped size (bytes)")
    args = ap.parse_args()

    tpl_path = pathlib.Path(args.template)
    schema_path = pathlib.Path(args.schema)
    tpl = load_json(tpl_path)
    schema = load_json(schema_path)

    # Validate
    validator = Draft202012Validator(schema)
    errors = sorted(validator.iter_errors(tpl), key=lambda e: e.path)
    if errors:
        print("❌ Schema validation failed:")
        for e in errors:
            path = "/".join(str(p) for p in e.path) or "<root>"
            print(f"  - {path}: {e.message}")
        sys.exit(1)
    print("✅ Schema validation passed.")

    # Optional bump
    if args.bump:
        now = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")
        tpl["meta_config_version"] = now
        print(f"🔼 Bumped meta_config_version → {now}")

    # Size check (gzipped)
    size = gzipped_size_bytes(tpl)
    status = "✅" if size <= args.max_bytes else "❌"
    print(f"{status} Gzipped size = {size} bytes (limit {args.max_bytes})")

    # Optionally write changes
    if args.write:
        with open(tpl_path, "w", encoding="utf-8") as f:
            json.dump(tpl, f, ensure_ascii=False, indent=2)
        print(f"💾 Wrote: {tpl_path}")

    # Exit non-zero if size too large
    if size > args.max_bytes:
        sys.exit(1)

if __name__ == "__main__":
    main()

