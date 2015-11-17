{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE TypeOperators        #-}

module Main where

import           Control.Concurrent.STM   (TVar, newTVarIO)
import Control.Monad (liftM)
import qualified Data.Map.Strict as Map
import           Data.UUID              (toString)
import           Lucid                    (Html, body_, doctypehtml_, head_,
                                           script_, src_, title_)
import           Network.Wai              (Application)
import           Network.Wai.Handler.Warp (run)
import           Servant                  ((:<|>) ((:<|>)), (:>), Get,
                                           Proxy (Proxy), Raw, Server, serve,
                                           serveDirectory)
import           Servant.HTML.Lucid       (HTML)
import           System.Random          (randomIO)

import qualified Api.Server
import qualified Api.Types

type SiteApi =  "api" :> Api.Types.Api
            :<|> Get '[HTML] (Html ())
            :<|> "assets" :> Raw

siteApi :: Proxy SiteApi
siteApi = Proxy

server :: TVar Api.Types.BookDB -> Server SiteApi
server bookDb = apiServer :<|> home :<|> assets
  where home = return homePage
        apiServer = Api.Server.server bookDb
        assets = serveDirectory "frontend/dist"

homePage :: Html ()
homePage =
  doctypehtml_ $ do
    head_ $ do
      title_ "Example Servant-Elm App"
      script_ [src_ "assets/app.js"] ""
    body_ (script_ "var elmApp = Elm.fullscreen(Elm.Main)")

app :: TVar Api.Types.BookDB -> Application
app bookDb = serve siteApi (server bookDb)

main :: IO ()
main = do
  let port = 8000
  uuid1 <- liftM toString randomIO
  uuid2 <- liftM toString randomIO
  let books = [ Api.Types.Book (Just uuid1) "Real World Haskell" (Api.Types.Author "Bryan O'Sullivan, Don Stewart, and John Goerzen" 1970)
              , Api.Types.Book (Just uuid2) "Learn You a Haskell for Great Good" (Api.Types.Author "Miran Lipovača" 1970)
              ]
  bookDb <- newTVarIO (Map.fromList (zip [uuid1, uuid2] books))
  putStrLn $ "Serving on port " ++ show port ++ "..."
  run port (app bookDb)
