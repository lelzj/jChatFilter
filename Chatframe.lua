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

        --
        --  Join channel
        --
        --  @return bool
        Addon.CHAT.JoinChannel = function( self,ChannelName )
            if( ChannelName ) then
                local Type,Name = JoinPermanentChannel( ChannelName );
                Addon.CONFIG.persistence.Channels[ ChannelName ] = {
                    Color = {
                        254 / 255,
                        191 / 255,
                        191 / 255,
                        1,
                    },
                    Id = #Addon.CONFIG.ChatFrame.channelList+1,
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
                Addon.CONFIG.persistence.Channels[ ChannelName ] = nil;
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
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );