"""i18n helpers: stable unit ids, English source hashing, sidecar path."""
import os, hashlib, re


def uid_for(source_blocks):
    """Stable unit id from provenance: min source block, zero-padded -> sorts in
    document order. e.g. [29,30,33] -> 'u00029'."""
    return f"u{min(source_blocks):05d}" if source_blocks else "u00000"


def en_hash(text):
    """Short, stable hash of the English source a translation was made from.
    Whitespace-normalised so trivial reflow doesn't falsely flag staleness, but any
    real wording change does."""
    norm = re.sub(r"\s+", " ", (text or "").strip())
    return hashlib.sha256(norm.encode("utf-8")).hexdigest()[:8]


def sidecar_path(page_md_path):
    """The .i18n.yml sidecar next to a narrative page."""
    return re.sub(r"\.md$", ".i18n.yml", page_md_path)
