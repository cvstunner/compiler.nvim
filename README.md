Most people (specially beginers) are familiarized with the way visual studio IDE compiles your program without making questions. This package gives you that for all the languages that allow it.

* c
* c++
* c#
* rust
* python

## Purpose
Making compiling an running the program you are writing as painless as possible.

## FAQ

* **How to NeoCompiler know how to compile?** It looks for the conventional entry point file of that lenguage. To achieve this, it searches upwads in the directory tree from the file you are currently editing. It will search for the next file names.

  * c: main.c
  * c++: main.cpp
  * c#: Program.cs
  * rust: main.rs
  * python: __main__.py or main.py (in this order)

* **How do build solution work?** In .NET languages you have the concept of "solution". Building a solution is just a way of saying "Build every program in this repository". To achieve this, NeoCompiler will search in every directory of the repository for the entry point of every program and build it in parallel. It is also possible to run the a program after building the solution by setting `set vim.g.compiler_solution_run="/entrypoint/path"`. It is recommended you manually set the option on neovim, so it can be used per-project.

* **I'm coding a web, how do I run it?** Please don't try to compile/run web languages. For those cases, the solution you are looking for is most likely

  * A way to transpile: toggleterm + termux.
  * A way run the project: Just have the website opened it your browser.
  
This package do not implement any of this directly due to the lack of convention in the way of transpiling/running those projects. If the situation changes and conventions are instaurated, we will implement this it the future.

* **Why is x language not implemented?** We implement all that can be implemented. But if a certain language do not have a conventional entry point, of way of compiling, there is noghint we can do.

* **I know x language that has all of that and it is not supported by NeoCompiler, can I send a PR?** Please, be my guest.