package main

import (
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
)

const module = "github.com/uwdata/mosaic/packages/server/duckdb-server-go"

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run() error {
	args := os.Args[1:]
	sdk, source, engine, config := args[0], args[1], args[2], args[3]
	sourceCount, err := strconv.Atoi(args[4])
	if err != nil {
		return err
	}
	sources := args[5 : 5+sourceCount]
	compiler := args[5+sourceCount]
	cgoFiles := args[6+sourceCount:]
	work, err := os.MkdirTemp(os.Getenv("TEST_TMPDIR"), "go-lint-")
	if err != nil {
		return err
	}
	defer func() { _ = os.RemoveAll(work) }()
	gopath := filepath.Join(work, "gopath")
	if err := filepath.WalkDir(source, func(path string, entry fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() {
			return nil
		}
		relative, err := filepath.Rel(source, path)
		if err != nil {
			return err
		}
		return copyFile(path, filepath.Join(gopath, relative))
	}); err != nil {
		return err
	}
	project := filepath.Join(gopath, "src", module)
	for _, file := range sources {
		relative, err := filepath.Rel(filepath.Dir(config), file)
		if err != nil {
			return err
		}
		if err := copyFile(file, filepath.Join(project, relative)); err != nil {
			return err
		}
	}
	for i := 0; i < len(cgoFiles); i += 2 {
		if err := copyFile(cgoFiles[i], filepath.Join(gopath, "src", cgoFiles[i+1])); err != nil {
			return err
		}
	}
	sdkRoot := filepath.Dir(filepath.Dir(sdk))
	command := exec.Command(engine, "run", "--config", config, "./...")
	command.Dir = project
	command.Stdout, command.Stderr = os.Stdout, os.Stderr
	command.Env = []string{
		"PATH=" + filepath.Dir(sdk) + string(os.PathListSeparator) + filepath.Dir(compiler),
		"HOME=" + work,
		"TMPDIR=" + work,
		"GOROOT=" + sdkRoot,
		"GOPATH=" + gopath,
		"GOCACHE=" + filepath.Join(work, "go-cache"),
		"GOLANGCI_LINT_CACHE=" + filepath.Join(work, "lint-cache"),
		"GO111MODULE=off", "GOENV=off", "GOTOOLCHAIN=local", "GOWORK=off",
		"GOPROXY=off", "GOSUMDB=off", "GOTELEMETRY=off", "CGO_ENABLED=1", "CC=" + compiler,
	}
	return command.Run()
}

func copyFile(source, destination string) error {
	content, err := os.ReadFile(source)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(destination), 0o755); err != nil {
		return err
	}
	return os.WriteFile(destination, content, 0o644)
}
