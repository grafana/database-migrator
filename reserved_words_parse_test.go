package main

import (
	"testing"
)

func TestGetReservedWords(t *testing.T) {
	parsedWords := map[string]bool{"ZONE": true, "WINDOW": true, "SQL_TSI_MINUTE": true}
	// test that the reserved words are parsed correctly
	textfile := `
SQL_TSI_MINUTE

Z

ZONE; added in 8.0.22 (nonreserved)

W

WINDOW (R); added in 8.0.2 (reserved)
`
	reservedWords := getReservedWords([]byte(textfile))
	for _, word := range reservedWords {
		if !parsedWords[word] {
			t.Errorf("word %s not parsed correctly", word)
		}
	}
}
