module Types (
    Symbol(..),
    symbolToString,
    stringToSymbol,
    State,
    Movement(..),
    stringToMovement,
    Rule(..),
    TMVariant(..),
    stringToVariant,
    TMDescription(..),
    Tape,
    TapeZipper(..),
    Config(..)
) where

import Data.List (intercalate) -- For showing TapeZipper

-- | Symbols on the tape
data Symbol = Zero | One | X | Blank deriving (Eq, Read, Show)

symbolToString :: Symbol -> String
symbolToString Zero  = "0"
symbolToString One   = "1"
symbolToString X     = "X"
symbolToString Blank = "*"

stringToSymbol :: String -> Maybe Symbol
stringToSymbol "0" = Just Zero
stringToSymbol "1" = Just One
stringToSymbol "X" = Just X
stringToSymbol "*" = Just Blank
stringToSymbol _   = Nothing

-- | State of the TM
type State = String

-- | Head movement
data Movement = LEFT | RIGHT | RESET deriving (Eq, Read, Show)

stringToMovement :: String -> Maybe Movement
stringToMovement "LEFT"  = Just LEFT
stringToMovement "RIGHT" = Just RIGHT
stringToMovement "RESET" = Just RESET
stringToMovement _       = Nothing

-- | Transition rule: (currentState, readSymbol) -> (nextState, writeSymbol, movement)
data Rule = Rule {
    rCurrentState :: State,
    rReadSymbol   :: Symbol,
    rNextState    :: State,
    rWriteSymbol  :: Symbol,
    rMove         :: Movement
} deriving (Eq)

instance Show Rule where
    show (Rule cs rs ns ws m) =
        cs ++ "," ++ symbolToString rs ++ " -> " ++
        ns ++ "," ++ symbolToString ws ++ "," ++ show m

-- | TM variants
data TMVariant = CLASSICAL | LRTM | BBTM deriving (Eq, Read, Show)

stringToVariant :: String -> Maybe TMVariant
stringToVariant "CLASSICAL" = Just CLASSICAL
stringToVariant "LRTM"      = Just LRTM
stringToVariant "BBTM"      = Just BBTM
stringToVariant _           = Nothing

-- | Full TM description
data TMDescription = TMDescription {
    tmInitialState :: State,
    tmAcceptState  :: State,
    tmRejectState  :: State,
    tmVariant      :: TMVariant,
    tmRules        :: [Rule]
} deriving (Show)

-- | Tape representation (list of symbols)
type Tape = [Symbol]

-- | Tape with a focused head position (Zipper)
-- Left part is reversed for efficient additions/removals from the "head" side
data TapeZipper = TapeZipper {
    tzLeft   :: [Symbol], -- Symbols to the left of the head, reversed
    tzFocus  :: Symbol,   -- Symbol under the head
    tzRight  :: [Symbol], -- Symbols to the right of the head
    tzIndex  :: Int       -- Current 0-based index of the head
} deriving (Eq)

instance Show TapeZipper where
    show (TapeZipper l f r idx) =
        "TapeZipper (Left: " ++ show (map symbolToString (reverse l)) ++
        ", Focus: " ++ symbolToString f ++ " @idx " ++ show idx ++
        ", Right: " ++ show (map symbolToString r) ++ ")" ++
        "\nFull Tape: " ++ intercalate " " (map symbolToString (tapeZipperToTapeList (TapeZipper l f r idx)))

-- Helper to convert TapeZipper back to a flat list for display or other purposes
tapeZipperToTapeList :: TapeZipper -> [Symbol]
tapeZipperToTapeList (TapeZipper l f r _) = reverse l ++ [f] ++ r


-- | Configuration of the TM at a point in time
data Config = Config {
    cfgState :: State,
    cfgTape  :: TapeZipper,
    cfgDesc  :: TMDescription -- Keep a reference to the TM description for rule lookup etc.
} deriving (Show)