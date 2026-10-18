module Main where

import Prelude

import Affjax.Node as Affjax
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson, printJsonDecodeError)
import Data.Argonaut.Decode.Combinators ((.:))
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Argonaut.Parser (jsonParser)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Foldable (elem)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Console (error)
import Node.Process as Process

type WeatherReport =
  { city :: String
  , temperature :: Number
  , humidity :: Int
  , conditions :: String
  }

sampleJson :: String
sampleJson =
  """
{
  "city": "Munich",
  "temperature": 18.5,
  "humidity": 61,
  "conditions": "partly cloudy"
}
"""

decodeReport :: Json -> Either String WeatherReport
decodeReport json = do
  report <- lmap printJsonDecodeError (decodeFields json)
  if report.humidity < 0 || report.humidity > 100 then
    Left ("humidity out of range: " <> show report.humidity)
  else
    Right report

decodeFields :: Json -> Either JsonDecodeError WeatherReport
decodeFields json = do
  obj <- decodeJson json
  city <- obj .: "city"
  temperature <- obj .: "temperature"
  humidity <- obj .: "humidity"
  conditions <- obj .: "conditions"
  pure { city, temperature, humidity, conditions }

renderReport :: WeatherReport -> String
renderReport report =
  report.city <> ": "
    <> show report.temperature
    <> " C, "
    <> show report.humidity
    <> "% humidity, "
    <> report.conditions

printResult :: Either String WeatherReport -> Effect Unit
printResult = case _ of
  Left err -> error ("decode failed: " <> err)
  Right report -> log (renderReport report)

liveUrl :: String
liveUrl =
  "https://api.open-meteo.com/v1/forecast?latitude=48.14&longitude=11.58\
  \&current=temperature_2m,relative_humidity_2m,weather_code"

fetchLive :: Aff (Either String WeatherReport)
fetchLive = do
  response <- Affjax.request (Affjax.defaultRequest { url = liveUrl, responseFormat = ResponseFormat.json })
  pure case response of
    Left error -> Left (Affjax.printError error)
    Right ok -> lmap printJsonDecodeError do
      obj <- decodeJson ok.body
      current <- obj .: "current"
      temperature <- current .: "temperature_2m"
      humidity <- current .: "relative_humidity_2m"
      code <- current .: "weather_code"
      pure
        { city: "Munich"
        , temperature
        , humidity
        , conditions: describeCode code
        }

describeCode :: Int -> String
describeCode code
  | code == 0 = "clear sky"
  | code <= 3 = "partly cloudy"
  | code <= 48 = "fog"
  | code <= 67 = "rain"
  | code <= 77 = "snow"
  | code <= 82 = "showers"
  | otherwise = "thunderstorm"

main :: Effect Unit
main = do
  args <- Process.argv
  if elem "--live" args then do
    log "Fetching live weather from Open-Meteo..."
    launchAff_ do
      result <- fetchLive
      liftEffect (printResult result)
  else
    printResult (jsonParser sampleJson >>= decodeReport)

