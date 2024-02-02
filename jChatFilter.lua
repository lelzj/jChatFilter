local _, Addon = ...;

Addon.CHAT = CreateFrame( 'Frame' );
Addon.CHAT:RegisterEvent( 'ADDON_LOADED' );
Addon.CHAT:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then

        --
        --  Get module defaults
        --
        --  @return table
        Addon.CHAT.GetDefaults = function( self )
            return {
                AlertSound = false,
                ChannelColor = {
                    254 / 255,
                    191 / 255,
                    191 / 255,
                    1,
                },
                Font = {
                    Family = 'ARIALN',
                    Size = 12,
                    Flags = 'THINOUTLINE',
                },
                FadeOut = false,
                ClassColor = true,
                GeneralColor = {
                    254 / 255,
                    191 / 255,
                    191 / 255,
                    1,
                },
                WorldColor = {
                    254 / 255,
                    191 / 255,
                    191 / 255,
                    1,
                },
                IgnoreList = {
                    'boost',
                },
                MentionAlert = true,
                ScrollBack = true,
                TimeStamps = true,
                QuestAlert = true,
                WatchColor = {
                    150 / 255,
                    233 / 255,
                    240 / 255,
                    1,
                },
                WatchList = {
                    'heal',
                },
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
                    PET = true,
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
            };
        end

        Addon.CHAT.SetValue = function( self,Index,Value )
            if( self.persistence[ Index ] ~= nil ) then 
                self.persistence[ Index ] = Value;
            end
        end

        Addon.CHAT.GetValue = function( self,Index )
            if( self.persistence[ Index ] ~= nil ) then 
                return self.persistence[ Index ];
            end
        end

        Addon.CHAT.GetVarValue = function( self,Index )
            return self:GetValue( Index );
        end

        Addon.CHAT.SetVarValue = function( self,Index,Value )
            self:SetValue( Index,Value );
        end

        Addon.CHAT.GetMessageGroups = function( self )
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
                },
                WHISPER = {
                    'WHISPER',
                    'MONSTER_BOSS_WHISPER',
                    'MONSTER_WHISPER',
                },
                BN = {
                    'BG_SYSTEM_HORDE',
                    'BG_SYSTEM_ALLIANCE',
                    'BG_SYSTEM_NEUTRAL',
                    'BN_INLINE_TOAST_ALERT',
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

        Addon.CHAT.GetChatFilters = function( self )
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
                },
                --[[WHISPER = {
                    'CHAT_MSG_WHISPER',
                    'CHAT_MSG_WHISPER_INFORM',
                },]]
                GUILD = {
                    'CHAT_MSG_GUILD',
                    'GUILD_MOTD',
                },
                YELL = {
                    'CHAT_MSG_YELL',
                },
                SAY = {
                    'CHAT_MSG_SAY',
                },
                CHANNEL = {
                    'CHAT_MSG_CHANNEL',
                },
                WHISPER = {
                    'WHISPER',
                },
            };
        end

        --
        --  Get module settings
        --
        --  @return table
        Addon.CHAT.GetSettings = function( self )
            local Settings = {
                type = 'group',
                get = function( Info )
                    return self:GetValue( Info.arg );
                end,
                set = function( Info,Value )
                    self:SetValue( Info.arg,Value );
                end,
                name = AddonName,
                desc = 'Simple chat filter',
                args = {
                },
            };

            local Order = 1;
            Settings.args.GeneralSettings = {
                type = 'header',
                order = Order,
                name = 'General Settings',
            }
            Order = Order+1;
            Settings.args.TimeStamps = {
                type = 'toggle',
                order = Order,
                name = 'Time Stamps',
                desc = 'Enable/disable chat timestamps',
                arg = 'TimeStamps',
            };
            Order = Order+1;
            Settings.args.ScrollBack = {
                type = 'toggle',
                order = Order,
                name = 'Scroll Back',
                desc = 'Extend chat history to 10,000 lines',
                arg = 'ScrollBack',
            };
            Order = Order+1;
            Settings.args.FadeOut = {
                type = 'toggle',
                order = Order,
                name = 'Fade Out',
                desc = 'Enable/disable chat fading',
                arg = 'FadeOut',
            };
            Order = Order+1;
            Settings.args.ClassColor = {
                type = 'toggle',
                get = function( Info )
                    return self:GetValue( Info.arg );
                end,
                set = function( Info,Value )
                    self:SetValue( Info.arg,Value );
                    if( Value ) then
                        SetCVar( 'colorChatNamesByClass',true );
                    else
                        SetCVar( 'colorChatNamesByClass',false );
                    end
                end,
                order = Order,
                name = 'Class Color',
                desc = 'Enable/disable chat class colors',
                arg = 'ClassColor',
            };
            Order = Order+1;
            Settings.args.FontFamily = {
                type = 'select',
                get = function( Info )
                    if( Addon.CHAT.persistence.Font[ Info.arg ] ~= nil ) then
                        return Addon.CHAT.persistence.Font[ Info.arg ];
                    end
                end,
                set = function( Info,Value )
                    if( Addon.CHAT.persistence.Font[ Info.arg ] ~= nil ) then
                        Addon.CHAT.persistence.Font[ Info.arg ] = Value;
                    end
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
            Settings.args.FontSize = {
                type = 'select',
                get = function( Info )
                    if( Addon.CHAT.persistence.Font[ Info.arg ] ~= nil ) then
                        return Addon.CHAT.persistence.Font[ Info.arg ];
                    end
                end,
                set = function( Info,Value )
                    if( Addon.CHAT.persistence.Font[ Info.arg ] ~= nil ) then
                        Addon.CHAT.persistence.Font[ Info.arg ] = Value;
                    end
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
            Settings.args.AlertSettings = {
                type = 'header',
                order = Order,
                name = 'Alert Settings',
            };
            Order = Order+1;
            Settings.args.AlertList = {
                type = 'input',
                order = Order,
                multiline = true,
                get = function( Info )
                    return Addon:Implode( self:GetWatches(),',' );
                end,
                set = function( Info,Value )
                    self:SetWatches( Value );
                end,
                name = 'Alert List',
                desc = 'Words or phrases to be alerted on when they are mentioned in chat. Seperate individual things to alert on with a comma: e.g. healer,spriest,sfk,really cool',
                arg = 'WatchList',
                width = 'full',
            };
            Order = Order+1;
            Settings.args.IgnoreList = {
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
            Settings.args.AlertMention = {
                type = 'toggle',
                order = Order,
                name = 'Mention',
                desc = 'Enable/disable alerting if anyone mentions your name',
                arg = 'MentionAlert',
            };
            Order = Order+1;
            Settings.args.AlertQuest = {
                type = 'toggle',
                order = Order,
                name = 'Quest',
                desc = 'Enable/disable alerting if anyone mentions a quest you are on',
                arg = 'QuestAlert',
            };
            Order = Order+1;
            Settings.args.AlertColor = {
                type = 'color',
                order = Order,
                get = function( Info )
                    if( Addon.CHAT.persistence[ Info.arg ] ~= nil ) then
                        return unpack( Addon.CHAT.persistence[ Info.arg ] );
                    end
                end,
                set = function( Info,R,G,B,A )
                    if( Addon.CHAT.persistence[ Info.arg ] ~= nil ) then
                        Addon.CHAT.persistence[ Info.arg ] = { R,G,B,A };
                    end
                end,
                name = 'Color',
                desc = 'Set the color of Alerts chat',
                arg = 'WatchColor',
            };
            Order = Order+1;
            Settings.args.AlertSound = {
                type = 'toggle',
                order = Order,
                name = 'Sound',
                desc = 'Enable/disable chat alert sound',
                arg = 'AlertSound',
            };

            Order = Order+1;
            Settings.args.FilterSettings = {
                type = 'header',
                order = Order,
                name = 'Filter Settings',
            };
            for FilterName,FilterData in pairs( self:GetChatFilters() ) do
                Order = Order+1;
                local Disabled = false;
                if( FilterName == 'WHISPER' ) then
                    Disabled = true;
                end
                Settings.args[ FilterName..'Alert' ] = {
                    type = 'toggle',
                    order = Order,
                    name = FilterName,
                    disabled = Disabled,
                    desc = 'Enable/disable filtering for '..FilterName..' messages',
                    arg = FilterName,
                    get = function( Info )
                        if( Addon.CHAT.persistence.ChatFilters[ Info.arg ] ~= nil ) then
                            return Addon.CHAT.persistence.ChatFilters[ Info.arg ];
                        end
                    end,
                    set = function( Info,Value )
                        if( Addon.CHAT.persistence.ChatFilters[ Info.arg ] ~= nil ) then
                            Addon.CHAT.persistence.ChatFilters[ Info.arg ] = Value;
                            for _,FilterName in pairs( self:GetChatFilters()[ Info.arg ] ) do
                                self:SetFilter( FilterName,Value );
                            end
                        end
                    end,
                };
            end

            Order = Order+1;
            Settings.args.ChannelSettings = {
                type = 'header',
                order = Order,
                name = 'Channel Settings',
            };
            local JoinedChannels = {};
            for i,channel in pairs( self.ChatFrame.channelList ) do
                for ChannelName,ChannelData in pairs( self.persistence.Channels ) do
                    if( channel == ChannelName ) then
                        JoinedChannels[ ChannelName ] = ChannelData;
                    end
                end
            end
            for ChannelName,ChannelData in pairs( JoinedChannels ) do
                Order = Order+1;
                Settings.args[ ChannelName..'Color' ] = {
                    type = 'color',
                    order = Order,
                    get = function( Info )
                        if( Addon.CHAT.persistence.Channels[ Info.arg ] ~= nil and Addon.CHAT.persistence.Channels[ Info.arg ].Color ~= nil ) then
                            return unpack( Addon.CHAT.persistence.Channels[ Info.arg ].Color );
                        end
                    end,
                    set = function( Info,R,G,B,A )
                        if( Addon.CHAT.persistence.Channels[ Info.arg ] ~= nil ) then
                            Addon.CHAT.persistence.Channels[ Info.arg ].Color = { R,G,B,A };
                        end
                    end,
                    name = ChannelName..' Color',
                    desc = 'Set the color of '..ChannelName..' chat',
                    arg = ChannelName,
                };
            end

            Order = Order+1;
            Settings.args.MessageSettings = {
                type = 'header',
                order = Order,
                name = 'Message Settings',
            };
            for GroupName,GroupData in pairs( self:GetMessageGroups() ) do
                Order = Order+1;
                Settings.args[ GroupName..'Message' ] = {
                    type = 'toggle',
                    order = Order,
                    name = GroupName,
                    desc = 'Enable/disable messages for '..GroupName,
                    arg = GroupName,
                    get = function( Info )
                        if( Addon.CHAT.persistence.ChatGroups[ Info.arg ] ~= nil ) then
                            return Addon.CHAT.persistence.ChatGroups[ Info.arg ];
                        end
                    end,
                    set = function( Info,Value )
                        if( Addon.CHAT.persistence.ChatGroups[ Info.arg ] ~= nil ) then
                            Addon.CHAT.persistence.ChatGroups[ Info.arg ] = Value;
                            for _,GroupName in pairs( self:GetMessageGroups()[ Info.arg ] ) do
                                self:SetGroup( GroupName,Value );
                            end
                        end
                    end,
                };
            end

            --[[
            Order = Order+1;
            Settings.args.JoinGeneral = {
                type = 'toggle',
                order = Order,
                get = function( Info )
                    for i,v in pairs( self.ChatFrame.channelList ) do
                        if( Addon:Minify( v ):find( Addon:Minify( Info.arg ) ) ) then
                            return true;
                        end
                    end
                end,
                set = function( Info,Value )
                    if( Value ) then
                        self:JoinChannel( Info.arg );
                    else
                        self:LeaveChannel( Info.arg );
                    end
                end,
                name = 'General',
                desc = 'Join/Leave General',
                arg = 'General',
            };
            Order = Order+1;
            Settings.args.JoinTrade = {
                type = 'toggle',
                order = Order,
                get = function( Info )
                    for i,v in pairs( self.ChatFrame.channelList ) do
                        if( Addon:Minify( v ):find( Addon:Minify( Info.arg ) ) ) then
                            return true;
                        end
                    end
                end,
                set = function( Info,Value )
                    if( Value ) then
                        self:JoinChannel( Info.arg );
                    else
                        self:LeaveChannel( Info.arg );
                    end
                end,
                name = 'Trade',
                desc = 'Join/Leave Trade',
                arg = 'Trade',
            };
            Order = Order+1;
            Settings.args.JoinLocalDefense = {
                type = 'toggle',
                order = Order,
                get = function( Info )
                    for i,v in pairs( self.ChatFrame.channelList ) do
                        if( Addon:Minify( v ):find( Addon:Minify( Info.arg ) ) ) then
                            return true;
                        end
                    end
                end,
                set = function( Info,Value )
                    if( Value ) then
                        self:JoinChannel( Info.arg );
                    else
                        self:LeaveChannel( Info.arg );
                    end
                end,
                name = 'Local Defense',
                desc = 'Join/Leave Local Defense',
                arg = 'LocalDefense',
            };
            Order = Order+1;
            Settings.args.JoinWorldDefense = {
                type = 'toggle',
                order = Order,
                get = function( Info )
                    for i,v in pairs( self.ChatFrame.channelList ) do
                        if( Addon:Minify( v ):find( Addon:Minify( Info.arg ) ) ) then
                            return true;
                        end
                    end
                end,
                set = function( Info,Value )
                    if( Value ) then
                        self:JoinChannel( Info.arg );
                    else
                        self:LeaveChannel( Info.arg );
                    end
                end,
                name = 'World Defense',
                desc = 'Join/Leave World Defense',
                arg = 'WorldDefense',
            };
            Order = Order+1;
            Settings.args.JoinLookingForGroup = {
                type = 'toggle',
                order = Order,
                get = function( Info )
                    for i,v in pairs( self.ChatFrame.channelList ) do
                        if( Addon:Minify( v ):find( Addon:Minify( Info.arg ) ) ) then
                            return true;
                        end
                    end
                end,
                set = function( Info,Value )
                    if( Value ) then
                        self:JoinChannel( Info.arg );
                    else
                        self:LeaveChannel( Info.arg );
                    end
                end,
                name = 'Looking For Group',
                desc = 'Join/Leave LookingForGroup',
                arg = 'LookingForGroup',
            };
            Order = Order+1;
            Settings.args.JoinWorld = {
                type = 'toggle',
                order = Order,
                get = function( Info )
                    for i,v in pairs( self.ChatFrame.channelList ) do
                        if( Addon:Minify( v ):find( Addon:Minify( Info.arg ) ) ) then
                            return true;
                        end
                    end
                end,
                set = function( Info,Value )
                    if( Value ) then
                        self:JoinChannel( Info.arg );
                    else
                        self:LeaveChannel( Info.arg );
                    end
                end,
                name = 'World',
                desc = 'Join/Leave World',
                arg = 'World',
            };
            Order = Order+1;
            Settings.args.JoinFederation = {
                type = 'toggle',
                order = Order,
                get = function( Info )
                    for i,v in pairs( self.ChatFrame.channelList ) do
                        if( Addon:Minify( v ):find( Addon:Minify( Info.arg ) ) ) then
                            return true;
                        end
                    end
                end,
                set = function( Info,Value )
                    if( Value ) then
                        self:JoinChannel( Info.arg );
                    else
                        self:LeaveChannel( Info.arg );
                    end
                end,
                name = 'Federation',
                desc = 'Join/Leave Federation',
                arg = 'federation',
            };
            Order = Order+1;
            Settings.args.JoinRP = {
                type = 'toggle',
                order = Order,
                get = function( Info )
                    for i,v in pairs( self.ChatFrame.channelList ) do
                        if( Addon:Minify( v ):find( Addon:Minify( Info.arg ) ) ) then
                            return true;
                        end
                    end
                end,
                set = function( Info,Value )
                    if( Value ) then
                        self:JoinChannel( Info.arg );
                    else
                        self:LeaveChannel( Info.arg );
                    end
                end,
                name = 'RP',
                desc = 'Join/Leave RolePlay',
                arg = 'rp',
            };
            ]]

            return Settings;
        end

        --
        -- Set chant filter
        --
        -- @return void
        Addon.CHAT.SetFilter = function( self,Filter,Value )
            if( Value ) then
                --print( 'add',Value,Filter )
                ChatFrame_AddMessageEventFilter( Filter,self.Filter );
            else
                --print( 'remove',Value,Filter )
                ChatFrame_RemoveMessageEventFilter( Filter,self.Filter );
            end
        end

        --
        -- Set chat group
        --
        -- @return void
        Addon.CHAT.SetGroup = function( self,Group,Value )
            if ( Value ) then
                ChatFrame_AddMessageGroup( self.ChatFrame,Group );
            else
                ChatFrame_RemoveMessageGroup( self.ChatFrame,Group );
            end
            --ToggleChatMessageGroup( Value,Group );
        end

        --
        -- Set quests
        --
        -- @return void
        Addon.CHAT.SetQuests = function( self )
            if( Addon.CHAT.persistence.QuestAlert.On ) then
                Addon.CHAT:EnableQuestEvents();
                Addon.CHAT:RebuildQuests();
            else
                Addon.CHAT:DisableQuestEvents();
            end
        end

        --
        -- Set watch list
        --
        -- @param string
        --
        -- @return void
        Addon.CHAT.SetWatches = function( self,watch )
            watch = Addon:Explode( watch,',' );
            if( type( watch ) == 'table' ) then
                Addon.CHAT.persistence.WatchList = {};
                for i,v in pairs( watch ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( Addon.CHAT.persistence.WatchList,Addon:Minify( v ) );
                    else
                        Addon.CHAT.persistence.WatchList = {};
                    end
                end
            else
                Addon.CHAT.persistence.WatchList = {Addon:Minify( watch )};
            end
        end

        --
        -- Get watch list
        --
        -- @return table
        Addon.CHAT.GetWatches = function( self )
            return Addon.CHAT.persistence.WatchList;
        end

        --
        -- Set ignore list
        --
        -- @param string
        --
        -- @return void
        Addon.CHAT.SetIgnores = function( self,ignore )
            ignore = Addon:Explode( ignore,',' );
            if( type( ignore ) == 'table' ) then
                Addon.CHAT.persistence.IgnoreList = {};
                for i,v in pairs( ignore ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( Addon.CHAT.persistence.IgnoreList,Addon:Minify( v ) );
                    else
                        Addon.CHAT.persistence.IgnoreList = {};
                    end
                end
            else
                Addon.CHAT.persistence.IgnoreList = {Addon:Minify( ignore )};
            end
        end

        --
        -- Get ignore list
        --
        -- @return table
        Addon.CHAT.GetIgnores = function( self )
            return Addon.CHAT.persistence.IgnoreList;
        end

        --
        --  Accept Quest
        --
        --  @param  list
        --  @return void
        Addon.CHAT.AcceptQuest = function( self,... )
            local QuestTitle,IsHeader;
            if( Addon:IsClassic() ) then
                QuestTitle,_,_,IsHeader = Addon:Minify( select( 1, GetQuestLogTitle( select( 1, ... ) ) ) );
            else
                QuestTitle = Addon:Minify( C_QuestLog.GetTitleForQuestID( select( 1, ... ) ) );
            end
            if( not Addon.CHAT.ActiveQuests ) then
                Addon.CHAT.ActiveQuests = {};
            end
            if( QuestTitle and not IsHeader ) then
                Addon.CHAT.ActiveQuests[ QuestTitle ] = QuestTitle;
            end
        end

        --
        --  Complete Quest
        --
        --  @param  list
        --  @return void
        Addon.CHAT.CompleteQuest = function( self,... )
            if( Addon.CHAT.ActiveQuests[ QuestTitle ] ) then
                local QuestTitle;
                if( Addon:IsClassic() ) then
                    QuestTitle = Addon:Minify( C_QuestLog.GetQuestInfo( ... ) )
                else
                    QuestTitle = Addon:Minify( C_QuestLog.GetTitleForQuestID( ... ) )
                end
                Addon.CHAT.ActiveQuests[ QuestTitle ] = nil;
            end
        end

        --
        --  Rebuild Quest Watch
        --
        --  @return void
        Addon.CHAT.RebuildQuests = function( self )
            Addon.CHAT.ActiveQuests = {};
            local QuestHeaders,QuestEntries;
            if( Addon:IsClassic() ) then
                QuestHeaders,QuestEntries = GetNumQuestLogEntries();
            else
                QuestHeaders,QuestEntries = C_QuestLog.GetNumQuestLogEntries();
            end
            for i=1, QuestEntries do
                local QuestTitle,IsHeader;
                if( Addon:IsClassic() ) then
                    QuestTitle,_,_,IsHeader = GetQuestLogTitle( i );
                else
                    QuestTitle = C_QuestLog.GetTitleForQuestID( i );
                end
                if( QuestTitle and not IsHeader ) then
                    Addon.CHAT.ActiveQuests[ Addon:Minify( QuestTitle ) ] = Addon:Minify( QuestTitle );
                end
            end
        end

        --
        --  Enable Quest Watch Events
        --
        --  @return void
        Addon.CHAT.EnableQuestEvents = function( self )
            Addon.CHAT.Events:RegisterEvent( 'QUEST_ACCEPTED' );
            Addon.CHAT.Events:RegisterEvent( 'QUEST_TURNED_IN' );
            Addon.CHAT.Events:SetScript( 'OnEvent', function( self, event, ... )
                if( event == 'QUEST_ACCEPTED' ) then
                    Addon.CHAT:AcceptQuest( ...  );
                elseif( event == 'QUEST_TURNED_IN' ) then
                    Addon.CHAT:CompleteQuest( ... );
                end
            end );
        end

        --
        --  Disable Quest Watch
        --
        --  @return void
        Addon.CHAT.DisableQuestEvents = function( self )
            Addon.CHAT.ActiveQuests = {};
            Addon.CHAT.Events:UnregisterEvent( 'QUEST_ACCEPTED' );
            Addon.CHAT.Events:UnregisterEvent( 'QUEST_TURNED_IN' );
        end

        --
        --  Join channel
        --
        --  @return bool
        Addon.CHAT.JoinChannel = function( self,ChannelName )
            if( ChannelName ) then
                local Type,Name = JoinPermanentChannel( ChannelName );
                Addon.CHAT.persistence.Channels[ ChannelName ] = {
                    Color = {
                        254 / 255,
                        191 / 255,
                        191 / 255,
                        1,
                    },
                    Id = #self.ChatFrame.channelList+1,
                };
                return true;
            end
            return false;
        end

        --
        --  Leave channel
        --
        --  @return bool
        Addon.CHAT.LeaveChannel = function( self,ChannelName )
            if( ChannelName ) then
                LeaveChannelByName( ChannelName );
                Addon.CHAT.persistence.Channels[ ChannelName ] = nil;
                return true;
            end
            return false;
        end

        --
        --  Format Chat Message
        --
        --  @param  string  Event
        --  @param  string  MessageText
        --  @param  string  PlayerRealm
        --  @param  string  LangHeader
        --  @param  string  ChannelNameId
        --  @param  string  PlayerName
        --  @param  string  GMFlag
        --  @param  string  ChannelId
        --  @param  string  PlayerId
        --  @param  string  IconReplacement
        --  @return list
        Addon.CHAT.Format = function( Event,MessageText,PlayerRealm,LangHeader,ChannelNameId,PlayerName,GMFlag,ChannelId,ChannelBaseName,UnUsed,LineId,PlayerId,BNId,IconReplacement,Watched )
            local OriginalText = MessageText;
            local ChatType = strsub( Event,10 );
            local Info = ChatTypeInfo[ ChatType ];
            if( not Info ) then
                Info = {
                    colorNameByClass = true,r = 255/255,g = 255/255,b = 255/255,id = nil,
                };
            end
            local _, ChannelName = GetChannelName( ChannelId );
            local ChatGroup = Chat_GetChatCategory( ChatType );
            local LocalizedClass,EnglishClass,LocalizedRace,EnglishRace,Sex,Name,Server;
            if( PlayerId ) then
                LocalizedClass,EnglishClass,LocalizedRace,EnglishRace,Sex,Name,Server = GetPlayerInfoByGUID( PlayerId );
                if( PlayerName == '' ) then
                    PlayerName = Name;
                end
            end

            -- Chat color
            local r,g,b,a = Info.r,Info.g,Info.b,0;
            if( tonumber( ChannelId ) > 0 ) then
                if( Addon.CHAT.persistence.Channels[ ChannelName ] and Addon.CHAT.persistence.Channels[ ChannelName ].Color ) then
                    r,g,b,a = unpack( Addon.CHAT.persistence.Channels[ ChannelName ].Color );
                end
            end
            if( Watched and ( ChatType == 'WHISPER' ) == false ) then
                r,g,b,a = unpack( Addon.CHAT:GetValue( 'WatchColor' ) );
            end

            --Addon.CHAT.ChatFrame:SetTextColor( r,g,b,a );
            --ChangeChatColor( 'CHANNEL'..ChannelId,r,g,b,a );

            -- Class color
            if( PlayerId and Info and self:GetValue( 'ClassColor' ) ) then
                if( EnglishClass ) then
                    local ClassColorTable = RAID_CLASS_COLORS[ EnglishClass ];
                    if ( ClassColorTable ) then
                        PlayerName = string.format( "\124cff%.2x%.2x%.2x", ClassColorTable.r*255, ClassColorTable.g*255, ClassColorTable.b*255 )..PlayerName.."\124r";
                    end
                end
            end

            -- Replace icon and group tags like {rt4} and {diamond}
            if( Addon:IsClassic() ) then
                MessageText = ChatFrame_ReplaceIconAndGroupExpressions( MessageText, IconReplacement, not ChatFrame_CanChatGroupPerformExpressionExpansion( ChatGroup ) );
            else
                MessageText = C_ChatInfo.ReplaceIconAndGroupExpressions( MessageText, IconReplacement, not C_ChatInfo.ReplaceIconAndGroupExpressions( ChatGroup ) );
            end
            MessageText = RemoveExtraSpaces( MessageText );

            -- Questie support
            if( QuestieLoader ) then
                --[[
                local ChatFilter = QuestieLoader:ImportModule( 'ChatFilter' );
                if( ChatFilter ) then
                    ChatFilter:Filter( Addon.CHAT.ChatFrame,'junk',MessageText,PlayerRealm,LangHeader,ChannelNameId,PlayerName,GMFlag,ChannelId,ChannelIndex,ChannelBaseName,UnUsed,LineId,PlayerId,BNId );
                end
                ]]

                local QuestieLink = QuestieLoader:ImportModule( 'QuestieLink' );
                local QuestieDB = QuestieLoader:ImportModule( 'QuestieDB' );

                if( string.find( MessageText,"%[(..-) %((%d+)%)%]" ) ) then

                    if Addon.CHAT.ChatFrame.historyBuffer and #( Addon.CHAT.ChatFrame.historyBuffer.elements ) then

                        for k in string.gmatch( MessageText,"%[%[?%d?..?%]?..-%]" ) do
                            local sqid, questId, questLevel, questName;

                            questName, sqid = string.match( k,"%[(..-) %((%d+)%)%]" );

                            if( questName and sqid ) then
                                questId = tonumber(sqid)

                                if( string.find( questName,"(%[%d+.-%]) ") ~= nil ) then
                                    questLevel, questName = string.match( questName,"%[(..-)%] (.+)");
                                end
                            end

                            if( questId and QuestieDB.QuestPointers[questId] ) then
                                if( not PlayerId ) then
                                    playerName = BNGetFriendInfoByID( BNId );
                                    PlayerId = BNId;
                                end

                                local questLink = QuestieLink:GetQuestHyperLink( questId,PlayerId );

                                local function escapeMagic(toEsc)
                                    return (toEsc
                                            :gsub("%%", "%%%%")
                                            :gsub("^%^", "%%^")
                                            :gsub("%$$", "%%$")
                                            :gsub("%(", "%%(")
                                            :gsub("%)", "%%)")
                                            :gsub("%.", "%%.")
                                            :gsub("%[", "%%[")
                                            :gsub("%]", "%%]")
                                            :gsub("%*", "%%*")
                                            :gsub("%+", "%%+")
                                            :gsub("%-", "%%-")
                                            :gsub("%?", "%%?")
                                            :gsub("%|", "%%|")
                                    );
                                end

                                if( questName ) then
                                    questName = escapeMagic( questName );
                                end

                                if( questLevel ) then
                                    questLevel = escapeMagic( questLevel );
                                end

                                if( questLevel ) then
                                    MessageText = string.gsub( MessageText,"%[%["..questLevel.."%] "..questName.." %("..sqid.."%)%]",questLink );
                                else
                                    MessageText = string.gsub( MessageText,"%["..questName.." %("..sqid.."%)%]",questLink );
                                end
                            end
                        end
                    end
                end
            end

            -- Add AFK/DND flags
            local PFlag;
            if( GMFlag ~= '' ) then
                if( GMFlag == 'GM' ) then
                    --If it was a whisper, dispatch it to the GMChat addon.
                    if ( ChatType == 'WHISPER' ) then
                        return;
                    end
                    --Add Blizzard Icon, this was sent by a GM
                    PFlag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t ";
                elseif ( GMFlag == 'DEV' ) then
                    --Add Blizzard Icon, this was sent by a Dev
                    PFlag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t ";
                else
                    PFlag = _G["CHAT_FLAG_"..GMFlag];
                end
            else
                PFlag = '';
            end

            -- Timestamp
            local TimeStamp = '';
            if( Addon.CHAT:GetValue( 'TimeStamps' ) ) then
                TimeStamp = '['..BetterDate( "|cffffffff%I:%M:%S %p|r",time() )..'] ';
            end

            -- Channel link
            -- https://wowpedia.fandom.com/wiki/Hyperlinks
            local ChannelLink = '';
            if( tonumber( ChannelId ) > 0 ) then
                ChannelLink = "|Hchannel:channel:"..ChannelId.."|h["..ChannelNameId.."]|h"    -- "|Hchannel:channel:2|h[2. Trade - City]|h"
            elseif( ChatType == 'PARTY' ) then
                ChannelLink = "|Hchannel:PARTY|h[Party]|h";
            elseif( ChatType == 'PARTY_LEADER' ) then
                ChannelLink = "|Hchannel:PARTY|h[Party Leader]|h";
            elseif( ChatType == 'INSTANCE_CHAT' ) then
                ChannelLink = "|Hchannel:INSTANCE_CHAT|h[Instance]|h";
            elseif( ChatType == 'INSTANCE_CHAT_LEADER' ) then
                ChannelLink = "|Hchannel:INSTANCE_CHAT|h[Instance Leader]|h";
            elseif( ChatType == 'RAID' ) then
                ChannelLink = "|Hchannel:RAID|h[Raid]|h";
            elseif( ChatType == 'RAID_LEADER' or ChatType == 'RAID_WARNING' ) then
                ChannelLink = "|Hchannel:RAID|h[Raid Leader]|h";
            elseif( ChatType == 'GUILD' ) then
                ChannelLink = "|Hchannel:GUILD|h[Guild]|h";
            end

            -- Player link
            -- https://wowpedia.fandom.com/wiki/Hyperlinks
            local PlayerLink = "|Hplayer:"..PlayerRealm.."|h".."["..PlayerName.."]|h" -- |Hplayer:Blasfemy-Grobbulus|h was here

            -- Player action
            local PlayerAction = '';
            if( ChatType == 'YELL' ) then
                PlayerAction = ' yells';
            end
            if ( ChatType == 'WHISPER' ) then
                PlayerAction = ' whispers';
            end

            -- Player level
            local PlayerLevel = '';--'['..UnitLevel( PlayerId )..']';

            -- Message
            MessageText = TimeStamp..ChannelLink..PFlag..PlayerLink..PlayerAction..PlayerLevel..': '..MessageText;

            -- Append what was watched
            if( Watched ) then
                MessageText = MessageText..' : '..Watched;
            end

            return MessageText,r,g,b,a,Info.id;
        end

        --
        --  Filter Chat Message
        --
        --  @param  string  Event
        --  @param  list    ...
        --  @return bool
        Addon.CHAT.Filter = function( self,Event,... )
            local ChatType = strsub( Event,10 );
            local MessageText = select( 1,... );
            local OriginalText = MessageText;
            local PlayerRealm = select( 2,... );
            local LangHeader = select( 3,... );
            local ChannelNameId = select( 4,... );
            local PlayerName = select( 5,... );
            local GMFlag = select( 6,... );
            local ChannelId = select( 8,... );
            local ChannelBaseName = select( 9,... );
            local UnUsed = select( 10,... );
            local LineId = select( 11,... );
            local PlayerId = select( 12,... );
            local BNId = select( 13,... );
            local IconReplacement = select( 17,... );

            local MyPlayerName,MyRealm = UnitName( 'player' );

            -- Prevent ignored messages
            if( not Addon:Minify( PlayerName ):find( Addon:Minify( MyPlayerName ) ) ) then
                local IgnoredMessages = Addon.CHAT:GetIgnores();
                if( #IgnoredMessages > 0 ) then
                    for i,IgnoredMessage in ipairs( IgnoredMessages ) do
                        if( Addon:Minify( OriginalText ):find( Addon:Minify( IgnoredMessage ) ) ) then
                            return true;
                        end
                    end
                end
            end

            -- Prevent repeat messages for 1 minute
            local CacheKey = Addon:Minify( PlayerRealm..MessageText..date( "%H:%M" ) );
            if( Addon.CHAT.Cache[ CacheKey ] ) then
                return true;
            end
            Addon.CHAT.Cache[ CacheKey ] = true;

            -- Watch check
            local Watched;
            local MentionAlert = false;
            if( not Addon:Minify( PlayerName ):find( Addon:Minify( MyPlayerName ) ) ) then
                local WatchedMessages = Addon.CHAT:GetWatches();
                if( #WatchedMessages > 0 ) then
                    for i,WatchedMessage in ipairs( WatchedMessages ) do
                        if( Addon:Minify( OriginalText ):find( Addon:Minify( WatchedMessage ) ) ) then
                            Watched = WatchedMessage;
                        end
                    end
                end
                if( Addon.CHAT:GetValue( 'QuestAlert' ) ) then
                    for i,ActiveQuest in pairs( Addon.CHAT.ActiveQuests ) do
                        if( Addon:Minify( OriginalText ):find( ActiveQuest ) ) then
                            Watched = ActiveQuest;
                        end
                    end
                end
                if( Addon.CHAT:GetValue( 'MentionAlert' ) ) then
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( MyPlayerName ) ) ) then
                        Watched = MyPlayerName;
                        MentionAlert = true;
                    end
                end
            end

            -- Format message
            MessageText,r,g,b,a,id = Addon.CHAT.Format(
                Event,
                MessageText,
                PlayerRealm,
                LangHeader,
                ChannelNameId,
                PlayerName,
                GMFlag,
                ChannelId,
                ChannelBaseName,
                UnUsed,
                LineId,
                PlayerId,
                BNId,
                IconReplacement,
                Watched
            );

            -- Sound
            if ( ChatType == 'WHISPER' ) then
                PlaySound( SOUNDKIT.TELL_MESSAGE );
            end
            if( MentionAlert ) then
                PlaySound( SOUNDKIT.TELL_MESSAGE );
                --FCF_StartAlertFlash( Addon.CHAT.ChatFrame );
            end
            if( Watched ) then
                if( Addon.CHAT:GetValue( 'AlertSound' ) ) then
                    PlaySound( SOUNDKIT.TELL_MESSAGE );
                end
            end

            -- Display
            if( Addon:IsClassic() ) then
                Addon.CHAT.ChatFrame.DefaultSettings:AddMessage( MessageText,r,g,b,id );
            else
                Addon.CHAT.ChatFrame:AddMessage( MessageText,r,g,b,id ); 
            end
            return true;
        end;

        --
        --  Chat AddMessage Replacement
        --  @param  string  MessageText
        --  @param  string  R
        --  @param  string  G
        --  @param  string  B
        --  @param  string  id
        --  @return void
        function Addon.CHAT.SendMessage( self,MessageText,r,g,b,id )
            if( Addon.CHAT:GetValue( 'TimeStamps' ) ) then
                MessageText = '['..BetterDate( "|cffffffff%I:%M:%S %p|r",time() )..'] '..MessageText;
            end
            if( Addon:IsClassic() ) then
                Addon.CHAT.ChatFrame.DefaultSettings:AddMessage( MessageText,r,g,b,id );
            else
                Addon.CHAT.ChatFrame:AddMessage( MessageText,r,g,b,id );
            end
        end

        --
        --  Module run
        --
        --  @return void
        Addon.CHAT.Run = function( self )
            -- Chat filter
            for Filter,FilterData in pairs( self:GetChatFilters() ) do
                for _,FilterName in pairs( FilterData ) do
                    --print( FilterName,Filter,self.persistence.ChatFilters[ Filter ] )
                    self:SetFilter( FilterName,self.persistence.ChatFilters[ Filter ] );
                end
            end

            -- List channels
            for i,v in pairs( self.ChatFrame.channelList ) do
                print( 'You have joined '..v );
            end
        end

        --
        --  Create module config frames
        --
        --  @return void
        Addon.CHAT.CreateFrames = function( self )
            self.Config = LibStub( 'AceConfigDialog-3.0' ):AddToBlizOptions( string.upper( AddonName ),AddonName );
            self.Config.okay = function( self )
                RestartGx();
            end
            self.Config.default = function( self )
                Addon.CHAT.db:ResetDB();
            end
            LibStub( 'AceConfigRegistry-3.0' ):RegisterOptionsTable( string.upper( AddonName ),self:GetSettings() );


            --[[
            Test 1

            self.Config = CreateFrame( 'Frame',AddonName..'Main',UIParent,'UIPanelDialogTemplate' );
            self.Config:SetFrameStrata( 'HIGH' );

            self.Config:SetClampedToScreen( true );
            self.Config:SetSize( self.ChatFrame:GetWidth(),self.ChatFrame:GetHeight() );
            self.Config:DisableDrawLayer( 'OVERLAY' );
            self.Config:DisableDrawLayer( 'BACKGROUND' );

            self.Config:EnableKeyboard( true );
            self.Config:EnableMouse( true );
            self.Config:SetResizable( false );
            self.Config:SetPoint( 'bottomleft',self.ChatFrame,'bottomleft',0,0 );
            self.Config:SetScale( 1 );

            self.Config.Background = self.Config:CreateTexture( nil,'ARTWORK',nil,0 );
            self.Config.Background:SetTexture( 'Interface\\Addons\\jChatFilter\\Libs\\jUI\\Textures\\frame' );
            self.Config.Background:SetAllPoints( self.Config );

            self.Config.Tools = CreateFrame( 'Frame',self.Config:GetName()..'Tools',self.Config );
            self.Config.Tools:SetSize( self.Config:GetWidth(),1 );
            self.Config.Tools:SetPoint( 'topleft',self.Config,'topleft' );
            self.Config.Tools.Background = self.Config:CreateTexture( nil,'ARTWORK',nil,0 );
            self.Config.Tools.Background:SetTexture( 'Interface\\Addons\\jChatFilter\\Libs\\jUI\\Textures\\frame' );
            self.Config.Tools.Background:SetAllPoints( self.Config.Tools );

            self.Config.Browser = CreateFrame( 'Frame',self.Config:GetName()..'Browser',self.Config );
            self.Config.Browser:SetSize( self.Config:GetWidth(),self.Config:GetHeight()-self.Config.Tools:GetHeight() );
            self.Config.Browser:SetPoint( 'topleft',self.Config.Tools,'bottomleft' );

            self.Config.Browser.Heading = CreateFrame( 'Frame',self.Config.Browser:GetName()..'Heading',self.Config );
            self.Config.Browser.Heading:SetSize( self.Config.Browser:GetWidth(),100 );
            self.Config.Browser.Heading:SetPoint( 'topleft',self.Config.Tools,'bottomleft' );



            -- Options scroll frame
            self.Config.Browser.Data = CreateFrame( 'ScrollFrame',nil,self.Config.Browser,'UIPanelScrollFrameTemplate' );

            -- Options scrolling content frame
            self.Config.Browser.Data.ScrollChild = CreateFrame( 'Frame' );

            -- Options scroll frame
            self.Config.Browser.Data:SetSize( self.Config.Browser:GetWidth(),self.Config.Browser:GetHeight()-self.Config.Browser:GetHeight()-self.Config.Tools:GetHeight() );
            self.Config.Browser.Data:SetPoint( 'topleft',self.Config.Browser.Heading,'bottomleft' );

            -- Options scroll content 
            self.Config.Browser.Data:SetScrollChild( self.Config.Browser.Data.ScrollChild );
            self.Config.Browser.Data.ScrollChild:SetSize( self.Config.Browser.Data:GetWidth()-18,20 );


            -- Configurations
            self.Switches = {
                General = {
                    TimeStamps = Addon.FRAMES:AddCheckBox( { Name='TimeStamps',DisplayText='Add Timestamps',Description='Timestamp prefix messsages'},self.Config.Browser.Data,self ),
                    ScrollBack = Addon.FRAMES:AddCheckBox( { Name='ScrollBack',DisplayText='Extend History',Description='Extend chat history to 1,000 lines'},self.Config.Browser.Data,self ),
                    FadeOut = Addon.FRAMES:AddCheckBox( { Name='FadeOut',DisplayText='Message Fading',Description='Messages will disappear from view after a period of time'},self.Config.Browser.Data,self ),
                },
            };

            -- Configuration display
            local MaxElems = 3;
            local X,Y = 10,0;
            local InitX,InitY = X,Y;
            local XSpacing = 100;

            local Children = {};
            local Iterator = 0;

            for SetName,SwitchData in pairs( self.Switches ) do
                for Index,Frame in pairs( SwitchData ) do

                    if( #Children % MaxElems == 0 ) then
                        X,Y = XSpacing,0
                    elseif( #Children > 0 ) then
                        X,Y = XSpacing + Children[ Iterator ]:GetWidth(),Y;
                    end

                    Iterator = Iterator + 1;

                    Children[ Iterator ] = Frame;
                    print( Index,X,Y )
                    Frame:SetPoint( 'topleft',self.Config.Browser.Data.ScrollChild,'topleft',X,Y );
                end
            end
            ]]
            --[[
            --Test 2 
            self.Panel = CreateFrame( 'Frame',AddonName..'Main',UIParent,'UIPanelDialogTemplate' );
            self.Panel:SetFrameStrata( 'HIGH' );

            self.Panel:SetClampedToScreen( true );
            self.Panel:SetSize( self.ChatFrame:GetWidth(),self.ChatFrame:GetHeight() );
            self.Panel:DisableDrawLayer( 'OVERLAY' );
            self.Panel:DisableDrawLayer( 'BACKGROUND' );

            self.Panel:EnableKeyboard( true );
            self.Panel:EnableMouse( true );
            self.Panel:SetResizable( false );
            self.Panel:SetPoint( 'bottomleft',self.ChatFrame,'bottomleft',0,0 );
            self.Panel:SetScale( 1 );

            self.Panel.Background = self.Panel:CreateTexture( nil,'ARTWORK',nil,0 );
            self.Panel.Background:SetTexture( 'Interface\\Addons\\jChatFilter\\Libs\\jUI\\Textures\\frame' );
            self.Panel.Background:SetAllPoints( self.Panel );

            self.Panel.Tools = CreateFrame( 'Frame',self.Panel:GetName()..'Tools',self.Panel );
            self.Panel.Tools:SetSize( self.Panel:GetWidth(),1 );
            self.Panel.Tools:SetPoint( 'topleft',self.Panel,'topleft' );
            self.Panel.Tools.Background = self.Panel:CreateTexture( nil,'ARTWORK',nil,0 );
            self.Panel.Tools.Background:SetTexture( 'Interface\\Addons\\jChatFilter\\Libs\\jUI\\Textures\\frame' );
            self.Panel.Tools.Background:SetAllPoints( self.Panel.Tools );

            self.Panel.Browser = CreateFrame( 'Frame',self.Panel:GetName()..'Browser',self.Panel );
            self.Panel.Browser:SetSize( self.Panel:GetWidth(),self.Panel:GetHeight()-self.Panel.Tools:GetHeight() );
            self.Panel.Browser:SetPoint( 'topleft',self.Panel.Tools,'bottomleft' );

            self.Panel.Browser.Heading = CreateFrame( 'Frame',self.Panel.Browser:GetName()..'Heading',self.Panel );
            self.Panel.Browser.Heading:SetSize( self.Panel.Browser:GetWidth(),100 );
            self.Panel.Browser.Heading:SetPoint( 'topleft',self.Panel.Tools,'bottomleft' );


            Addon.CHAT.Test = function( self )
                return {
                    TimeStamps = {
                        Description = 'Timestamp prefix messsages',
                        KeyValue = 'TimeStamps',
                        DefaultValue = self:GetValue( 'TimeStamps' ),
                        KeyPairs = {
                            Option1 = {
                                Value = 0,
                                Description = 'Off',
                            },
                            Option2 = {
                                Value = 1,
                                Description = 'On',
                            },
                        },
                        Type = 'Toggle',
                    },
                    ScrollBack = {
                        Description = 'Extend chat history to 1,000 lines',
                        KeyValue = 'ScrollBack',
                        DefaultValue = self:GetValue( 'ScrollBack' ),
                        KeyPairs = {
                            Option1 = {
                                Value = 0,
                                Description = 'Off',
                            },
                            Option2 = {
                                Value = 1,
                                Description = 'On',
                            },
                        },
                        Type = 'Toggle',
                    },
                    FadeOut = {
                        Description = 'Messages will disappear from view after a period of time',
                        KeyValue = 'FadeOut',
                        DefaultValue = self:GetValue( 'FadeOut' ),
                        KeyPairs = {
                            Option1 = {
                                Value = 0,
                                Description = 'Off',
                            },
                            Option2 = {
                                Value = 1,
                                Description = 'On',
                            },
                        },
                        Type = 'Toggle',
                    },
                    AlertSound = {
                        Description = 'Alerts should produce a sound',
                        KeyValue = 'AlertSound',
                        DefaultValue = self:GetValue( 'AlertSound' ),
                        KeyPairs = {
                            Option1 = {
                                Value = 0,
                                Description = 'Off',
                            },
                            Option2 = {
                                Value = 1,
                                Description = 'On',
                            },
                        },
                        Type = 'Toggle',
                    },
                };
            end

            Addon.FRAMES:DrawFromSettings( Addon.CHAT:Test(),Addon.CHAT );
            ]]
        end

        --
        --  Module init
        --
        --  @return void
        Addon.CHAT.Init = function( self )
            -- Chat frame
            self.ChatFrame = DEFAULT_CHAT_FRAME;

            -- Database
            self.db = LibStub( 'AceDB-3.0' ):New( AddonName,{ char = self:GetDefaults() },true );
            if( not self.db ) then
                return;
            end
            self.persistence = self.db.char;
            if( not self.persistence ) then
                return;
            end

            -- Watch cache
            self.Cache = {};

            -- Chat defaults
            self.ChatFrame.DefaultSettings = {};

            -- Events frame
            self.Events = CreateFrame( 'Frame' );

            -- Expired channels
            local Colors = {};
            for ChannelName,ChannelData in pairs( self.persistence.Channels ) do
                if( not self.ChatFrame.channelList[ ChannelName ] ) then
                    Colors[ ChannelName ] = self.persistence.Channels[ ChannelName ].Color;
                    self.persistence.Channels[ ChannelName ] = nil;
                end
            end

            -- Color chat channels
            for i,Channel in pairs( self.ChatFrame.channelList ) do
                if( not self.persistence.Channels[ Channel ] ) then
                    if( Colors[ Channel ] ) then
                        self.persistence.Channels[ Channel ] = {
                            Color = Colors[ Channel ];
                        };
                    else
                        self.persistence.Channels[ Channel ] = {
                            Color = {
                                254 / 255,
                                191 / 255,
                                191 / 255,
                                1,
                            },
                        };
                    end
                end
            end

            -- Fading
            self.ChatFrame:SetFading( self:GetValue( 'FadeOut' ) );

            -- Scrolling
            if( self:GetValue( 'ScrollBack' ) ) then
                self.ChatFrame:SetMaxLines( 10000 );
            end

            -- Chat text
            self.ChatFrame:SetFont( 'Fonts\\'..self:GetValue( 'Font' ).Family..'.ttf',self:GetValue( 'Font' ).Size,self:GetValue( 'Font' ).Flags );
            self.ChatFrame:SetShadowOffset( 0,0 );
            self.ChatFrame:SetShadowColor( 0,0,0,0 );
            
            -- Chat replacement
            if( Addon:IsClassic() ) then
                self.ChatFrame.DefaultSettings.AddMessage = self.ChatFrame.AddMessage;
                self.ChatFrame.AddMessage = self.SendMessage;
            end

            -- Chat types
            for Group,GroupData in pairs( self:GetMessageGroups() ) do
                for _,GroupName in pairs( GroupData ) do
                    self:SetGroup( GroupName,self.persistence.ChatGroups[ Group ] );
                end
            end

            -- Active quests
            self:RebuildQuests();
        end

        C_Timer.After( 2,function()
            self:Init();
            self:CreateFrames();
            self:Run();
        end );
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );