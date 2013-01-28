module Text.CSL.Input.Identifier where


import           Control.Applicative ((<$>))
import           Network.Curl.Download (openURIWithOpts)
import           Network.Curl.Opts (CurlOption(CurlFollowLocation, CurlHttpHeaders))
import qualified Data.ByteString.Char8 as BS
import           Text.CSL (Reference, readBiblioString, BibFormat(Bibtex))


-- $setup
-- >>> import Text.CSL

-- | resolve a DOI to a 'Reference'.
--
-- >>> (\(Right x) -> take 7 $ title x) <$> readDOI "10.1088/1749-4699/5/1/015003"
-- "Paraiso"

readDOI :: String -> IO (Either String Reference)
readDOI doi = do
  let
      opts = [ CurlFollowLocation True
             , CurlHttpHeaders ["Accept: text/bibliography; style=bibtex"]
             ]
      url = "http://dx.doi.org/" ++ doi
  res <- openURIWithOpts opts url
  case res of
    Left msg -> return $ Left msg
    Right bs -> do
      rs <- readBiblioString Bibtex $ BS.unpack bs
      case rs of
        [r] -> return $ Right r
        []  -> return $ Left $ url ++ " returned no reference."
        _   -> return $ Left $ url ++ " returned multiple references."
