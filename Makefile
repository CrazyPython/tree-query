.PHONY = md2sexpr-build

# Compile a debug build for quick development
tree-query: tree-query.d interp.d query.d parser.d
	dmd -g -debug -check=invariant -unittest tree-query.d interp.d query.d parser.d

md2sexpr-build:
	~/dlang/ldc-1.23.0/bin/ldc2 --link-defaultlib-shared=false -O3 -release md2sexpr.d parser.d

# Compile with LLVM
tree-query-build:
	~/dlang/ldc-1.23.0/bin/ldc2 --link-defaultlib-shared=false -O2 -release tree-query.d interp.d query.d parser.d
	strip tree-query
