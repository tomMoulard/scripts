package precommit_test

import (
	"testing"

	"github.com/magefile/mage/sh"
	"github.com/stretchr/testify/require"
)

func TestGoModTidy(t *testing.T) {
	err := sh.Run("go", "mod", "tidy")
	require.NoError(t, err)

	err = sh.Run("git", "diff", "--exit-code", "go.*")
	require.NoError(t, err)
}
