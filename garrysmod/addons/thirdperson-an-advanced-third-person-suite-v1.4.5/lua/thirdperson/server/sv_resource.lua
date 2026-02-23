--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561199109663690)

SERVERSIDE FILE
]]--

-- Addon Content Download for Players
if ( THIRDPERSON.downloadMethod == "direct" ) then
    -- Method #1: Direct or FastDL
    -- This is used for FastDLs or direct download from the server.
    if (THIRDPERSON.useFonts) then
        resource.AddFile( "resource/fonts/roboto-thirdperson-ad3fc.ttf" );
    end
    resource.AddFile( "materials/icon64/thirdperson/thirdperson-icon.png" );
elseif ( THIRDPERSON.downloadMethod == "workshop" ) then
    -- Method #2: Workshop
    -- This is used for a download from the workshop to the player.
    resource.AddWorkshop( "1953525147" ); -- https://steamcommunity.com/sharedfiles/filedetails/?id=1953525147
end