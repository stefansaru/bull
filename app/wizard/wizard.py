"""Bull app wizard — the app's zero-to-release pipeline (PROC-REPO-005).

    py -3 app/wizard/wizard.py                 # development run, ends with an HTML report
    py -3 app/wizard/wizard.py --release       # zero to signed AAB + release verdict
    py -3 app/wizard/wizard.py --content       # only rebuild assets/content from the wiki
    py -3 app/wizard/wizard.py --rights-init   # add `pending` entries to wiki/assets/rights.yml

See app/docs/wizard.md.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from bullwiz import content, paths, rights  # noqa: E402
from bullwiz.pipeline import Wizard, load_config  # noqa: E402


def main(argv: list[str] | None = None) -> int:
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    mode = ap.add_mutually_exclusive_group()
    mode.add_argument("--release", action="store_true", help="run every gate and build the signed AAB")
    mode.add_argument("--content", action="store_true", help="only rebuild the content bundle")
    mode.add_argument("--rights-init", action="store_true", help="register referenced images as pending")
    ap.add_argument("--skip-flutter", action="store_true", help="skip flutter steps (content work only)")
    args = ap.parse_args(argv)

    if args.rights_init:
        cfg = load_config()
        langs = [cfg.get("master_language", "en")]
        referenced = content.referenced_images(content.load_sections(langs))
        added = rights.init(referenced)
        print(f"{len(referenced)} images referenced; {added} new pending entries in {paths.RIGHTS}")
        return 0
    return Wizard(release=args.release, skip_flutter=args.skip_flutter).run(
        only="content" if args.content else None)


if __name__ == "__main__":
    sys.exit(main())
