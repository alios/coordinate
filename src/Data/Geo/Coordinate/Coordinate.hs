module Data.Geo.Coordinate.Coordinate(
  Coordinate
, (.#.)
, (..#..)
, HasCoordinate(..)
, coordinateLatLon
, coordinateLonLat
, coordinateDMSLatLon
, coordinateLatDMSLon
, coordinateDMSLatDMSLon
) where

import Prelude(Eq, Show, Ord, Double, id, return, (.))
import Data.Maybe(Maybe)
import Control.Lens(Iso', Lens', iso, lens, mapping, swapped, withIso, (^?))
import Data.Geo.Coordinate.Latitude
import Data.Geo.Coordinate.Longitude
import Data.Geo.Coordinate.DegreesLatitude
import Data.Geo.Coordinate.DegreesLongitude
import Data.Geo.Coordinate.Minutes
import Data.Geo.Coordinate.Seconds

data Coordinate =
  Coordinate
    Latitude
    Longitude
  deriving (Eq, Ord, Show)

-- | Build a coordinate from a latitude and longitude.
(.#.) ::
  Latitude
  -> Longitude
  -> Coordinate
(.#.) =
  Coordinate

-- | Build a coordinate from a fractional latitude and fractional longitude. Fails
-- if either are out of range.
(..#..) ::
  Double
  -> Double
  -> Maybe Coordinate
lat ..#.. lon =
  do lat' <- lat ^? fracLatitude
     lon' <- lon ^? fracLongitude
     return (lat' .#. lon')

coordinateLatLon ::
  Iso' (Latitude, Longitude) Coordinate
coordinateLatLon =
  iso (\(lat, lon) -> Coordinate lat lon) (\(Coordinate lat lon) -> (lat, lon))

coordinateLonLat ::
  Iso' (Longitude, Latitude) Coordinate
coordinateLonLat =
  swapped . coordinateLatLon

coordinateDMSLatLon ::
  Iso' ((DegreesLatitude, Minutes, Seconds), Longitude) Coordinate
coordinateDMSLatLon =
  swapped . mapping dmsLatitude . coordinateLonLat

coordinateLatDMSLon ::
  Iso' (Latitude, (DegreesLongitude, Minutes, Seconds)) Coordinate
coordinateLatDMSLon =
  mapping dmsLongitude . coordinateLatLon

coordinateDMSLatDMSLon ::
  Iso' ((DegreesLatitude, Minutes, Seconds), (DegreesLongitude, Minutes, Seconds)) Coordinate
coordinateDMSLatDMSLon =
  iso (\((td, tm, ts), (nd, nm, ns)) -> Coordinate (withIso dmsLatitude (\k _ -> k (td, tm, ts))) (withIso dmsLongitude (\k _ -> k (nd, nm, ns))))
      (\(Coordinate lat lon) -> (withIso dmsLatitude (\_ k -> k lat), withIso dmsLongitude (\_ k -> k lon)))

class HasCoordinate t where
  coordinate ::
    Lens' t Coordinate

instance HasCoordinate Coordinate where
  coordinate =
    id

instance HasLatitude Coordinate where
  latitude =
    lens (\(Coordinate lat _) -> lat) (\(Coordinate _ lon) lat -> Coordinate lat lon)

instance HasLongitude Coordinate where
  longitude =
    lens (\(Coordinate _ lon) -> lon) (\(Coordinate lat _) lon -> Coordinate lat lon)

instance HasDegreesLatitude Coordinate where
  degreesLatitude =
    latitude . degreesLatitude

instance HasDegreesLongitude Coordinate where
  degreesLongitude =
    longitude . degreesLongitude