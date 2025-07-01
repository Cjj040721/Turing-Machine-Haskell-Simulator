module Tape (
    initializeTapeZipper,
    moveHead,
    readCurrentSymbol,
    writeToTape,
    tapeToList,
    maxTapeIndex
) where

import Types

-- | Maximum 0-based index for the tape (19 for a 20-cell tape)
maxTapeIndex :: Int
maxTapeIndex = 19

-- | Tape size
tapeSize :: Int
tapeSize = maxTapeIndex + 1

-- | Creates an initial TapeZipper
initializeTapeZipper :: TMVariant -> String -> TapeZipper
initializeTapeZipper variant inputStr =
    let initialTape = case variant of
            CLASSICAL -> createClassicalLRTMtape inputStr
            LRTM      -> createClassicalLRTMtape inputStr
            BBTM      -> replicate tapeSize Zero -- BBTM ignores inputStr, starts with all Zeros
        initialHeadPos = case variant of
            BBTM -> 9 -- Cell 10 (0-indexed)
            _    -> 0 -- Leftmost for Classical/LRTM
    in listToTapeZipper initialTape initialHeadPos

createClassicalLRTMtape :: String -> Tape
createClassicalLRTMtape inputStr =
    let symbols = map (maybe Blank id . stringToSymbol . (:[])) inputStr -- Convert char to symbol
        paddedInput = take maxTapeIndex (symbols ++ repeat Blank)
    in paddedInput ++ [Blank] -- Last cell is always Blank

listToTapeZipper :: [Symbol] -> Int -> TapeZipper
listToTapeZipper tape headPos
    | headPos < 0 || headPos >= length tape = error "listToTapeZipper: headPos out of bounds"
    | otherwise =
        let (l, rWithFocus) = splitAt headPos tape
        in case rWithFocus of
            (f:rs) -> TapeZipper (reverse l) f rs headPos
            []     -> error "listToTapeZipper: empty tape or invalid split" -- Should not happen if bounds checked

-- | Read symbol under the head
readCurrentSymbol :: TapeZipper -> Symbol
readCurrentSymbol = tzFocus

-- | Write a symbol to the tape at the current head position
writeToTape :: Symbol -> TapeZipper -> TapeZipper
writeToTape newSymbol tz = tz { tzFocus = newSymbol }

-- | Move the head
moveHead :: Movement -> TMVariant -> TapeZipper -> TapeZipper
moveHead moveType variant tz@(TapeZipper l f r idx) =
    case moveType of
        LEFT ->
            if variant == LRTM then error "LRTM cannot move LEFT" else
            case l of
                []     -> tz -- At leftmost, cannot move left
                (h:t)  -> TapeZipper t h (f:r) (idx - 1)
        RIGHT ->
            case r of
                []     -> tz -- At rightmost, cannot move right
                (h:t)  -> TapeZipper (f:l) h t (idx + 1)
        RESET -> -- Only applicable for LRTM
            if variant /= LRTM then error "RESET move is only for LRTM" else
            let fullTape = tapeToList tz
            in listToTapeZipper fullTape 0 -- Reset to index 0

-- | Convert TapeZipper back to a flat list
tapeToList :: TapeZipper -> [Symbol]
tapeToList (TapeZipper l f r _) = reverse l ++ [f] ++ r