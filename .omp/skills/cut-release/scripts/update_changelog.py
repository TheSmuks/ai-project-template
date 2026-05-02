#!/usr/bin/env python3
"""Update CHANGELOG.md for a version release.

Usage: python3 update_changelog.py <NEW_VERSION> <DATE> <OLD_VERSION>

Moves content from [Unreleased] section to a new [X.Y.Z] section.
"""

import re
import sys
from pathlib import Path

def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <NEW_VERSION> <DATE> <OLD_VERSION>")
        sys.exit(1)
    
    new_version = sys.argv[1]
    date_now = sys.argv[2]
    old_version = sys.argv[3]
    
    changelog_path = Path('CHANGELOG.md')
    if not changelog_path.exists():
        print(f"FAIL: {changelog_path} not found")
        sys.exit(1)
    
    content = changelog_path.read_text()
    
    # Extract unreleased section
    unreleased_match = re.search(r'## \[Unreleased\](.*?)(?=\n## \[|\Z)', content, re.DOTALL)
    if not unreleased_match:
        print("FAIL: No [Unreleased] section found")
        sys.exit(1)
    
    unreleased_content = unreleased_match.group(1).strip()
    if not unreleased_content:
        print("FAIL: [Unreleased] section is empty")
        sys.exit(1)
    
    # Build new version section
    new_section = f"## [{new_version}] — {date_now}\n\n{unreleased_content}\n\n## [Unreleased]\n\n"
    
    # Replace
    new_content = re.sub(
        r'## \[Unreleased\].*?(?=\n## \[|\Z)',
        new_section,
        content,
        count=1,
        flags=re.DOTALL
    )
    
    changelog_path.write_text(new_content)
    print(f"PASS: Created [{new_version}] section with unreleased content")

if __name__ == '__main__':
    main()