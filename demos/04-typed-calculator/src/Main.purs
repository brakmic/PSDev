module Main where

import Prelude

import Data.Either (Either(..))
import Data.Lens (Prism', preview, prism')
import Data.Maybe (Maybe(..))
import Data.Variant (Variant, inj, match)
import Effect (Effect)
import Effect.Console (log)
import Type.Proxy (Proxy(..))

data Expr
  = Lit Int
  | Add Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  | Neg Expr

eval :: Expr -> Either String Int
eval = case _ of
  Lit n -> Right n
  Add left right -> (+) <$> eval left <*> eval right
  Mul left right -> (*) <$> eval left <*> eval right
  Div left right -> do
    numerator <- eval left
    denominator <- eval right
    if denominator == 0 then Left "division by zero" else Right (numerator / denominator)
  Neg inner -> negate <$> eval inner

class Pretty a where
  pretty :: a -> String

instance prettyExpr :: Pretty Expr where
  pretty = case _ of
    Lit n -> show n
    Add left right -> "(" <> pretty left <> " + " <> pretty right <> ")"
    Mul left right -> "(" <> pretty left <> " * " <> pretty right <> ")"
    Div left right -> "(" <> pretty left <> " / " <> pretty right <> ")"
    Neg inner -> "-" <> pretty inner

negPrism :: Prism' Expr Expr
negPrism = prism' Neg case _ of
  Neg inner -> Just inner
  _ -> Nothing

type BinaryOp = Variant (add :: Unit, sub :: Unit, mul :: Unit)

applyOp :: BinaryOp -> Int -> Int -> Int
applyOp op left right =
  match { add: \_ -> left + right, sub: \_ -> left - right, mul: \_ -> left * right } op

type EvalConfig r =
  { strict :: Boolean | r }

describeConfig :: forall r. EvalConfig r -> String
describeConfig config = if config.strict then "strict" else "permissive"

main :: Effect Unit
main = do
  let expression = Add (Lit 2) (Mul (Lit 3) (Neg (Lit 4)))
  log ("expression: " <> pretty expression)
  log ("result: " <> show (eval expression))
  case preview negPrism (Neg (Lit 42)) of
    Just inner -> log ("inner expression of negation: " <> pretty inner)
    Nothing -> log "not a negation"
  log ("20 + 22 = " <> show (applyOp (inj (Proxy :: _ "add") unit) 20 22))
  log ("mode: " <> describeConfig { strict: true })

