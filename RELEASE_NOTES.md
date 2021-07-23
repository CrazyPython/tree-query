# Release notes

## 0.1.1
 - Added hyperlinked documentation on usage instructions for people new to the CLI
 - Added missing source files, now it's possible to compile
 - Support for starting queries with `{query:` was enabled
 - Shows message when executed without a query
 - Fixed build instructions for Windows and added a binary release for Windows and Mac

## 0.1.0
 - Supports `{and:`, `{or:`, `{not:`, nested arbitrarily, querying using page references
 - Works on any kind of indentation, including tabs, spaces.
   - Caveat: Mixing tabs and spaces in one file may lead to undesired results, because a tab is interpreted as one space
 - Ignores text inside Markdown code blocks
   - Indentation is different for these code blocks. Searching with their text included as part of the parent block is not supported yet
