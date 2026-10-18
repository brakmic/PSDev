module Main where

import Prelude

import Data.Array (filter, length, range)
import Data.Foldable (all)
import Data.Int (floor, toNumber)
import Data.Number (sqrt)
import Effect (Effect)
import Effect.Console (error, log)

foreign import countPrimesCpp :: Int -> Effect Int
foreign import now :: Effect Number

countPrimesPure :: Int -> Int
countPrimesPure limit
  | limit < 2 = 0
  | otherwise = length (filter isPrime (range 2 limit))

isPrime :: Int -> Boolean
isPrime n = n >= 2 && all (\divisor -> n `mod` divisor /= 0) (divisors n)

divisors :: Int -> Array Int
divisors n =
  let
    top = floor (sqrt (toNumber n))
  in
    if top < 2 then [] else range 2 top

benchmarkPure :: Int -> Effect { value :: Int, ms :: Number }
benchmarkPure limit = do
  started <- now
  let value = countPrimesPure limit
  finished <- now
  pure { value, ms: finished - started }

benchmarkNative :: Int -> Effect { value :: Int, ms :: Number }
benchmarkNative limit = do
  started <- now
  value <- countPrimesCpp limit
  finished <- now
  pure { value, ms: finished - started }

main :: Effect Unit
main = do
  let limit = 100000
  native <- benchmarkNative limit
  interpreted <- benchmarkPure limit
  log ("limit: " <> show limit)
  log ("C++ N-API:  " <> show native.value <> " primes in " <> show native.ms <> " ms")
  log ("PureScript: " <> show interpreted.value <> " primes in " <> show interpreted.ms <> " ms")
  when (native.value /= interpreted.value) do
    error "C++ and PureScript results disagree"

