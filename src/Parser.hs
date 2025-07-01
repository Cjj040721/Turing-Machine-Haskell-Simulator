module Parser (
    parseTMDescription
) where

import Types
import Data.List.Split (splitOn) -- From 'split' package
-- Removed: import Data.Maybe (mapMaybe) -- This was unused

parseTMDescription :: String -> Either String TMDescription
parseTMDescription content = do
    linesMap <- parseLines (lines content)
    initialSt <- trim <$> lookupEither "initialState" linesMap
    acceptSt  <- trim <$> lookupEither "acceptState" linesMap
    rejectSt  <- trim <$> lookupEither "rejectState" linesMap
    variantStr<- trim <$> lookupEither "variant" linesMap
    variant   <- case stringToVariant (trim variantStr) of
                    Just v -> Right v
                    Nothing -> Left $ "Invalid TM variant: " ++ variantStr
    rulesStr  <- trim <$> lookupEither "rules" linesMap
    rulesList <- parseRulesString rulesStr
    pure TMDescription {
        tmInitialState = initialSt,
        tmAcceptState  = acceptSt,
        tmRejectState  = rejectSt,
        tmVariant      = variant,
        tmRules        = rulesList
    }
    where 
        trim = reverse . dropWhile isSpace . reverse . dropWhile isSpace
        isSpace c = c == ' ' || c == '\t' || c == '\r' || c == '\n'

lookupEither :: Eq a => Show a => a -> [(a, b)] -> Either String b -- Added Show constraint for better error msg
lookupEither key assocList =
    case lookup key assocList of
        Just val -> Right val
        Nothing  -> Left $ "Missing key: " ++ show key -- Now uses show

parseLines :: [String] -> Either String [(String, String)]
parseLines ls = mapM parseLine $ filter (not . nullOrComment) ls
  where
    nullOrComment s = null s || head s == '#' -- Potential partial function if s is empty, but filter (not . null) handles it.
    parseLine line =
        case splitOn "=" line of
            [key, value] -> Right (key, value)
            _            -> Left $ "Invalid line format: " ++ line

parseRulesString :: String -> Either String [Rule]
parseRulesString "" = Right [] -- No rules is valid
parseRulesString rulesStr =
    let ruleStrings = splitOn "<>" rulesStr
    in mapM parseSingleRule ruleStrings

parseSingleRule :: String -> Either String Rule
parseSingleRule ruleStr =
    case splitOn "," ruleStr of
        [cs, rsStr, ns, wsStr, mStr] -> do
            rs <- maybeToEither ("Invalid read symbol: " ++ rsStr ++ " in rule: " ++ ruleStr) (stringToSymbol rsStr)
            ws <- maybeToEither ("Invalid write symbol: " ++ wsStr ++ " in rule: " ++ ruleStr) (stringToSymbol wsStr)
            m  <- maybeToEither ("Invalid movement: " ++ mStr ++ " in rule: " ++ ruleStr) (stringToMovement mStr)
            pure Rule {
                rCurrentState = cs,
                rReadSymbol   = rs,
                rNextState    = ns,
                rWriteSymbol  = ws,
                rMove         = m
            }
        _ -> Left $ "Invalid rule format: " ++ ruleStr

maybeToEither :: String -> Maybe a -> Either String a
maybeToEither err Nothing  = Left err
maybeToEither _   (Just x) = Right x