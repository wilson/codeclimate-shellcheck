{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module CC.Types where

import Data.Aeson       (ToJSON(..), (.=), genericToJSON, object)
import Data.Aeson.Types (Pair, Value(Null), defaultOptions, fieldLabelModifier)
import Data.Char        (isUpper, toLower)
import GHC.Generics     (Generic)

data BeginEnd = BeginEnd {
    _begin :: Int
  , _end   :: Int
} deriving (Generic, Show)

data Category = BugRisk
              | Clarity
              | Compatibility
              | Complexity
              | Duplication
              | Security
              | Style
              deriving Show

data Issue = Issue {
    _check_name         :: String
  , _description        :: String
  , _categories         :: [Category]
  , _location           :: Location
  , _remediation_points :: Maybe Int
  , _content            :: Maybe String
  , _other_locations    :: Maybe [Location]
} deriving Show

data LineColumn = LineColumn {
    _line   :: Int
  , _column :: Int
} deriving (Generic, Show)

data Location = Lines FilePath BeginEnd
              | Positions FilePath Position
              deriving Show

data Position = Coords LineColumn
              | Offset Int
              deriving Show

instance ToJSON Category where
  toJSON BugRisk       = "bug risk"
  toJSON Clarity       = "clarity"
  toJSON Compatibility = "compatibility"
  toJSON Complexity    = "complexity"
  toJSON Duplication   = "duplication"
  toJSON Security      = "security"
  toJSON Style         = "style"

instance ToJSON BeginEnd where
  toJSON = genericToJSON defaultOptions { fieldLabelModifier = drop 1 }

instance ToJSON Issue where
  toJSON Issue{..} = object . withoutNulls $ [
        "type"               .= ("issue" :: String)
      , "check_name"         .= _check_name
      , "description"        .= _description
      , "categories"         .= _categories
      , "location"           .= _location
      , "remediation_points" .= _remediation_points
      , "content"            .= _content
      , "other_locations"    .= _other_locations
    ]
    where
      withoutNulls :: [(a, Value)] -> [(a, Value)]
      withoutNulls = filter (\(_, v) -> v /= Null)

instance ToJSON LineColumn where
  toJSON = genericToJSON defaultOptions { fieldLabelModifier = drop 1 }

instance ToJSON Location where
  toJSON location = object $ case location of
    Lines     x y -> [ f x, "lines" .= y ]
    Positions x y -> [ f x, "positions" .= y ]
    where
      f :: FilePath -> Pair
      f = (.=) "path"

instance ToJSON Position where
  toJSON (Coords x) = toJSON x
  toJSON (Offset x) = object [ "offset" .= x ]