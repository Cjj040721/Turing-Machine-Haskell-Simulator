<div align="center">

# Turing Machine Haskell Simulator

**A small Turing machine engine with a custom parser, tape zipper, and Gloss visualisation.**

Implemented in Haskell with classical, left-restricted, and busy-beaver machine variants, command-line execution, and an interactive graphical mode.

[![Haskell](https://img.shields.io/badge/Haskell-9.6-5E5086?logo=haskell&logoColor=white)](https://www.haskell.org/)
[![Cabal](https://img.shields.io/badge/Cabal-Build-0072B2)](https://www.haskell.org/cabal/)
[![Gloss](https://img.shields.io/badge/Graphics-Gloss-2AA887)](http://gloss.ouroborus.net/)
[![Verification](https://img.shields.io/badge/Build_%26_M1-Verified-6E56CF)](#verification)

[Features](#features) · [Build](#build) · [Run](#run) · [Machine Descriptions](#machine-descriptions) · [Verification](#verification)

</div>

---

## 1. Features

- Custom parser for Turing machine descriptions.
- Tape zipper and configuration model in `Tape.hs` and `Types.hs`.
- Command-line execution with accept/reject results and a 50,000-step limit.
- Graphical tape and state visualisation using Gloss.
- Classical, left-restricted, and busy-beaver variants.
- Three included descriptions under `desc/`.
- Strict GHC warning settings enabled in the Cabal file.

## 2. Build

### Requirements

- GHC 9.6 or a compatible version supported by the Cabal constraints
- Cabal 3.x
- Gloss and its native graphics dependencies, installed through Cabal

```bash
git clone https://github.com/Cjj040721/Turing-Machine-Haskell-Simulator.git
cd Turing-Machine-Haskell-Simulator
cabal update
cabal build
```

`dist-newstyle/` is generated locally and is not committed.

<a id="run"></a>
## 3. Run

The executable is named `coursework` and expects three arguments:

```text
coursework <tm_description_file_path> <input_string> <M1|M2>
```

Run the first included machine in command-line mode:

```bash
cabal run coursework -- desc/example_1.desc 0 M1
# ACCEPTED

cabal run coursework -- desc/example_1.desc 1 M1
# REJECTED
```

Open the same machine in graphical mode:

```bash
cabal run coursework -- desc/example_1.desc 0 M2
```

M2 opens a Gloss window; close the window to exit. Non-busy-beaver inputs are binary strings with a maximum length of 19 characters.

<a id="machine-descriptions"></a>
## 4. Machine Descriptions

The parser reads the format used by the included `.desc` files:

```text
initialState=q0
acceptState=qa
rejectState=qr
variant=CLASSICAL
rules=q0,0,qa,0,RIGHT<>q0,1,qr,1,RIGHT<>q0,*,qr,*,RIGHT
```

The rule fields are source state, tape symbol, destination state, written symbol, and movement direction. See `desc/example_1.desc`, `example_2.desc`, and `example_3.desc` for working input files.

## 5. Repository Structure

```text
Turing-Machine-Haskell-Simulator/
├── app/Main.hs                 # CLI argument validation and M1 / M2 entry points
├── src/
│   ├── Types.hs                # Machine, configuration, and variant types
│   ├── Parser.hs               # Description parser
│   ├── Tape.hs                 # Tape zipper
│   ├── TM.hs                   # Execution model
│   └── Gui.hs                  # Gloss visualisation
├── desc/                       # Included machine descriptions
├── turing-machine-simulator.cabal
├── CHANGELOG.md
└── LICENSE
```

<a id="verification"></a>
## 6. Verification

| Check | Result |
|---|---|
| `cabal build` | Passed on GHC 9.6.7 / Cabal 3.12.1.0 |
| `example_1.desc` with input `0`, M1 | `ACCEPTED` |
| `example_1.desc` with input `1`, M1 | `REJECTED` |
| Graphical mode | Implemented with Gloss; not part of the headless verification |

The project has no automated test suite. Verification uses a clean Cabal build and real command-line runs.

## 7. Licence

This project is available under the **BSD 3-Clause Licence**. See [LICENSE](LICENSE).

---

<div align="center">

**Turing Machine Haskell Simulator — Parse a machine. Run the tape. Watch the state evolve.**

</div>
