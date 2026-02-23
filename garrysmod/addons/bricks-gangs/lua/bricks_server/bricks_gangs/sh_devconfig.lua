--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

BRICKS_SERVER.DEVCONFIG.GangURLWhitelist = {
    "https://i.imgur.com/",
    "https://imgur.com/"
}

BRICKS_SERVER.DEVCONFIG.GangRankLimit = 15
BRICKS_SERVER.DEVCONFIG.GangPrinterServerTime = 0.1 -- The decimal to reduce the server time by for each server, e.g. 0.1 would make the added time 10% less for server 2 and 20% less for server 3.

BRICKS_SERVER.DEVCONFIG.GangNameCharMin = 5
BRICKS_SERVER.DEVCONFIG.GangNameCharMax = 30
BRICKS_SERVER.DEVCONFIG.GangIconCharLimit = 200
BRICKS_SERVER.DEVCONFIG.GangNextEditTime = 1
BRICKS_SERVER.DEVCONFIG.GangPermissions = {
    ["DepositMoney"] = { BRICKS_SERVER.Func.L( "gangDepositMoney" ), BRICKS_SERVER.Func.L( "gangBalance" ) },
    ["WithdrawMoney"] = { BRICKS_SERVER.Func.L( "gangWithdrawMoney" ), BRICKS_SERVER.Func.L( "gangBalance" ) },
    ["EditRoles"] = { BRICKS_SERVER.Func.L( "gangEditRoles" ), BRICKS_SERVER.Func.L( "gangSettings" ) },
    ["EditSettings"] = { BRICKS_SERVER.Func.L( "gangEditSettings" ), BRICKS_SERVER.Func.L( "gangSettings" ) },
    ["InvitePlayers"] = { BRICKS_SERVER.Func.L( "gangInvitePlayers" ), BRICKS_SERVER.Func.L( "gangManagement" ) },
    ["KickPlayers"] = { BRICKS_SERVER.Func.L( "gangKickPlayers" ), BRICKS_SERVER.Func.L( "gangManagement" ) },
    ["ChangePlayerRoles"] = { BRICKS_SERVER.Func.L( "gangChangeRank" ), BRICKS_SERVER.Func.L( "gangManagement" ) },
    ["PurchaseUpgrades"] = { BRICKS_SERVER.Func.L( "gangPurchaseUpgrades" ), BRICKS_SERVER.Func.L( "gangManagement" ) },
    ["EditInbox"] = { BRICKS_SERVER.Func.L( "gangAcceptDeclineInbox" ), BRICKS_SERVER.Func.L( "gangManagement" ) },
    ["SendMessages"] = { BRICKS_SERVER.Func.L( "gangSendChatMessages" ), BRICKS_SERVER.Func.L( "gangChatLower" ) }
}

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "associations" ) ) then
    BRICKS_SERVER.DEVCONFIG.GangPermissions["RequestAssociations"] = { BRICKS_SERVER.Func.L( "gangAssociationSend" ), BRICKS_SERVER.Func.L( "gangAssociations" ) }
    BRICKS_SERVER.DEVCONFIG.GangPermissions["AcceptAssociations"] = { BRICKS_SERVER.Func.L( "gangAssociationAccept" ), BRICKS_SERVER.Func.L( "gangAssociations" ) }
end

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "storage" ) ) then
    BRICKS_SERVER.DEVCONFIG.GangPermissions["DepositItem"] = { BRICKS_SERVER.Func.L( "gangDepositItems" ), BRICKS_SERVER.Func.L( "gangStorage" ) }
    BRICKS_SERVER.DEVCONFIG.GangPermissions["WithdrawItem"] = { BRICKS_SERVER.Func.L( "gangWithdrawItems" ), BRICKS_SERVER.Func.L( "gangStorage" ) }
    BRICKS_SERVER.DEVCONFIG.GangPermissions["ViewItem"] = { BRICKS_SERVER.Func.L( "gangViewStorage" ), BRICKS_SERVER.Func.L( "gangStorage" ) }
