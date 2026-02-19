package tree_sitter_basilir_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_basilir "github.com/tree-sitter/tree-sitter-basilir/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_basilir.Language())
	if language == nil {
		t.Errorf("Error loading Basil IR grammar")
	}
}
