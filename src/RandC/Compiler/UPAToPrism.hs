module RandC.Compiler.UPAToPrism where

import RandC.Pass
import qualified RandC.UPA   as Src
import qualified RandC.Prism as Tgt

import qualified Data.Map.Strict as M

compileAssn :: Src.Assn -> Tgt.Assns
compileAssn (Src.Assn assn) =
  Tgt.Assns [Tgt.Assn v e | (v, e) <- M.assocs assn]

compileModule :: (Int, Src.Module) -> Tgt.Module
compileModule (id, Src.Module decls trans) =
  let decls' = [Tgt.VarDecl v lb ub | (v, (lb, ub)) <- M.assocs decls]

      trans' = [Tgt.Transition guard (compileAssn <$> assns)
               |(guard, assns) <- trans]

  in
    Tgt.Module id decls' trans'

compile :: Src.Program -> Pass Tgt.Program
compile (Src.Program defs rews mods) =
  let defs' = [Tgt.Formula v e | (v, e) <- M.assocs defs]
      rews' = [Tgt.Rewards v e | (v, e) <- M.assocs rews]
      mods' = map compileModule $ zip [0..] mods in
  return $ Tgt.Program defs' rews' mods'
