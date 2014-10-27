{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveFoldable             #-}
{-# LANGUAGE DeriveFunctor              #-}
{-# LANGUAGE DeriveTraversable          #-}
{-# LANGUAGE ExtendedDefaultRules       #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures             #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TupleSections              #-}

{-# OPTIONS_GHC -fno-warn-type-defaults #-}

-- Module      : Gen.V2.Types
-- Copyright   : (c) 2013-2014 Brendan Hay <brendan.g.hay@gmail.com>
-- License     : This Source Code Form is subject to the terms of
--               the Mozilla Public License, v. 2.0.
--               A copy of the MPL can be found in the LICENSE file or
--               you can obtain it at http://mozilla.org/MPL/2.0/.
-- Maintainer  : Brendan Hay <brendan.g.hay@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)

module Gen.V2.Types where

import           Control.Applicative
import           Control.Lens         (makeLenses)
import           Data.Attoparsec.Text (Parser, parseOnly)
import qualified Data.Attoparsec.Text as AText
import           Data.Bifunctor
import           Data.Foldable        (Foldable)
import           Data.Jason.Types     hiding (Parser)
import           Data.Monoid
import           Data.Ord
import           Data.Text            (Text)
import qualified Data.Text            as Text
import           Data.Traversable     (Traversable, traverse)
import           Gen.V2.TH

default (Text)

-- NOTE: Keep the boto json structure completely intact.
-- FIXME: _retry.json
-- FIXME: _endpoints.json

class ToFilePath a where
    toFilePath :: a -> FilePath

instance ToFilePath FilePath where
    toFilePath = id

data OrdMap a = OrdMap { ordMap :: [(Text, a)] }
    deriving (Eq, Show, Functor, Foldable, Traversable)

makeLenses ''OrdMap

instance FromJSON a => FromJSON (OrdMap a) where
    parseJSON = withObject "ordered_map" $ \case
        Obj xs -> OrdMap <$> traverse (\(k, v) -> (k,) <$> parseJSON v) xs

instance ToJSON a => ToJSON (OrdMap a) where
    toJSON = Object . Obj . map (second toJSON) . ordMap

data Signature
    = V2
    | V3
    | V4
      deriving (Eq, Show)

instance FromJSON Signature where
    parseJSON = withText "signature" $ \case
        "v2"      -> pure V2
        "v3"      -> pure V3
        "v3https" -> pure V3
        "v4"      -> pure V4
        "s3"      -> pure V4
        e         -> fail ("Unknown Signature: " ++ Text.unpack e)

nullary stage2 ''Signature

data Protocol
    = JSON
    | RestJSON
    | RestXML
    | Query
      deriving (Eq, Show)

instance FromJSON Protocol where
    parseJSON = withText "protocol" $ \case
        "json"      -> pure JSON
        "rest-json" -> pure RestJSON
        "rest-xml"  -> pure RestXML
        "query"     -> pure Query
        "ec2"       -> pure Query
        e           -> fail ("Unknown Protocol: " ++ Text.unpack e)

nullary stage2 ''Protocol

data Timestamp
    = RFC822
    | ISO8601
    | POSIX
      deriving (Eq, Show)

instance FromJSON Timestamp where
    parseJSON = withText "timestamp" $ \case
        "rfc822"        -> pure RFC822
        "iso8601"       -> pure ISO8601
        "unixTimestamp" -> pure POSIX
        e               -> fail ("Unknown Timestamp: " ++ Text.unpack e)

timestamp :: Timestamp -> Text
timestamp = Text.pack . show

data Checksum
    = MD5
    | SHA256
      deriving (Eq, Show)

nullary stage1 ''Checksum
nullary stage2 ''Checksum

data Method
    = GET
    | POST
    | HEAD
    | PUT
    | DELETE
      deriving (Eq, Show)

instance FromJSON Method where
    parseJSON = withText "method" $ \case
        "GET"    -> pure GET
        "POST"   -> pure POST
        "HEAD"   -> pure HEAD
        "PUT"    -> pure PUT
        "DELETE" -> pure DELETE
        e        -> fail ("Unknown Method: " ++ Text.unpack e)

nullary stage2 ''Method

data Location
    = Headers
    | Header
    | Uri
    | Querystring
    | Unknown
      deriving (Eq, Show)

nullary stage1 ''Location
nullary stage2 ''Location

data Path
    = Seg Text
    | Var Text
      deriving (Eq, Show)

pathParser :: Parser Path
pathParser = Seg <$> AText.takeWhile1 end <|> Var <$> var
  where
    var = AText.char '{' *> AText.takeWhile1 end <* AText.char '}'

    end '{' = False
    end '?' = False
    end _   = True

instance ToJSON Path where
    toJSON = \case
        Seg t -> object ["type" .= "const", "value" .= t]
        Var t -> object ["type" .= "var",   "value" .= t]

data URI = URI
    { _uriPath  :: [Path]
    , _uriQuery :: Maybe Text
    } deriving (Eq, Show)

uriParser :: Parser URI
uriParser = URI
    <$> ((:) <$> pathParser <*> many pathParser)
    <*> (optional (AText.char '?' *> AText.takeText))

instance FromJSON URI where
    parseJSON = withText "uri" (either fail return . parseOnly uriParser)

record stage2 ''URI

data Stage = S1 | S2

data Model (a :: Stage) = Model
    { _mName    :: String
    , _mVersion :: String
    , _mPath    :: FilePath
    , _mModel   :: Object
    } deriving (Show, Eq)

instance Ord (Model a) where
    compare a b = comparing _mName a b <> comparing _mVersion a b

dots :: FilePath -> Bool
dots "."  = False
dots ".." = False
dots _    = True
