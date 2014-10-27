{-# LANGUAGE BangPatterns      #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes        #-}
{-# LANGUAGE TemplateHaskell   #-}

-- Module      : Main
-- Copyright   : (c) 2013-2014 Brendan Hay <brendan.g.hay@gmail.com>
-- License     : This Source Code Form is subject to the terms of
--               the Mozilla Public License, v. 2.0.
--               A copy of the MPL can be found in the LICENSE file or
--               you can obtain it at http://mozilla.org/MPL/2.0/.
-- Maintainer  : Brendan Hay <brendan.g.hay@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)

module Main (main) where

import Control.Applicative
import Control.Error
import Control.Lens
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.State
import Data.Monoid
import Gen.V2.Asset
import Gen.V2.Log
import Gen.V2.Model
import Gen.V2.Stage1
import Gen.V2.Stage2
import Gen.V2.Template
import Gen.V2.Transform
import Options.Applicative
import System.Directory
import System.FilePath

data Options = Options
    { _out       :: FilePath
    , _models    :: [FilePath]
    , _services  :: FilePath
    , _overrides :: FilePath
    , _templates :: FilePath
    , _assets    :: FilePath
    } deriving (Show)

makeLenses ''Options

options :: ParserInfo Options
options = info (helper <*> parser) fullDesc

parser :: Parser Options
parser = Options
    <$> strOption
         ( long "out"
        <> metavar "DIR"
        <> help "Directory to place the generated library. [required]"
         )

    <*> some (strOption
         ( long "model"
        <> metavar "PATH"
        <> help "Directory for a service's botocore models. [required]"
         ))

    <*> strOption
         ( long "services"
        <> metavar "PATH"
        <> help "Directory for amazonka models. [required]"
         )

    <*> strOption
         ( long "overrides"
        <> metavar "DIR"
        <> help "Directory containing amazonka overrides. [required]"
         )

    <*> strOption
         ( long "templates"
        <> metavar "DIR"
        <> help "Directory containing ED-E templates. [required]"
         )

    <*> strOption
         ( long "assets"
        <> metavar "PATH"
        <> help "Directory containing assets for generated libraries. [required]"
         )

validate :: MonadIO m => Options -> m Options
validate o = flip execStateT o $ do
    sequence_
        [ check out
        , check services
        , check overrides
        , check templates
        , check assets
        ]
    mapM canon (o ^. models)
        >>= assign models

check :: (MonadIO m, MonadState s m) => Lens' s FilePath -> m ()
check l = gets (view l) >>= canon >>= assign l

canon :: MonadIO m => FilePath -> m FilePath
canon = liftIO . canonicalizePath

main :: IO ()
main = do
    o <- customExecParser (prefs showHelpOnError) options >>= validate

    runScript $ do
        !ts <- loadTemplates (o ^. templates)

        -- Process a Stage1 AST from the corresponding botocore model.
        forM_ (o ^. models) $ \d -> do
            -- Load the Stage1 raw JSON.
            !m1 <- loadS1 d

            -- Decode the Stage1 JSON to AST.
            !s1 <- decodeS1 m1

            -- Transformation from Stage1 -> Stage2 AST.
            let !i2 = transformS1ToS2 s1

            -- Store the intemediary Stage2 AST as JSON.
            -- Note: This is primarily done for debugging purposes,
            -- but it's also convenient for merging overrides.
            storeS2 (o ^. services) m1 i2

            -- -- Load the intemediary Stage2 JSON,
            -- -- with left-biased merge of overrides(l).
            -- !m2 <- loadS2 _overrides _services m1

            -- -- Decode the Stage2 JSON to AST.
            -- !s2 <- decodeS2 m2

            -- -- Truncation and trimming phase of Stage2 AST.
            -- let !r = trimS2 s2

            -- Render the templates, creating or overriding the target library.
            -- renderSources s

            -- Copy static assets to the library root.
            -- copyAssets _assets ?
            return ()
