local _,Addon = ...;

Addon.Implode = function( self,Input,Delimiter )
  return table.concat( Input,Delimiter );
end

Addon.Minify = function( self,Input )
  return strlower( Input:gsub( '%W', '' ) );
end

Addon.Dump = function( self,Input )
  DevTools_Dump( Input );
end

Addon.Explode = function( self,Input,Delimiter )
  local Result = {};
  for Match in (Input..Delimiter):gmatch( "(.-)"..Delimiter ) do
    table.insert( Result,Match )
  end
  return Result;
end

Addon.InArray = function( self,Needle,Haystack )
  for index, _ in pairs( Haystack ) do
    if index == Needle then
      return true, index
    end
  end
  return false;
end

Addon.Sort = function( self,Input )
  local A = {}
  for N in pairs(Input) do table.insert( A,N ) end
  table.sort( A,function( X,Y ) return 
      strlower( Y ) > strlower( X )
    end )
  local I = 0      -- iterator variable
  local Iter = function ()   -- iterator function
      I = I + 1
      if A[ I ] == nil then return nil
      else return A[ I ], Input[ A[ I ] ]
      end
   end
   return Iter;
end

Addon.Int2Bool = function( self,Input )
    if tonumber( Input ) == 0 then
        return false
    else
        return true
    end
end

Addon.BoolToInt = function( self,Input )
    return Input and 1 or 0;
end

Addon.SliderRound = function( self,Val,ValStep )
  return floor( Val/ValStep )*ValStep;
end

Addon.IsClassic = function( self )
  return ( WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE );
end

Addon.Hex2RGB = function( self,Hex )
  Hex = Hex:gsub( '#','' );
  return tonumber( '0x' .. Hex:sub( 1,2 ) ) / 255, 
    tonumber( '0x' .. Hex:sub( 3,4 ) ) / 255, 
    tonumber( '0x' .. Hex:sub( 5,6 ) ) / 255
end