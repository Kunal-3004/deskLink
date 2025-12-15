package server

import (
	"bytes"
	"context"
	"desklink/internal/system"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"image/jpeg"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/gorilla/websocket"
	"github.com/kbinani/screenshot"
	"github.com/nfnt/resize"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

type Message struct {
	Type    string `json:"type"`
	Payload string `json:"payload"`
	DX      int    `json:"dx"`
	DY      int    `json:"dy"`
}

func HandleConnections(w http.ResponseWriter, r *http.Request) {
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Fatal(err)
	}
	defer ws.Close()

	system.InitClipboard()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go func() {
		updates := system.WatchClipboard(ctx)
		for text := range updates {
			ws.WriteJSON(map[string]string{
				"type": "clipboard",
				"text": string(text),
			})
		}
	}()

	go func() {
		for {
			stats := system.GetStats()
			err := ws.WriteJSON(map[string]interface{}{
				"type": "stats",
				"cpu":  stats.CPU,
				"ram":  stats.RAM,
			})
			if err != nil {
				return
			}
			time.Sleep(1 * time.Second)
		}
	}()

	for {
		var msg map[string]interface{}

		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Printf("Client disconnected: %v", err)
			break
		}

		msgType, ok := msg["type"].(string)
		if !ok {
			continue
		}

		switch msgType {

		case "command":
			if payload, ok := msg["payload"].(string); ok {
				if payload == "ping" {
					ws.WriteJSON(map[string]string{
						"type":    "notification",
						"message": "Pong! 🏓 PC is alive.",
					})
				} else {
					system.ExecuteCommand(payload)
				}
			}

		case "type":
			if text, ok := msg["payload"].(string); ok {
				system.TypeString(text)
			}

		case "key":
			if key, ok := msg["payload"].(string); ok {
				system.HandleSpecialKey(key)
			}

		case "clipboard":
			if text, ok := msg["payload"].(string); ok {
				system.WriteClipboard(text)
			}

		case "mouse":
			dx := int(msg["dx"].(float64))
			dy := int(msg["dy"].(float64))
			system.MoveMouseRelative(dx, dy)

		case "click":
			system.LeftClick()

		case "right_click":
			system.RightClick()

		case "get_apps":
			psScript := "@(Get-Process | Where-Object {$_.MainWindowTitle -ne ''} | Select-Object MainWindowTitle, Id, ProcessName | ConvertTo-Json -Compress)"
			cmd := exec.Command("powershell", "-NoProfile", "-Command", psScript)
			output, err := cmd.CombinedOutput()

			if err != nil {
				log.Println("Error getting apps:", err)
				continue
			}

			ws.WriteJSON(map[string]interface{}{
				"type": "apps_list",
				"data": string(output),
			})

		case "activate_app":
			var pidStr string
			if f, ok := msg["payload"].(float64); ok {
				pidStr = fmt.Sprintf("%d", int(f))
			} else {
				pidStr = fmt.Sprintf("%v", msg["payload"])
			}

			psScript := fmt.Sprintf(`
				$code = '
				[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
				[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
				'
				$type = Add-Type -MemberDefinition $code -Name Win32 -Namespace Win32 -PassThru
				
				$proc = Get-Process -Id %s -ErrorAction SilentlyContinue
				if ($proc) {
					$handle = $proc.MainWindowHandle
					if ($handle -ne [IntPtr]::Zero) {
						$type::ShowWindow($handle, 9) 
						$type::SetForegroundWindow($handle)
					}
				}
			`, pidStr)

			exec.Command("powershell", "-NoProfile", "-Command", psScript).Start()
			log.Printf("🚀 Force Switching to PID: %s", pidStr)

		case "kill_app":
			if payload, ok := msg["payload"]; ok {
				pid := fmt.Sprintf("%v", payload)
				exec.Command("taskkill", "/F", "/PID", pid).Start()
				log.Printf("Killed App PID: %s", pid)
			}

		case "get_screen":
			n := screenshot.NumActiveDisplays()
			if n <= 0 {
				return
			}

			bounds := screenshot.GetDisplayBounds(0)
			img, err := screenshot.CaptureRect(bounds)
			if err != nil {
				return
			}

			resizedImg := resize.Resize(800, 0, img, resize.Bilinear)

			buf := new(bytes.Buffer)
			jpeg.Encode(buf, resizedImg, &jpeg.Options{Quality: 50})

			encodedStr := base64.StdEncoding.EncodeToString(buf.Bytes())

			ws.WriteJSON(map[string]interface{}{
				"type": "screen_frame",
				"data": encodedStr,
			})

		case "mouse_move_absolute":
			payload, ok := msg["payload"].(map[string]interface{})
			if !ok {
				continue
			}

			getFloat := func(v interface{}) float64 {
				switch i := v.(type) {
				case float64:
					return i
				case int:
					return float64(i)
				default:
					return -1.0
				}
			}

			percentX := getFloat(payload["x"])
			percentY := getFloat(payload["y"])

			screenWidth, screenHeight := system.GetScreenSize()
			targetX := int(percentX * float64(screenWidth))
			targetY := int(percentY * float64(screenHeight))

			system.MoveMouseAbsolute(targetX, targetY)

		case "get_files":
			path := ""
			if p, ok := msg["payload"].(string); ok {
				path = p
			}

			var fileList []map[string]interface{}

			if path == "" {
				for _, drive := range "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
					drivePath := string(drive) + ":\\"
					f, err := os.Open(drivePath)
					if err == nil {
						fileList = append(fileList, map[string]interface{}{
							"name": drivePath,
							"type": "drive",
							"path": drivePath,
						})
						f.Close()
					}
				}

				jsonBytes, _ := json.Marshal(fileList)
				ws.WriteJSON(map[string]interface{}{
					"type":         "file_list",
					"current_path": "",
					"data":         string(jsonBytes),
				})
				continue
			}

			entries, err := os.ReadDir(path)
			if err != nil {
				ws.WriteJSON(map[string]string{
					"type":    "notification",
					"message": "❌ Access Denied: " + path,
				})
				continue
			}

			parent := filepath.Dir(path)
			if parent == path {
				parent = ""
			}

			fileList = append(fileList, map[string]interface{}{
				"name": "..",
				"type": "back",
				"path": parent,
			})

			for _, e := range entries {
				fullPath := filepath.Join(path, e.Name())
				entryType := "file"
				if e.IsDir() {
					entryType = "folder"
				}

				fileList = append(fileList, map[string]interface{}{
					"name": e.Name(),
					"type": entryType,
					"path": fullPath,
				})
			}

			jsonBytes, _ := json.Marshal(fileList)
			ws.WriteJSON(map[string]interface{}{
				"type":         "file_list",
				"current_path": path,
				"data":         string(jsonBytes),
			})

		case "open_file":
			if path, ok := msg["payload"].(string); ok {
				exec.Command("cmd", "/C", "start", "", path).Start()
			}
		}
	}
}