end

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "printers" ) ) then
    BRICKS_SERVER.DEVCONFIG.GangPermissions["PurchasePrinters"] = { BRICKS_SERVER.Func.L( "gangPurchasePrinters" ), BRICKS_SERVER.Func.L( "gangPrinters" ) }
    BRICKS_SERVER.DEVCONFIG.GangPermissions["UpgradePrinters"] = { BRICKS_SERVER.Func.L( "gangUpgradePrinters" ), BRICKS_SERVER.Func.L( "gangPrinters" ) }
    BRICKS_SERVER.DEVCONFIG.GangPermissions["PlacePrinters"] = { BRICKS_SERVER.Func.L( "gangPlacePrinters" ), BRICKS_SERVER.Func.L( "gangPrinters" ) }

    BRICKS_SERVER.DEVCONFIG.GangPrinterSlots = 6
    BRICKS_SERVER.DEVCONFIG.GangPrinterW = 807*0.8
    BRICKS_SERVER.DEVCONFIG.GangPrinterH = 1018*0.8
end

BRICKS_SERVER.DEVCONFIG.GangUpgrades = {
    ["MaxMembers"] = {
        Name = BRICKS_SERVER.Func.L( "gangMaxMembers" ),
        Format = function( reqInfo )
            return (reqInfo[1] or 0) .. " " .. BRICKS_SERVER.Func.L( "gangMembers" )
        end,
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "gangMembers" ), "integer" }
        }
    },
    ["MaxBalance"] = { 
        Name = BRICKS_SERVER.Func.L( "gangMaxBalance" ), 
        Format = function( reqInfo )
            return DarkRP.formatMoney( reqInfo[1] or 0 )
        end,
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "gangBalance" ), "integer" }
        }
    },
    ["Health"] = { 
        Name = BRICKS_SERVER.Func.L( "gangIncreasedHealth" ), 
        Format = function( reqInfo )
            return BRICKS_SERVER.Func.L( "gangXHP", (reqInfo[1] or 0) )
        end,
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "gangExtraHealth" ), "integer" }
        }
    },
    ["Armor"] = { 
        Name = BRICKS_SERVER.Func.L( "gangIncreasedArmor" ), 
        Format = function( reqInfo )
            return BRICKS_SERVER.Func.L( "gangXAP", (reqInfo[1] or 0) )
        end,
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "gangExtraArmor" ), "integer" }
        }
    },
    ["Salary"] = { 
        Name = BRICKS_SERVER.Func.L( "gangIncreasedSalary" ), 
        Format = function( reqInfo )
            return "+" .. DarkRP.formatMoney( reqInfo[1] or 0 )
        end,
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "gangExtraSalary" ), "integer" }
        }
    },
    ["Weapon"] = { 
        Name = BRICKS_SERVER.Func.L( "gangPermWeapon" ), 
        Unlimited = true,
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "gangWeapon" ), "table", "weapons" }
        }
    }
}

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "storage" ) ) then
    BRICKS_SERVER.DEVCONFIG.GangUpgrades["StorageSlots"] = { 
        Name = BRICKS_SERVER.Func.L( "gangStorageSlots" ), 
        Format = function( reqInfo )
            return BRICKS_SERVER.Func.L( "gangXSlots", (reqInfo[1] or 0) )
        end,
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "gangSlots" ), "integer" }
        }
    }
