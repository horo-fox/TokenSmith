= Making the TokenSmith repository more maintainable

There's always more software engineering practices to follow, so I
decided that the best project for me, considering I am familiar with
the Python ecosystem, is to help improve the setup for this repository.

Copying over the list of potential improvements from my initial
proposal (with better formatting now!), here's some possibilities:
 - allow substituting out ollama for llama.cpp
 - alternatively find a precompiled llama.cpp on PyPI
 - either of the above would allow users not to have anaconda installed
 - add a linter
 - switch from Black to Ruff's autoformatter
 - add a typechecker
 - have a lockfile
 - clean up unnecessary files, like `.DS_Store`
 - update the GitHub Actions configuration to run everything
 - improve tests

Some of these are vaguer than others, but generally they should help
future contributors by standardizing more.
