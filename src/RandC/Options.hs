{-# LANGUAGE DeriveDataTypeable #-}

-- | Options to tweak the behavior of the compiler.

module RandC.Options where

import System.Console.CmdArgs.Implicit

data Target = Imp   -- ^ The internal representation of programs
                    -- built by the 'RandC.Prog' monad.
            | CFG   -- ^ The first intermediate pass: convert the syntax of
                    -- 'Imp' commands into a control-flow graph.
            | UPA   -- ^ The last intermediate pass: introduce a PC variable to
                    -- keep track of which CFG node to execute.
            | Prism -- ^ Prism source code
  deriving (Ord, Eq, Read, Show, Data, Typeable)

data Inlining = All
              | Pure
              | None
  deriving (Ord, Eq, Read, Show, Data, Typeable, Enum)

data Options = Options { target   :: Target         -- ^ The compilation target
                       , inlining :: Inlining       -- ^ Inline assignments
                       , trimming :: Bool           -- ^ Remove unused state variables
                       , merge    :: Bool           -- ^ Perform assignments in parallel when possible
                       , simplify :: Bool           -- ^ Perform simplications
                       , output   :: Maybe FilePath -- ^ Output file
                       }
  deriving (Ord, Eq, Show, Data, Typeable)

defaultOptions :: Options
defaultOptions =
  Options { target   = Prism    &= help "Output format"
          , inlining = All      &= help "Inline assignments"
          , trimming = True     &= help "Remove unused state variables"
          , merge    = True     &= help "Perform assignments in parallel when possible"
          , simplify = True     &= help "Perform simplifications"
          , output   = Nothing  &= help "Output file. If none is present, output to stdout."
          }

data DoInlining = DoAll | DoPure

doInlining :: Options -> Maybe DoInlining
doInlining opts =
  case inlining opts of
    All -> Just DoAll
    Pure -> Just DoPure
    None -> Nothing

readOptions :: IO Options
readOptions =
  cmdArgs $ defaultOptions
          &= program "randc"
          &= summary "randc v0.3.0.0"