end

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "achievements" ) ) then
    BRICKS_SERVER.DEVCONFIG.GangAchievements = {
        ["Balance"] = {
            Name = BRICKS_SERVER.Func.L( "gangBalanceFull" ),
            Format = function( progress, goal )
                return DarkRP.formatMoney( progress ) .. "/" .. DarkRP.formatMoney( goal )
            end,
            GetProgress = function( gangTable )
                return gangTable.Money or 0
            end,
            GetGoal = function( reqInfo )
                return reqInfo[1] or 0
            end,
            ReqInfo = {
                [1] = { BRICKS_SERVER.Func.L( "gangBalance" ), "integer" }
            }
        },
        ["Members"] = {
            Name = BRICKS_SERVER.Func.L( "gangMembersFull" ),
            Format = function( progress, goal )
                return progress .. "/" .. goal .. " " .. BRICKS_SERVER.Func.L( "gangMembers" )
            end,
            GetProgress = function( gangTable )
                return table.Count( gangTable.Members or {} )
            end,
            GetGoal = function( reqInfo )
                return reqInfo[1] or 0
            end,
            ReqInfo = {
                [1] = { BRICKS_SERVER.Func.L( "gangMembers" ), "integer" }
            }
        },
        ["Level"] = {
            Name = BRICKS_SERVER.Func.L( "gangLevel" ),
            Format = function( progress, goal )
                return BRICKS_SERVER.Func.L( "level" ) .. " " .. progress .. "/" .. goal
            end,
            GetProgress = function( gangTable )
                return gangTable.Level or 0
            end,
            GetGoal = function( reqInfo )
                return reqInfo[1] or 0
            end,
            ReqInfo = {
                [1] = { BRICKS_SERVER.Func.L( "level" ), "integer" }
            }
        }
    }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "storage" ) ) then
        BRICKS_SERVER.DEVCONFIG.GangAchievements["Storage"] = {
            Name = BRICKS_SERVER.Func.L( "gangStorageFull" ),
            Format = function( progress, goal )
                return progress .. "/" .. goal .. " " .. BRICKS_SERVER.Func.L( "gangItems" )
            end,
            GetProgress = function( gangTable )
                local itemCount = 0
                for k, v in pairs( gangTable.Storage or {} ) do
                    itemCount = itemCount+(v[1] or 0)
                end

                return itemCount
            end,
            GetGoal = function( reqInfo )
                return reqInfo[1] or 0
            end,
            ReqInfo = {
                [1] = { BRICKS_SERVER.Func.L( "gangItems" ), "integer" }
            }
        }
    end
end

BRICKS_SERVER.DEVCONFIG.GangNotifications = {
    ["GangInvite"] = {
        Name = BRICKS_SERVER.Func.L( "gangInvite" ),
        ReqInfo = {
            [1] = { "InviterGangID", "integer" },
            [2] = { "InviterGangName", "string" }
        },
        FormatDescription = function( reqInfo )
            return BRICKS_SERVER.Func.L( "gangInviteReceivedInbox", reqInfo[2] )
        end,
        AcceptFunc = function( reqInfo ) 
            net.Start( "BRS.Net.GangInviteAccept" )
                net.WriteUInt( reqInfo[1], 16 )
            net.SendToServer()
        end
    },
    ["AssociationInvite"] = {
        Name = BRICKS_SERVER.Func.L( "gangAssociationInvite" ),
        ReqInfo = {
            [1] = { "InviterGangID", "integer" },
            [2] = { "InviterGangName", "string" },
            [3] = { "AssociationType", "string" }
        },
        FormatDescription = function( reqInfo )
            return BRICKS_SERVER.Func.L( "gangAssociationInviteInbox", reqInfo[2], reqInfo[3] )
        end,
        AcceptFunc = function( reqInfo ) 
            net.Start( "BRS.Net.AcceptGangAssociation" )
                net.WriteUInt( reqInfo[1], 16 )
            net.SendToServer()
        end
    },
    ["AssociationCreated"] = {
        Name = BRICKS_SERVER.Func.L( "gangAssociationCreated" ),
        ReqInfo = {
            [1] = { "OtherGangID", "integer" },
            [2] = { "OtherGangName", "string" },
            [3] = { "AssociationType", "string" }
        },
        FormatDescription = function( reqInfo )
            return BRICKS_SERVER.Func.L( "gangAssociationCreatedInbox", reqInfo[3], reqInfo[2] )
        end
    },
    ["AssociationDissolved"] = {
        Name = BRICKS_SERVER.Func.L( "gangAssociationDissolved" ),
        ReqInfo = {
            [1] = { "OtherGangID", "integer" },
            [2] = { "OtherGangName", "string" }
        },
        FormatDescription = function( reqInfo )
            return BRICKS_SERVER.Func.L( "gangAssociationDissolvedInbox", reqInfo[2] )
        end
    },
    ["AdminMail"] = {
        Name = BRICKS_SERVER.Func.L( "gangAdminNotification" ),
        ReqInfo = {
            [1] = { "Header", "string" },
            [2] = { "Description", "string" }
        },
        FormatHeader = function( reqInfo )
            return reqInfo[1]
        end,
        FormatDescription = function( reqInfo )
            return reqInfo[2]
        end
    },
    ["Achievement"] = {
        Name = BRICKS_SERVER.Func.L( "gangInboxAchievement" ),
        ReqInfo = {
            [1] = { "Achievement Key", "integer" }
        },
        FormatDescription = function( reqInfo )
            local achievementConfig = BRICKS_SERVER.CONFIG.GANGS.Achievements[reqInfo[1]]

            return BRICKS_SERVER.Func.L( "gangInboxAchievementCompleted", achievementConfig.Name )
        end
    },
    ["AchievementReward"] = {
        Name = BRICKS_SERVER.Func.L( "gangInboxAchievement" ),
        ReqInfo = {
            [1] = { "Achievement Key", "integer" },
            [2] = { "Achievement Rewards", "table" }
        },
        FormatDescription = function( reqInfo )
            local rewardString = ""
            for k, v in pairs( reqInfo[2] or {} ) do
                local devConfigReward = BRICKS_SERVER.DEVCONFIG.GangRewards[k]

                if( not devConfigReward ) then continue end

                if( rewardString == "" ) then
                    rewardString =  devConfigReward.FormatDescription( v )
                else
                    rewardString = rewardString .. ", " .. devConfigReward.FormatDescription( v )
                end
            end

            local achievementConfig = BRICKS_SERVER.CONFIG.GANGS.Achievements[reqInfo[1]]

            return BRICKS_SERVER.Func.L( "gangInboxAchievementCompletedReward", achievementConfig.Name, rewardString )
        end,
        AcceptFunc = function( reqInfo, inboxKey ) 
            net.Start( "BRS.Net.GangAchievementClaim" )
                net.WriteUInt( inboxKey, 16 )
            net.SendToServer()
        end
    }
}

BRICKS_SERVER.DEVCONFIG.GangRewards = {
    ["GangExperience"] = {
        Name = BRICKS_SERVER.Func.L( "gangExperienceFull" ),
        Color = Color( 22, 160, 133 ),
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "experience" ), "integer" }
        },
        FormatDescription = function( reqInfo )
            return BRICKS_SERVER.Func.FormatGangEXP( reqInfo[1] or 0 ) .. " " .. BRICKS_SERVER.Func.L( "exp" )
        end,
        RewardFunc = function( gangID, reqInfo )
            BRICKS_SERVER.Func.AddGangExperience( gangID, reqInfo[1] )

            return true
        end
    },
    ["GangBalance"] = {
        Name = BRICKS_SERVER.Func.L( "gangBalanceFull" ),
        Color = Color( 39, 174, 96 ),
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "money" ), "integer" }
        },
        FormatDescription = function( reqInfo )
            return DarkRP.formatMoney( reqInfo[1] or 0 )
        end,
        RewardFunc = function( gangID, reqInfo )
            BRICKS_SERVER.Func.AddGangBalance( gangID, reqInfo[1] )
        end
    }
}

