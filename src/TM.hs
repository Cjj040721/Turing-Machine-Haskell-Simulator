module TM (
    findRule,
    stepTM,
    runTM_M1,
    runTM_M2,
    isHaltingState
) where

import Types
import Tape

-- | Find a rule matching the current state and symbol under the head
findRule :: State -> Symbol -> [Rule] -> Maybe Rule
findRule currentState currentSymbol rules =
    go rules
  where
    go [] = Nothing
    go (r:rs)
        | rCurrentState r == currentState && rReadSymbol r == currentSymbol = Just r
        | otherwise = go rs

-- | Check if the TM is in a halting state
isHaltingState :: Config -> Bool
isHaltingState cfg =
    let desc = cfgDesc cfg
        st = cfgState cfg
    in st == tmAcceptState desc || st == tmRejectState desc

-- | Perform a single step of the TM
-- Returns Nothing if no rule is found (implicit halt/reject) or already in halt state
stepTM :: Config -> Maybe Config
stepTM cfg
    | isHaltingState cfg = Nothing -- Already halted
    | otherwise =
        let desc = cfgDesc cfg
            tapeZipper = cfgTape cfg
            currentState = cfgState cfg
            currentSymbol = readCurrentSymbol tapeZipper
        in case findRule currentState currentSymbol (tmRules desc) of
            Nothing -> Nothing -- No rule found, TM halts (implicitly reject)
            Just rule ->
                let newTapeFocus = writeToTape (rWriteSymbol rule) tapeZipper
                    movedTape    = moveHead (rMove rule) (tmVariant desc) newTapeFocus
                    newState     = rNextState rule
                in Just Config {
                    cfgState = newState,
                    cfgTape  = movedTape,
                    cfgDesc  = desc
                }

-- | Run TM for M1 mode: returns final state (Accepted/Rejected)
-- Includes a step limit to prevent infinite loops in practice, though spec implies halting TMs.
runTM_M1 :: Config -> Int -> (Config, String) -- Returns final config and status string
runTM_M1 initialConfig maxSteps = go initialConfig 0
  where
    go cfg stepCount
        | stepCount >= maxSteps = (cfg, "MAX_STEPS_REACHED") -- Safety break
        | isHaltingState cfg =
            if cfgState cfg == tmAcceptState (cfgDesc cfg)
            then (cfg, "ACCEPTED")
            else (cfg, "REJECTED")
        | otherwise =
            case stepTM cfg of
                Nothing -> (cfg, "REJECTED") -- No rule, implicitly reject
                Just nextCfg -> go nextCfg (stepCount + 1)


-- | Run TM for M2 mode: returns all configurations encountered
runTM_M2 :: Config -> Int -> [Config] -- Includes initial config
runTM_M2 initialConfig maxSteps = go initialConfig 0 [initialConfig]
  where
    go cfg stepCount accCfgs
        | stepCount >= maxSteps = reverse accCfgs
        | isHaltingState cfg = reverse accCfgs
        | otherwise =
            case stepTM cfg of
                Nothing      -> reverse accCfgs
                Just nextCfg -> go nextCfg (stepCount + 1) (nextCfg : accCfgs)