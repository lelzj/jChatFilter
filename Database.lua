local _, Addon = ...;

Addon.DB = CreateFrame( 'Frame' );
Addon.DB:RegisterEvent( 'ADDON_LOADED' );
Addon.DB:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then

        --
        --  Get module defaults
        --
        --  @return table
        Addon.DB.GetDefaults = function( self )
            return {
                Font = {
                    Family = 'ARIALN',
                    Size = 14,
                    Flags = 'THINOUTLINE',
                },
                FadeOut = false,
                IgnoreList = {
                    'boost',
                },
                AFKAlert = true,
                MentionAlert = true,
                MentionDrop = {
                },
                MentionMove = 0,
                AliasList = {
                },
                ScrollBack = true,
                QuestAlert = true,
                ChannelColor = {
                    254 / 255,
                    191 / 255,
                    191 / 255,
                    1,
                },
                AlertColor = {
                    224 / 255,
                    157 / 255,
                    240 / 255,
                    1,
                },
                AlertChannel = 'SFX',
                AlertVolume = .5,
                AlertList = {
                },
                FullHighlight = true,
                LinksEnabled = true,
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
                    PET = false,
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
                showTimestamps = '%I:%M:%S %p ',
                TimeColor = {
                    184 / 255,
                    184 / 255,
                    184 / 255,
                    1,
                },
                AutoInvite = true,
                DungeonQueue = {
                },
                RaidQueue = {
                },
                ColorNamesByClass = true,
                Roles = {
                    DPS = true,
                    HEALER = false,
                    TANK = false,
                },
                Debug = false,
            };
        end

        Addon.DB.Reset = function( self )
            if( not self.db ) then
                return;
            end
            self.db:ResetDB();
        end

        --
        --  Get module persistence
        --
        --  @return table
        Addon.DB.GetPersistence = function( self )
            if( not self.db ) then
                return;
            end
            local Player = UnitName( 'player' );
            local Realm = GetRealmName();
            local PlayerRealm = Player..'-'..Realm;

            self.persistence = self.db.char;
            if( not self.persistence ) then
                return;
            end
            return self.persistence;
        end

        --
        -- Set DB value
        --
        -- @return void
        Addon.DB.SetValue = function( self,Index,Value )
            if( self:GetPersistence()[ Index ] ~= nil ) then
                self:GetPersistence()[ Index ] = Value;
            end
        end

        --
        -- Get DB value
        --
        -- @return mixed
        Addon.DB.GetValue = function( self,Index )
            if( self:GetPersistence()[ Index ] ~= nil ) then
                return self:GetPersistence()[ Index ];
            end
        end

        --
        --  Module init
        --
        --  @return void
        Addon.DB.Init = function( self )
            self.db = LibStub( 'AceDB-3.0' ):New( AddonName,{ char = self:GetDefaults() },true );
            if( not self.db ) then
                return;
            end

            if( not self:GetPersistence() ) then
                return;
            end
        end
        
        Addon.DB:UnregisterEvent( 'ADDON_LOADED' );
    end
end );