hook.Add("bWhitelist:Init", "BricksServerHooks_bWhitelist:Init_Gang", function()
    BRICKS_SERVER.DEVCONFIG.GangRewards["bWhitelist"] = {
        Name = BRICKS_SERVER.Func.L( "gangJobWhitelist" ),
        Temporary = true,
        Color = Color( 52, 152, 219 ),
        ReqInfo = {
            [1] = { BRICKS_SERVER.Func.L( "gangJobs" ), "custom", function( rewardTable, rewardKey, reqInfoKey, currentReqInfo )
                BRICKS_SERVER.Func.CreateTeamSelector( (currentReqInfo or {}), BRICKS_SERVER.Func.L( "gangJobsSelect" ), function( teamTable ) 
                    if( table.Count( teamTable ) > 0 ) then
                        rewardTable[rewardKey] = rewardTable[rewardKey] or {}
                        rewardTable[rewardKey][reqInfoKey] = teamTable
                    else
                        rewardTable[rewardKey] = nil
                    end
                end, function() end )
            end }
        },
        FormatDescription = function( reqInfo )
            local jobString = ""
            for k, v in pairs( reqInfo[1] or {} ) do
                for key, val in pairs( RPExtraTeams ) do
                    if( val.command == k ) then
                        if( jobString == "" ) then
                            jobString = val.name
                        else
                            jobString = jobString .. ", " .. val.name
                        end
                        break
                    end
                end
            end

            return jobString
        end,
        RewardFunc = function( gangID, reqInfo )
            local teams = {}
            for k, v in pairs( reqInfo[1] or {} ) do
                for key, val in pairs( RPExtraTeams ) do
                    if( val.command == k ) then
                        table.insert( teams, k )
                        break
                    end
                end
            end

            local gangTable = (BRICKS_SERVER_GANGS or {})[gangID] or {}

            for k, v in pairs( teams ) do
                for key, val in pairs( gangTable.Members ) do
                    GAS.JobWhitelist:AddToWhitelist( v, GAS.JobWhitelist.LIST_TYPE_STEAMID, key )
                end
            end

            return true
        end,
        UnRewardFunc = function( gangID, reqInfo )
            local teams = {}
            for k, v in pairs( reqInfo[1] or {} ) do
                for key, val in pairs( RPExtraTeams ) do
                    if( val.command == k ) then
                        table.insert( teams, k )
                        break
                    end
                end
            end

            local gangTable = (BRICKS_SERVER_GANGS or {})[gangID] or {}

            for k, v in pairs( teams ) do
                for key, val in pairs( gangTable.Members ) do
                    GAS.JobWhitelist:RemoveFromWhitelist( v, GAS.JobWhitelist.LIST_TYPE_STEAMID, key )
                end
            end

            return true
        end
    }
end )

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "leaderboards" ) ) then
    BRICKS_SERVER.DEVCONFIG.GangLeaderboards = {
        ["Experience"] = {
            Name = BRICKS_SERVER.Func.L( "experience" ),
            Color = Color( 22, 160, 133 ),
            FormatDescription = function( value )
                return BRICKS_SERVER.Func.FormatGangEXP( value or 0 ) .. " " .. BRICKS_SERVER.Func.L( "exp" )
            end,
            GetSortValue = function( gangTable )
                return gangTable.Experience or 0
            end
        },
        ["Members"] = {
            Name = BRICKS_SERVER.Func.L( "gangMembers" ),
            Color = Color( 41, 128, 185 ),
            FormatDescription = function( value )
                return (value or 0) .. " " .. (((value or 0) != 1 and BRICKS_SERVER.Func.L( "gangMembers" )) or BRICKS_SERVER.Func.L( "gangMember" ))
            end,
            GetSortValue = function( gangTable )
                return table.Count( gangTable.Members or {} )
            end
        },
        ["Balance"] = {
            Name = BRICKS_SERVER.Func.L( "gangBalance" ),
            Color = Color( 39, 174, 96 ),
            FormatDescription = function( value )
                return DarkRP.formatMoney( value or 0 )
            end,
            GetSortValue = function( gangTable )
                return gangTable.Money or 0
            end
        }
    }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "storage" ) ) then
        BRICKS_SERVER.DEVCONFIG.GangLeaderboards["StorageItems"] = {
            Name = BRICKS_SERVER.Func.L( "gangStorageItems" ),
            Color = Color( 231, 76, 60 ),
            FormatDescription = function( value )
                return (value or 0) .. " " .. (((value or 0) != 1 and BRICKS_SERVER.Func.L( "gangItems" )) or BRICKS_SERVER.Func.L( "gangItem" ))
            end,
            GetSortValue = function( gangTable )
                return table.Count( gangTable.Storage or {} )
            end
        }
    end
