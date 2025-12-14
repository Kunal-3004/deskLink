package server

import (
	"context"
	"desklink/internal/system"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
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
			msg := map[string]string{
				"type": "clipboard",
				"text": string(text),
			}
			ws.WriteJSON(msg)
		}
	}()

	go func() {
		for {
			stats := system.GetStats()
			msg := map[string]interface{}{
				"type": "stats",
				"cpu":  stats.CPU,
				"ram":  stats.RAM,
			}
			if err := ws.WriteJSON(msg); err != nil {
				return
			}
			time.Sleep(1 * time.Second)
		}
	}()

	for {
		var msg Message
		err := ws.ReadJSON(&msg)
		if err != nil {
			break
		}

		switch msg.Type {

		case "command":
			if msg.Payload == "ping" {
				response := map[string]string{
					"type":    "notification",
					"message": "Pong! 🏓 PC is alive.",
				}
				ws.WriteJSON(response)
			} else {
				system.ExecuteCommand(msg.Payload)
			}

		case "type":
			system.TypeString(msg.Payload)

		case "key":
			system.HandleSpecialKey(msg.Payload)

		case "clipboard":
			system.WriteClipboard(msg.Payload)

		case "mouse":
			system.MoveMouseRelative(msg.DX, msg.DY)

		case "click":
			system.LeftClick()

		case "right_click":
			system.RightClick()
		}

	}
}
