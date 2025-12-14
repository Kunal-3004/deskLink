package system

import (
	"math"

	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/mem"
)

type SystemStats struct {
	CPU float64 `json:"cpu"`
	RAM float64 `json:"ram"`
}

func GetStats() SystemStats {
	percentages, _ := cpu.Percent(0, false)
	cpuVal := 0.0
	if len(percentages) > 0 {
		cpuVal = percentages[0]
	}

	v, _ := mem.VirtualMemory()

	return SystemStats{
		CPU: math.Round(cpuVal),
		RAM: math.Round(v.UsedPercent),
	}
}
