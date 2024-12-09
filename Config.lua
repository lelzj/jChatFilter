local _, Addon = ...;

Addon.CONFIG = CreateFrame( 'Frame' );
Addon.CONFIG:RegisterEvent( 'ADDON_LOADED' );
Addon.CONFIG:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then

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
                Settings.AlertHighlights = {
                    type = 'header',
                    order = Order,
                    name = 'Highlights',
                };

                Order = Order+1;
                Settings.FullHighLight = {
                    type = 'toggle',
                    order = Order,
                    name = 'Fully Highlight Message',
                    desc = 'Enable/disable highlighting entire message alerts during match',
                    arg = 'FullHighlight',
                };
                Order = Order+1;
                Settings.AlertColor = {
                    type = 'color',
                    order = Order,
                    get = function( Info )
                        if( Addon.DB:GetPersistence()[ Info.arg ] ~= nil ) then
                            return unpack( Addon.DB:GetPersistence()[ Info.arg ] );
                        end
                    end,
                    set = function( Info,R,G,B,A )
                        if( Addon.DB:GetPersistence()[ Info.arg ] ~= nil ) then
                            Addon.DB:GetPersistence()[ Info.arg ] = { R,G,B,A };
                        end
                    end,
                    name = 'Alert Color',
                    desc = 'Set the color of Alerts chat',
                    arg = 'AlertColor',
                    --hasAlpha = true,
                };
                Order = Order+1;
                Settings.TimeColor = {
                    type = 'color',
                    order = Order,
                    get = function( Info )
                        if( Addon.DB:GetPersistence()[ Info.arg ] ~= nil ) then
                            return unpack( Addon.DB:GetPersistence()[ Info.arg ] );
                        end
                    end,
                    set = function( Info,R,G,B,A )
                        if( Addon.DB:GetPersistence()[ Info.arg ] ~= nil ) then
                            Addon.DB:GetPersistence()[ Info.arg ] = { R,G,B,A };
                        end
                    end,
                    name = 'Time Color',
                    desc = 'Set the color of Timestamps',
                    arg = 'TimeColor',
                    --hasAlpha = true,
                };

                Order = Order+1;
                Settings.AlertTypes = {
                    type = 'header',
                    order = Order,
                    name = 'Types',
                };
                Order = Order+1;
                Settings.AlertQuest = {
                    type = 'toggle',
                    order = Order,
                    name = 'Quest Alert',
                    desc = 'Enable/disable alerting if anyone mentions a quest you are on',
                    arg = 'QuestAlert',
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
                            if( Addon.DB:GetPersistence().ChatFilters[ Info.arg ] ~= nil ) then
                                return Addon.DB:GetPersistence().ChatFilters[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            if( Addon.DB:GetPersistence().ChatFilters[ Info.arg ] ~= nil ) then
                                Addon.DB:GetPersistence().ChatFilters[ Info.arg ] = Value;
                                for _,FilterName in pairs( self:GetChatFilters()[ Info.arg ] ) do
                                    Addon.APP:SetFilter( FilterName,Value );
                                end
                            end
                        end,
                    };
                end

                Order = Order+1;
                Settings.AlertSounds = {
                    type = 'header',
                    order = Order,
                    name = 'Sounds',
                };
                Order = Order+1;
                Settings.AlertChannel = {
                    type = 'select',
                    order = Order,
                    name = 'Sound Channel',
                    desc = 'Alert sound channel',
                    values = {
                        SFX = 'SFX',
                        Master = 'Master',
                        Music = 'Music',
                        Ambience = 'Ambience',
                        Dialog = 'Dialog',
                    },
                    arg = 'AlertChannel',
                };
                Order = Order+1;
                Settings.AlertVolume = {
                    type = 'range',
                    order = Order,
                    name = 'Sound Volume',
                    desc = 'Alert sound volume',
                    min = 0,max = 1,step = 0.1,
                    set = function( Info,Value )
                        local SoundChannel = Addon.DB:GetValue( 'AlertChannel' );
                        local CVarSetting = 'Sound_'..SoundChannel..'Volume';
                        local SoundChannelVolume = GetCVar( CVarSetting );
                        if( SoundChannelVolume ~= nil ) then
                            SetCVar( CVarSetting,Value );
                        end
                        if( Addon.DB:GetPersistence()[ Info.arg ] ~= nil ) then
                            Addon.DB:GetPersistence()[ Info.arg ] = Value;
                        end
                    end,
                    arg = 'AlertVolume',
                };

                return Settings;
            end
            local function GetMessages()
                local Order = 1;
                local Settings = {
                    Alerts = {
                        type = 'header',
                        order = Order,
                        name = 'Personal Alerts',
                    },
                };

                Order = Order+1;
                Settings.AFKAlert = {
                    type = 'toggle',
                    order = Order,
                    name = 'AFK Whisper Alert',
                    desc = 'Enable to get persistent alerts for whispers while AFK',
                    arg = 'AFKAlert',
                };

                Order = Order+1;
                Settings.AlertMention = {
                    type = 'toggle',
                    order = Order,
                    name = 'Personal Mention Alert',
                    desc = 'Enable/disable alerting if anyone mentions your name. Note that mentions always produce an alert sound and have the whisper color',
                    arg = 'MentionAlert',
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
                Settings.MentionMove = {
                    type = 'select',
                    order = Order,
                    name = 'Move Message Window',
                    desc = 'Reposition message window',
                    values = Addon:ArrayReverse( {
                        Stop = 0,
                        Start = 1,
                    } ),
                    get = function( Info )
                        local Value;
                        if( Addon.DB:GetPersistence()[ Info.arg ] ~= nil ) then
                            Value = Addon.DB:GetPersistence()[ Info.arg ];
                        end
                        if( tonumber( Value ) > 0 ) then
                            Addon.CONFIG.MentionPosition:Show();
                        else
                            Addon.CONFIG.MentionPosition:Hide();
                        end
                        return Value;
                    end,
                    set = function( Info,Value )
                        if( Value > 0 ) then
                            Addon.CONFIG.MentionPosition:Show();
                        else
                            Addon.CONFIG.MentionPosition:Hide();
                        end
                        if( Addon.DB:GetPersistence()[ Info.arg ] ~= nil ) then
                            Addon.DB:GetPersistence()[ Info.arg ] = Value;
                        end
                    end,
                    style = 'radio',
                    arg = 'MentionMove',
                };

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
                for Abbrev,Instance in Addon:Sort( Addon.DUNGEONS:GetDungeonsF( UnitLevel( 'player' ) ) ) do
                    Order = Order + 1;
                    Settings[ Abbrev ] = {
                        type = 'toggle',
                        order = Order,
                        name = CreateColor( unpack( Instance.Color ) ):WrapTextInColorCode( Instance.Name ),
                        desc = Instance.Description,
                        arg = Abbrev,
                        disabled = Instance.Disabled,
                        get = function( Info )
                            if( Addon.DB:GetPersistence().DungeonQueue[ Info.arg ] ~= nil ) then
                                return Addon.DB:GetPersistence().DungeonQueue[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            local ABBREV = Info.arg;
                            Addon.DB:GetPersistence().DungeonQueue[ ABBREV ] = Value;
                        end,
                    };
                end
                Order = Order + 1;
                Settings.RaidGroups = {
                    type = 'header',
                    order = Order,
                    name = 'Classic Raid Groups',
                };
                for Abbrev,Instance in Addon:Sort( Addon.DUNGEONS:GetRaidsF( UnitLevel( 'player' ) ) ) do
                    Order = Order + 1;
                    Settings[ Abbrev ] = {
                        type = 'toggle',
                        order = Order,
                        name = CreateColor( unpack( Instance.Color ) ):WrapTextInColorCode( Instance.Name ),
                        desc = Instance.Description,
                        arg = Abbrev,
                        disabled = Instance.Disabled,
                        get = function( Info )
                            if( Addon.DB:GetPersistence().RaidQueue[ Info.arg ] ~= nil ) then
                                return Addon.DB:GetPersistence().RaidQueue[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            Addon.DB:GetPersistence().RaidQueue[ Info.arg ] = Value;
                        end,
                    };
                end

                return Settings;
            end
            local function GetChannels()
                local Order = 1;
                local Settings = {
                    ChannelMessages = {
                        type = 'header',
                        order = Order,
                        name = 'Message Types',
                    },
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
                            if( Addon.DB:GetPersistence().ChatGroups[ Info.arg ] ~= nil ) then
                                return Addon.DB:GetPersistence().ChatGroups[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            if( Addon.DB:GetPersistence().ChatGroups[ Info.arg ] ~= nil ) then
                                Addon.DB:GetPersistence().ChatGroups[ Info.arg ] = Value;
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

                --[[
                Order = Order+1;
                Settings.Channels = {
                    type = 'header',
                    order = Order,
                    name = 'Channels',
                };

                Order = Order+1;
                Settings.GeneralChannel = {
                    type = 'toggle',
                    order = Order,
                    name = '[1)General]',
                    desc = 'Local General channel',
                    arg = 'general:1',
                    get = function( Info )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:GetConnectedChannel( ChannelName );
                    end,
                    set = function( Info,Value )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:SetConnectedChannel( ChannelName,ChannelId,Value )
                    end,
                };

                Order = Order+1;
                Settings.TradeChannel = {
                    type = 'toggle',
                    order = Order,
                    name = '[2)Trade]',
                    desc = 'Trade channel',
                    arg = 'trade:2',
                    get = function( Info )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:GetConnectedChannel( ChannelName );
                    end,
                    set = function( Info,Value )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:SetConnectedChannel( ChannelName,ChannelId,Value )
                    end,
                };

                Order = Order+1;
                Settings.LocalDefenseChannel = {
                    type = 'toggle',
                    order = Order,
                    name = '[3)LocalDefense]',
                    desc = 'Local Defense channel',
                    arg = 'localdefense:3',
                    get = function( Info )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:GetConnectedChannel( ChannelName );
                    end,
                    set = function( Info,Value )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:SetConnectedChannel( ChannelName,ChannelId,Value )
                    end,
                };

                Order = Order+1;
                Settings.WorldDefenseChannel = {
                    type = 'toggle',
                    order = Order,
                    name = '[4)WorldDefense]',
                    desc = 'World Defense channel',
                    arg = 'worlddefense:4',
                    get = function( Info )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:GetConnectedChannel( ChannelName );
                    end,
                    set = function( Info,Value )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:SetConnectedChannel( ChannelName,ChannelId,Value )
                    end,
                };

                Order = Order+1;
                Settings.LookingForGroupChannel = {
                    type = 'toggle',
                    order = Order,
                    name = '[5)LookingForGroup]',
                    desc = 'LFG/Looking For Group channel',
                    arg = 'lookingforgroup:5',
                    get = function( Info )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:GetConnectedChannel( ChannelName );
                    end,
                    set = function( Info,Value )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:SetConnectedChannel( ChannelName,ChannelId,Value )
                    end,
                };

                Order = Order+1;
                Settings.WorldChannel = {
                    type = 'toggle',
                    order = Order,
                    name = '[6)World]',
                    desc = 'World channel',
                    arg = 'world:6',
                    get = function( Info )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:GetConnectedChannel( ChannelName );
                    end,
                    set = function( Info,Value )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:SetConnectedChannel( ChannelName,ChannelId,Value )
                    end,
                };

                Order = Order+1;
                Settings.RPChannel = {
                    type = 'toggle',
                    order = Order,
                    name = '[7)RP]',
                    desc = 'RolePlay channel',
                    arg = 'rp:7',
                    get = function( Info )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:GetConnectedChannel( ChannelName );
                    end,
                    set = function( Info,Value )
                        local Data = Addon:Explode( Info.arg,':' );
                        local ChannelName,ChannelId = Data[1],Data[2];
                        return self:SetConnectedChannel( ChannelName,ChannelId,Value )
                    end,
                };
                ]]

                Order = Order+1;
                Settings.ChannelColors = {
                    type = 'header',
                    order = Order,
                    name = 'Colors',
                };

                for i,ChannelData in pairs( Addon.CHAT:GetChannels() ) do
                    if( ChannelData.Name ) then

                        -- club
                        local ClubData = Addon:Explode( ChannelData.Name,':' );
                        if( ClubData and tonumber( #ClubData ) > 0 ) then
                            local ClubId = ClubData[2] or 0;
                            if( tonumber( ClubId ) > 0 ) then
                                local ClubInfo = C_Club.GetClubInfo( ClubId );
                                if( ClubInfo ) then
                                    ChannelData.Name = ClubInfo.shortName or ClubInfo.name;
                                    ChannelData.Name = ChannelData.Name:gsub( '%W','' );
                                end
                            end
                        end
                        
                        Order = Order+1;

                        Settings[ ChannelData.Name..'Color' ] = {
                            type = 'color',
                            order = Order,
                            get = function( Info )
                                if( Addon.DB:GetPersistence().Channels[ Info.arg ] ~= nil and Addon.DB:GetPersistence().Channels[ Info.arg ].Color ~= nil ) then
                                    return unpack( Addon.DB:GetPersistence().Channels[ Info.arg ].Color );
                                else
                                    if( Addon.DB:GetValue( 'Debug' ) ) then
                                        Addon:Dump( {
                                            Arg = Info.arg,
                                            AllData = Addon.DB:GetPersistence().Channels,
                                            MyData = Addon.DB:GetPersistence().Channels[ Info.arg ],
                                        });
                                        Addon.FRAMES:Debug( Info.arg,'has no Addon.DB:GetPersistence().Channels entry' );
                                    end
                                end
                            end,
                            set = function( Info,R,G,B,A )
                                if( Addon.DB:GetPersistence().Channels[ Info.arg ] ~= nil ) then
                                    Addon.DB:GetPersistence().Channels[ Info.arg ].Color = { R,G,B,A };
                                    local Community,ClubId,StreamId = unpack( Addon:Explode( Info.arg,':' ) );
                                    if( Addon:Minify( Community ) == 'community' ) then
                                        local Channel = Chat_GetCommunitiesChannel( ClubId,StreamId );
                                    elseif( Channel ) then
                                        ChangeChatColor( Channel,R,G,B,A );
                                    end
                                    local Channel = Addon.CHAT:GetChannelId( Info.arg );
                                    if( Channel ) then
                                        ChangeChatColor( 'CHANNEL'..tostring( Channel ),R,G,B,A );
                                    end
                                end
                            end,
                            name = '['..ChannelData.Id..')'..ChannelData.LongName..']',
                            desc = 'Set the color of '..ChannelData.Name..' chat',
                            arg = ChannelData.Name,
                            --hasAlpha = true,
                        };
                    end
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
                        if( Addon.DB:GetPersistence().Font[ Info.arg ] ~= nil ) then
                            return Addon.DB:GetPersistence().Font[ Info.arg ];
                        end
                    end,
                    set = function( Info,Value )
                        if( Addon.DB:GetPersistence().Font[ Info.arg ] ~= nil ) then
                            Addon.DB:GetPersistence().Font[ Info.arg ] = Value;
                        end
                        Addon.CHAT:SetFont( Addon.APP:GetValue( 'Font' ),Addon.CHAT.ChatFrame );
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
                        if( Addon.DB:GetPersistence().Font[ Info.arg ] ~= nil ) then
                            return Addon.DB:GetPersistence().Font[ Info.arg ];
                        end
                    end,
                    set = function( Info,Value )
                        if( Addon.DB:GetPersistence().Font[ Info.arg ] ~= nil ) then
                            Addon.DB:GetPersistence().Font[ Info.arg ] = Value;
                        end
                        Addon.CHAT:SetFont( Addon.APP:GetValue( 'Font' ),Addon.CHAT.ChatFrame );
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
                Settings.LinksEnabled = {
                    type = 'toggle',
                    order = Order,
                    name = 'Links',
                    desc = 'Automatically convert links to clickable',
                    arg = 'LinksEnabled',
                };

                Order = Order+1;
                Settings.Debug = {
                    type = 'toggle',
                    order = Order,
                    name = 'Debug',
                    desc = 'Show any debug messages',
                    arg = 'Debug',
                };

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
                type = 'group',
                name = 'Personal Messages',
                width = 'full',
                order = Order,
                args = GetMessages(),
            };

            local LFGEnabled;
            --[[if( C_LFGInfo and C_LFGInfo.IsGroupFinderEnabled ) then
                LFGEnabled = C_LFGInfo.IsGroupFinderEnabled();
            end]]
            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                hidden = Addon:IsRetail() or LFGEnabled,
                type = 'group',
                name = 'Dungeon Alerts',
                width = 'full',
                order = Order,
                args = GetDungeons(),
            };

            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'Channels',
                width = 'full',
                order = Order,
                args = GetChannels(),
            };

            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'General',
                width = 'full',
                order = Order,
                args = GetGeneral(),
            };

            Settings.args.profiles = LibStub( 'AceDBOptions-3.0' ):GetOptionsTable( Addon.DB.db );

            return Settings;
        end

        --
        --  Create module config frames
        --
        --  @return void
        Addon.CONFIG.Init = function( self )

            -- Setup Mention
            self.MentionPosition = Addon.FRAMES:AddMovable( {
                Name = 'Mention Alert',
                Value = 'Mention Alert Position\r Drag to your desired location',
            },UIParent );
            self.MentionPosition:Hide();
            self.MentionPosition:SetScript( 'OnDragStop',function( self )

                self:StopMovingOrSizing();
                self:SetUserPlaced( true );

                local p,rt,rp,x,y = self:GetPoint();
                Addon.APP:SetValue( 'MentionDrop',{
                    p = p,
                    rt = rt or 'UIParent',
                    rp = rp,
                    x = x,
                    y = y,
                } );

            end );
            local MentionDrop = Addon.APP:GetValue( 'MentionDrop' );
            if( MentionDrop.x and MentionDrop.y ) then
                self.MentionPosition:SetPoint( MentionDrop.p,MentionDrop.x,MentionDrop.y );
            else
                self.MentionPosition:SetPoint( 'center' );
            end
            self.MentionPosition:Hide();

            -- Initialize window
            local AppName = string.upper( 'jChat' );
            local BlizOptions = LibStub( 'AceConfigDialog-3.0' ).BlizOptions;
            if( not BlizOptions[ AppName ] ) then
                BlizOptions[ AppName ] = {};
            end
            local Key = AppName;
            if( not BlizOptions[ AppName ][ Key ] ) then
                self.Config = LibStub( 'AceConfigDialog-3.0' ):AddToBlizOptions( AppName,'jChat' );

                LibStub( 'AceConfigRegistry-3.0' ):RegisterOptionsTable( AppName,self:GetSettings() );
            end

            hooksecurefunc( self.Config,'OnCommit',function()
                -- handle like window close...
                self.MentionPosition:Hide();
            end );

            hooksecurefunc( self.Config,'OnRefresh',function()
                -- handle like window open...
            end );

            hooksecurefunc( self.Config,'OnDefault',function()
                --print( 'OnDefault',... )
                --Addon.CHAT.db:ResetDB();
            end );

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
                    'CHAT_MSG_CHANNEL_NOTICE_USER',
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
                Addon.DB:GetPersistence().AlertList = {};
                for i,v in pairs( watch ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( Addon.DB:GetPersistence().AlertList,Addon:Minify( v ) );
                    end
                end
            else
                Addon.DB:GetPersistence().AlertList = { Addon:Minify( watch ) };
            end
            --Addon:Dump( Addon.DB:GetPersistence().AlertList )
        end

        --
        -- Get watch list
        --
        -- @return table
        Addon.CONFIG.GetAlerts = function( self )
            return Addon.DB:GetPersistence().AlertList;
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
                Addon.DB:GetPersistence().IgnoreList = {};
                for i,v in pairs( ignore ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( Addon.DB:GetPersistence().IgnoreList,Addon:Minify( v ) );
                    end
                end
            else
                Addon.DB:GetPersistence().IgnoreList = { Addon:Minify( ignore ) };
            end
            --Addon:Dump( Addon.DB:GetPersistence().IgnoreList )
        end

        --
        -- Get ignore list
        --
        -- @return table
        Addon.CONFIG.GetIgnores = function( self )
            return Addon.DB:GetPersistence().IgnoreList;
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
                Addon.DB:GetPersistence().AliasList = {};
                for i,v in pairs( Alias ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( Addon.DB:GetPersistence().AliasList,Addon:Minify( v ) );
                    end
                end
            else
                Addon.DB:GetPersistence().AliasList = { Addon:Minify( Alias ) };
            end
            --Addon:Dump( Addon.DB:GetPersistence().AliasList )
        end

        --
        -- Get channel persistence
        --
        -- @param  string
        -- @return table
        Addon.CONFIG.GetConnectedChannel = function( self,ChannelName )
            return Addon.CHAT:IsChannelJoined( ChannelName );
        end

        --
        -- Set channel persistence
        --
        -- @param  string
        -- @return table
        Addon.CONFIG.SetConnectedChannel = function( self,ChannelName,ChannelId,Connected )
            if( Connected ) then
                return Addon.CHAT:JoinChannel( ChannelName,ChannelId );
            else
                return Addon.CHAT:LeaveChannel( ChannelName );
            end
        end

        --
        -- Get alist list
        --
        -- @return table
        Addon.CONFIG.GetAliasList = function( self )
            return Addon.DB:GetPersistence().AliasList;
        end

        Addon.CONFIG.RegisterCallbacks = function( self,ChatLib )
            hooksecurefunc( 'ToggleChatMessageGroup',function( Checked,Group )
                if( ChatFrame_ContainsMessageGroup and ChatFrame_ContainsMessageGroup( ChatLib.ChatFrame,Group ) ~= nil ) then
                    ChatLib:SetGroup( Group,Checked );
                end
            end );
            hooksecurefunc( 'ToggleChatColorNamesByClassGroup',function( Checked,Group )
                if( Addon.DB:GetValue( 'Debug' ) ) then
                    Addon.FRAMES:Debug( 'App.CONFIG','ToggleChatColorNamesByClassGroup',Checked,Group );
                end
            end );
        end
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );