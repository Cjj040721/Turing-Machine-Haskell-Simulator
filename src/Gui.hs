module Gui (
    runGraphicalMode
) where

import Types
-- Corrected imports for Tape and TM:
import Tape (initializeTapeZipper, readCurrentSymbol, tapeToList {- Removed maxTapeIndex -})
import TM (runTM_M2)
import Graphics.Gloss
-- Removed: import Graphics.Gloss.Interface.IO.Game -- For event handling if needed later, but animate is simpler

-- GUI Constants
cellWidth :: Float
cellWidth = 30
cellHeight :: Float
cellHeight = 30
cellMargin :: Float
cellMargin = 5
tapeStartY :: Float
tapeStartY = 150
stateDisplayY :: Float
stateDisplayY = tapeStartY + cellHeight + 20
rulesTableStartY :: Float
rulesTableStartY = tapeStartY - cellHeight - 80
ruleRowHeight :: Float
ruleRowHeight = 20

-- | Main function for M2 mode
runGraphicalMode :: TMDescription -> String -> IO ()
runGraphicalMode desc inputStr = do
    let initialTapeZipper = initializeTapeZipper (tmVariant desc) inputStr
    let initialConfig = Config (tmInitialState desc) initialTapeZipper desc
    let configs = runTM_M2 initialConfig 500 -- Max 500 steps for animation

    animate
        (InWindow "Universal Turing Machine" (1000, 700) (10, 10))
        white
        (animFrame configs)

-- | Generates a Picture for each frame of the animation
animFrame :: [Config] -> Float -> Picture
animFrame cfgs time =
    let frameDuration = 0.5 -- seconds per TM step
        frameIdx = floor (time / frameDuration)
        currentCfgs = if null cfgs then [] else take (max 1 (frameIdx + 1)) cfgs
    in if null currentCfgs
        then blank
        else drawConfig (last currentCfgs)

-- | Draw a single TM configuration
drawConfig :: Config -> Picture
drawConfig cfg =
    Pictures [
        drawTape (cfgTape cfg),
        drawHead (cfgTape cfg),
        drawCurrentState (cfgState cfg),
        drawRulesTable (tmRules (cfgDesc cfg)) (cfgState cfg) (readCurrentSymbol (cfgTape cfg)),
        drawVariant (tmVariant (cfgDesc cfg))
    ]

drawVariant :: TMVariant -> Picture
drawVariant variant =
    translate (-450) (300) $ scale 0.15 0.15 $ color black $ text (show variant ++ " Mode")

-- | Draw the tape
drawTape :: TapeZipper -> Picture
drawTape tz =
    let symbols = tapeToList tz
        tapeWidth = fromIntegral (length symbols) * (cellWidth + cellMargin) - cellMargin
        startX = -tapeWidth / 2
    in Pictures $ zipWith (drawCell startX) [0..] symbols

drawCell :: Float -> Int -> Symbol -> Picture
drawCell startX idx sym =
    let x = startX + fromIntegral idx * (cellWidth + cellMargin) + cellWidth / 2
        cellBox = translate x tapeStartY $ rectangleWire cellWidth cellHeight
        cellText = translate x tapeStartY $ scale 0.15 0.15 $ color black $ text (symbolToString sym)
    in Pictures [cellBox, cellText]

-- | Draw the head indicator
drawHead :: TapeZipper -> Picture
drawHead tz =
    let headIdx = tzIndex tz
        fullTapeList = tapeToList tz
        tapeCellsCount = length fullTapeList
        tapeWidth = fromIntegral tapeCellsCount * (cellWidth + cellMargin) - cellMargin
        startX = if tapeCellsCount == 0 then 0 else -tapeWidth / 2

        x = startX + fromIntegral headIdx * (cellWidth + cellMargin) + cellWidth / 2
        y = tapeStartY - cellHeight / 2 - 10
        triangle = Polygon [(0,0), (-5, -10), (5, -10)]
    in if tapeCellsCount == 0
       then blank
       else translate x y $ color blue triangle

-- | Draw the current state
drawCurrentState :: State -> Picture
drawCurrentState st =
    translate 0 stateDisplayY $ scale 0.2 0.2 $ color red $ text ("State: " ++ st)

-- | Draw the rules table
drawRulesTable :: [Rule] -> State -> Symbol -> Picture
drawRulesTable rules currentSt currentSym =
    let tableHeader = translate (-450) rulesTableStartY $ scale 0.12 0.12 $ color black $
                      text "Rule: Current State, Read -> Next State, Write, Move"
        rulePics = zipWith (drawRuleEntry currentSt currentSym) [0..] rules
        maxRulesToShow = 15
    in Pictures (tableHeader : take maxRulesToShow rulePics)

drawRuleEntry :: State -> Symbol -> Int -> Rule -> Picture
drawRuleEntry currentSt currentSym idx rule =
    let y = rulesTableStartY - fromIntegral (idx + 1) * ruleRowHeight - 10
        ruleStr = rCurrentState rule ++ ", " ++ symbolToString (rReadSymbol rule) ++ " -> " ++
                  rNextState rule ++ ", " ++ symbolToString (rWriteSymbol rule) ++ ", " ++ show (rMove rule)
        textColor = if rCurrentState rule == currentSt && rReadSymbol rule == currentSym then red else black
    in translate (-450) y $ scale 0.1 0.1 $ color textColor $ text ruleStr