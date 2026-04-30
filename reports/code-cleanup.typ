#show link: set text(fill: blue)

= Making the TokenSmith repository more maintainable

Code link: #link("https://github.com/horo-fox/TokenSmith"), but you can
see the diff here: #link("https://github.com/georgia-tech-db/TokenSmith/compare/main...horo-fox:TokenSmith:code-cleanup").

Note that once merged, the following two commands should be run
separately:
 - `uv run ruff check --fix`
 - `uv run ruff format`

This is because they will introduce so many changes that performing
them on my fork would mean that my changes couldn't get merged.

#line(length: 100%)

There's always more software engineering practices to follow, so I
decided that the best project for me, considering I am familiar with
the Python ecosystem, is to help improve the setup for TokenSmith.

TODO: original pitch for my idea, original ideas. To quote:
> A re-iteration of your proposed goals, with explicit discussion about
> what progress you have made to date on those goals.

Most notably, I allowed developers to use `uv` instead of `conda`,
which makes installation significantly faster and be more familiar to
any potential contributors. Additionally, `uv` provides lockfiles,
meaning if a build works on one machine, it will work on another at a
later time. This is contra `conda` -- and avoiding bit rot is
important, as shown by the warning in the README about what to do about
numpy v1!

== No longer requiring Anaconda

Anaconda is required for the compiled `llama_cpp`. However, I am not
convinced that is necessary. The ideal would be to switch away, because
Anaconda is gigantic -- ~1GB installer via homebrew! -- and an extra
thing to install and slow: `make build` takes 150.26 seconds. It's also
sometimes confusing, as I ran into an issue while timing setup where
`conda activate tokensmith` was telling me to run `conda init`, but I
had already done that. (the issue was that it was initializing Anaconda
for the wrong shell!)

=== Switching to a precompiled `llama.cpp` on PyPI

Unfortunately, it seems that Python wheels (precompiled packages) are
not advanced enough to support the large array of possibilities that
depend e.g. on your GPU. I don't think this is possible.

=== Shelling out to a precompiled provider

It seems possible to use Ollama. Essentially, anything with a
`from llama_cpp import Llama` has been replaced with `import ollama`.
However, I'm not yet convinced this is the easiest alternative.
Regardless, it's easier to install than worrying about Anaconda and a
Makefile and having to compile llama.cpp.

The simple solution I implemented is to catch `ImportError` and try
using `ollama` instead. This would mean that if someone wants, they
could use `llama.cpp`, but they could also avoid having to compile
anything.

After making this change, I switched the project to be able to use
`uv`. I updated the README for all the necessary commands. Compared to
`make build` which took 150.26 seconds (n=1), `uv sync` with a cold
cache took 9.7 seconds (n=1).

Additionally, when using GitHub Actions (described later), using `uv`
made the overall job take 32 seconds, whereas just `conda`'s install
phase took 5 and a half minutes!

=== One more benefit: lockfiles

It looks like there's a #link("https://github.com/conda/conda-lock")[conda-lock]
project that provides lockfiles for anaconda. However, it appears any
`conda create` would need to then be `conda-lock install`, which is not
great.

Instead, by allowing the project to be installed via `uv`, I've
automatically made lockfiles work.

== Clean up repository

There are many files included in the repository that I don't think
should be. To fix this, I removed the following from git:
 - `.DS_Store` and `index/.DS_Store`
 - `config/config.yaml` (I copied it to `config.example.yaml`)
 - `data/*`

== Linter + autoformatter

Since there was already ruff mentioned in the gitignore, I ensured that
`uv sync` would install ruff, as well as adding the relevant commands
to lint and autoformat to the README. I did *not* run `ruff check --fix`
or `ruff format` to avoid merge conflicts.

== GitHub Actions

I made the GitHub Actions run on every push, as well as added a new job
whose only purpose was to run the linter and autoformatter. Since I
did not run the autoformatter or fixed any lints, this will fail for
now.

== Typechecking

Since I assume most contributors are using VSCode's Python support, I
added `pyright` as a typechecker in GitHub Actions as well as the
README. By default, it should roughly match what VSCode would say.

As part of this, I added any requirements necessary to ensure that all
the imports can get resolved. In addition, I added a `|| true` to CI
for now, since there are 166 errors! This is nonetheless a strict
improvement as now developers can see all the typechecking issues
without having to navigate VSCode.

== Future work

TODO, but:
 - fixing type errors
 - fixing lint errors that don't get autofixed
 - evaluating `pre-commit` so that lint issues/formatting issues don't
   need an extra round-trip to the CI.
 - evaluating the shared interface between `ollama` and `llama_cpp`,
   since I basically cloned `llama_cpp`'s interface.
 - evaluating new capabilities `ollama` provides, like batches for
   embedding
