{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}

module Data.Geo.Coordinate.DegreesLongitude(
  DegreesLongitude
, AsDegreesLongitude(..)
, remDegreesLongitude
) where

import Control.Applicative(Applicative)
import Control.Category(Category(id))
import Control.Lens(Optic', Choice, prism')
import Data.Bool((&&))
import Data.Eq(Eq)
import Data.Int(Int)
import Data.Maybe(Maybe(Just, Nothing))
import Data.Ord(Ord((<), (>)))
import Prelude(Show, rem)

-- $setup
-- >>> import Control.Lens((#), (^?))
-- >>> import Data.Foldable(all)
-- >>> import Prelude(Eq(..))

newtype DegreesLongitude =
  DegreesLongitude Int
  deriving (Eq, Ord, Show)

class AsDegreesLongitude p f s where
  _DegreesLongitude ::
    Optic' p f s DegreesLongitude

instance AsDegreesLongitude p f DegreesLongitude where
  _DegreesLongitude =
    id

-- | A prism on degrees longitude to an integer between -180 and 180 exclusive.
--
-- >>> (7 :: Int) ^? _DegreesLongitude
-- Just (DegreesLongitude 7)
--
-- >>> (0 :: Int) ^? _DegreesLongitude
-- Just (DegreesLongitude 0)
--
-- >>> (179 :: Int) ^? _DegreesLongitude
-- Just (DegreesLongitude 179)
--
-- >>> (180 :: Int) ^? _DegreesLongitude
-- Nothing
--
-- >>> (-179 :: Int) ^? _DegreesLongitude
-- Just (DegreesLongitude (-179))
--
-- >>> (-180 :: Int) ^? _DegreesLongitude
-- Nothing
--
-- prop> all (\m -> _DegreesLongitude # m == (n :: Int)) (n ^? _DegreesLongitude)
instance (Choice p, Applicative f) => AsDegreesLongitude p f Int where
  _DegreesLongitude =
    prism'
      (\(DegreesLongitude i) -> i)
      (\i -> if i > -180 && i < 180
               then Just (DegreesLongitude i)
               else Nothing)

-- | Setting a value @>= 180@ will get that value @(`rem` 180)@.
--
-- >>> remDegreesLongitude 7
-- DegreesLongitude 7
--
-- >>> remDegreesLongitude 0
-- DegreesLongitude 0
--
-- >>> remDegreesLongitude 180
-- DegreesLongitude 0
--
-- >>> remDegreesLongitude 1
-- DegreesLongitude 1
--
-- >>> remDegreesLongitude 179
-- DegreesLongitude 179 
remDegreesLongitude ::
  Int
  -> DegreesLongitude
remDegreesLongitude x =
  DegreesLongitude (x `rem` 180)
