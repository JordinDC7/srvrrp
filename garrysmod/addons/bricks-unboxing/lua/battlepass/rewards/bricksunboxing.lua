local REWARD = BATTLEPASS:CreateReward()

function REWARD:CanUnlock( ply, reward, amount )
	return true
end

function REWARD:GetTooltip( reward )
	return self:GetName( reward )
end

function REWARD:GetModel( reward )
    if( not BRICKS_SERVER or not BRICKS_SERVER.Func.IsModuleEnabled( "unboxing" ) ) then return ".mdl" end
    
    local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( reward )
	if( not configItemTable ) then return ".mdl" end

	return configItemTable.Icon or configItemTable.Model
end

function REWARD:GetName( reward, amount )
    amount = amount or 1

    if( not BRICKS_SERVER or not BRICKS_SERVER.Func.IsModuleEnabled( "unboxing" ) ) then return "Unboxing not installed/enabled!" end
    
    local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( reward )
	if( not configItemTable ) then return "Unknown Name" end

    if( amount > 1 ) then
        return amount .. "x " .. configItemTable.Name
    end
  
	return configItemTable.Name
end

function REWARD:Unlock( ply, reward, amount )
    if( CLIENT ) then return end
    
    ply:AddUnboxingInventoryItem( reward, amount or 1 )
    ply:SendUnboxingItemNotification( "BATTLEPASS", reward, amount or 1 )
end

function REWARD:ErrorPanel()
    local panel = vgui.Create( "Panel" )
    panel.PostInit = function() end
  
    return panel
end
  
function REWARD:GetCustomPanel( reward )
    if( not BRICKS_SERVER or not BRICKS_SERVER.Func.IsModuleEnabled( "unboxing" ) ) then return self:ErrorPanel() end

    local configItemTable = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey( reward )
    if( not configItemTable ) then return self:ErrorPanel() end

    local displayPanel = vgui.Create( "bricks_server_unboxing_itemdisplay" )
    displayPanel:SetItemData( reward:match( "(.+)_" ), configItemTable )
    displayPanel:SetIconSizeAdjust( 0.75 )
    displayPanel.PostInit = function() end

    return displayPanel
end

REWARD:Register( "bricksunboxing" )