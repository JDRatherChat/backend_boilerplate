from pathlib import Path


def get_version():
    """Get the current version from VERSION file."""
    version_file = Path(__file__).parents[2] / "VERSION"

    if not version_file.exists():
        return "0.0.0"

    with open(version_file, "r") as f:
        return f.read().strip()


__version__ = get_version()