end

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "associations" ) ) then
    BRICKS_SERVER.DEVCONFIG.GangAssociationTypes = {
        ["Allies"] = {
            Icon = "flag.png",
            Color = Color( 52, 152, 219 ),
            Query = BRICKS_SERVER.Func.L( "gangAllyRequest" )
        },
        ["War"] = {
            Icon = "gang_war.png",
            Color = Color( 231, 76, 60 ),
            Query = BRICKS_SERVER.Func.L( "gangWarRequest" )
        },
    }
end

BRICKS_SERVER.DEVCONFIG.GangAdminCmds = {
    [1] = {
        Name = BRICKS_SERVER.Func.L( "gangSetLevel" ),
        Icon = "levelling.png",
        ReqInfo = {
            [1] = { "Level", "integer", false, BRICKS_SERVER.Func.L( "gangSetLevelQuery" ) }
        },
        ServerFunc = function( gangTable, gangID, reqInfo )
            local newLevel = math.Clamp( reqInfo[1] or (gangTable.Level or 0), 0, BRICKS_SERVER.CONFIG.GANGS["Max Level"] )
            BRICKS_SERVER.Func.SetGangLevel( gangID, newLevel )
            BRICKS_SERVER.Func.SetGangExperience( gangID, BRICKS_SERVER.Func.GetGangExpToLevel( 0, newLevel ) )
            return BRICKS_SERVER.Func.L( "gangSetLevelMsg", (gangTable.Name or "NIL"), newLevel )
        end
    },
    [2] = {
        Name = BRICKS_SERVER.Func.L( "gangAddExperience" ),
        Icon = "gang_experience.png",
        ReqInfo = {
            [1] = { "Experience", "integer", false, BRICKS_SERVER.Func.L( "gangAddExperienceQuery" ) }
        },
        ServerFunc = function( gangTable, gangID, reqInfo )
            local experience = reqInfo[1] or (gangTable.Experience or 0)
            BRICKS_SERVER.Func.AddGangExperience( gangID, experience )
            return BRICKS_SERVER.Func.L( "gangAddExperienceMsg", BRICKS_SERVER.Func.FormatGangEXP( experience ), (gangTable.Name or "NIL") )
        end
    },
    [3] = {
        Name = BRICKS_SERVER.Func.L( "gangSetBalance" ),
        Icon = "balance.png",
        ReqInfo = {
            [1] = { "Money", "integer", false, BRICKS_SERVER.Func.L( "gangSetBalanceQuery" ) }
        },
        ServerFunc = function( gangTable, gangID, reqInfo )
            local newBalance = reqInfo[1] or (gangTable.Money or 0)
            BRICKS_SERVER.Func.SetGangBalance( gangID, newBalance )
            return BRICKS_SERVER.Func.L( "gangSetBalanceMsg", (gangTable.Name or "NIL"), DarkRP.formatMoney( newBalance ) )
        end
    },
    [4] = {
        Name = BRICKS_SERVER.Func.L( "gangAddBalance" ),
        Icon = "gang_add_money.png",
        ReqInfo = {
            [1] = { "Money", "integer", false, BRICKS_SERVER.Func.L( "gangAddBalanceQuery" ) }
        },
        ServerFunc = function( gangTable, gangID, reqInfo )
            local addBalance = reqInfo[1] or 0
            BRICKS_SERVER.Func.AddGangBalance( gangID, addBalance )
            return BRICKS_SERVER.Func.L( "gangAddBalanceMsg", DarkRP.formatMoney( addBalance ), (gangTable.Name or "NIL") )
        end
    },
    [5] = {
        Name = BRICKS_SERVER.Func.L( "gangViewMembers" ),
        Icon = "gang_viewmembers.png",
        ClientFunc = function( gangTable, gangID, panel )
            panel:ViewMembers()
        end
    },
    [6] = { -- Kick member
        ReqInfo = {
            [1] = { "MemberSteamID", "string" }
        },
        ServerFunc = function( gangTable, gangID, reqInfo )
            if( gangTable.Owner == reqInfo[1] ) then
                return BRICKS_SERVER.Func.L( "gangCantKickOwner" )
            end

            local success = BRICKS_SERVER.Func.GangKickMember( gangID, reqInfo[1] )

            return (success and BRICKS_SERVER.Func.L( "gangKickSuccessAdmin" )) or BRICKS_SERVER.Func.L( "gangKickFailAdmin" )
        end
    },
    [7] = { -- Set member rank
        ReqInfo = {
            [1] = { "MemberSteamID", "string" },
            [2] = { "NewRank", "integer" }
        },
        ServerFunc = function( gangTable, gangID, reqInfo )
            local success = BRICKS_SERVER.Func.GangMemberSetRank( gangID, reqInfo[1], reqInfo[2] )

            return (success and BRICKS_SERVER.Func.L( "gangSetRankSuccessAdmin" )) or BRICKS_SERVER.Func.L( "gangSetRankFailAdmin" )
        end
    },
    [8] = { -- Transfer ownership
        ReqInfo = {
            [1] = { "MemberSteamID", "string" }
        },
        ServerFunc = function( gangTable, gangID, reqInfo )
            if( gangTable.Owner == reqInfo[1] ) then
                return BRICKS_SERVER.Func.L( "gangMemberAlreadyOwner" )
            end

            if( not gangTable.Members or not gangTable.Members[reqInfo[1]] ) then 
                return BRICKS_SERVER.Func.L( "gangNotMember" )
            end
        
            BRICKS_SERVER.Func.UpdateGangTable( gangID, "Owner", reqInfo[1] )

            return BRICKS_SERVER.Func.L( "gangOwnershipTransferedAdmin" )
        end
    },
    [9] = {
        Name = BRICKS_SERVER.Func.L( "delete" ),
        Icon = "gang_delete.png",
        ClientFunc = function( gangTable, gangID, panel )
            BRICKS_SERVER.Func.StringRequest( BRICKS_SERVER.Func.L( "gang" ), BRICKS_SERVER.Func.L( "gangDeleteAdminQuery", string.upper( gangTable.Name or "" ) ), "", function( text ) 
                if( text == string.upper( gangTable.Name ) ) then
                    net.Start( "BRS.Net.AdminGangCMD" )
                        net.WriteUInt( 9, 8 )
                        net.WriteUInt( gangID, 16 )
                        net.WriteTable( {} )
                    net.SendToServer()
                end
            end, function() end, BRICKS_SERVER.Func.L( "ok" ), BRICKS_SERVER.Func.L( "cancel" ), false )
        end,
        ServerFunc = function( gangTable, gangID, reqInfo )
            BRICKS_SERVER.Func.DeleteGangTable( gangID )

            return BRICKS_SERVER.Func.L( "gangDeleteSuccessAdmin", gangTable.Name )
        end
    }
}

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "gangs", "printers" ) ) then
    BRICKS_SERVER.DEVCONFIG.GangServerUpgradeTypes = {
        ["Cooling"] = {
            Name = "Cooling",
            Icon = Material( "bricks_server/gangprinter_upgrade_cooling.png" ),
            Tiered = true,
            ReqInfo = {
                [1] = { "Temperature Decrease", "integer" }
            },
            SetFunc = function( ent, server, tier, upgradeConfig )
                ent:SetNW2Int( "CoolingServer" .. server, tier )

                if( tier >= #upgradeConfig.Tiers/2 ) then
                    ent:SetBodygroup( 8+((server-1)*2), 1 )

                    if( tier >= #upgradeConfig.Tiers ) then
                        ent:SetBodygroup( 8+((server-1)*2)+1, 1 )
                    end
                end
            end,
            GetFunc = function( ent, server )
                return ent:GetNW2Int( "CoolingServer" .. server, 0 )
            end
        },
        ["Speed"] = {
            Name = "Speed",
            Icon = Material( "bricks_server/gangprinter_upgrade_speed.png" ),
            Tiered = true,
            ReqInfo = {
                [1] = { "Speed Increase", "integer" }
            },
            SetFunc = function( ent, server, tier, upgradeConfig )
                ent:SetNW2Int( "SpeedServer" .. server, tier )
            end,
            GetFunc = function( ent, server )
                return ent:GetNW2Int( "SpeedServer" .. server, 0 )
            end
        },
        ["Amount"] = {
            Name = "Amount",
            Icon = Material( "bricks_server/gangprinter_upgrade_amount.png" ),
            Tiered = true,
            ReqInfo = {
                [1] = { "Amount Increase", "integer" }
            },
            SetFunc = function( ent, server, tier, upgradeConfig )
                ent:SetNW2Int( "AmountServer" .. server, tier )
            end,
            GetFunc = function( ent, server )
                return ent:GetNW2Int( "AmountServer" .. server, 0 )
            end
        }
    }

    BRICKS_SERVER.DEVCONFIG.GangPrinterUpgradeTypes = {
        ["Health"] = {
            Name = "Health",
            Icon = Material( "bricks_server/gangprinter_upgrade_health.png" ),
            Tiered = true,
            ReqInfo = {
                [1] = { "Health Increase", "integer" }
            },
            SetFunc = function( ent, value )
                ent:SetNW2Int( "HealthUpgrade", value )
            end,
            GetFunc = function( ent )
                return ent:GetNW2Int( "HealthUpgrade", 0 )
            end
        },
        ["RGB"] = {
            Name = "RGB",
            SetFunc = function( ent, value )
                ent:SetNW2Bool( "RGBUpgrade", true )

                ent:SetBodygroup( 7, 1 )
            end,
            GetFunc = function( ent )
                return ent:GetNW2Bool( "RGBUpgrade", false )
            end
        }
    }
end

BRICKS_SERVER.DEVCONFIG.PresetGangIcons = {
    "bricks_server/gang_viewmembers.png",
    "bricks_server/gang_add_money.png",
    "bricks_server/storage_64.png"
}

-- 1: sql key (set to false to not save to DB), 2: data type
BRICKS_SERVER.DEVCONFIG.GangTableKeys = {
    ["Name"] = { "gangName", "string" },
    ["Icon"] = { "gangIcon", "string" },
    ["Owner"] = { "owner", "string" },
    ["Level"] = { "level", "integer" },
    ["Experience"] = { "experience", "integer" },
    ["Money"] = { "money", "integer" },
    ["Storage"] = { "storage", "table" },
    ["Members"] = { "members", "table" },
    ["Roles"] = { "roles", "table" },
    ["Upgrades"] = { "upgrades", "table" },
    ["Achievements"] = { "achievements", "table" },
    ["Printers"] = { false, "table" },
}

BRICKS_SERVER.DEVCONFIG.NPCTypes = BRICKS_SERVER.DEVCONFIG.NPCTypes or {}
BRICKS_SERVER.DEVCONFIG.NPCTypes["Gang"] = {
    UseFunction = function( ply, ent, NPCKey )
        BRICKS_SERVER.Func.OpenGangMenu( ply )
    end
}

BRICKS_SERVER.DEVCONFIG.EntityTypes = BRICKS_SERVER.DEVCONFIG.EntityTypes or {}
BRICKS_SERVER.DEVCONFIG.EntityTypes["bricks_server_territory"] = { 
    GetDataFunc = function( entity ) 
        return entity:GetTerritoryKey() or 0
    end,
    SetDataFunc = function( entity, data ) 
        return entity:SetTerritoryKeyFunc( data or 0 )
    end
}