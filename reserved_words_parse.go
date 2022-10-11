package main

import (
	"fmt"
	"os"
	"path"
	"strings"
	"unicode"
)

func main() {
	pwd, err := os.Getwd()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	fmt.Printf("pwd: %s\n", pwd)
	b, err := os.ReadFile(path.Join(pwd, "mysql_reserved_words.txt"))
	if err != nil {
		fmt.Errorf("read file error: %v", err)
	}
	reservedWords := getReservedWords(b)
	fmt.Printf("MYSQL_RESERVED_WORDS=%s\n", fmt.Sprintf("%s", strings.Join(reservedWords, ", ")))
}

func getReservedWords(b []byte) []string {
	reservedWords := []string{}
	for _, line := range strings.Split(string(b), "\n") {
		// empty lines
		if line == "" {
			continue
		}
		if len(line) == 1 {
			// new alphabet character
			continue
		}
		if IsUpper(string(line[0])) {
			parts := strings.Split(line, " ")
			keyword := strings.Trim(parts[0], ";")
			reservedWords = append(reservedWords, keyword)
		}
	}
	return reservedWords
}

func IsUpper(s string) bool {
	for _, r := range s {
		if !unicode.IsUpper(r) && unicode.IsLetter(r) {
			return false
		}
	}
	return true
}
