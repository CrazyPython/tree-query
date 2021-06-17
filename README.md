# `tree-query`

> This README is TODO. If you'd like to use this software in a project, **don't hestiate to reach out to me.**

`tree-query` is a tool that lets you execute queries on ordinary directories of files like text and Markdown, inspired by Roam Research's query syntax.

It is a replacement for Roam's query system. It supports everything Roam does, except for block references.

[Join us on Discord](https://discord.gg/7B9ywS5x)

## Quickstart

**Query in current directory:**
```
tree-query '{and: [[Page 1]] [[Page 2]]}' .
```
[*Learn to navigate to a working directory with `cd`*](https://linuxize.com/post/linux-cd-command/)

**Query in a folder:**
```
tree-query '{and: [[Page 1]] [[Page 2]]}' /Users/steve/myfoldername/
```
*Learn to get the location of a folder on [macOS](https://osxdaily.com/2009/11/23/copy-a-files-path-to-the-terminal-by-dragging-and-dropping/), [Windows](https://www.top-password.com/blog/copy-full-path-of-a-folder-file-in-windows/), or [GNU+Linux](https://unix.stackexchange.com/questions/102551/mouse-shortcut-to-copy-the-path-to-a-file-in-the-gnome-file-manager).*

Or query in multiple folders and files:

```
tree-query '{and: [[Page 1]] [[Page 2]]}' /Users/steve/myfoldername/ file1
```

**Query stdin with pipes:**
```
cat myfile | tree-query '{and: [[Page 1]] [[Page 2]]}'
```
[*Learn to build powerful no-code applications using pipes*](https://youtu.be/tc4ROCJYbm0?t=360)

## Installation
### [Download a copy](https://github.com/CrazyPython/tree-query/releases/tag/v0.1.1)
The more convenient method. Click above for instructions.

### Build from source

On FreeBSD, GNU+Linux, and macOS, open Terminal and go:
```
curl https://dlang.org/install.sh | bash -s
```

On Windows, download and install [Git Bash](https://gitforwindows.org/) and [7-Zip to C:\Program Files](https://www.7-zip.org/), then run:
```
mkdir %USERPROFILE%\dlang
set PATH="%PATH%;C:\Program Files\7-Zip"
set BASH="\Program Files\Git\usr\bin\bash.exe"
mkdir dlang
powershell.exe -Command "wget https://dlang.org/install.sh -OutFile dlang\install.sh"
```

Then:
```
~/dlang/install.sh install ldc-1.23.0
```

Then `cd` into the directory where you cloned this directory (`git clone https://github.com/CrazyPython/tree-query.git && cd tree-query`) and type:
```
~/dlang/ldc-1.23.0/bin/ldc2 --link-defaultlib-shared=false -O2 -release tree-query.d interp.d query.d parser.d
```

(Non-Windows) Install to make available eveywhere:
```
chmod 700 tree-query
sudo mv tree-query /usr/local/bin
```

## Features

This section is a work-in-progress.

* **Fast**

## Basic usage with the command-line

### Copy result to clipboard
macOS:
```
tree-query '{and: [[Page 1]] [[Page 2]]}' . | pbcopy
```

GNU+Linux:
```
tree-query '{and: [[Page 1]] [[Page 2]]}' . | xclip
```

## Contributing

Tree-query is written in [Dlang](https://dlang.org) but don't let that put you off- if you know C, C++, or Java, you'll pick it up very quickly.

If you have any questions on D, feel free to go to #d on freenode or D Forums. People are very nice.

### Internals

I've spent some time writing doc comments inside the code. They provide a conceptual explanation of how the system works. Look for `/**` and `/++`.

Inside the unittests, there's an example guide on using `parser.d` as a library to build a Markdown to XML converter. 

### Notes

A string in D is a reference to a region of immutable memory. It is a length and a pointer. For this reason, it is is very efficient to copy.

A struct is like a Java record or class.

## Known bugs
 - Mixing tabs and spaces in the same file is not supported, unless an explicit spaces per indent specified

## Your rights

This is open-source software.

We use copyleft to gurantee these rights:

0. Free for commercial use and any other purpose
1. Freedom to remix to fit your needs: You (and if you can't code, by proxy a programmer you hire) have freedom to add new query keywords, completely change the query system, add support for new formats like org-mode, or anything else
2. Freedom to help friends by sharing
3. Freedom to share remixes, commercially and noncommercially

I believe knowledge management is a deeply, and everyone should have freedom over their "digital brain." A digital brain is a deeply intimate and personal thing. This means you are the sovereign of your digital brain.

Compatible with permissive licenses like Apache License, MIT License, and Mozilla Public License.

(C) 2021. Affero General Public License v3.0 or any later version
