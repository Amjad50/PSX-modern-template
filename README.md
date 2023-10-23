# PSX Project Template using PSYQ

This project provides a template that you can start from to create your own PSX game/program.

#### The main issues this project fixes
- It provides you the original **PSYQ** libraries and functions.
- The libraries are in a modern form (`.a`) files, which can be linked with modern compilers (ex.`gcc/clang`).
  Which will help since you are not required to fight with PSYQ toolchain anymore (except for creating TIM files and audio files).
- Get fancy code completion from `clangd` or something similar.

### How to use
You can compile the program with
```
sh make.sh
```
This allows you to compile easily without needing to install any `mipsel` toolchains.

### Adding libraries
When adding a header to your code
```c
#include <libgs.h>
```
You might have a compilation error because it can't find some of the symbols.

If you got that, then probably you need to add these libraries into the [Makefile](./Makefile), You can do it here
```Makefile
LIBS += -lgs
```
Sometimes, a library uses code from another library, so you have to include that as well.

Same thing in the includes, the headers are not including dependencies headers, so, sometimes when you include a header,
you will get compilation error because it can't find the types/functions, and that's because the header is relying on other headers, which **MUST** be included before it (the formatter might play with the sorting, which is bad here).

> **Note:** the issue above could be solved by adding these includes manually, but I think that figuring out these headers will help you know which libraries to include the [Makefile](./Makefile) as well.

#### An example
If you want to use `GsInitGraph` from the `gs` library. You need to include these headers
```c
#include <stddef.h>
#include <libetc.h>
#include <libgte.h>
#include <libgpu.h>
#include <libgs.h>
```
And these libraries
```Makefile
LIBS += -letc -lgte -lgpu -lgs 
```

### Completion and `compile_commands.json`

Since building is happening inside `docker`, I'm not sure if there is a way to get the `compile_commands.json` file.

But I have included a template file [compile_commands.json](./compile_commands.json) where the `directory` is empty.
This won't work, but you can just put the directory of your project in that space, then all should work.

### Adding multiple `C` files
When adding a new `C` file, you should modify 2 places.
1) In the [Makefile](./Makefile) add the `<file>.o`
   ```Makefile
   main.elf: main.o extra1.o extra2.o ...    
   ```
2) In the [compile_commands.json](./compile_commands.json) file, to add a new entry so that you get completion for it.
   You can just copy the `main.c` entry and then modify the file to `extra1.c` or `extra2.c`, etc...

### Configuring the CD ROM and adding more files
The CD ROM is being built using [mkpsxiso](https://github.com/Lameguy64/mkpsxiso), so you can look there for more documentations. I just included a prebuilt binary in the repo to make it easier to use.

You can modify [mkpsxiso.xml](./mkpsxiso.xml) and [system.cnf](./system.cnf) as you need.

### Future Plans
I'm planning to add a `CI` setup to this template as well, using a headless emulator that can test based on some stuff. So we can have test driven development for the PSX :D.

We can expand [my PSX emulator](https://github.com/Amjad50/PSX) to have this feature.

### Acknowledgements
- The `.a` files were generated using https://gitlab.com/jype/psyq2elf from the original `PSYQ` binaries
- The docker image used is created for the https://github.com/Lameguy64/PSn00bSDK project, but since it doesn't have all the features yet, we can use the toolchain only.

### Enjoy
Any improvements for this "template" projects are always welcome.