package main

import (
	"desklink/internal/server"
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/ws", server.HandleConnections)

	hostname, _ := os.Hostname()
	fmt.Printf("🚀 DeskLink Agent Running on %s:8080\n", hostname)
	fmt.Println("👉 Connect your phone to the same WiFi and use your PC's IP Address.")

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
