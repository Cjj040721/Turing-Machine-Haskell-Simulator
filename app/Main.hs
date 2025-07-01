import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import Control.Monad (when)

import Types -- This already brings Config(..), TMDescription(..), etc. into scope
import Parser (parseTMDescription)
import Tape (initializeTapeZipper)
-- Corrected TM import: Config(..) is not exported by TM, it comes from Types
import TM (runTM_M1, stepTM, isHaltingState)
import Gui (runGraphicalMode)


main :: IO ()
main = do
    args <- getArgs
    when (length args /= 3) $ do
        putStrLn "Usage: coursework <tm_description_file_path> <input_string> <M1|M2>"
        exitFailure

    let filePath   = args !! 0
        inputStr   = args !! 1
        modeStr    = args !! 2

    fileContent <- readFile filePath
    -- Use a pure binding for tmDescEither to emphasize its purity before passing to IO actions
    let tmDescEither = parseTMDescription fileContent

    case tmDescEither of
        Left errMsg -> do
            putStrLn $ "Error parsing TM description: " ++ errMsg
            exitFailure
        Right tmDesc -> do
            let maxInputLen = 19 -- As per spec: "maximum input length is 19"
            when (tmVariant tmDesc /= BBTM && length inputStr > maxInputLen) $ do
                putStrLn $ "Error: Input string for " ++ show (tmVariant tmDesc) ++
                           " cannot exceed " ++ show maxInputLen ++ " characters. Given: " ++ show (length inputStr)
                exitFailure
            
            -- Input string validation for allowed characters (0, 1 for Classical/LRTM)
            -- BBTM ignores input string, but for others, ensure they are binary.
            -- The spec's input alphabet is {0,1}. The tape alphabet is {0,1,X,*}
            when (tmVariant tmDesc /= BBTM && not (all (`elem` ['0', '1']) inputStr)) $ do
                putStrLn $ "Error: Input string must only contain '0' or '1'. Given: " ++ inputStr
                exitFailure


            let initialTape = initializeTapeZipper (tmVariant tmDesc) inputStr
            let initialConfig = Config { -- This is valid because Config{..} is from 'Types'
                                    cfgState = tmInitialState tmDesc,
                                    cfgTape  = initialTape,
                                    cfgDesc  = tmDesc
                                }

            case modeStr of
                "M1" -> do
                    let (_, result) = runTM_M1 initialConfig 50000
                    putStrLn result -- M1 only prints ACCEPTED or REJECTED
                    if result == "ACCEPTED" then exitSuccess else exitFailure
                "M2" -> do
                    putStrLn $ "Starting M2 (Graphical Mode) for: " ++ filePath
                    putStrLn $ "Input: '" ++ inputStr ++ "'"
                    putStrLn "Close the Gloss window to exit."
                    runGraphicalMode tmDesc inputStr
                _ -> do
                    putStrLn "Invalid mode. Use M1 or M2."
                    exitFailure