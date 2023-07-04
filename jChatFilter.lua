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
                FadeOut = false,
                GeneralColor = {
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
            };
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
            return {
                type = 'group',
                get = function( Info )
                    if( Addon.CHAT.persistence[ Info.arg ] ~= nil ) then
                        return Addon.CHAT.persistence[ Info.arg ];
                    end
                end,
                set = function( Info,Value )
                    if( Addon.CHAT.persistence[ Info.arg ] ~= nil ) then
                        Addon.CHAT.persistence[ Info.arg ] = Value;
                    end
                end,
                name = AddonName..' Settings',
                desc = 'Simple chat filter',
                args = {
                    intro = {
                        order = 1,
                        type = 'description',
                        name = 'A description goes here',
                    },
                    AlertSound = {
                        type = 'toggle',
                        name = 'AlertSound',
                        desc = 'Enable/disable chat alert sound',
                        arg = 'AlertSound',
                    },
                    ChannelColor = {
                        type = 'color',
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
                        name = 'ChannelColor',
                        desc = 'Set the color of Channel chat',
                        arg = 'ChannelColor',
                    },
                    FadeOut = {
                        type = 'toggle',
                        name = 'FadeOut',
                        desc = 'Enable/disable chat fading',
                        arg = 'FadeOut',
                    },
                    GeneralColor = {
                        type = 'color',
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
                        name = 'GeneralColor',
                        desc = 'Set the color of General chat',
                        arg = 'GeneralColor',
                    },
                    IgnoreList = {
                        type = 'input',
                        multiline = true,
                        get = function( Info )
                            if( Addon.CHAT.persistence[ Info.arg ] ~= nil ) then
                                return Addon:Implode( Addon.CHAT.persistence[ Info.arg ],',' );
                            end
                        end,
                        set = function( Info,Value )
                            Value = Addon:Explode( Value,',' );
                            if( type( Value ) == 'table' ) then
                                Addon.CHAT.persistence[ Info.arg ] = {};
                                for i,v in pairs( Value ) do
                                    table.insert( Addon.CHAT.persistence[ Info.arg ],Addon:Minify( v ) );
                                end
                            else
                                Addon.CHAT.persistence[ Info.arg ] = {Addon:Minify( Value )};
                            end
                        end,
                        name = 'IgnoreList',
                        desc = 'Words or phrases which should be omitted in chat. Note that phrases contain no spaces',
                        arg = 'IgnoreList',
                        width = 'full',
                    },
                    MentionAlert = {
                        type = 'toggle',
                        name = 'MentionAlert',
                        desc = 'Enable/disable alerting if anyone mentions your name while in joined channels',
                        arg = 'MentionAlert',
                    },
                    ScrollBack = {
                        type = 'toggle',
                        name = 'ScrollBack',
                        desc = 'Extend chat history to 10,000 lines',
                        arg = 'ScrollBack',
                    },
                    TimeStamps = {
                        type = 'toggle',
                        name = 'TimeStamps',
                        desc = 'Enable/disable chat timestamps',
                        arg = 'TimeStamps',
                    },
                    QuestAlert = {
                        type = 'toggle',
                        name = 'QuestAlert',
                        desc = 'Enable/disable quest alerts while in joined channels',
                        arg = 'QuestAlert',
                    },
                    WatchColor = {
                        type = 'color',
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
                        name = 'WatchColor',
                        desc = 'Set the color of Alerts chat',
                        arg = 'WatchColor',
                    },
                    WatchList = {
                        type = 'input',
                        multiline = true,
                        get = function( Info )
                            if( Addon.CHAT.persistence[ Info.arg ] ~= nil ) then
                                return Addon:Implode( Addon.CHAT.persistence[ Info.arg ],',' );
                            end
                        end,
                        set = function( Info,Value )
                            Value = Addon:Explode( Value,',' );
                            if( type( Value ) == 'table' ) then
                                Addon.CHAT.persistence[ Info.arg ] = {};
                                for i,v in pairs( Value ) do
                                    table.insert( Addon.CHAT.persistence[ Info.arg ],Addon:Minify( v ) );
                                end
                            else
                                Addon.CHAT.persistence[ Info.arg ] = {Addon:Minify( Value )};
                            end
                        end,
                        name = 'WatchList',
                        desc = 'Words or phrases to be alerted on when they are mentioned in chat. Note that phrases contain no spaces',
                        arg = 'WatchList',
                        width = 'full',
                    },
                }
            };
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
                    table.insert( Addon.CHAT.persistence.WatchList,Addon:Minify( v ) );
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
                    table.insert( Addon.CHAT.persistence.IgnoreList,Addon:Minify( v ) );
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
                if( Addon:Minify( ChannelName ):find( 'general' ) ) then
                    r,g,b,a = unpack( Addon.CHAT:GetValue( 'GeneralColor' ) );
                else
                    r,g,b,a = unpack( Addon.CHAT:GetValue( 'ChannelColor' ) );
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

            -- Prevent ignored messages
            for i,Ignore in ipairs( Addon.CHAT:GetIgnores() ) do
                if( Addon:Minify( OriginalText ):find( Addon:Minify( Ignore ) ) ) then
                    return true;
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
            for i,Watch in ipairs( Addon.CHAT:GetWatches() ) do
                if( Addon:Minify( OriginalText ):find( Addon:Minify( Watch ) ) ) then
                    Watched = Watch;
                end
            end
            if( Addon.CHAT:GetValue( 'QuestAlert' ) ) then
                for i,Watch in pairs( Addon.CHAT.ActiveQuests ) do
                    if( Addon:Minify( OriginalText ):find( Watch ) ) then
                        Watched = Watch;
                    end
                end
            end
            if( Addon.CHAT:GetValue( 'MentionAlert' ) ) then
                local MyPlayerName,Realm = UnitName( 'player' );
                if( Addon:Minify( OriginalText ):find( Addon:Minify( MyPlayerName ) ) ) then
                    Watched = MyPlayerName;
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
                if( Addon.CHAT:GetValue( 'AlertSound' ) ) then
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
            -- List channels
            C_Timer.After( 2, function()
                for i,v in pairs( Addon.CHAT.ChatFrame.channelList ) do
                    print( 'You have joined '..v );
                end
            end );
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
            -- Database
            Addon.CHAT.db = LibStub( 'AceDB-3.0' ):New( AddonName,{ char = Addon.CHAT:GetDefaults() },true );
            if( not Addon.CHAT.db ) then
                return;
            end
            Addon.CHAT.persistence = Addon.CHAT.db.char;
            if( not Addon.CHAT.persistence ) then
                return;
            end
            -- Chat frame
            Addon.CHAT.ChatFrame = DEFAULT_CHAT_FRAME;
            -- Watch cache
            Addon.CHAT.Cache = {};
            -- Chat defaults
            Addon.CHAT.ChatFrame.DefaultSettings = {};
            --Addon.CHAT.ChatFrame.editBox:SetScript( 'OnEditFocusGained',function( self )
                --local lastTold, lastToldType = ChatEdit_GetLastToldTarget();
                --Addon:Dump( { lastTold = lastTold,lastToldType = lastToldType })
                --self:SetTextColor( )
            --end );
        end

        Addon.CHAT:Init();
        Addon.CHAT:CreateFrames();
        Addon.CHAT:Refresh();
        Addon.CHAT:Run();
        Addon.CHAT:UnregisterEvent( 'ADDON_LOADED' );
    end
end );