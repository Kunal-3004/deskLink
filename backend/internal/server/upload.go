package server

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
)

func HandleFileUpload(w http.ResponseWriter, r *http.Request) {

	r.ParseMultipartForm(500 << 20)

	file, handler, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "Error retrievinf file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	homeDir, err := os.UserHomeDir()
	if err != nil {
		http.Error(w, "Could not find home directory", http.StatusInternalServerError)
		return
	}

	downloadPath := filepath.Join(homeDir, "Downloads", handler.Filename)

	dst, err := os.Create(downloadPath)
	if err != nil {
		http.Error(w, "Could not create file", http.StatusInternalServerError)
		return
	}

	defer dst.Close()

	if _, err := io.Copy(dst, file); err != nil {
		http.Error(w, "Error saving file", http.StatusInternalServerError)
		return
	}

	fmt.Printf("📂 File Received: %s\n", handler.Filename)
	fmt.Fprintf(w, "Successfully uploaded file")
}
