--[[
-- Interface/AddOns/Blizzard_APIDocumentationGenerated/ChatInfoDocumentation.lua
-- Interface/AddOns/Blizzard_Channels/RosterButton.lua
-- Interface/AddOns/Blizzard_UnitPopupShared/UnitPopupShared.lua
-- Interface/AddOns/Blizzard_Channels/ChannelRoster.lua

local _, Addon = ...;

Addon.ROSTER = CreateFrame( 'Frame' );
Addon.ROSTER:RegisterEvent( 'ADDON_LOADED' );
Addon.ROSTER:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then

        local EventsFrame = CreateFrame( 'frame' );
        EventsFrame:RegisterEvent( 'CHANNEL_ROSTER_UPDATE' );
        EventsFrame:SetScript( 'OnEvent',function( self,Event,ChannelId,NumRostered )
            
            --local name, owner, moderator, guid = C_ChatInfo.GetChannelRosterInfo(channelID, rosterIndex);
        end );
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );
]]