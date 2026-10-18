module Test.Main where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Test.QuickCheck (quickCheck)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)

import Main (Expr(..), eval)

main :: Effect Unit
main = runSpecAndExitProcess [ consoleReporter ] do
  describe "eval" do
    it "evaluates nested arithmetic" do
      eval (Add (Lit 2) (Mul (Lit 3) (Lit 4))) `shouldEqual` Right 14
    it "reports division by zero" do
      eval (Div (Lit 1) (Lit 0)) `shouldEqual` Left "division by zero"
  describe "properties" do
    it "adding zero is identity" $ liftEffect $ quickCheck \(n :: Int) ->
      eval (Add (Lit n) (Lit 0)) == Right n
    it "multiplying by one is identity" $ liftEffect $ quickCheck \(n :: Int) ->
      eval (Mul (Lit n) (Lit 1)) == Right n

