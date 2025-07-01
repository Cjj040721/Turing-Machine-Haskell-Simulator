# Turing Machine Simulator

A Turing Machine simulator implemented in Haskell, featuring a custom parser, tape logic, and optional graphical visualization.

## Project Structure

```

turing-machine-simulator/
├── LICENSE
├── CHANGELOG.md
├── turing-machine-simulator.cabal
├── src/
│   ├── Parser.hs       # Module for parsing Turing machine descriptions
│   ├── Types.hs        # Type definitions for machine states and symbols
│   ├── Tape.hs         # Tape implementation logic
│   ├── TM.hs           # Core Turing machine logic
│   └── Gui.hs          # Optional GUI (Gloss/GTK)
└── README.md

````

## Features

- **Custom Turing Machine Descriptions**: Define your machine's states, transitions, and tape.
- **Step-by-Step Execution**: Simulate and visualize state transitions.
- **GUI Support**: Visual interface for tape and head movement.

## Requirements

- [GHC](https://www.haskell.org/ghc/) (Haskell Compiler)
- [Cabal](https://www.haskell.org/cabal/) (or [Stack](https://docs.haskellstack.org/en/stable/README/))

## Installation

```bash
git clone https://github.com/<your-username>/turing-machine-simulator.git
cd turing-machine-simulator
cabal update
cabal build
````

## Usage

Prepare a machine description file like `example.tm`:

```
states: q0, q1, qH
symbols: 0, 1, _
start: q0
accept: qH

q0 0 -> 1 R q0
q0 1 -> 0 R q0
q0 _ -> _ L qH
```

Then run:

```bash
cabal run turing-machine-simulator example.tm
```

If GUI is enabled, a window will show the tape and machine state in real-time.

## Development

* All source code is under the `src/` directory.
* Edit `Parser.hs`, `TM.hs`, and `Gui.hs` to extend functionality.
* Contributions are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

