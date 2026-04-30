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

I had many original ideas, all of which are discussed and solved here;
the `readline` change is the only change not inspired by my ideas.
Additionally, I did not accomplish my goal of improving the test suite.
Due to iterating through all these ideas, I accomplished all my
original goal of making TokenSmith easier to contribute to!

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
`from llama_cpp import Llama` has been supplemented with
`import ollama`. I additionally added basic `FakeLlama` interfaces to
avoid breaking things with the new interface `ollama` provides.
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

== Better prompts for chat mode

Currently `uv run -m src.main chat` uses `input` to get user input, to
then to the model. However, this can be improved. I added an
`import readline` to the top of the file, which ensures that basic
keyboard shortcuts start working (for example option+delete for a
single word deletion) and that up arrows work.

This is technically not within scope for my project, but it's a single
line change and a very obscure technique! This could also use e.g.
`rich.prompt` if someone wants to follow up on this, since `rich` is
already a dependency for the markdown viewing in the terminal.

== Future work

There's many future directions for work to go! For one, I left any type
errors alone. Many of them simply require some extra type hints. For
example, the first one `uv run pyright` shows is:

```
.../TokenSmith/src/api_server.py:137:17 - error: "save_chat_log" is not a known attribute of "None" (reportOptionalMemberAccess)
```

This can be fixed by changing `_logger = None` to
`_logger: RunLogger | None = None`, as well as adding an
`assert _logger is not None` above the `_logger.save_chat_log` usage.
Alternatively, if the `except Exception:` is meant to catch the
`AttributeError`, the code could add
`if _logger is not None: return False` and remove the `try`/`except`.
Many other type errors would be this trivial to solve and those that
require larger refactors can be silenced by adding a `# type: ignore`.

I also didn't address all lint errors. This is because there's so many
that fixing them would lead to merge conflicts. However,
`uv run ruff --fix` will take the error count from 90 to 30. The
remaining ones are likely significantly easier the type errors to fix.
For example, the first is:

```
E402 Module level import not at top of file
  --> src/api_server.py:19:1
   |
17 |     sys.path.insert(0, str(_project_root))
18 |
19 | from fastapi import FastAPI, HTTPException
   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
20 | from fastapi.middleware.cors import CORSMiddleware
21 | from fastapi.responses import StreamingResponse
```

This could be fixed by removing the `sys.path` modification logic
directly above. One possible alternative is to, for example, make
TokenSmith a proper package, allowing `import tokensmith` instead of
`import src`.

In this same vein, I didn't go through all possible lint settings to
choose what would work best for TokenSmith. That can only be done after
existing lint errors are gone! For future use, I've typically used this
configuration for ruff:

```toml
fix = true
preview = true

[lint]
extend-select = [
    "I",  # isort
    "RUF",  # ruff specific, generally helpful
    "UP", "FURB", "FLY", "PTH",  # use newest idioms
    "N", "A",  # names
    "SIM", "RET", "PIE",  # simplification stuff
    "T20",  # all output should use rich
    "B",  # probably a bug
    # TODO: "ERA",  # remove commented out code
]
```

Once all this linting is setup, some people may dislike that changes
take round trips to CI to notice. In this case, maybe `pre-commit`
would help: `pre-commit` adds a `git` pre-commit hook so that all
changes can get checked before getting committed! Concretely, this
would include `ruff check` and `ruff format`, though not the type
checker (since the type checker needs all the dependencies).

I intentionally shoved Ollama into the interface `llama_cpp` provides,
even if that required returning an ad-hoc dictionary. This way, I could
avoid breaking anything, which justified testing less. However, someone
with more time could instead construct a shared interface that doesn't
need to do so much hacky things (constructing a
`{'data': [{'embedding': embedding_vector}]}` is probably the least
hacky thing I had to do!). Additionally, this holistic view could allow
more `ollama` capabilities to be used. For example, `ollama` allows
embedding to be batched! This is in contrast to `llama_cpp`, which
according to in-code comments does not support this capability.
