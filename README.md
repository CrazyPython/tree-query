# `tree-query`

> This README is TODO. If you'd like to use this software in a project, **don't hestiate to reach out to me.**

Tree query is a tool that searches across indented lines.

It is a replacement for Roam's query system.

## Command-line usage

`tree-query '{and: [[Hello]] [[Hi]]}' file1 file2 folder1 folder2`

## Features

This section is a work-in-progress.

* **Fast**: Over 880Gbps on a MacBook Air

## Contributing

Tree-query is written in [Dlang](https://dlang.org) but don't let that put you off- if you know C, C++, or Java, you'll pick it up very quickly.

If you have any questions on D, feel free to go to #d on freenode or D Forums. People are very nice.

### Notes

A string in D is a reference to a region of immutable memory. It is a length and a pointer. For this reason, it is is very efficient to copy.

A struct is like a Java record or class.

## Known bugs
 - Mixing tabs and spaces is not supported, unless an explicit spaces per indent specified
