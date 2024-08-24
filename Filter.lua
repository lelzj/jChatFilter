local _, Addon = ...;

Addon.FILTER = CreateFrame( 'Frame' );
Addon.FILTER:RegisterEvent( 'ADDON_LOADED' );
Addon.FILTER:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then
        --
        -- Set chant filter
        --
        -- @return void
        Addon.FILTER.SetFilter = function( self,Filter,Value )
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
        Addon.FILTER.SetGroup = function( self,Group,Value )
            if ( Value ) then
                --print( Addon.CHAT.ChatFrame:GetName(),'add',Group )
                ChatFrame_AddMessageGroup( Addon.CHAT.ChatFrame,Group );
            else
                --print( Addon.CHAT.ChatFrame:GetName(),'remove',Group )
                ChatFrame_RemoveMessageGroup( Addon.CHAT.ChatFrame,Group );
            end
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
        Addon.FILTER.Format = function( Event,MessageText,PlayerRealm,LangHeader,ChannelNameId,PlayerName,GMFlag,ChannelId,ChannelBaseName,UnUsed,LineId,PlayerId,BNId,IconReplacement,Watched,Mentioned )
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
                if( Addon.CONFIG.persistence.Channels[ ChannelName ] and Addon.CONFIG.persistence.Channels[ ChannelName ].Color ) then
                    r,g,b,a = unpack( Addon.CONFIG.persistence.Channels[ ChannelName ].Color );
                end
            end
            if( Watched and ( ChatType == 'WHISPER' ) == false ) then
                r,g,b,a = unpack( Addon.CONFIG:GetValue( 'AlertColor' ) );
            elseif( Mentioned ) then
                if( ChatTypeInfo.WHISPER ) then
                    r,g,b,a = ChatTypeInfo.WHISPER.r,ChatTypeInfo.WHISPER.g,ChatTypeInfo.WHISPER.b,1;
                end
            end

            -- Class color
            if( PlayerName and Addon.CONFIG:GetValue( 'ColorNamesByClass' ) ) then
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
            local chatTimestampFmt = Addon.CONFIG:GetValue( 'showTimestamps' );
            if ( chatTimestampFmt ~= 'none' ) then
                TimeStamp = BetterDate( chatTimestampFmt,time() );
            end
            SetCVar( 'showTimestamps',chatTimestampFmt );

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
            local PlayerLink = "|Hplayer:"..PlayerRealm.."|h".."["..PlayerName.."]|h"; -- |Hplayer:Blasfemy-Grobbulus|h was here

            --[[
            -- todo: fix communities link
            -- while we are at it, prob should make it so that when we join a community..
            -- it automatically adds it to the chat window

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
            if( ( not MessageText or MessageText == '' ) and ChatType == 'CHANNEL_JOIN' ) then
                MessageText = 'has joined the channel.';
            elseif( ( not MessageText or MessageText == '' ) and ChatType == 'CHANNEL_LEAVE' ) then
                MessageText = 'has left the channel.';
            end
            MessageText = TimeStamp..ChannelLink..PFlag..PlayerLink..PlayerAction..PlayerLevel..': '..MessageText;

            -- Highlight
            if( Watched ) then
                MessageText = Addon:GiSub( MessageText, Watched, CreateColor( r,g,b ):WrapTextInColorCode( Watched ) );
            end

            --[[-- Append what was watched
            if( Watched ) then
                MessageText = MessageText..' : '..CreateColor( r,g,b ):WrapTextInColorCode( Watched );
            end]]

            -- Return
            if( Addon.CONFIG:GetValue( 'FullHighlight' ) ) then
                return MessageText,r,g,b,a,Info.id;
            end
            return MessageText,Info.r,Info.g,Info.b,1,Info.id;
        end

        --
        --  Filter Chat Message
        --
        --  @param  string  Event
        --  @param  list    ...
        --  @return bool
        Addon.FILTER.Filter = function( self,Event,... )
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

            -- Invite check
            if( ChatType == 'WHISPER' and Addon.CONFIG:GetValue( 'AutoInvite' ) ) then
                if( Addon:Minify( OriginalText ):find( 'inv' ) ) then
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
            local FoundType = false;
            for index,value in pairs( Addon.CHAT.ChatFrame.messageTypeList ) do
                if( strupper( value ) == strupper( ChatType ) ) then
                    FoundType = true;
                end
            end
            if( not Addon:Minify( PlayerName ):find( Addon:Minify( MyPlayerName ) ) ) then
                if( not FoundType ) then
                    return true;
                end
            end

            -- Prevent repeat messages for 1 minute
            local CacheKey = Addon:Minify( PlayerRealm..MessageText..date( "%H:%M" ) );
            if( Addon.FILTER.Cache[ CacheKey ] ) then
                return true;
            end
            Addon.FILTER.Cache[ CacheKey ] = true;

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
            if( Addon.CONFIG:GetValue( 'QuestAlert' ) ) then
                for i,ActiveQuest in pairs( Addon.QUESTS.ActiveQuests ) do
                    if( Addon:Minify( OriginalText ):find( ActiveQuest ) ) then
                        Watched = ActiveQuest;
                    end
                end
            end
            if( Addon.CONFIG:GetValue( 'MentionAlert' ) ) then
                if( Addon:Minify( OriginalText ):find( Addon:Minify( MyPlayerName ) ) ) then
                    Mentioned = true;
                end
            end
            local AliasList = Addon.CONFIG:GetAliasList();
            if( #AliasList > 0 ) then
                for i,Alias in ipairs( AliasList ) do
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( Alias ) ) ) then
                        Mentioned = true;
                    end
                end
            end

            -- Queue check
            local Dungeons = Addon.DUNGEONS:GetDungeonsF( UnitLevel( 'player' ) );
            for ABBREV,IsQueued in pairs( Addon.DUNGEONS:GetDungeonQueue() ) do
                if( IsQueued ) then
                    for _,Abbrev in pairs( Dungeons[ ABBREV ].Abbrevs ) do
                        if( Addon:Minify( OriginalText ):find( Addon:Minify( Abbrev ) ) ) then
                            Watched = Abbrev;
                        end
                    end
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( Dungeons[ ABBREV ].Name ) ) ) then
                        Watched = Dungeons[ ABBREV ].Name;
                    end
                end
            end
            local Raids = Addon.DUNGEONS:GetRaidsF( UnitLevel( 'player' ) );
            for ABBREV,IsQueued in pairs( Addon.DUNGEONS:GetRaidQueue() ) do
                if( IsQueued ) then
                    for _,Abbrev in pairs( Raids[ ABBREV ].Abbrevs ) do
                        if( Addon:Minify( OriginalText ):find( Addon:Minify( Abbrev ) ) ) then
                            Watched = Abbrev;
                        end
                    end
                    if( Addon:Minify( OriginalText ):find( Addon:Minify( Raids[ ABBREV ].Name ) ) ) then
                        Watched = Raids[ ABBREV ].Name;
                    end
                end
            end

            -- Format message
            MessageText,r,g,b,a,id = Addon.FILTER.Format(
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

            -- Always sound whispers
            if ( ChatType == 'WHISPER' ) then
                PlaySound( SOUNDKIT.TELL_MESSAGE );
            end
            -- Always sound mentions
            if( Mentioned ) then
                PlaySound( SOUNDKIT.TELL_MESSAGE );
                Addon.FRAMES:PopUpMessage( { Name='Mention',Value=MessageText,r=r,g=g,b=b,a=a },UIParent,Addon.FILTER );
            end
            -- Conditionally sound alerts
            if( Watched ) then
                if( Addon.CONFIG:GetValue( 'AlertSound' ) ) then
                    PlaySound( SOUNDKIT.TELL_MESSAGE );
                end
            end

            -- Display
            Addon.CHAT.ChatFrame:AddMessage( MessageText,r,g,b,id ); 
            return true;
        end;

        --
        --  Module run
        --
        --  @return void
        Addon.FILTER.Run = function( self )
            -- Chat filter
            for Filter,FilterData in pairs( Addon.CONFIG:GetChatFilters() ) do
                for _,FilterName in pairs( FilterData ) do
                    self:SetFilter( FilterName,Addon.CONFIG.persistence.ChatFilters[ Filter ] );
                end
            end
        end

        --
        --  Module init
        --
        --  @return void
        Addon.FILTER.Init = function( self )
            -- Watch cache
            self.Cache = {};

            -- Chat types
            for Group,GroupData in pairs( Addon.CONFIG:GetMessageGroups() ) do
                for _,GroupName in pairs( GroupData ) do
                    -- Always allow outgoing whispers
                    if( Addon:Minify( GroupName ):find( 'whisperinform' ) ) then
                        self:SetGroup( GroupName,true );
                    else
                        self:SetGroup( GroupName,Addon.CONFIG.persistence.ChatGroups[ Group ] );
                    end
                end
            end
        end

        C_Timer.After( 2,function()
            self:Init();
            self:Run();
        end );
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );