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
            local Defaults = {
                AlertSound = false,
                ChannelColor = {
                    254 / 255,
                    191 / 255,
                    191 / 255,
                    1,
                },
                FadeOut = false,
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
                    242 / 255,
                    63 / 255,
                    0 / 255,
                    1,
                },
                WatchList = {
                    'heal','voa',
                },
                Channels = {},
            };
            for i,Channel in pairs( Addon.CHAT.ChatFrame.channelList ) do
                Defaults.Channels[ Channel ] = {
                    Color = {
                        254 / 255,
                        191 / 255,
                        191 / 255,
                        1,
                    },
                };
            end
            return Defaults;
        end

        Addon.CHAT.SetValue = function( self,Index,Value )
            if( Addon.CHAT.persistence[ Index ] ~= nil ) then 
                Addon.CHAT.persistence[ Index ] = Value;
            end
        end

        Addon.CHAT.GetValue = function( self,Index )
            if( Addon.CHAT.persistence[ Index ] ~= nil ) then 
                return Addon.CHAT.persistence[ Index ];
            end
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
                name = AddonName..' Settings',
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
            Settings.args.ChannelSettings = {
                type = 'header',
                order = Order,
                name = 'Channel Settings',
            };

            local JoinedChannels = {};
            for i,channel in pairs( Addon.CHAT.ChatFrame.channelList ) do
                for ChannelName,ChannelData in pairs( Addon.CHAT.persistence.Channels ) do
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
                        if( Addon.CHAT.persistence.Channels[ Info.arg ] ~= nil ) then
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
                }
            end
            Order = Order+1;
            Settings.args.AlertSettings = {
                type = 'header',
                order = Order,
                name = 'Alert Settings',
            };
            Order = Order+1;
            Settings.args.AlertSettings = {
                type = 'header',
                order = Order,
                name = 'Alert Settings',
            };
            Order = Order+1;
            Settings.args.AlertSound = {
                type = 'toggle',
                order = Order,
                name = 'Alert Sound',
                desc = 'Enable/disable chat alert sound',
                arg = 'AlertSound',
            };
            Order = Order+1;
            Settings.args.AlertMention = {
                type = 'toggle',
                order = Order,
                name = 'Alert Mention',
                desc = 'Enable/disable alerting if anyone mentions your name while in joined channels',
                arg = 'MentionAlert',
            };
            Order = Order+1;
            Settings.args.AlertQuest = {
                type = 'toggle',
                order = Order,
                name = 'Alert Quest',
                desc = 'Enable/disable alerting if anyone mentions a quest you are on while in joined channels',
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
                name = 'Alert Color',
                desc = 'Set the color of Alerts chat',
                arg = 'WatchColor',
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
                desc = 'Words or phrases to be alerted on when they are mentioned in chat. Note that phrases contain no spaces',
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
                desc = 'Words or phrases which should be omitted in chat. Note that phrases contain no spaces',
                arg = 'IgnoreList',
                width = 'full',
            };
            return Settings;
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
            local QuestTitle;
            if( Addon:IsClassic() ) then
                QuestTitle = Addon:Minify( select( 1, GetQuestLogTitle( select( 1, ... ) ) ) );
            else
                QuestTitle = Addon:Minify( C_QuestLog.GetTitleForQuestID( select( 1, ... ) ) );
            end
            if( not Addon.CHAT.ActiveQuests ) then
                Addon.CHAT.ActiveQuests = {};
            end
            Addon.CHAT.ActiveQuests[ QuestTitle ] = QuestTitle;
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
                local QuestTitle;
                if( Addon:IsClassic() ) then
                    QuestTitle = GetQuestLogTitle( i );
                else
                    QuestTitle = C_QuestLog.GetTitleForQuestID( i );
                end
              if( QuestTitle ) then
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

        Addon.CHAT.JoinChannel = function( self,... )
            --[[
            Addon.CHAT.persistence.Channels[ ChannelName ] = {
                Color = {
                    254 / 255,
                    191 / 255,
                    191 / 255,
                    1,
                },
                Id = ChannelId,
            };
                    Addon:Dump( {
                        ...
                    })
            ]]
        end

        Addon.CHAT.LeaveChannel = function( self,... )
        --[[
            local Index = 1;
            for Name,ChannelData in pairs( Addon.CHAT.persistence.Channels ) do
                if( Addon:Minify( Name ) == Addon:Minify( ChannelName ) ) then
                    table.remove( Addon.CHAT.persistence.Channels,Index );
                end
                Index = Index+1;
            end
                    Addon:Dump( {
                        ...
                    })
            ]]
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
        Addon.CHAT.Format = function( Event,MessageText,PlayerRealm,LangHeader,ChannelNameId,PlayerName,GMFlag,ChannelId,PlayerId,IconReplacement,Watched )
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
            if( Watched ) then
                r,g,b,a = unpack( Addon.CHAT:GetValue( 'WatchColor' ) );
            end

            --Addon.CHAT.ChatFrame:SetTextColor( r,g,b,a );
            --ChangeChatColor( 'CHANNEL'..ChannelId,r,g,b,a );

            -- Class color
            if( Addon:Int2Bool( GetCVar( 'colorChatNamesByClass' ) ) ) then
                if( PlayerId and Info and Chat_ShouldColorChatByClass( Info ) ) then
                    if( EnglishClass ) then
                        local ClassColorTable = RAID_CLASS_COLORS[ EnglishClass ];
                        if ( ClassColorTable ) then
                            PlayerName = string.format( "\124cff%.2x%.2x%.2x", ClassColorTable.r*255, ClassColorTable.g*255, ClassColorTable.b*255 )..PlayerName.."\124r";
                        end
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

            -- Player level
            local PlayerLevel = '';--'['..UnitLevel( PlayerId )..']';

            -- Play whisper sound
            if ( ChatType == 'WHISPER' ) then
                PlayerAction = ' whispers';
                PlaySound( SOUNDKIT.TELL_MESSAGE );
            end

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
            local MessageText = select( 1,... );
            local OriginalText = MessageText;
            local PlayerRealm = select( 2,... );
            local LangHeader = select( 3,... );
            local ChannelNameId = select( 4,... );
            local PlayerName = select( 5,... );
            local GMFlag = select( 6,... );
            local ChannelId = select( 8,... );
            local PlayerId = select( 12,... );
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
                PlayerId,
                IconReplacement,
                Watched
            );

            if( Watched ) then
                if( Addon.CHAT:GetValue( 'AlertSound' ) or MentionAlert ) then
                    PlaySound( SOUNDKIT.TELL_MESSAGE );
                end
            end

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
        --  Module refresh
        --
        --  @return void
        Addon.CHAT.Refresh = function( self )
            if( not Addon.CHAT.persistence ) then
                return;
            end
            -- Color chat names
            if( Addon:Int2Bool( GetCVar( 'colorChatNamesByClass' ) ) ) then
                for i,channel in pairs( Addon.CHAT.ChatFrame.channelList ) do
                    ToggleChatColorNamesByClassGroup( true, 'CHANNEL' .. i );
                end
            else
                for i,channel in pairs( Addon.CHAT.ChatFrame.channelList ) do
                    ToggleChatColorNamesByClassGroup( false, 'CHANNEL' .. i );
                end
            end
            -- Fading
            Addon.CHAT.ChatFrame:SetFading( Addon.CHAT:GetValue( 'FadeOut' ) );
            -- Scrolling
            if( Addon.CHAT:GetValue( 'ScrollBack' ) ) then
                Addon.CHAT.ChatFrame:SetMaxLines( 10000 );
            end
        end;

        --
        --  Module run
        --
        --  @return void
        Addon.CHAT.Run = function( self )
            -- Active quests
            Addon.CHAT:RebuildQuests();
            -- Chat text
            Addon.CHAT.ChatFrame:SetFont( Addon.CHAT.ChatFrame:GetFont(),12,'THINOUTLINE' );
            Addon.CHAT.ChatFrame:SetShadowOffset( 0,0 );
            Addon.CHAT.ChatFrame:SetShadowColor( 0,0,0,0 );
            -- Chat replacement
            if( Addon:IsClassic() ) then
                Addon.CHAT.ChatFrame.DefaultSettings.AddMessage = Addon.CHAT.ChatFrame.AddMessage;
                Addon.CHAT.ChatFrame.AddMessage = Addon.CHAT.SendMessage;
            end
            -- Chat filter
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_CHANNEL',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_SAY',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_YELL',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_WHISPER',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_GUILD',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_PARTY',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_PARTY_LEADER',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_RAID',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_RAID_LEADER',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_RAID_WARNING',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_INSTANCE_CHAT',Addon.CHAT.Filter );
            ChatFrame_AddMessageEventFilter( 'CHAT_MSG_INSTANCE_CHAT_LEADER',Addon.CHAT.Filter );
            -- Chat events
            Addon.CHAT.Events:RegisterEvent( 'CHAT_MSG_CHANNEL_NOTICE' );
            Addon.CHAT.Events:SetScript( 'OnEvent', function( self, event, ... )
                if( event == 'CHAT_MSG_CHANNEL_NOTICE' ) then
                    if( SubEvent == 'YOU_CHANGED' ) then
                        Addon.CHAT:JoinChannel( ... );
                    elseif( SubEvent == 'YOU_LEFT' ) then
                        Addon.CHAT:LeaveChannel( ... );
                    end
                end
            end );
            -- List channels
            for i,v in pairs( Addon.CHAT.ChatFrame.channelList ) do
                print( 'You have joined '..v );
            end
        end

        --
        --  Create module config frames
        --
        --  @return void
        Addon.CHAT.CreateFrames = function( self )
            Addon.CHAT.Config = LibStub( 'AceConfigDialog-3.0' ):AddToBlizOptions( string.upper( AddonName ),AddonName );
            Addon.CHAT.Config.okay = function( self )
                Addon.CHAT:Refresh();
                RestartGx();
            end
            Addon.CHAT.Config.default = function( self )
                Addon.CHAT.db:ResetDB();
            end
            LibStub( 'AceConfigRegistry-3.0' ):RegisterOptionsTable( string.upper( AddonName ),Addon.CHAT:GetSettings() );
        end

        --
        --  Module init
        --
        --  @return void
        Addon.CHAT.Init = function( self )
            -- Chat frame
            Addon.CHAT.ChatFrame = DEFAULT_CHAT_FRAME;
            -- Database
            Addon.CHAT.db = LibStub( 'AceDB-3.0' ):New( AddonName,{ char = Addon.CHAT:GetDefaults() },true );
            if( not Addon.CHAT.db ) then
                return;
            end
            Addon.CHAT.persistence = Addon.CHAT.db.char;
            if( not Addon.CHAT.persistence ) then
                return;
            end
            -- Watch cache
            Addon.CHAT.Cache = {};
            -- Chat defaults
            Addon.CHAT.ChatFrame.DefaultSettings = {};
            -- Events frame
            Addon.CHAT.Events = CreateFrame( 'Frame' );
        end

        C_Timer.After( 2, function()
            Addon.CHAT:Init();
            Addon.CHAT:CreateFrames();
            Addon.CHAT:Refresh();
            Addon.CHAT:Run();
        end );
        Addon.CHAT:UnregisterEvent( 'ADDON_LOADED' );
    end
end );