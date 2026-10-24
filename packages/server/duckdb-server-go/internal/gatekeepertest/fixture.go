package gatekeepertest

import (
	"context"
	"database/sql/driver"
	"errors"
	"os"
	"path/filepath"
	"strings"

	"github.com/uwdata/mosaic/packages/server/duckdb-server-go/pkg/extensions"
)

func Path() (string, error) {
	path := os.Getenv("MOSAIC_GATEKEEPER_EXTENSION")
	if path == "" {
		return "", errors.New("gatekeeper fixture must be supplied by Bazel")
	}
	return filepath.Join(os.Getenv("TEST_SRCDIR"), path), nil
}

func DSN(value string) string {
	if value == "" {
		value = ":memory:"
	}
	separator := "?"
	if strings.Contains(value, "?") {
		separator = "&"
	}
	return value + separator + "allow_unsigned_extensions=true"
}

func Load(ctx context.Context, execer driver.ExecerContext) error {
	path, err := Path()
	if err != nil {
		return err
	}
	return extensions.InstallAndLoadFile(ctx, execer, path)
}
