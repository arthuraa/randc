module RandC.Compiler where

import RandC.Var
import qualified RandC.Imp                 as Imp
import qualified RandC.Prism               as Prism
import qualified RandC.Compiler.Diceing    as I2D
import qualified RandC.Compiler.DiceToSSA1 as D2SSA
import qualified RandC.Compiler.SSA1ToSSA2 as SSA12
import qualified RandC.Compiler.SSA2ToSSA3 as SSA23
import qualified RandC.Compiler.Inlining   as Inlining
import qualified RandC.Compiler.Undiceing  as SSA2UPA
import qualified RandC.Compiler.UPAToPrism as UPA2P

import Control.Monad

compile :: Imp.Program -> VarGen Prism.Program
compile =
  I2D.compile      >=>
  D2SSA.compile    >=>
  SSA12.compile    >=>
  SSA23.compile    >=>
  Inlining.compile >=>
  SSA2UPA.compile  >=>
  UPA2P.compile
