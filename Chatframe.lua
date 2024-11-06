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
        --  Get channel persistence
        --
        --  @return table
        Addon.CHAT.GetChannelPersistence = function( self )
            return Addon.DB:GetPersistence().Channels;
        end

        --
        --  Is channel joined
        --
        --  @param  string  ChannelName
        --  @return bool
        Addon.CHAT.IsChannelJoined = function( self,ChannelName )
            if( Addon.DB:GetValue( 'Debug' ) ) then
                Addon:Dump( self.ChatFrame.channelList );
            end

            for Id,Name in pairs( self.ChatFrame.channelList ) do
                if( Addon:Minify( ChannelName ) == Addon:Minify( Name ) ) then
                    return true;
                end
            end
        end

        --
        --  Join channel
        --  @todo blizz does not expose JoinChannel or LeaveChannel source code. as such, 
        --  it seems impossible to manage joined and left channels in a precise ordering.
        --  for now, this function should not be used until it can be updated to truly allow joining a channel in specifc order
        --
        --  @return bool
        Addon.CHAT.JoinChannel = function( self,ChannelName,ChannelId )
            if( ChannelName ) then
                local Type,Name = JoinPermanentChannel( ChannelName );

                local NumEntries = #self.ChatFrame.channelList or 0;

                local PreviousEntry = self.ChatFrame.channelList[tonumber( ChannelId )] or nil;

                self.ChatFrame.channelList[tonumber( ChannelId )] = ChannelName;

                if( PreviousEntry ) then
                    self.ChatFrame.channelList[NumEntries+1] = PreviousEntry
                end
                if( Addon.DB:GetValue( 'Debug' ) ) then
                    Addon.FRAMES:Debug( 'Joined',ChannelName,'Position',tonumber( ChannelId ) );
                end
                return Addon:Minify( self.ChatFrame.channelList[tonumber( ChannelId )] ) == Addon:Minify( ChannelName );
            end
        end

        --
        --  Leave channel
        --
        --  @return void
        Addon.CHAT.LeaveChannel = function( self,ChannelName )
            if( ChannelName ) then
                if( self:IsChannelJoined( ChannelName ) ) then

                    local ChannelId = self:GetChannelId( ChannelName );

                    if( tonumber( ChannelId ) > 0 ) then
                        LeaveChannelByName( ChannelName );
                        self.ChatFrame.channelList[tonumber( ChannelId )] = nil;
                    end
                end
            end
        end

        --
        --  Get channel id
        --
        --  @param  string  ChannelName
        --  @return int
        Addon.CHAT.GetChannelId = function( self,ChannelName )
            for Id,Name in pairs( self.ChatFrame.channelList ) do
                if( Addon:Minify( ChannelName ) == Addon:Minify( Name ) ) then
                    return Id;
                end
            end
        end

        --
        --  Get channel name
        --
        --  @param  string  Id
        --  @return int
        Addon.CHAT.GetChannelName = function( self,ChannelId )
            for Id,Name in pairs( self.ChatFrame.channelList ) do
                if( tonumber( Id ) == tonumber( ChannelId ) ) then
                    return Name;
                end
            end
        end

        Addon.CHAT.GetChannels = function( self )
            local ChannelList = {};
            local Channels = { GetChannelList() };
            for i = 1,#Channels,3 do
                local Club;
                local ClubData = Addon:Explode( Channels[i+1],':' );
                if( ClubData and tonumber( #ClubData ) > 0 ) then
                    local ClubId = ClubData[2] or 0;
                    if( tonumber( ClubId ) > 0 ) then
                        Club = C_Club.GetClubInfo( ClubId );
                    end
                end
                local LongName = Channels[i+1];
                if( Club ) then
                    LongName = Club.name;
                    LongName = LongName:gsub( '%W','' );
                end

                ChannelList[ i ] = {
                    Id = Channels[i],
                    Name = Channels[i+1],
                    LongName = LongName,
                    Disabled = Channels[i+2],
                    Color = self:GetBaseColor(),
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
                    local Name = ClubInfo.shortName or ClubInfo.name;
                    return Name:gsub( '%W','' );
                end
            end
        end
        -- @todo: review GetClubName and how it functions here
        -- functionality may have gotten broken. check on this
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
                return channelIndex;
            end

            local Found;
            local NewInfo = C_Club.GetClubInfo( ClubId );
            for ChannelId,CName in pairs( ChatFrame.channelList ) do

                local OldName = self:GetClubName( CName );
                NewInfo.name = NewInfo.shortName or NewInfo.name;
                NewInfo.name = NewInfo.name:gsub( '%W','' );

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
                local channelIndex = ChatFrame_AddCommunitiesChannel( ChatFrame,ChannelName,ChannelColor,SetEditBoxToChannel );
                if( tonumber( channelIndex ) > 0 ) then
                    chatFrame:AddMessage(COMMUNITIES_CHANNEL_ADDED_TO_CHAT_WINDOW:format(channelIndex, ChatFrame_ResolveChannelName(ChannelName)), channelColor:GetRGB());
                end
            end
        end

        --
        --  Module init
        --
        --  @return void
        Addon.CHAT.Init = function( self )

            -- Chatframe
            self.ChatFrame = DEFAULT_CHAT_FRAME;

            -- Initialize channel persistence
            for Id,ChannelData in pairs( self:GetChannels() ) do
                local Club;
                local ClubData = Addon:Explode( ChannelData.Name,':' );
                if( ClubData and tonumber( #ClubData ) > 0 ) then
                    local ClubId = ClubData[2] or 0;
                    if( tonumber( ClubId ) > 0 ) then
                        Club = C_Club.GetClubInfo( ClubId );
                    end
                end
                local Key = ChannelData.Name;
                if( Club ) then
                    Key = Club.shortName or Club.name;
                    Key = Key:gsub( '%W','' );

                    self:GetChannelPersistence()[ Key ] = self:GetChannelPersistence()[ Key ] or {};
                end

                self:GetChannelPersistence()[ Key ] = self:GetChannelPersistence()[ Key ] or {};
                self:GetChannelPersistence()[ Key ].Id = ChannelData.Id;
                self:GetChannelPersistence()[ Key ].Name = Key;

                if( not self:GetChannelPersistence()[ Key ].Color ) then
                    self:GetChannelPersistence()[ Key ].Color = self:GetBaseColor();
                end
            end

            -- Remove orphan channels
            local ChannelList = {}
            for i,v in pairs( self:GetChannels() ) do

                local Club;
                local ClubData = Addon:Explode( v.Name,':' );
                if( ClubData and tonumber( #ClubData ) > 0 ) then
                    local ClubId = ClubData[2] or 0;
                    if( tonumber( ClubId ) > 0 ) then
                        Club = C_Club.GetClubInfo( ClubId );
                    end
                end
                local Key = v.Name;
                if( Club ) then
                    Key = Club.shortName or Club.name;
                    Key = Key:gsub( '%W','' );
                end

                ChannelList[ Key ] = v;
            end

            for Name,_ in pairs( self:GetChannelPersistence() ) do
                if( ChannelList and not ChannelList[ Name ] ) then
                    self:GetChannelPersistence()[ Name ] = nil;
                end
            end

            -- Update chat options
            for _,Channel in pairs( self:GetChannelPersistence() ) do
                ChangeChatColor( 'CHANNEL'..Channel.Id,unpack( Channel.Color ) );
            end
        end

        self:Init();
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );