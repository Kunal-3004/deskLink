package system

import (
	"log"
	"os/exec"
	"runtime"
	"syscall"
	"time"
)

const (
	KEYEVENTF_EXTENDEDKEY = 0x0001
	KEYEVENTF_KEYUP       = 0x0002
	KEYEVENTF_SCANCODE    = 0x0008

	VK_VOLUME_DOWN = 0xAE
	VK_VOLUME_UP   = 0xAF
	VK_LEFT        = 0x25
	VK_UP          = 0x26
	VK_RIGHT       = 0x27
	VK_DOWN        = 0x28
	VK_B           = 0x42
)

var (
	user32            = syscall.NewLazyDLL("user32.dll")
	procKeybdEvent    = user32.NewProc("keybd_event")
	procMapVirtualKey = user32.NewProc("MapVirtualKeyW")
)

func ExecuteCommand(cmdID string) {
	log.Printf("Executing command: %s", cmdID)

	var cmd *exec.Cmd

	switch cmdID {
	case "calc":
		if runtime.GOOS == "windows" {
			cmd = exec.Command("calc")
		} else {
			cmd = exec.Command("open", "-a", "Calculator")
		}
	case "notepad":
		if runtime.GOOS == "windows" {
			cmd = exec.Command("notepad")
		} else {
			cmd = exec.Command("open", "-a", "TextEdit")
		}

	case "lock":
		if runtime.GOOS == "windows" {
			cmd = exec.Command("rundll32.exe", "user32.dll,LockWorkStation")
		} else {
			cmd = exec.Command("pmset", "displaysleepnow")
		}

	case "shutdown":
		log.Println("Shutdown command received (Simulated)")
		return

	case "vol_up":
		if runtime.GOOS == "windows" {
			pressKeySafe(VK_VOLUME_UP)
			return
		} else {
			cmd = exec.Command("osascript", "-e", "set volume output volume (output volume of (get volume settings) + 10)")
		}
	case "vol_down":
		if runtime.GOOS == "windows" {
			pressKeySafe(VK_VOLUME_DOWN)
			return
		} else {
			cmd = exec.Command("osascript", "-e", "set volume output volume (output volume of (get volume settings) - 10)")
		}

	case "youtube":
		openUrl("https://www.youtube.com")
		return

	case "netflix":
		openUrl("https://www.netflix.com")
		return

	case "next_slide":
		if runtime.GOOS == "windows" {
			pressKeySafe(VK_RIGHT)
		} else {
			cmd = exec.Command("osascript", "-e", "tell application \"System Events\" to key code 124")
		}
		return

	case "prev_slide":
		if runtime.GOOS == "windows" {
			pressKeySafe(VK_LEFT)
		} else {

			cmd = exec.Command("osascript", "-e", "tell application \"System Events\" to key code 123")
		}
		return

	case "black_screen":
		if runtime.GOOS == "windows" {
			pressKeySafe(VK_B)
		} else {
			cmd = exec.Command("osascript", "-e", "tell application \"System Events\" to keystroke \"b\"")
		}
		return

	default:
		log.Println("Unknown command")
		return
	}

	if cmd != nil {
		err := cmd.Start()
		if err != nil {
			log.Printf("Error: %v", err)
		}
	}
}

func HandleSpecialKey(keyName string) {
	switch keyName {
	case "enter":
		pressKeySafe(0x0D) // VK_RETURN
	case "backspace":
		pressKeySafe(0x08) // VK_BACK
	case "tab":
		pressKeySafe(0x09) // VK_TAB
	case "esc":
		pressKeySafe(0x1B) // VK_ESCAPE
	case "win":
		pressKeySafe(0x5B) // VK_LWIN
	case "space":
		pressKeySafe(0x20) // VK_SPACE
	}
}

func pressKeySafe(vk int) {
	scanCode, _, _ := procMapVirtualKey.Call(uintptr(vk), 0)

	procKeybdEvent.Call(
		uintptr(vk),
		scanCode,
		KEYEVENTF_EXTENDEDKEY,
		0,
	)

	time.Sleep(10 * time.Millisecond)

	procKeybdEvent.Call(
		uintptr(vk),
		scanCode,
		KEYEVENTF_EXTENDEDKEY|KEYEVENTF_KEYUP,
		0,
	)
}

func openUrl(url string) {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("rundll32", "url.dll,FileProtocolHandler", url)
	} else {
		cmd = exec.Command("open", url)
	}
	cmd.Start()

}
