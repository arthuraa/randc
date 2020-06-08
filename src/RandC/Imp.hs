{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module RandC.Imp where

import RandC.Var
import RandC.Formatting
import RandC.Prism.Expr hiding (If)
import RandC.G hiding (If)
import RandC.Prob hiding (Choice)

import Data.Text (Text)
import Data.Text.Prettyprint.Doc hiding (cat)
import qualified Data.Map.Strict as M
import Data.Set (Set)
import qualified Data.Set as S

data Program = Program { pVarDecls :: M.Map Var (Int, Int)
                       , pDefs :: M.Map Var Expr
                       , pRewards :: M.Map Text Expr
                       , pCom :: Com }
  deriving (Show, Eq)

data Instr = Assn (M.Map Var (G (P Expr)))
           | If Expr Com Com
           | Block (Set Var) Com
  deriving (Eq, Show)

newtype Com = Com { instrs :: [Instr] }
  deriving (Eq, Show)

skip :: Com
skip = Com []

cat :: Com -> Com -> Com
cat c1 c2 = Com $ instrs c1 ++ instrs c2

revSeq :: [Com] -> Com
revSeq cs = foldl cat skip $ reverse cs

instance Pretty Instr where
  pretty (Assn assns) =
    vcat [ "assn"
         , vcat [ sep [ pretty v, ".<-", pretty e ]
                | (v, e) <- M.assocs assns ] ]
  pretty (If e c1 c2) =
    vcat [ sep [ "if", pretty e, "then" ]
         , indent 2 (pretty c1)
         , "else"
         , indent 2 (pretty c2)
         , "fi" ]
  pretty (Block vs c) =
    vcat [ "block"
         , indent 2 $ sep [pretty v | v <- S.toList vs]
         , indent 2 $ pretty c
         , "end" ]

instance Pretty Com where
  pretty (Com is) = vcat [ pretty i <> ";" | i <- is ]

instance Pretty Program where
  pretty Program{..} =
    vcat [ declarations pVarDecls
         , vcat [ sep [ "def", pretty v, "=", pretty e, ";" ]
                | (v, e) <- M.assocs pDefs ]
         , vcat [ sep [ "reward", pretty v, "=", pretty e, ";" ]
                | (v, e) <- M.assocs pRewards ]
         , pretty pCom ]

switch :: [(Expr, Com)] -> Com
switch = foldr (\(e, branch) acc -> Com [If e branch acc]) skip
