local _, Addon = ...;

Addon.CONFIG = CreateFrame( 'Frame' );
Addon.CONFIG:RegisterEvent( 'ADDON_LOADED' );
Addon.CONFIG:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then

        --
        --  Get module defaults
        --
        --  @return table
        Addon.CONFIG.GetDefaults = function( self )
            return {
                Font = {
                    Family = 'ARIALN',
                    Size = 14,
                    Flags = 'THINOUTLINE',
                },
                FadeOut = false,
                IgnoreList = {
                    'boost',
                },
                MentionAlert = true,
                MentionTime = 20,
                AliasList = {
                },
                ScrollBack = true,
                QuestAlert = true,
                ChannelColor = {
                    254 / 255,
                    191 / 255,
                    191 / 255,
                    1,
                },
                AlertColor = {
                    224 / 255,
                    157 / 255,
                    240 / 255,
                    1,
                },
                AlertSound = false,
                AlertList = {
                },
                FullHighlight = true,
                Channels = {},
                ChatGroups = {
                    BATTLEGROUND = true,
                    TRADESKILLS = false,
                    SAY = true,
                    EMOTE = true,
                    YELL = true,
                    GUILD = true,
                    WHISPER = true,
                    BN = true,
                    PARTY = true,
                    RAID = true,
                    COMBAT = true,
                    SKILL = true,
                    LOOT = true,
                    MONEY = true,
                    OPENING = true,
                    PET = false,
                    ERRORS = true,
                    IGNORED = true,
                    CHANNEL = true,
                },
                ChatFilters = {
                    PARTY = true,
                    RAID = true,
                    GUILD = true,
                    YELL = true,
                    SAY = false,
                    CHANNEL = true,
                    WHISPER = true,
                },
                showTimestamps = '%I:%M:%S %p ',
                AutoInvite = true,
                DungeonQueue = {
                },
                RaidQueue = {
                },
                ColorNamesByClass = true,
                Roles = {
                    DPS = true,
                    HEALER = false,
                    TANK = false,
                },
            };
        end

        --
        --  Get module settings
        --
        --  @return table
        Addon.CONFIG.GetSettings = function( self )
            local function GetAlerts()
                local Order = 1;
                local Settings = {
                    Alerts = {
                        type = 'header',
                        order = Order,
                        name = 'Custom Alerts',
                    },
                };
                Order = Order+1;
                Settings.AlertList = {
                    type = 'input',
                    order = Order,
                    multiline = true,
                    get = function( Info )
                        return Addon:Implode( self:GetAlerts(),',' );
                    end,
                    set = function( Info,Value )
                        self:SetAlerts( Value );
                    end,
                    name = 'Alert List',
                    desc = 'Words or phrases to be alerted on when they are mentioned in chat. Seperate individual things to alert on with a comma: e.g. healer,spriest,sfk,really cool',
                    arg = 'AlertList',
                    width = 'full',
                };
                Order = Order+1;
                Settings.IgnoreList = {
                    type = 'input',
                    order = Order,
                    multiline = true,
                    get = function( Info )
                        return Addon:Implode( self:GetIgnores(),',' );
                    end,
                    set = function( Info,Value )
                        self:SetIgnores( Value );
                    end,
                    name = 'Ignore List',
                    desc = 'Words or phrases which should be omitted in chat. Seperate individual things to ignore with a comma: e.g. boost,spam,anidiot,absolutely terrible',
                    arg = 'IgnoreList',
                    width = 'full',
                };
                Order = Order+1;
                Settings.AlertMention = {
                    type = 'toggle',
                    order = Order,
                    name = 'Mention Alert',
                    desc = 'Enable/disable alerting if anyone mentions your name. Note that mentions always produce an alert sound and have the whisper color',
                    arg = 'MentionAlert',
                };
                Order = Order+1;
                Settings.MentionTime = {
                    type = 'range',
                    order = Order,
                    name = 'Mention Duration',
                    desc = 'The duration of time in seconds to show mention alerts',
                    min = 10, max = 120, step = 10,
                    arg = 'MentionTime',
                };
                Order = Order+1;
                Settings.AliasList = {
                    type = 'input',
                    order = Order,
                    multiline = true,
                    get = function( Info )
                        return Addon:Implode( self:GetAliasList(),',' );
                    end,
                    set = function( Info,Value )
                        self:SetAliasList( Value );
                    end,
                    name = 'Alias List',
                    desc = 'Comma seperated list of aliases for your character name, to be used in mention alerts',
                    arg = 'Aliases',
                    width = 'normal',
                    multiline = false,
                };
                Order = Order+1;
                Settings.AlertQuest = {
                    type = 'toggle',
                    order = Order,
                    name = 'Quest Alert',
                    desc = 'Enable/disable alerting if anyone mentions a quest you are on',
                    arg = 'QuestAlert',
                };
                Order = Order+1;
                Settings.AlertColor = {
                    type = 'color',
                    order = Order,
                    get = function( Info )
                        if( Addon.APP.persistence[ Info.arg ] ~= nil ) then
                            return unpack( Addon.APP.persistence[ Info.arg ] );
                        end
                    end,
                    set = function( Info,R,G,B,A )
                        if( Addon.APP.persistence[ Info.arg ] ~= nil ) then
                            Addon.APP.persistence[ Info.arg ] = { R,G,B,A };
                        end
                    end,
                    name = 'Alert Color',
                    desc = 'Set the color of Alerts chat',
                    arg = 'AlertColor',
                };
                Order = Order+1;
                Settings.AlertSound = {
                    type = 'toggle',
                    order = Order,
                    name = 'Sound Alert',
                    desc = 'Enable/disable chat Alert sound',
                    arg = 'AlertSound',
                };
                for FilterName,FilterData in pairs( self:GetChatFilters() ) do
                    Order = Order+1;
                    local Disabled = false;
                    if( FilterName == 'WHISPER' ) then
                        Disabled = true;
                    end
                    Settings[ FilterName..'Alert' ] = {
                        type = 'toggle',
                        order = Order,
                        name = FilterName,
                        disabled = Disabled,
                        desc = 'Enable/disable alerting for '..FilterName..' messages',
                        arg = FilterName,
                        get = function( Info )
                            if( Addon.APP.persistence.ChatFilters[ Info.arg ] ~= nil ) then
                                return Addon.APP.persistence.ChatFilters[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            if( Addon.APP.persistence.ChatFilters[ Info.arg ] ~= nil ) then
                                Addon.APP.persistence.ChatFilters[ Info.arg ] = Value;
                                for _,FilterName in pairs( self:GetChatFilters()[ Info.arg ] ) do
                                    Addon.FILTER:SetFilter( FilterName,Value );
                                end
                            end
                        end,
                    };
                end
                --[[
                Order = Order+1;
                Settings.FullHighLight = {
                    type = 'toggle',
                    order = Order,
                    name = 'Fully Highlight Message',
                    desc = 'Enable/disable highlighting entire message alerts during match',
                    arg = 'FullHighlight',
                };
                ]]

                return Settings;
            end
            local function GetDungeons()

                local Order = 1;
                local Settings = {
                    DungeonGroups = {
                        type = 'header',
                        order = Order,
                        name = 'Classic Dungeon Groups',
                    },
                };
                for Abbrev,Instance in pairs( Addon.DUNGEONS:GetDungeonsF( UnitLevel( 'player' ) ) ) do
                    Order = Order + 1;
                    Settings[ Abbrev ] = {
                        type = 'toggle',
                        order = Order,
                        name = CreateColor( unpack( Instance.Color ) ):WrapTextInColorCode( Instance.Name ),
                        desc = Instance.Description,
                        arg = Abbrev,
                        disabled = Instance.Disabled,
                        get = function( Info )
                            if( Addon.APP.persistence.DungeonQueue[ Info.arg ] ~= nil ) then
                                return Addon.APP.persistence.DungeonQueue[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            local ABBREV = Info.arg;
                            Addon.APP.persistence.DungeonQueue[ ABBREV ] = Value;
                        end,
                    };
                end
                for Abbrev,Instance in pairs( Addon.DUNGEONS:GetRaidsF( UnitLevel( 'player' ) ) ) do
                    Order = Order + 1;
                    Settings[ Abbrev ] = {
                        type = 'toggle',
                        order = Order,
                        name = CreateColor( unpack( Instance.Color ) ):WrapTextInColorCode( Instance.Name ),
                        desc = Instance.Description,
                        arg = Abbrev,
                        disabled = Instance.Disabled,
                        get = function( Info )
                            if( Addon.APP.persistence.RaidQueue[ Info.arg ] ~= nil ) then
                                return Addon.APP.persistence.RaidQueue[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            Addon.APP.persistence.RaidQueue[ Info.arg ] = Value;
                        end,
                    };
                end

                return Settings;
            end
            local function GetTypes()
                local Order = 1;
                local Settings = {
                    FilterTypes = {
                        type = 'header',
                        order = Order,
                        name = 'Message Types',
                    }
                };
                for GroupName,GroupData in pairs( self:GetMessageGroups() ) do
                    Order = Order+1;
                    Settings[ GroupName..'Message' ] = {
                        type = 'toggle',
                        order = Order,
                        name = GroupName,
                        desc = 'Enable/disable messages for '..GroupName,
                        arg = GroupName,
                        get = function( Info )
                            if( Addon.APP.persistence.ChatGroups[ Info.arg ] ~= nil ) then
                                return Addon.APP.persistence.ChatGroups[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            if( Addon.APP.persistence.ChatGroups[ Info.arg ] ~= nil ) then
                                Addon.APP.persistence.ChatGroups[ Info.arg ] = Value;
                                for _,GroupName in pairs( self:GetMessageGroups()[ Info.arg ] ) do
                                    -- Always allow outgoing whispers
                                    if( Addon:Minify( GroupName ):find( 'whisperinform' ) ) then
                                        Value = true;
                                    end
                                    Addon.APP:SetGroup( GroupName,Value );
                                end
                            end
                        end,
                    };
                end

                return Settings;
            end
            local function GetGeneral()
                local Order = 1;
                local Settings = {
                    General = {
                        type = 'header',
                        order = Order,
                        name = 'General',
                    },
                };
                Order = Order+1;
                Settings.ScrollBack = {
                    type = 'toggle',
                    order = Order,
                    name = 'Scroll Back',
                    desc = 'Extend chat history to 10,000 lines',
                    arg = 'ScrollBack',
                };
                Order = Order+1;
                Settings.FadeOut = {
                    type = 'toggle',
                    order = Order,
                    name = 'Fade Out',
                    desc = 'Enable/disable chat fading',
                    arg = 'FadeOut',
                };
                Order = Order+1;
                Settings.ClassColor = {
                    type = 'toggle',
                    order = Order,
                    name = 'Class Color',
                    desc = 'Enable/disable chat class colors',
                    arg = 'ColorNamesByClass',
                };
                Order = Order+1;
                Settings.FontFamily = {
                    type = 'select',
                    get = function( Info )
                        if( Addon.APP.persistence.Font[ Info.arg ] ~= nil ) then
                            return Addon.APP.persistence.Font[ Info.arg ];
                        end
                    end,
                    set = function( Info,Value )
                        if( Addon.APP.persistence.Font[ Info.arg ] ~= nil ) then
                            Addon.APP.persistence.Font[ Info.arg ] = Value;
                        end
                        Addon.CHAT:SetFont( Addon.APP:GetValue( 'Font' ),Addon.APP.ChatFrame );
                    end,
                    values = {
                        skurri = 'skurri',
                        ARIALN = 'ARIALN',
                        MORPHEUS = 'MORPHEUS',
                        FRIZQT__ = 'FRIZQT__',
                    },
                    order = Order,
                    name = 'Font Family',
                    desc = 'Chat Font Family',
                    arg = 'Family',
                };
                Order = Order+1;
                Settings.FontSize = {
                    type = 'select',
                    get = function( Info )
                        if( Addon.APP.persistence.Font[ Info.arg ] ~= nil ) then
                            return Addon.APP.persistence.Font[ Info.arg ];
                        end
                    end,
                    set = function( Info,Value )
                        if( Addon.APP.persistence.Font[ Info.arg ] ~= nil ) then
                            Addon.APP.persistence.Font[ Info.arg ] = Value;
                        end
                        Addon.CHAT:SetFont( Addon.APP:GetValue( 'Font' ),Addon.APP.ChatFrame );
                    end,
                    values = {
                        [10] = 10,
                        [12] = 12,
                        [14] = 14,
                        [16] = 16,
                        [18] = 18,
                    },
                    order = Order,
                    name = 'Font Size',
                    desc = 'Chat Font Size',
                    arg = 'Size',
                };
                Order = Order+1;
                Settings.ShowTimestamps = {
                    type = 'select',
                    values = Addon:ArrayReverse( {
                        none = 'none',
                        hour_min_12 = '%I:%M ',
                        hour_min_ext = '%I:%M %p ',
                        hour_min_sec_12_ext = '%I:%M:%S %p ',
                        hour_min_24 = '%H:%M ',
                        hour_min_sec_24 = '%H:%M:%S ',
                    } ),
                    order = Order,
                    name = 'Timestamps',
                    desc = 'Timestamp format',
                    arg = 'showTimestamps',
                };
                Order = Order+1;
                Settings.AutoInvite = {
                    type = 'toggle',
                    order = Order,
                    name = 'Auto Invite',
                    desc = 'Automatically accept party members who send "inv" messages',
                    arg = 'AutoInvite',
                };

                Order = Order+1;
                Settings.ChannelColors = {
                    type = 'header',
                    order = Order,
                    name = 'Channel Colors',
                };
                for _,ChannelData in pairs( Addon.APP.persistence.Channels ) do
                    if( ChannelData.Name ) then
                        Order = Order+1;
                        Settings[ ChannelData.Name..'Color' ] = {
                            type = 'color',
                            order = Order,
                            get = function( Info )
                                if( Addon.APP.persistence.Channels[ Info.arg ] ~= nil and Addon.APP.persistence.Channels[ Info.arg ].Color ~= nil ) then
                                    return unpack( Addon.APP.persistence.Channels[ Info.arg ].Color );
                                end
                            end,
                            set = function( Info,R,G,B,A )
                                if( Addon.APP.persistence.Channels[ Info.arg ] ~= nil ) then
                                    Addon.APP.persistence.Channels[ Info.arg ].Color = { R,G,B,A };
                                    local Community,ClubId,StreamId = unpack( Addon:Explode( Info.arg,':' ) );
                                    if( Addon:Minify( Community ) == 'community' ) then
                                        local Channel = Chat_GetCommunitiesChannel( ClubId,StreamId );
                                    elseif( Channel ) then
                                        ChangeChatColor( Channel,R,G,B,A );
                                    end
                                end
                                local Channel = Addon.CHAT:GetChannelId( Info.arg );
                                if( Channel ) then
                                    ChangeChatColor( 'CHANNEL'..tostring( Channel ),R,G,B,A );
                                end
                            end,
                            name = ChannelData.Name..' Color',
                            desc = 'Set the color of '..ChannelData.Name..' chat',
                            arg = ChannelData.Name,
                        };
                    end
                end

                return Settings;
            end
            local Settings = {
                type = 'group',
                get = function( Info )
                    return Addon.APP:GetValue( Info.arg );
                end,
                set = function( Info,Value )
                    Addon.APP:SetValue( Info.arg,Value );
                end,
                name = 'jChat Settings',
                desc = 'Simple chat filter',
                childGroups = 'tab',
                args = {
                },
            };
            local Order = 1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'Custom Alerts',
                width = 'full',
                order = Order,
                args = GetAlerts(),
            };

            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                hidden = Addon:IsRetail(),
                type = 'group',
                name = 'Dungeon Alerts',
                width = 'full',
                order = Order,
                args = GetDungeons(),
            };

            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'Message Types',
                width = 'full',
                order = Order,
                args = GetTypes(),
            };

            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'General',
                width = 'full',
                order = Order,
                args = GetGeneral(),
            };

            return Settings;
        end

        --
        --  Create module config frames
        --
        --  @return void
        Addon.CONFIG.CreateFrames = function( self )
            -- Initialize window
            local AppName = string.upper( 'jChat' );
            local BlizOptions = LibStub( 'AceConfigDialog-3.0' ).BlizOptions;
            if( not BlizOptions[ AppName ] ) then
                BlizOptions[ AppName ] = {};
            end
            local Key = AppName;
            if( not BlizOptions[ AppName ][ Key ] ) then
                self.Config = LibStub( 'AceConfigDialog-3.0' ):AddToBlizOptions( AppName,'jChat' );
                self.Config.okay = function( self )
                    RestartGx();
                end
                self.Config.default = function( self )
                    Addon.CHAT.db:ResetDB();
                end
                LibStub( 'AceConfigRegistry-3.0' ):RegisterOptionsTable( AppName,self:GetSettings() );
            end
        end

        Addon.CONFIG.GetChatFilters = function( self )
            return {
                PARTY = {
                    'CHAT_MSG_PARTY',
                    'CHAT_MSG_PARTY_LEADER',
                },
                RAID = {
                    'CHAT_MSG_RAID',
                    'CHAT_MSG_RAID_LEADER',
                    'CHAT_MSG_RAID_WARNING',
                    'CHAT_MSG_INSTANCE_CHAT',
                    'CHAT_MSG_INSTANCE_CHAT_LEADER',
                    'CHAT_MSG_TARGETICONS',
                },
                GUILD = {
                    'CHAT_MSG_GUILD',
                    'CHAT_MSG_OFFICER',
                    'GUILD_MOTD',
                    'PLAYER_GUILD_UPDATE',
                },
                YELL = {
                    'CHAT_MSG_YELL',
                },
                SAY = {
                    'CHAT_MSG_SAY',
                },
                CHANNEL = {
                    'CHAT_MSG_CHANNEL',
                    'CHAT_MSG_CHANNEL_JOIN',
                    'CHAT_MSG_CHANNEL_LEAVE',
                    'CHAT_MSG_COMMUNITIES_CHANNEL',
                },
                WHISPER = {
                    'CHAT_MSG_WHISPER',
                    'CHAT_MSG_WHISPER_INFORM',
                },
            };
        end

        Addon.CONFIG.GetMessageGroups = function( self )
            return {
                SAY = {
                    'SAY',
                    'MONSTER_SAY',
                },
                EMOTE = {
                    'EMOTE',
                    'MONSTER_EMOTE',
                    'MONSTER_BOSS_EMOTE',
                },
                YELL = {
                    'YELL',
                    'MONSTER_YELL',
                },
                GUILD = {
                    'GUILD',
                    'OFFICER',
                },
                WHISPER = {
                    'WHISPER',
                    'WHISPER_INFORM',
                    'SMART_WHISPER',
                    'MONSTER_BOSS_WHISPER',
                    'MONSTER_WHISPER',
                    'RAID_BOSS_WHISPER',
                    'BN_WHISPER',
                    'BN_WHISPER_INFORM',
                    'BN_WHISPER_PLAYER_OFFLINE',
                },
                BN = {
                    'BN_ALERT',
                    'BN_BROADCAST',
                    'BN_BROADCAST_INFORM',
                    'BN_INLINE_TOAST_ALERT',
                    'BN_INLINE_TOAST_BROADCAST',
                    'BN_INLINE_TOAST_BROADCAST_INFORM',
                    'BN_WHISPER',
                    'BN_WHISPER_INFORM',
                    'BN_WHISPER_PLAYER_OFFLINE',
                },
                PARTY = {
                    'PARTY',
                    'PARTY_LEADER',
                },
                RAID = {
                    'RAID',
                    'RAID_LEADER',
                    'RAID_WARNING',
                    'INSTANCE_CHAT',
                    'INSTANCE_CHAT_LEADER',
                },
                COMBAT = {
                    'COMBAT',
                    'COMBAT_XP_GAIN',
                    'COMBAT_HONOR_GAIN',
                    'COMBAT_FACTION_CHANGE',
                },
                SKILL = {
                    'SKILL',
                },
                LOOT = {
                    'LOOT',
                },
                MONEY = {
                    'MONEY',
                },
                TRADESKILLS = {
                    'TRADESKILLS',
                },
                OPENING = {
                    'OPENING',
                },
                PET = {
                    'PET',
                    'PET_INFO',
                },
                BATTLEGROUND = {
                    'BG_SYSTEM_HORDE',
                    'BG_SYSTEM_ALLIANCE',
                    'BG_SYSTEM_NEUTRAL',
                    'BATTLEGROUND',
                },
                ERRORS = {
                    'ERRORS',
                },
                IGNORED = {
                    'IGNORED',
                },
                CHANNEL = {
                    'CHANNEL',
                },
            };
        end

        --
        -- Set watch list
        --
        -- @param string
        --
        -- @return void
        Addon.CONFIG.SetAlerts = function( self,watch )
            watch = Addon:Explode( watch,',' );
            if( type( watch ) == 'table' ) then
                Addon.APP.persistence.AlertList = {};
                for i,v in pairs( watch ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( Addon.APP.persistence.AlertList,Addon:Minify( v ) );
                    end
                end
            else
                Addon.APP.persistence.AlertList = { Addon:Minify( watch ) };
            end
            --Addon:Dump( Addon.APP.persistence.AlertList )
        end

        --
        -- Get watch list
        --
        -- @return table
        Addon.CONFIG.GetAlerts = function( self )
            return Addon.APP.persistence.AlertList;
        end

        --
        -- Set ignore list
        --
        -- @param string
        --
        -- @return void
        Addon.CONFIG.SetIgnores = function( self,ignore )
            ignore = Addon:Explode( ignore,',' );
            if( type( ignore ) == 'table' ) then
                Addon.APP.persistence.IgnoreList = {};
                for i,v in pairs( ignore ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( Addon.APP.persistence.IgnoreList,Addon:Minify( v ) );
                    end
                end
            else
                Addon.APP.persistence.IgnoreList = { Addon:Minify( ignore ) };
            end
            --Addon:Dump( Addon.APP.persistence.IgnoreList )
        end

        --
        -- Get ignore list
        --
        -- @return table
        Addon.CONFIG.GetIgnores = function( self )
            return Addon.APP.persistence.IgnoreList;
        end

        --
        -- Set alias list
        --
        -- @param string
        --
        -- @return void
        Addon.CONFIG.SetAliasList = function( self,Alias )
            Alias = Addon:Explode( Alias,',' );
            if( type( Alias ) == 'table' ) then
                Addon.APP.persistence.AliasList = {};
                for i,v in pairs( Alias ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( Addon.APP.persistence.AliasList,Addon:Minify( v ) );
                    end
                end
            else
                Addon.APP.persistence.AliasList = { Addon:Minify( Alias ) };
            end
            --Addon:Dump( Addon.APP.persistence.AliasList )
        end

        --
        -- Get alist list
        --
        -- @return table
        Addon.CONFIG.GetAliasList = function( self )
            return Addon.APP.persistence.AliasList;
        end

        Addon.CONFIG.RegisterCallbacks = function( self,ChatLib )
            hooksecurefunc( 'ToggleChatMessageGroup',function( Checked,Group )
                if( ChatFrame_ContainsMessageGroup and ChatFrame_ContainsMessageGroup( ChatLib.ChatFrame,Group ) ~= nil ) then
                    ChatLib:SetGroup( Group,Checked );
                end
            end );
        end

        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );