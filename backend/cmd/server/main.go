package main

import (
	"desklink/internal/server"
	"fmt"
	"log"
	"net"
	"net/http"
	"os/exec"
	"runtime"

	"github.com/skip2/go-qrcode"
)

func main() {

	ip := getLocalIP()
	fmt.Printf("🚀 Server running on: %s:8080\n", ip)

	err := qrcode.WriteFile(ip, qrcode.Medium, 256, "connect_qr.png")
	if err != nil {
		log.Println("Could not generate QR code:", err)
	} else {
		fmt.Println("📷 QR Code generated! Opening it now...")
		openFile("connect_qr.png")
	}

	http.HandleFunc("/ws", server.HandleConnections)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func getLocalIP() string {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return ""
	}

	var bestCandidate string

	for _, address := range addrs {
		if ipnet, ok := address.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				ip := ipnet.IP.String()

				if len(ip) >= 7 && ip[0:7] == "169.254" {
					continue
				}

				if len(ip) >= 7 && ip[0:7] == "192.168" {
					return ip
				}

				if len(ip) >= 3 && ip[0:3] == "10." {
					bestCandidate = ip
				}

				if bestCandidate == "" {
					bestCandidate = ip
				}
			}
		}
	}
	if bestCandidate != "" {
		return bestCandidate
	}
	return "localhost"
}

func openFile(path string) {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("rundll32", "url.dll,FileProtocolHandler", path)
	} else {
		cmd = exec.Command("open", path)
	}
	cmd.Start()
}
