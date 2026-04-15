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

== Current progress

Unfortunately, I easily get distracted. However, I had nonetheless done
research regarding ollama and I've done some of the improvements.
Describing them one at a time:

=== TODO

TODO

== Challenges and observations

TODO

== Next steps

I should do more of the improvements and come up with some more.
Additionally, I should probably get some feedback on what sort of
code quality tools are even nice; maybe our instructor has some set of
preferred tooling.

#pagebreak()

= Appendix: learning episode questions

TODO! Follow the EdStem post and provide some data for the AI model /s
