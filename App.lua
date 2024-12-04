local _, Addon = ...;

Addon.APP = CreateFrame( 'Frame' );
Addon.APP:RegisterEvent( 'ADDON_LOADED' );
Addon.APP:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then

        --
        -- Set chant filter
        --
        -- @return void
        Addon.APP.SetFilter = function( self,Filter,Value )
            if( Value ) then
                ChatFrame_AddMessageEventFilter( Filter,self.Filter );
            else
                ChatFrame_RemoveMessageEventFilter( Filter,self.Filter );
            end
        end

        --
        -- Set chat group
        --
        -- @return void
        Addon.APP.SetGroup = function( self,Group,Value )
            if ( Value ) then
                ChatFrame_AddMessageGroup( Addon.CHAT.ChatFrame,Group );
            else
                ChatFrame_RemoveMessageGroup( Addon.CHAT.ChatFrame,Group );
            end
        end

        Addon.APP.GetMentionFrame = function( self,MessageText )
            local Frame = Addon.FRAMES:AddMovable( { Name='jChatMention',Value=MessageText },nil,self );

            Frame:SetScript( 'OnDragStop',function( self )
                self:StopMovingOrSizing();
                self:SetUserPlaced( true );
            end );

            Frame.Butt = CreateFrame( 'Button',nil,Frame,'UIPanelButtonTemplate' );
            Frame.Butt:SetSize( 32,32 );
            Frame.Butt:SetText( 'OK' );
            Frame.Butt:SetScript( 'OnClick',function( self )
                self:GetParent():Hide();
            end );
            Frame.Butt:SetPoint( 'topright',Frame,'topright',-10,-10 );
            Frame.Butt:RegisterForClicks( 'AnyDown','AnyUp' );

            return Frame;
        end

        Addon.APP.GetURLPatterns = function()
            return {
                { '[a-z]*://[^ >,;]*','%s' },
            };
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
        --  @param  string  Watched
        --  @param  bool    Mentioned
        --  @return list
        Addon.APP.Format = function( Event,MessageText,PlayerRealm,LangHeader,ChannelNameId,PlayerName,GMFlag,ChannelId,ChannelBaseName,UnUsed,LineId,PlayerId,BNId,IconReplacement,Watched,Mentioned )
            local OriginalText = MessageText;
            local ChatType = strsub( Event,10 );
            local Info = ChatTypeInfo[ ChatType ];
            if( not Info ) then
                Info = {
                    colorNameByClass = true,r = 255/255,g = 255/255,b = 255/255,id = nil,
                };
            end
            local _, ChannelName = GetChannelName( ChannelId );

            local GetName = function( Id )
                local Channels = Addon.DB:GetPersistence().Channels;
                for _,ChannelData in pairs( Channels ) do
                    if( ChannelData.Id == Id ) then
                        return ChannelData.Name;
                    end
                end
            end
            ChannelName = GetName( ChannelId ) or ChannelName;
            local ChatGroup = Chat_GetChatCategory( ChatType );

            -- Player info
            local LocalizedClass,EnglishClass,LocalizedRace,EnglishRace,Sex,Name,Server;
            if( PlayerId ) then
                LocalizedClass,EnglishClass,LocalizedRace,EnglishRace,Sex,Name,Server = GetPlayerInfoByGUID( PlayerId );
                if( PlayerName == '' ) then
                    PlayerName = Name;
                end
            end
            --print( C_FriendList.SendWho( PlayerRealm ) );

            -- Chat color
            local ChannelColor = {
                r = Info.r,
                g = Info.g,
                b = Info.b,
                a = 1,
            };
            local Channels = Addon.DB:GetPersistence().Channels;
            if( tonumber( ChannelId ) > 0 ) then
                if( Channels[ ChannelName ] and Channels[ ChannelName ].Color ) then
                    ChannelColor.r,ChannelColor.g,ChannelColor.b,ChannelColor.a = unpack( Channels[ ChannelName ].Color );
                end
            end
            local HighLightColor = {};
            if( Mentioned ) then
                if( ChatTypeInfo.WHISPER ) then
                    HighLightColor.r,HighLightColor.g,HighLightColor.b,HighLightColor.a = ChatTypeInfo.WHISPER.r,ChatTypeInfo.WHISPER.g,ChatTypeInfo.WHISPER.b,1;
                end
            elseif( Watched and ( ChatType == 'WHISPER' ) == false ) then
                HighLightColor.r,HighLightColor.g,HighLightColor.b,HighLightColor.a = unpack( Addon.APP:GetValue( 'AlertColor' ) );
            end
            ChatTypeInfo[ ChatType ] = ChatTypeInfo[ ChatType ] or {
                r = Info.r,
                g = Info.g,
                b = Info.b,
                a = 1,
            };
            ChatTypeInfo[ ChatType ].r,
            ChatTypeInfo[ ChatType ].g,
            ChatTypeInfo[ ChatType ].b,
            ChatTypeInfo[ ChatType ].a = ChannelColor.r,ChannelColor.g,ChannelColor.b,ChannelColor.a;
            -- Channel changes
            --[[
            if( Event == 'CHAT_MSG_CHANNEL_NOTICE_USER' ) then
                local CausedPlayer = MessageText;
                local AffectedPlayer = ChannelNameId;
                local TypeOfEvent = Event;
                if( AffectedPlayer ) then
                    MessageText = AffectedPlayer..' '..TypeOfEvent;
                else
                    MessageText = CausedPlayer..' '..TypeOfEvent;
                end
            end
            ]]

            -- Class color
            if( PlayerName and Addon.APP:GetValue( 'ColorNamesByClass' ) ) then
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
            local Text;
            if( QuestieLoader ) then
                local QuestieFilter = QuestieLoader:ImportModule( 'ChatFilter' );
                _,Text = QuestieFilter.Filter( Addon.CHAT.ChatFrame,_,MessageText,PlayerRealm,LangHeader,ChannelNameId,PlayerName,GMFlag,ChannelNameId,ChannelId,ChannelBaseName,UnUsed,LineId,PlayerId,BNId );
            end
            if( Text ) then
                MessageText = Text;
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
            local chatTimestampFmt = Addon.APP:GetValue( 'showTimestamps' );
            if ( chatTimestampFmt ~= 'none' ) then
                TimeStamp = BetterDate( chatTimestampFmt,time() );
            end
            if( GetCVar( 'showTimestamps' ) ~= chatTimestampFmt ) then
                SetCVar( 'showTimestamps',chatTimestampFmt );
            end

            TimeStamp = CreateColor( unpack( Addon.APP:GetValue( 'TimeColor' ) ) ):WrapTextInColorCode( TimeStamp );

            -- Channel link
            -- https://wowpedia.fandom.com/wiki/Hyperlinks
            -- https://wowwiki-archive.fandom.com/wiki/ItemLink
            -- Interface/AddOns/Blizzard_UIPanels_Game/Mainline/ItemRef.lua
            local ChannelLink = '';
            if( tonumber( ChannelId ) > 0 ) then
                ChannelLink = "|Hchannel:channel:"..ChannelId.."|h["..ChannelId..')'..ChannelBaseName.."]|h"    -- "|Hchannel:channel:2|h[2. Trade - City]|h"
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
            local TypeColor = ChatTypeInfo[ ChatType ];
            if( TypeColor ) then
                ChannelLink = CreateColor( TypeColor.r,TypeColor.g,TypeColor.b ):WrapTextInColorCode( ChannelLink );
            end

            -- Player link
            local PlayerLink = "|Hplayer:"..PlayerRealm.."|h".."["..PlayerName.."]|h"; -- |Hplayer:Blasfemy-Grobbulus|h was here

            -- Outfit link -- test code copied from reference links above
            --local OutfitLink = '|cffff80ff|Houtfit:"a;"aA%ib"a>!.h&Ul"uH"a8"v""a@"v<"a"!!!!5o!!!!!!!!!|h[|T1598183:13:13:-1:0|tOutfit]|h|r';


            --[[
            -- todo: fix communities link

            if( ChatType == 'COMMUNITIES_CHANNEL' ) then
                local IsBattleNetCommunity = BNId ~= nil and BNId ~= 0;
                local MessageInfo,ClubId,StreamId,ClubType = C_Club.GetInfoFromLastCommunityChatLine();
                if( MessageInfo ~= nil ) then
                    if( IsBattleNetCommunity ) then
                        PlayerLink = GetBNPlayerCommunityLink( PlayerRealm,PlayerName,BNId,ClubId,StreamId,MessageInfo.messageId.epoch,MessageInfo.messageId.position );
                    else
                        playerLink = GetPlayerCommunityLink( PlayerRealm,PlayerName,ClubId,StreamId,MessageInfo.messageId.epoch,MessageInfo.messageId.position );
                    end
                end
            end
            ]]

            -- join/leave
            if( ( not MessageText or MessageText == '' ) and ChatType == 'CHANNEL_JOIN' ) then
                MessageText = 'has joined the channel.';
            elseif( ( not MessageText or MessageText == '' ) and ChatType == 'CHANNEL_LEAVE' ) then
                MessageText = 'has left the channel.';
            end

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

            -- Message Prefix
            local MessagePrefix = TimeStamp..ChannelLink..PFlag..PlayerLink..PlayerAction..PlayerLevel;

            -- url copy
            if( Addon.APP:GetValue( 'LinksEnabled' ) ) then
                local Color = 'ffffff';
                local ALink = '|cff'..Color..'|Haddon:jChat:url|h[>%1$s<]|h|r';
                if( strlen( MessageText ) > 7 ) then
                    local Patterns = Addon.APP:GetURLPatterns();
                    for i = 1, #Patterns do
                        local v = Patterns[i];
                        MessageText = gsub( MessageText,v[1],function( str )
                            return format( ALink,str );
                        end );
                    end
                end
            end

            -- Partial highlight
            if( Watched and ChatType ~= 'WHISPER' ) then
                MessageText = Addon:GiSub( MessageText,Watched,CreateColor( HighLightColor.r,HighLightColor.g,HighLightColor.b,HighLightColor.a ):WrapTextInColorCode( Watched ) );
            end

            -- Always sound whispers
            if ( ChatType == 'WHISPER' ) then
                PlaySound( SOUNDKIT.TELL_MESSAGE,Addon.APP:GetValue( 'AlertChannel' ) );
            end

            -- Always sound whispers
            if( ChatType == 'WHISPER' and Addon.APP.Notices[ Addon:Minify( MessageText ) ] ~= true ) then

                if( Addon.APP:GetValue( 'AFKAlert' ) and UnitIsAFK( 'player' ) ) then
                    PlaySound( SOUNDKIT.TELL_MESSAGE,Addon.APP:GetValue( 'AlertChannel' ) );

                    local F = Addon.APP:GetMentionFrame( MessagePrefix..' '..MessageText );
                    local MentionDrop = Addon.APP:GetValue( 'MentionDrop' );
                    if( MentionDrop.x and MentionDrop.y ) then
                        F:SetPoint( MentionDrop.p,MentionDrop.x,MentionDrop.y );
                    else
                        F:SetPoint( 'center' );
                    end

                    F.Butt:SetScript( 'OnClick',function( self )
                        if( Addon.APP.Notices and Addon.APP.Notices[ Addon:Minify( MessageText ) ] ) then
                            Addon.APP.Notices[ Addon:Minify( MessageText ) ] = nil;
                        end
                        self:GetParent():Hide();
                    end );

                    Addon.APP.Notices[ Addon:Minify( MessageText ) ] = true;
                end
            end

            -- Always sound mentions
            if( Mentioned and Addon.APP.Notices[ Addon:Minify( MessageText ) ] ~= true ) then

                if( Addon.APP:GetValue( 'MentionAlert' ) ) then
                    PlaySound( SOUNDKIT.TELL_MESSAGE,Addon.APP:GetValue( 'AlertChannel' ) );

                    local F = Addon.APP:GetMentionFrame( MessagePrefix..' '..MessageText );
                    local MentionDrop = Addon.APP:GetValue( 'MentionDrop' );
                    if( MentionDrop.x and MentionDrop.y ) then
                        F:SetPoint( MentionDrop.p,MentionDrop.x,MentionDrop.y );
                    else
                        F:SetPoint( 'center' );
                    end

                    F.Butt:SetScript( 'OnClick',function( self )
                        if( Addon.APP.Notices and Addon.APP.Notices[ Addon:Minify( MessageText ) ] ) then
                            Addon.APP.Notices[ Addon:Minify( MessageText ) ] = nil;
                        end
                        self:GetParent():Hide();
                    end );

                    Addon.APP.Notices[ Addon:Minify( MessageText ) ] = true;
                end
            end

            -- Full highlight
            if( Watched and Addon.APP:GetValue( 'FullHighlight' ) and ChatType ~= 'WHISPER' ) then
                MessageText = MessageText..' : '..CreateColor( HighLightColor.r,HighLightColor.g,HighLightColor.b,HighLightColor.a ):WrapTextInColorCode( Watched );
                PlaySound( SOUNDKIT.TELL_MESSAGE,Addon.APP:GetValue( 'AlertChannel' ) );

                return MessagePrefix..' '..MessageText,HighLightColor.r,HighLightColor.g,HighLightColor.b,HighLightColor.a,Info.id;
            end

            -- Partial highlight
            if( Watched and ChatType ~= 'WHISPER') then
                MessageText = MessageText..' : '..CreateColor( HighLightColor.r,HighLightColor.g,HighLightColor.b,HighLightColor.a ):WrapTextInColorCode( Watched );
                PlaySound( SOUNDKIT.TELL_MESSAGE,Addon.APP:GetValue( 'AlertChannel' ) );
            end

            return MessagePrefix..' '..MessageText,ChannelColor.r,ChannelColor.g,ChannelColor.b,Info.id;
        end

        --
        --  Time Cache Rules
        --
        --  @param  list    ...
        --  @return string
        Addon.APP.GetCacheKey = function( self,... )
            local ChatType = strsub( Event,10 );
            local MessageText = select( 1,... );
            local PlayerName = select( 5,... );
            local PlayerId = select( 12,... );

            local MyPlayerName,MyRealm = UnitName( 'player' );
            local Player = PlayerId or PlayerName;

            local OncePerMinute = "%H:%M";
            local OncePerSecond = "%H:%M:%S";

            -- My own messages
            if( Addon:Minify( PlayerName ):find( Addon:Minify( MyPlayerName ) ) ) then
                return Addon:Minify( Player..MessageText..date( OncePerSecond ) );

            -- Guild messages
            elseif( Addon:Minify( ChatType ):find( 'guild' ) ) then
                return Addon:Minify( Player..MessageText..date( OncePerSecond ) )

            -- Everyone else
            else
                return Addon:Minify( Player..MessageText..date( OncePerMinute ) );
            end
        end

        --
        --  Filter Chat Message
        --
        --  @param  string  Event
        --  @param  list    ...
        --  @return bool
        Addon.APP.Filter = function( self,Event,... )
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

            local Prefix,ABBREV,Queued,_,_,_,Tank,Healer,DPS = strsplit( ':',MessageText );
            local MyPlayerName,MyRealm = UnitName( 'player' );

            -- Invite check
            if( ChatType == 'WHISPER' and Addon.APP:GetValue( 'AutoInvite' ) ) then
                if( Addon:Minify( OriginalText ):find( 'inv' ) ) then
                    if( Addon.APP:GetValue( 'Debug' ) ) then
                        Addon.FRAMES:Debug( 'jChat:App','found "inv"' );
                    end
                    if( GetNumGroupMembers and GetNumGroupMembers() > 4 ) then
                        if( Addon.APP:GetValue( 'Debug' ) ) then
                            Addon.FRAMES:Debug( 'jChat:App','GetNumGroupMembers',GetNumGroupMembers() );
                        end
                        if( ConvertToRaid ) then
                            ConvertToRaid();
                        elseif( C_PartyInfo and C_PartyInfo.ConvertToRaid ) then
                            C_PartyInfo:ConvertToRaid();
                        end
                    end
                    if( Addon.APP:GetValue( 'Debug' ) ) then
                        print( 'jChat:App','Inviting Player',PlayerName );
                    end
                    InviteUnit( PlayerName );
                end
            end

            -- Prevent ignored messages
            local IgnoredMessages = Addon.CONFIG:GetIgnores();
            if( #IgnoredMessages > 0 ) then
                for i,IgnoredMessage in ipairs( IgnoredMessages ) do
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( IgnoredMessage ) ) ) then
                        if( not Addon:Minify( PlayerName ):find( Addon:Minify( MyPlayerName ) ) ) then
                            return true;
                        end
                    end
                end
            end

            -- Prevent toggled off message types
            local PossibleTypes = {};
            for Type,MessageTypes in pairs( Addon.CONFIG:GetChatFilters() ) do
                for i,MessageType in pairs( MessageTypes ) do
                    PossibleTypes[ MessageType ] = Type;
                end
            end
            local Values = Addon.APP:GetValue( 'ChatGroups' );
            if( PossibleTypes[ Event ] and not Values[ PossibleTypes[ Event ] ] ) then
                --print( 'stopped sending',Event,MessageText )
                return true;
            end

            -- GM check
            if( GMFlag == 'GM' and ChatType == 'WHISPER' ) then
                return;
            end

            -- Prevent repeat messages
            local CacheKey = Addon.APP:GetCacheKey( ... );
            if( Addon.APP.Cache[ CacheKey ] ) then
                return true;
            end
            Addon.APP.Cache[ CacheKey ] = true;

            -- Watch check
            local Watched,Mentioned = false,false;
            local WatchedMessages = Addon.CONFIG:GetAlerts();
            if( #WatchedMessages > 0 ) then
                for i,WatchedMessage in ipairs( WatchedMessages ) do
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( WatchedMessage ) ) ) then
                        Watched = WatchedMessage;
                    end
                end
            end
            if( Addon.APP:GetValue( 'QuestAlert' ) ) then
                for i,ActiveQuest in pairs( Addon.QUESTS.ActiveQuests ) do
                    if( Addon:Minify( OriginalText ):find( ActiveQuest ) ) then
                        Watched = ActiveQuest;
                    end
                end
            end
            if( Addon.APP:GetValue( 'MentionAlert' ) ) then
                if( Addon:Minify( OriginalText ):find( Addon:Minify( MyPlayerName ) ) ) then
                    Mentioned = true;
                end
                if( Prefix and Prefix == Addon.DUNGEONS.PREFIX ) then
                    Mentioned = false;
                end
            end
            local AliasList = Addon.CONFIG:GetAliasList();
            if( #AliasList > 0 ) then
                for i,Alias in ipairs( AliasList ) do
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( Alias ) ) ) then
                        Mentioned = true;
                    end
                end
                if( Prefix and Prefix == Addon.DUNGEONS.PREFIX ) then
                    Mentioned = false;
                end
            end

            -- Queue check
            local Dungeons = Addon.DUNGEONS:GetDungeonsF();
            for ABBREV,IsQueued in pairs( Addon.APP:GetDungeonQueue() ) do
                if( IsQueued ) then
                    for _,Abbrev in pairs( Dungeons[ ABBREV ].Abbrevs ) do
                        if( Addon:Minify( OriginalText ):find( Addon:Minify( Abbrev ) ) ) then
                            Watched = Abbrev;
                        end
                    end
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( ABBREV ) ) ) then
                        Watched = ABBREV;
                    end
                end
            end
            local Raids = Addon.DUNGEONS:GetRaidsF();
            for ABBREV,IsQueued in pairs( Addon.APP:GetRaidQueue() ) do
                if( IsQueued ) then
                    for _,Abbrev in pairs( Raids[ ABBREV ].Abbrevs ) do
                        if( Addon:Minify( OriginalText ):find( Addon:Minify( Abbrev ) ) ) then
                            Watched = Abbrev;
                        end
                    end
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( ABBREV ) ) ) then
                        Watched = ABBREV;
                    end
                end
            end
            --[[
            if( Prefix and Prefix == Addon.DUNGEONS.PREFIX ) then
                local ChannelId;
                for i,Channel in pairs( Addon.CHAT:GetChannels() ) do
                    if( Channel.Name == Addon.DUNGEONS.CHANNEL_NAME ) then
                        ChannelId = Channel.Id;
                    end
                end
                if( ChannelId ) then
                    Addon.DUNGEONS:OnCommReceived( Prefix,MessageText,'CHANNEL',ChannelId );
                end
            end
            ]]

            -- Format message
            MessageText,r,g,b,a,id = Addon.APP.Format(
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
                Watched,
                Mentioned
            );

            -- Display
            Addon.CHAT.ChatFrame:AddMessage( MessageText,r,g,b,id );

            return true;
        end;

        --
        -- Set DB value
        --
        -- @return void
        Addon.APP.SetValue = function( self,Index,Value )
            Addon.DB:SetValue( Index,Value );
        end

        --
        -- Get DB value
        --
        -- @return mixed
        Addon.APP.GetValue = function( self,Index )
            return Addon.DB:GetValue( Index );
        end

        --
        -- Get dungeon queue
        --
        -- @return table
        Addon.APP.GetDungeonQueue = function( self )
            return Addon.DB:GetPersistence().DungeonQueue or {};
        end

        --
        -- Get raid queue
        --
        -- @return table
        Addon.APP.GetRaidQueue = function( self )
            return Addon.DB:GetPersistence().RaidQueue or {};
        end

        --
        --  Module init
        --
        --  @return void
        Addon.APP.Init = function( self )
            if( not Addon.DB:GetPersistence() ) then
                return;
            end

            -- Message cache
            self.Cache = {};

            -- Notice cache
            self.Notices = {};

            -- Chat text
            Addon.CHAT:SetFont( self:GetValue( 'Font' ),Addon.CHAT.ChatFrame);

            -- Fading
            Addon.CHAT:SetFading( self:GetValue( 'FadeOut' ),Addon.CHAT.ChatFrame );

            -- Scrolling
            Addon.CHAT:SetScrolling( self:GetValue( 'ScrollBack' ),Addon.CHAT.ChatFrame );

            -- Quests
            if( self:GetValue( 'QuestAlert' ) ) then
                Addon.QUESTS:EnableQuestEvents();
            else
                Addon.QUESTS:DisableQuestEvents();
            end
            Addon.QUESTS:RebuildQuests();

            -- Chat link clicks
            hooksecurefunc( 'SetItemRef',function( Pattern,FullText )
                local linkType,addon,param1 = strsplit( ':',Pattern );
                if( linkType == 'addon' and addon == 'jChat' ) then
                    if( param1 == 'url' ) then
                        Addon.CHAT.ChatFrame.editBox:SetText( FullText:match( ">(.-)<" ) );

                        ChatEdit_ActivateChat( Addon.CHAT.ChatFrame.editBox );
                    end
                end
            end );

            -- Chat types
            for Group,GroupData in pairs( Addon.CONFIG:GetMessageGroups() ) do
                for _,GroupName in pairs( GroupData ) do
                    -- Always allow outgoing whispers
                    if( Addon:Minify( GroupName ):find( 'whisperinform' ) ) then
                        self:SetGroup( GroupName,true );
                    -- Respect checked options
                    else
                        local Groups = self:GetValue( 'ChatGroups' );
                        if( Groups ) then
                            self:SetGroup( GroupName,Groups[ Group ] );
                            ToggleChatColorNamesByClassGroup( Groups[ Group ],GroupName );
                        end
                    end
                end
            end

            -- Chat filter
            for Filter,FilterData in pairs( Addon.CONFIG:GetChatFilters() ) do
                for _,FilterName in pairs( FilterData ) do
                    local Filters = self:GetValue( 'ChatFilters' );
                    if( Filters ) then
                        self:SetFilter( FilterName,Filters[ Filter ] );
                    end
                end
            end

            -- Communities
            local Clubs = C_Club.GetSubscribedClubs();
            for i,Club in pairs( Clubs ) do
                if( Club.clubType ~= 2 ) then -- guild
                    local ClubStreams = C_Club.GetStreams( Club.clubId );
                    local ClubInfo = C_Club.GetClubInfo( Club.clubId );
                    for v,Stream in pairs( ClubStreams ) do
                        if( Stream.streamId ) then
                            Addon.CHAT:InitCommunity( Addon.CHAT.ChatFrame,Club.clubId,Stream.streamId );
                        end
                    end
                end
            end

            -- List channels
            for i,Channel in pairs( Addon.CHAT:GetChannels() ) do
                Channel.Name = Addon.CHAT:GetClubName( Channel.Name ) or Channel.Name;

                -- club
                local ClubData = Addon:Explode( Channel.Name,':' );
                if( ClubData and tonumber( #ClubData ) > 0 ) then
                    local ClubId = ClubData[2] or 0;
                    if( tonumber( ClubId ) > 0 ) then
                        local ClubInfo = C_Club.GetClubInfo( ClubId );
                        if( ClubInfo ) then
                            Channel.Name = ClubInfo.shortName or ClubInfo.name;
                            Channel.Name = ChannelData.Name:gsub( '%W','' );
                        end
                    end
                end

                local ChannelLink = Channel.Id..')'..Channel.Name;
                if( tonumber( Channel.Id ) > 0 ) then
                    ChannelLink = "|Hchannel:channel:"..Channel.Id.."|h["..Channel.Id..')'..Channel.Name.."]|h"    -- "|Hchannel:channel:2|h[2. Trade - City]|h"s
                end

                local r,g,b,a,id = 1,1,1,1,nil;
                local Channels = Addon.DB:GetPersistence().Channels;
                if( tonumber( Channel.Id ) > 0 ) then
                    if( Channels[ Channel.Name ] and Channels[ Channel.Name ].Color ) then
                        r,g,b,a = unpack( Channels[ Channel.Name ].Color );
                    end
                end

                Addon.CHAT.ChatFrame:AddMessage( 'You have joined '..ChannelLink,r,g,b,a,id );
            end

            -- Requeue
            --[[
                    -- blizz disabled this functionality

                    -- see Dungeons:OnCommReceived() for more details

            C_Timer.After( 5,function()
                for ABBREV,Instance in pairs( Addon.DUNGEONS:GetDungeonsF( UnitLevel( 'player' ) ) ) do
                    if( Addon.DB:GetPersistence().DungeonQueue[ ABBREV ] ) then
                        local ReqLevel = Addon.DUNGEONS:GetDungeons()[ ABBREV ].LevelBracket[1];
                        local Roles = Addon.DB:GetPersistence().Roles;
                        local Queued = Addon.DB:GetPersistence().DungeonQueue[ ABBREV ] or false;

                        Addon.DUNGEONS:SendAddonMessage( ABBREV,ReqLevel,Roles,Queued );
                    end
                end
            end );
            ]]

            -- Config callbacks
            Addon.CONFIG:RegisterCallbacks( self );

            -- Slash command
            SLASH_JCHAT1, SLASH_JCHAT2 = '/jc', '/jchat';
            SlashCmdList['JCHAT'] = function( Msg,EditBox )
                Settings.OpenToCategory( 'jChat' );
            end
        end

        local Iterator = 1;
        local Timer = 10; if( Addon:IsRetail() ) then Timer = 15; end;
        -- todo: solve issue where we can't join channels due to IsFlying()
        -- seems rather silly that the game can't join channels when you log in while flying
        hooksecurefunc( 'ChatFrame_RegisterForChannels',function( self,...)
            if( not( Iterator > 1 ) ) then
                C_Timer.After( Timer,function()

                    Addon.DB:Init();
                    --Addon.DB:Reset();

                    Addon.CHAT:Init();
                    Addon.CONFIG:Init();
                    Addon.APP:Init();

                end );
                Iterator = Iterator+1;
            end
        end );
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );