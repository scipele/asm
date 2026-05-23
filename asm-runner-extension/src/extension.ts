import * as path from "path";
import * as vscode from "vscode";

function shellQuote(input: string): string {
  return `'${input.replace(/'/g, `'"'"'`)}'`;
}

function getBuildPaths(filePath: string, outputDirName: string): {
  sourceDir: string;
  baseName: string;
  buildDir: string;
  objectPath: string;
  binaryPath: string;
} {
  const sourceDir = path.dirname(filePath);
  const baseName = path.basename(filePath, path.extname(filePath));
  const buildDir = path.join(sourceDir, outputDirName);
  const objectPath = path.join(buildDir, `${baseName}.o`);
  const binaryPath = path.join(buildDir, baseName);

  return { sourceDir, baseName, buildDir, objectPath, binaryPath };
}

function getActiveFilePath(): string | undefined {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    return undefined;
  }

  return editor.document.uri.fsPath;
}

function createTerminal(): vscode.Terminal {
  const terminalName = "ASM Runner";

  const existing = vscode.window.terminals.find((t) => t.name === terminalName);
  if (existing) {
    return existing;
  }

  return vscode.window.createTerminal(terminalName);
}

function getBuildCommand(filePath: string, outputDirName: string): string {
  const ext = path.extname(filePath).toLowerCase();
  const paths = getBuildPaths(filePath, outputDirName);

  const mkdirCmd = `mkdir -p ${shellQuote(paths.buildDir)}`;

  if (ext === ".asm") {
    return [
      mkdirCmd,
      `nasm -f elf64 ${shellQuote(filePath)} -o ${shellQuote(paths.objectPath)}`,
      `ld ${shellQuote(paths.objectPath)} -o ${shellQuote(paths.binaryPath)}`
    ].join(" && ");
  }

  if (ext === ".s") {
    return [
      mkdirCmd,
      `gcc -no-pie ${shellQuote(filePath)} -o ${shellQuote(paths.binaryPath)}`
    ].join(" && ");
  }

  throw new Error("Only .asm and .s files are supported.");
}

function getRunCommand(filePath: string, outputDirName: string): string {
  const paths = getBuildPaths(filePath, outputDirName);
  const buildCmd = getBuildCommand(filePath, outputDirName);

  return `${buildCmd} && ${shellQuote(paths.binaryPath)}`;
}

function runCommandForActiveFile(runMode: "build" | "run"): void {
  const filePath = getActiveFilePath();
  if (!filePath) {
    vscode.window.showErrorMessage("ASM Runner: open an assembly file first.");
    return;
  }

  const ext = path.extname(filePath).toLowerCase();
  if (ext !== ".asm" && ext !== ".s") {
    vscode.window.showErrorMessage("ASM Runner supports only .asm and .s files.");
    return;
  }

  const config = vscode.workspace.getConfiguration("asmRunner");
  const outputDirName = config.get<string>("outputDirectory", "build");

  let cmd: string;
  try {
    cmd = runMode === "build"
      ? getBuildCommand(filePath, outputDirName)
      : getRunCommand(filePath, outputDirName);
  } catch (error) {
    const msg = error instanceof Error ? error.message : "Unknown error";
    vscode.window.showErrorMessage(`ASM Runner: ${msg}`);
    return;
  }

  const terminal = createTerminal();
  terminal.show(true);
  terminal.sendText(cmd, true);
}

export function activate(context: vscode.ExtensionContext): void {
  const buildDisposable = vscode.commands.registerCommand("asmRunner.buildCurrentFile", () => {
    runCommandForActiveFile("build");
  });

  const runDisposable = vscode.commands.registerCommand("asmRunner.runCurrentFile", () => {
    runCommandForActiveFile("run");
  });

  context.subscriptions.push(buildDisposable, runDisposable);
}

export function deactivate(): void {
  // No-op: commands are disposed by VS Code when extension deactivates.
}
