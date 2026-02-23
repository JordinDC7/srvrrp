--[[

Author: tochnonement
Email: tochnonement@gmail.com

12/08/2024

--]]

local PLAYER = FindMetaTable( 'Player' )

util.AddNetworkString( 'onyx.hud::SendAlert' )

local function overridePrintMessage()
    onyx.hud.original_PrintMessage = onyx.hud.original_PrintMessage or PLAYER.PrintMessage                                                                                                                                                                                                                              -- a0e762ff-7eea-45b0-9009-1be3e92f9b18

    PLAYER.PrintMessage = function( self, type, message )
        if ( type == HUD_PRINTCENTER ) then
            net.Start( 'onyx.hud::SendAlert' )
                net.WriteString( message )
            net.Send( self )
        else
            onyx.hud.original_PrintMessage( self, type, message )
        end
    end
end
onyx.WaitForGamemode( 'onyx.hud.OverridePrintMessage', overridePrintMessage )

hook.Add( 'PlayerSay', 'onyx.hud.OpenSettings', function( ply, text )
    local text = string.lower( text )
    if ( text == '!hud' or text == '/hud' ) then
        ply:ConCommand( 'onyx_hud' )
        return ''
    end
end )