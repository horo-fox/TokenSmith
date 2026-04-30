#show link: set text(fill: blue)

= Making the TokenSmith repository more maintainable

Code link: #link("https://github.com/horo-fox/TokenSmith"), but you can
see the diff here: #link("https://github.com/georgia-tech-db/TokenSmith/compare/main...horo-fox:TokenSmith:code-cleanup").

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


=== No longer requiring Anaconda

Anaconda is required for the compiled `llama_cpp`. However, I am not
convinced that is necessary. The ideal would be to switch away, because
Anaconda is gigantic -- ~1GB installer via homebrew! -- and an extra
thing to install and slow: `make build` takes 150.26 seconds. It's also
sometimes confusing, as I ran into an issue while timing setup where
`conda activate tokensmith` was telling me to run `conda init`, but I
had already done that. (the issue was that it was initializing Anaconda
for the wrong shell!)

==== Switching to a precompiled `llama.cpp` on PyPI

Unfortunately, it seems that Python wheels (precompiled packages) are
not advanced enough to support the large array of possibilities that
depend e.g. on your GPU. I don't think this is possible.

==== Shelling out to a precompiled provider

It seems possible to use Ollama. Essentially, anything with a
`from llama_cpp import Llama` has been replaced with `import ollama`.
However, I'm not yet convinced this is the easiest alternative.
Regardless, it's easier to install than worrying about Anaconda and a
Makefile and having to compile llama.cpp.

The simple solution I implemented is to catch `ImportError` and try
using `ollama` instead. This would mean that if someone wants, they
could use `llama.cpp`, but they could also avoid having to compile
anything.

Additionally, someone must modify `config.yaml`!

After making this change, I switched the project to be able to use
`uv`. I updated the README for all the necessary commands. Compared to
`make build` which took 150.26 seconds (n=1), `uv sync` with a cold
cache took 9.7 seconds (n=1).

==== One more benefit: lockfiles

It looks like there's a #link("https://github.com/conda/conda-lock")[conda-lock]
project that provides lockfiles for anaconda. However, it appears any
`conda create` would need to then be `conda-lock install`, which is not
great.

Instead, by allowing the project to be installed via `uv`, I've
automatically made lockfiles work.

=== Clean up repository

There are many files included in the repository that I don't think
should be. To fix this, I removed the following from git:
 - `.DS_Store` and `index/.DS_Store`
 - `config/config.yaml` (I copied it to `config.example.yaml`)
 - `data/*`

=== Linter + autoformatter

Since there was already ruff mentioned in the gitignore, I ensured that
`uv sync` would install ruff, as well as adding the relevant commands
to lint and autoformat to the README. I did *not* run `ruff check --fix`
or `ruff format` to avoid merge conflicts.

=== GitHub Actions

I made the GitHub Actions run on every push, as well as added a new job
whose only purpose was to run the linter and autoformatter. Since

== Next steps

I should do more of the improvements and come up with some more.
Additionally, I should probably get some feedback on what sort of
code quality tools are even nice; maybe our instructor has some set of
preferred tooling.
