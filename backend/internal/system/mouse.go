package system

import (
	"unsafe"
)

var (
	procSetCursorPos = user32.NewProc("SetCursorPos")
	procGetCursorPos = user32.NewProc("GetCursorPos")
	procMouseEvent   = user32.NewProc("mouse_event")
)

type POINT struct {
	X, Y int32
}

func MoveMouseRelative(dx, dy int) {
	var pt POINT
	procGetCursorPos.Call(uintptr(unsafe.Pointer(&pt)))

	newX := pt.X + int32(dx)
	newY := pt.Y + int32(dy)

	procSetCursorPos.Call(uintptr(newX), uintptr(newY))
}

func LeftClick() {
	procMouseEvent.Call(0x0002, 0, 0, 0, 0)
	procMouseEvent.Call(0x0004, 0, 0, 0, 0)
}

func RightClick() {
	procMouseEvent.Call(0x0008, 0, 0, 0, 0)
	procMouseEvent.Call(0x0010, 0, 0, 0, 0)
}
