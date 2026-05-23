# ASM Runner (VS Code Extension)

Run Linux Assembly directly from VS Code.

## What it does

Adds two commands:

- `ASM Runner: Build Current File`
- `ASM Runner: Build && Run Current File`

Supported file types:

- `.asm`: built using `nasm -f elf64` and linked with `ld`
- `.s`: built using `gcc -no-pie`

Output files are generated under `build/` by default (next to the source file).

## Requirements

Linux tools must be installed and on PATH:

- `nasm`
- `ld` (binutils)
- `gcc` (for `.s` files)

## Extension setting

- `asmRunner.outputDirectory` (default: `build`)

## Local usage

1. Open this folder in VS Code: `asm/asm-runner-extension`
2. Run `npm install`
3. Run `npm run compile`
4. Press `F5` to launch Extension Development Host
5. In that new window, open any `.asm` or `.s` file
6. Run command palette and execute one of the ASM Runner commands

## Notes

- This extension currently targets Linux command-line toolchains.
- If you want support for debug builds or custom link flags, extend command construction in `src/extension.ts`.
