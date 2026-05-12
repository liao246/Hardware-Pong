# Hardware Pong ASIC

A custom hardware implementation of the classic game Pong, designed from the ground up to operate within a strict **1,000 standard cell limit**. This project spans the entire hardware design lifecycle—from high-level game mechanics and micro-architectural specifications, through FPGA prototyping, all the way to RTL-to-GDSII physical design and tapeout.

### 🎥 Hardware Demo

https://github.com/user-attachments/assets/642d3d36-c565-4d1c-9674-19c36439427d

## 🚀 Key Features
- **Custom Game Engine:** RTL-based game physics supporting dynamic mechanics and collision-based speed scaling.
- **Combinational VGA Rendering:** Optimized, coordinate-based VGA rendering designed specifically to minimize standard cell usage.
- **Rigorous Prototyping:** Playability and logic verified on an iCE40 FPGA prior to synthesis.
- **ASIC Tapeout Ready:** Fully compliant with DRC (Design Rule Check) and LVS (Layout Versus Schematic) constraints via the OpenLane physical design flow.

## 🕹️ Game Mechanics & Rendering

- **Coordinate-Based Rendering:** To avoid the massive standard cell cost of a frame buffer, the system uses purely combinational logic to render the game. The VGA controller keeps track of the current `(x, y)` pixel being drawn on the screen. The pixel generator simply checks if the current pixel coordinate falls within the mathematical bounds of the ball or either paddle, outputting the correct color in real-time. 
- **Dynamic Ball Acceleration:** The game physics engine continuously tracks the ball's position and velocity vectors. Each time the ball successfully collides with a paddle, the engine increases the ball's velocity magnitude. This dynamic speed scaling naturally ramps up the difficulty of each rally, ensuring fast-paced and competitive gameplay.

## 🛠️ Architecture & Design Flow

This project was architected by a 3-person team, focusing heavily on resource optimization without sacrificing game responsiveness or visual fidelity.

1. **Specification & Architecture:** Translated abstract game rules into comprehensive RTL block diagrams and datapath/FSM specifications.
2. **Resource-Constrained RTL Design:** Developed SystemVerilog modules focusing heavily on combinational logic instead of sequential memory to comfortably meet the 1,000 standard cell limit.
3. **FPGA Prototyping:** Deployed the design onto an iCE40 FPGA to fine-tune game feel, paddle speeds, and collision behaviors in real-time.
4. **Physical Design (Tapeout):** Processed the verified RTL through the OpenLane flow, generating the final GDSII layout for fabrication.

## 📁 Module Overview

The system is broken down into several highly-optimized modules:
- **`fpga_top.sv`**: The top-level wrapper interconnecting game logic, rendering, and input processing.
- **`game_physics.sv`**: The core game engine computing ball vectors, paddle collisions, and dynamic speed scaling.
- **`vga.sv` / `pixel_gen.sv`**: The display subsystem utilizing combinational logic to render the paddle and ball coordinates onto a VGA display.
- **`clk_divider.sv` & Counters**: Timing and synchronization for the VGA signal and game tick rate.
- **`edge_detector.sv`**: Synchronizes and debounces raw player inputs for stable logic evaluation.
