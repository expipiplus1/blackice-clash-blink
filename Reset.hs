{-# LANGUAGE DataKinds #-}

module Reset
  ( topEntity
  ) where

import           Clash.Prelude

topEntity
  :: Clock System Source -> Reset System 'Asynchronous -> Signal System Bit
topEntity = exposeClockReset $ let c = counter in complement . msb <$> c

counter
  :: HiddenClockReset domain gates synchronous => Signal domain (BitVector 8)
counter = s where s = register 0 ((`boundedPlus` 1) <$> s)
