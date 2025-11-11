# 🎧 FPGA-Based FIR Digital Audio Filter (MAC Architecture)

## 📄 Overview
This project implements a **real-time audio signal processing system** using **Finite Impulse Response (FIR)** digital filters on the **DE2-115 FPGA board**.  
The design focuses on building **Low-Pass, High-Pass, and Band-Pass filters** using a **Multiply–Accumulate (MAC)**-based architecture to manipulate and enhance live audio signals.  

Unlike conventional systems requiring external audio modules (like PMOD I2S2), this project fully utilizes the DE2-115’s onboard **Wolfson WM8731 Audio Codec**, enabling direct Line-In (input) and Line-Out (output) audio streaming with zero external peripherals.

---

## ⚙️ Features & Functions
- 🎵 **Real-Time Audio Processing:**  
  Line-In → ADC (Wolfson) → FIR Filter → DAC → Headphones.
- 🔀 **10 Selectable Audio Modes:** Controlled via FPGA slide switches.  
  Includes:
  - Volume control (65% / 110%)
  - Right-channel isolation
  - Vocal enhancement (20–25%)
  - Mid-vocal boost
  - Background filtering (high-frequency variants)
  - Bass boost (10–15%)
  - Echo and On/Off modes
- 🎚️ **Filter Types:** Low-Pass, High-Pass, and Band-Pass FIR filters.
- 💡 **User Feedback:**  
  - 7-segment display shows selected mode.  
  - LEDs (0–15) display lower 16 bits of filtered output.  
  - Success/Error LEDs indicate functional status.  
- ⏱️ **Debounced Interface:**  
  Custom debouncer ensures 200 ms stable switching for glitch-free control.

---

## 🧠 System Architecture

The design is fully modular and written in **Verilog HDL**, following a pipelined data flow for real-time synchronization.

### Core Modules
| Module | Function |
|---------|-----------|
| `audioinit.v` | Initializes and configures Wolfson codec |
| `audioadc.v` | Captures analog input and converts to digital |
| `audiodac.v` | Sends processed data back as analog output |
| `i2c.v` | Handles codec communication via I²C protocol |
| `fir_lpf.v`, `fir_hpf.v`, `fir_bpf.v` | Implements LPF, HPF, and BPF using MAC logic |
| `fsm.v` | Controls mode selection and routing logic |
| `debouncer.v` | Provides 200 ms debounce delay for switches |
| `sevenseg.v` | Displays mode number on 7-segment display |
| `audio_output_test.v` | Top-level integration module |

---

## 🔄 Audio Processing Flow

- Audio sampled at 48 kHz codec rate  
- Filter coefficients hardcoded for precise frequency response  
- FSM-based routing controls active filters/effects dynamically  

---

## 📊 Performance Metrics

| Metric | Value | Notes |
|---------|--------|-------|
| Logic Elements (LEs) | ~2,325 (2%) | Out of 114,480 available |
| Registers | 1,305 | Moderate and scalable |
| Setup Slack | +41.6 ns | Excellent timing stability |
| Hold Slack | +0.4 ns | Reliable signal capture |
| Recovery Slack | +96.8 ns | Stable async response |
| Compilation Time | 40 s | Fast synthesis and fitting (Quartus Prime) |

✅ **Only 2%** of total FPGA logic used — highly resource-efficient while supporting **10 real-time functions.**

---

## 🔊 Results & Observations
- **Low-Pass Filter:** Smoothly attenuates high-frequency noise.  
- **High-Pass Filter:** Improves vocal clarity by removing low-frequency hums.  
- **Volume Control:** Accurate real-time scaling (65% and 110%) without distortion.  
- **Vocal Enhancement:** Boosts mid-range frequencies for clarity.  
- **Bass Boost:** Deepens low-end response without clipping.  
- **Latency:** Negligible — verified real-time playback.  
- **Indicator Feedback:** 7-seg and LEDs reflect live operational status.

---


## 🧰 Tools & Environment
- **Hardware:** Terasic DE2-115 FPGA Board  
- **Codec:** Wolfson WM8731  
- **Software:** Intel Quartus Prime, MATLAB, Python (for coefficient generation)  
- **Language:** Verilog HDL  

---

## 🚀 Future Enhancements
- Dynamic filter coefficients for adjustable cutoff frequencies  
- Adaptive filtering for noise reduction  
- Stereo audio processing  
- Real-time waveform visualization (VGA / GUI)

---

## 👨‍💻 Authors
- **Aravinthvasan S** 
B.Tech Electronics & Communication Engineering  
SASTRA Deemed University
Role: Coding, Hardware integration, and Filter designing.

🔗 [GitHub Profile](https://github.com/av1429)

- **Saravana Balaji S** - Testing and documentation.
- **Ashwinramasamy P** - Testing and documentation.

---

## 🪪 License
This project is licensed under the **MIT License** — you are free to use, modify, and distribute with attribution.

---



