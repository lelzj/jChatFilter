local _, Addon = ...;

Addon.CHAT = CreateFrame( 'Frame' );
Addon.CHAT:RegisterEvent( 'ADDON_LOADED' );
Addon.CHAT:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then
        Addon.CHAT.SetFont = function( self,Font,ChatFrame )
            if( Font ) then
                ChatFrame:SetFont( 'Fonts\\'..Font.Family..'.ttf',Font.Size,Font.Flags );
                ChatFrame:SetShadowOffset( 0,0 );
                ChatFrame:SetShadowColor( 0,0,0,0 );
            end
        end
        Addon.CHAT.SetFading = function( self,Value,ChatFrame )
            ChatFrame:SetFading( Value );
        end
        Addon.CHAT.SetScrolling = function( self,Value,ChatFrame )
            if( Value ) then
                ChatFrame:SetMaxLines( 10000 );
            end
        end

        Addon.CHAT.GetBaseColor = function( self )
            return {
                        254 / 255,
                        191 / 255,
                        191 / 255,
                        1,
                    };
        end

        --
        --  Join channel
        --
        --  @return bool
        Addon.CHAT.JoinChannel = function( self,ChannelName )
            if( ChannelName ) then
                local Type,Name = JoinPermanentChannel( ChannelName );
                Addon.APP.persistence.Channels[ ChannelName ] = {
                    Color = self:GetBaseColor(),
                    Id = #Addon.APP.ChatFrame.channelList+1,
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
                Addon.APP.persistence.Channels[ ChannelName ] = nil;
                return true;
            end
            return false;
        end

        --
        --  Get channel id
        --
        --  @param  string  ChannelName
        --  @return int
        Addon.CHAT.GetChannelId = function( self,ChannelName )
            local ChannelId;
            if( ChannelName ) then
                local Channels = { GetChannelList() };
                for i=1,#Channels,3 do
                    local Id,Name = Channels[i],Channels[i+1];
                    if( Addon:Minify( Name ):find( Addon:Minify( ChannelName ) ) ) then
                        ChannelId = Id;
                    end
                end
            end
            return ChannelId;
        end

        --
        --  Get channel name
        --
        --  @param  string  Id
        --  @return int
        Addon.CHAT.GetChannelName = function( self,ChannelId )
            local ChannelName;
            if( ChannelId ) then
                local Channels = { GetChannelList() };
                for i=1,#Channels,3 do
                    local Id,Name = Channels[i],Channels[i+1];
                    if( Addon:Minify( ChannelId ):find( Addon:Minify( tostring( Id ) ) ) ) then
                        ChannelName = Name;
                    end
                end
            end
            return ChannelName;
        end

        Addon.CHAT.GetChannels = function( self )
            local ChannelList = {};
            local Channels = { GetChannelList() };
            for i = 1,#Channels,3 do
                ChannelList[ i ] = {
                    Id = Channels[i],
                    Name = Channels[i+1],
                    Disabled = Channels[i+2],
                };
            end
            return ChannelList;
        end

        Addon.CHAT.GetClubName = function( self,ChannelName )
            local ClubData = Addon:Explode( ChannelName,':' );
            if( ClubData and tonumber( #ClubData ) > 0 ) then
                local ClubId = ClubData[2] or 0;
                local ClubInfo = C_Club.GetClubInfo( ClubId );
                if( ClubInfo ) then
                    return ClubInfo.name;
                end
            end
        end

        Addon.CHAT.InitCommunity = function( self,ChatFrame,ClubId,StreamId )
            C_Club.AddClubStreamChatChannel( ClubId,StreamId );
            
            local ChannelName = Chat_GetCommunitiesChannelName( ClubId,StreamId );
            
            local ChannelColor = CreateColor( unpack( self:GetBaseColor() ) );

            local SetEditBoxToChannel;

            local function ChatFrame_AddCommunitiesChannel(chatFrame, channelName, channelColor, setEditBoxToChannel)
                local channelIndex = ChatFrame_AddChannel(chatFrame, channelName);
                --chatFrame:AddMessage(COMMUNITIES_CHANNEL_ADDED_TO_CHAT_WINDOW:format(channelIndex, ChatFrame_ResolveChannelName(channelName)), channelColor:GetRGB());

                if setEditBoxToChannel then
                    chatFrame.editBox:SetAttribute("channelTarget", channelIndex);
                    chatFrame.editBox:SetAttribute("chatType", "CHANNEL");
                    chatFrame.editBox:SetAttribute("stickyType", "CHANNEL");
                    ChatEdit_UpdateHeader(chatFrame.editBox);
                end
            end

            local Found;
            local NewInfo = C_Club.GetClubInfo( ClubId );
            for ChannelId,CName in pairs( ChatFrame.channelList ) do

                local OldName = self:GetClubName( CName );
                if( NewInfo and NewInfo.name and OldName ) then

                    local ClubStreams = C_Club.GetStreams( NewInfo.clubId );
                    if( ClubStreams ) then
                        for v,Stream in pairs( ClubStreams ) do
                            if( Stream.streamId ) then
                                if( OldName == NewInfo.name and Stream.streamId == StreamId ) then
                                    Found = true;
                                end
                            end
                        end
                    end
                end
            end
            if( not Found ) then
                ChatFrame_AddCommunitiesChannel( ChatFrame,ChannelName,ChannelColor,SetEditBoxToChannel );
            end
        end

        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );