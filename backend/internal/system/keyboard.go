package system

import (
	"unicode/utf16"
	"unsafe"
)

var (
	procSendInput = user32.NewProc("SendInput")
)

const (
	INPUT_KEYBOARD    = 1
	KEYEVENTF_UNICODE = 0x0004
)

type INPUT struct {
	Type uint32
	Ki   KEYBDINPUT
	Pad  [8]byte
}

type KEYBDINPUT struct {
	WVk         uint16
	WScan       uint16
	DwFlags     uint32
	Time        uint32
	DwExtraInfo uintptr
}

func TypeString(str string) {
	utf16Chars := utf16.Encode([]rune(str))

	for _, char := range utf16Chars {
		sendUnicodeChar(char)
	}
}

func sendUnicodeChar(char uint16) {
	var inputs []INPUT

	inputs = append(inputs, INPUT{
		Type: INPUT_KEYBOARD,
		Ki: KEYBDINPUT{
			WScan:   char,
			DwFlags: KEYEVENTF_UNICODE,
		},
	})
	inputs = append(inputs, INPUT{
		Type: INPUT_KEYBOARD,
		Ki: KEYBDINPUT{
			WScan:   char,
			DwFlags: KEYEVENTF_UNICODE | KEYEVENTF_KEYUP,
		},
	})

	procSendInput.Call(
		uintptr(len(inputs)),
		uintptr(unsafe.Pointer(&inputs[0])),
		uintptr(unsafe.Sizeof(inputs[0])),
	)
}
