package system

import (
	"context"

	"golang.design/x/clipboard"
)

func InitClipboard() {
	err := clipboard.Init()
	if err != nil {
		return
	}
}

func WatchClipboard(ctx context.Context) <-chan []byte {
	return clipboard.Watch(ctx, clipboard.FmtText)
}

func WriteClipboard(text string) {
	clipboard.Write(clipboard.FmtText, []byte(text))
}
