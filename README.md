# PROJECTS

## Overview

This repository contains multiple hardware projects, each with its own source files and documentation. Each project is organized in its own directory or as a major file in the root, with supporting diagrams and explanations.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [MIPS Project](#mips-project)
- [UART Project](#uart-project)
- [Code Explanation](#code-explanation)
- [Diagrams](#diagrams)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

## Features

- Multiple hardware design projects in one repository.
- Well-documented source code and modules.
- Supporting diagrams for architecture and data flow.
- Example outputs and references for clarity.

## Project Structure

```plaintext
PROJECTS/
├── src/                # Other source code files
├── mips.v              # MIPS processor top-level Verilog file 
├── uart/               # UART project directory
│   ├── uart_xmt.sv     # UART transmitter module
│   ├── uart_rcv.sv     # UART receiver module
│   └── uart.sv         # Top-level UART module
├── info.pdf            # Diagrams for architecture/workflow
├── outputs.pdf         # Output diagrams and data flow
├── README.md           # Project documentation
└── ...                 # Other files/folders
```

## MIPS Project

The `mips.v` file implements a standalone MIPS processor in SystemVerilog and Verilog.  
Features:
- Implements a basic MIPS CPU architecture.
- Suitable for simulation, learning, and extension.
- See comments in `mips.v` and `info.pdf` for architecture and workflow details.

## UART Project

The `uart` directory contains a complete Universal Asynchronous Receiver/Transmitter (UART) implementation:

- **uart_xmt.sv**: UART transmitter module—serializes data for transmission.
- **uart_rcv.sv**: UART receiver module—deserializes incoming serial data.
- **uart.sv**: Top-level UART module—connects the transmitter and receiver.

Features:
- Modular design for easy reuse and integration.
- Configurable baud rates and parameters.
- See diagrams in `info.pdf` for module relationships.

## Code Explanation

- Each project (MIPS, UART) is organized and documented separately.
- Source files contain comments for code clarity.
- Diagrams provide additional explanation for architecture and workflows.

## Diagrams

- **Architecture/Workflow:** See [`info.pdf`](./info.pdf)
- **Output/Data Flow:** See [`outputs.pdf`](./outputs.pdf)

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/SANGEETH-KUMAR07/PROJECTS.git
   cd PROJECTS
   ```

2. **Explore the projects:**
   - For the MIPS processor: open and review `mips.v`
   - For the UART modules: see the `uart/` directory

3. **View diagrams:**  
   Open `info.pdf` and `outputs.pdf` for project visuals.

## Contributing

Contributions are welcome! Open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---
For questions, see code comments and diagrams in the repository.
