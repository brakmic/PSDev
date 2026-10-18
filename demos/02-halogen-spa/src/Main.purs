module Main where

import Prelude

import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.VDom.Driver (runUI)

type State =
  { count :: Int
  , saved :: Array Int
  }

data Action
  = Increment
  | Decrement
  | Reset
  | Save

component :: forall q i o m. MonadAff m => H.Component q i o m
component =
  H.mkComponent
    { initialState: const { count: 0, saved: [] }
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

handleAction :: forall o m. MonadAff m => Action -> H.HalogenM State Action () o m Unit
handleAction = case _ of
  Increment -> H.modify_ \state -> state { count = state.count + 1 }
  Decrement -> H.modify_ \state -> state { count = state.count - 1 }
  Reset -> H.modify_ \state -> state { count = 0 }
  Save -> do
    H.liftAff $ delay (Milliseconds 250.0)
    state <- H.get
    H.modify_ _ { saved = state.saved <> [ state.count ] }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div_
    [ HH.h1_ [ HH.text "PureScript Halogen counter" ]
    , HH.p_ [ HH.text ("Count: " <> show state.count <> parity state.count) ]
    , HH.div_
        [ HH.button [ HE.onClick \_ -> Decrement ] [ HH.text "-1" ]
        , HH.button [ HE.onClick \_ -> Reset ] [ HH.text "Reset" ]
        , HH.button [ HE.onClick \_ -> Increment ] [ HH.text "+1" ]
        , HH.button [ HE.onClick \_ -> Save ] [ HH.text "Save snapshot" ]
        ]
    , HH.p_ [ HH.text ("Saved snapshots: " <> show state.saved) ]
    ]
  where
  parity n = if n `mod` 2 == 0 then " (even)" else " (odd)"

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body

