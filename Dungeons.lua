local _, Addon = ...;

Addon.DUNGEONS = CreateFrame( 'Frame' );
Addon.DUNGEONS:RegisterEvent( 'ADDON_LOADED' );
Addon.DUNGEONS:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then

        Addon.DUNGEONS.EXPIRE_TIME = 1800; -- 30 minutes in seconds
        Addon.DUNGEONS.PREFIX = 'JDUNGEON';
        Addon.DUNGEONS.CHANNEL_NAME = 'jLFG';

        Addon.DUNGEONS.SendMessage = function( self,Abbrev,ReqLevel,Roles,Queued )
            local Player = UnitName( 'player' );
            local Realm = GetRealmName();
            local PlayerRealm = Player..'-'..Realm;
            local Tank,Healer,DPS,AllowMultiRoles = self:GetRoles( Roles );
            local PlayerLevel = UnitLevel( 'player' );
            local Prefix = self.PREFIX;
            local NewPingTime = time();
            local CanQueue = PlayerLevel >= ReqLevel;
            local Type = 'CHANNEL';

            for i,Channel in pairs( Addon.CHAT:GetChannels() ) do
                if( Channel.Name == self.CHANNEL_NAME ) then
                    self.CHANNEL_ID = Channel.Id;
                end
            end

            --[[
            Addon:Dump( {
                AllowMultiRoles = AllowMultiRoles,
                Roles = {
                    Tank = Tank,
                    Healer = Healer,
                    DPS = DPS,
                },
                PlayerRealm = PlayerRealm,
                PlayerLevel = PlayerLevel,
                Prefix = Prefix,
                NewPingTime = NewPingTime,
                CanQueue = CanQueue,
                Roles = Roles,
                Queued = Queued,
                Type = Type,
            });
            ]]

            if( CanQueue ) then
                local MessageText = Prefix
                    ..':'..Abbrev
                    ..':'..tostring( Queued )
                    ..':'..PlayerRealm
                    ..':'..PlayerLevel
                    ..':'..tostring( AllowMultiRoles )
                    ..':'..tostring( Tank )
                    ..':'..tostring( Healer )
                    ..':'..tostring( DPS );

                --print( 'sending',Prefix,MessageText,Type,self.CHANNEL_ID );
                if( not( tonumber( self.CHANNEL_ID or 0 ) > 0 ) ) then
                    Addon.FRAMES:Error( 'Unable to ping the server for other players!' );
                    Addon.FRAMES:Error( 'You will need to /join '..self.CHANNEL_NAME );
                else
                    SendChatMessage( MessageText,Type,nil,self.CHANNEL_ID );
                end
            end
            return NewPingTime;
        end

        --[[
        LibStub( 'AceComm-3.0' ):RegisterComm( self.PREFIX,function( Prefix,MessageText,Distribution,Sender )
            print( 'receiving',Prefix,MessageText,Distribution,Sender );
            --self:OnCommReceived( Prefix,MessageText,Distribution,Sender );
        end );

        Addon.DUNGEONS.OnCommReceived = function( self,Prefix,MessageText,Distribution,Sender )
            print( 'receiving',Prefix,MessageText,Distribution,Sender );
            if( MessageText ) then
                local ABBREV,Queued,PlayerRealm,_,_,Tank,Heaaler,DPS = strsplit( ':',MessageText );

                print( 'received from comms:',MessageText );

                -- track players.. need to sort out groups and fill them until appropriate
                self.YourGroups = self.YourGroups or {};
                self.YourGroups[ ABBREV ] = self.YourGroups[ ABBREV ] or {
                    TANK = false,
                    HEAL = false,
                    DPS = false,
                };

                if( Queued and Tank ) then
                    if( not self.YourGroups[ ABBREV ]['TANK'] ) then
                        self.YourGroups[ ABBREV ]['TANK'] = {
                            PlayerRealm = PlayerRealm,
                        };
                    end
                elseif( not Queued and Tank ) then
                    self.YourGroups[ ABBREV ]['TANK'] = false;
                end

                if( Queued and Healer ) then
                    if( not self.YourGroups[ ABBREV ]['HEAL'] ) then
                        self.YourGroups[ ABBREV ]['HEAL'] = {
                            PlayerRealm = PlayerRealm,
                        };
                    end
                elseif( not Queued and Healer ) then
                    self.YourGroups[ ABBREV ]['HEAL'] = false;
                end

                if( Queued and DPS ) then
                    self.YourGroups[ ABBREV ]['DPS'][ PlayerRealm ] = PlayerRealm;
                elseif( not Queued and DPS ) then
                    self.YourGroups[ ABBREV ]['DPS'][ PlayerRealm ] = nil;
                end

                -- add queued players
                if( Queued ) then
                    if( self.YourGroups[ ABBREV ]['TANK'] and self.YourGroups[ ABBREV ]['HEAL'] ) then
                        if( tonumber( #self.YourGroups[ ABBREV ]['DPS'] ) > 2 ) then
                            -- group ready
                        end
                    end
                end
            end
        end

        Addon.DUNGEONS.SendMessage = function( self,Abbrev,ReqLevel,Roles,Queued )
            local Player = UnitName( 'player' );
            local Realm = GetRealmName();
            local PlayerRealm = Player..'-'..Realm;
            local Tank,Healer,DPS,AllowMultiRoles = self:GetRoles( Roles );
            local PlayerLevel = UnitLevel( 'player' );
            local Prefix = self.PREFIX;
            local NewPingTime = time();
            local CanQueue = PlayerLevel >= ReqLevel;
            local Type;
            if( UnitInParty( 'player' ) ) then
                Type = 'PARTY';
            elseif( IsInRaid() ) then
                Type = 'RAID';
            end
            Type = 'CHANNEL';
            Addon:Dump( {
                AllowMultiRoles = AllowMultiRoles,
                Roles = {
                    Tank = Tank,
                    Healer = Healer,
                    DPS = DPS,
                },
                PlayerRealm = PlayerRealm,
                PlayerLevel = PlayerLevel,
                Prefix = Prefix,
                NewPingTime = NewPingTime,
                CanQueue = CanQueue,
                Roles = Roles,
                Queued = Queued,
                Type = Type,
            });

            if( CanQueue ) then
                local MessageText = Prefix
                    ..':'..Abbrev
                    ..':'..tostring( Queued )
                    ..':'..PlayerRealm
                    ..':'..PlayerLevel
                    ..':'..tostring( AllowMultiRoles )
                    ..':'..tostring( Tank )
                    ..':'..tostring( Healer )
                    ..':'..tostring( DPS );

                print( 'sending',Prefix,MessageText,Type,self.CHANNEL_ID );
                LibStub( 'AceComm-3.0' ):SendCommMessage( Prefix,MessageText,Type,self.CHANNEL_ID );
            end
            return NewPingTime;
        end
        ]]

        Addon.DUNGEONS.IsQueued = function( self )
            local Queued;
            if( tonumber( #Addon.APP.persistence.DungeonQueue ) > 0 ) then
                for ABBREV,IsQueued in pairs( Addon.APP:GetDungeonQueue() ) do
                    if( IsQueued ) then
                        Queued = IsQueued;
                    end
                end
            end
            return Queued;
        end

        Addon.DUNGEONS.GetRoles = function( self,Roles )
            local Tank,Healer,DPS,AllowMultiRoles = false,false,false,false;

            Tank = Roles.TANK;
            Healer = Roles.HEALER;
            DPS = Roles.DPS;

            if( DPS and Healer or Healer and Tank or Tank and DPS ) then
                AllowMultiRoles = true;
            end
            return Tank,Healer,DPS,AllowMultiRoles;
        end

        Addon.DUNGEONS.ShouldExpire = function( self,PingTime )
            local Expired = false;
            if( tonumber( PingTime ) > 0 ) then
                local CurrentTime = time();
                local SecondsDiff = tonumber( CurrentTime - PingTime );
                Expired = SecondsDiff > self.EXPIRE_TIME;
            end
            return Expired;
        end

        -- https://www.zockify.com/wowclassic/dungeons/
        Addon.DUNGEONS.GetDungeons = function()
            return {
                RFC = {
                    Abbrevs = {
                        'rfc','ragefire',
                    },
                    Description = 'Ragefire Chasm',
                    LevelBracket = {8,60},
                    BestLevels = {13,19},
                    PlayerLimit = {5},
                },
                WC = {
                    Abbrevs = {
                        'wc','wailingcav',
                    },
                    Description = 'Wailing Caverns',
                    LevelBracket = {10,60},
                    BestLevels = {17,25},
                    PlayerLimit = {5},
                },
                DEADMINES = {
                    Abbrevs = {
                        'dm','vc','deadm',
                    },
                    Description = 'The Deadmines',
                    LevelBracket = {10,60},
                    BestLevels = {17,25},
                    PlayerLimit = {5},
                },
                SFK = {
                    Abbrevs = {
                        'sfk','shadowfang',
                    },
                    Description = 'Shadowfang Keep',
                    LevelBracket = {10,60},
                    BestLevels = {19,28},
                    PlayerLimit = {5},
                },
                STOCKS = {
                    Abbrevs = {
                        'stock','thestockade',
                    },
                    Description = 'The Stockade',
                    LevelBracket = {15,60},
                    BestLevels = {22,32},
                    PlayerLimit = {5},
                },
                -- Adj for SoD
                BFD = {
                    Abbrevs = {
                        'bfd','blackfath',
                    },
                    Description = 'Blackfathom Deeps',
                    LevelBracket = {15,60},
                    BestLevels = {20,30},
                    PlayerLimit = {5},
                },
                SMGY = {
                    Abbrevs = {
                        'smgy','smgrave','graveyard',
                    },
                    Description = 'Scarlet Monastery Graveyard',
                    LevelBracket = {20,60},
                    BestLevels = {25,32},
                    PlayerLimit = {5},
                },
                SMLIB = {
                    Abbrevs = {
                        'smlib','library',
                    },
                    Description = 'Scarlet Monastery Library',
                    LevelBracket = {20,60},
                    BestLevels = {26,34},
                    PlayerLimit = {5},
                },
                SMARM = {
                    Abbrevs = {
                        'smarm','armory',
                    },
                    Description = 'Scarlet Monastery Armory',
                    LevelBracket = {20,60},
                    BestLevels = {32,42},
                    PlayerLimit = {5},
                },
                SMCATH = {
                    Abbrevs = {
                        'smcath','cath',
                    },
                    Description = 'Scarlet Monastery Cathedral',
                    LevelBracket = {20,60},
                    BestLevels = {35,45},
                    PlayerLimit = {5},
                },
                -- Adj for SoD
                GNOMER = {
                    Abbrevs = {
                        'gnom',
                    },
                    Description = 'Gnomeregan',
                    LevelBracket = {19,60},
                    BestLevels = {29,38},
                    PlayerLimit = {5},
                },
                RFK = {
                    Abbrevs = {
                        'rfk','kraul',
                    },
                    Description = 'Razorfen Kraul',
                    LevelBracket = {20,60},
                    BestLevels = {30,40},
                    PlayerLimit = {5},
                },
                RFD = {
                    Abbrevs = {
                        'rfd','downs',
                    },
                    Description = 'Razorfen Downs',
                    LevelBracket = {28,60},
                    BestLevels = {33,45},
                    PlayerLimit = {5},
                },
                ULDA = {
                    Abbrevs = {
                        'ulda',
                    },
                    Description = 'Uldaman',
                    LevelBracket = {30,60},
                    BestLevels = {43,53},
                    PlayerLimit = {5},
                },
                ZF = {
                    Abbrevs = {
                        'zf','zulf',
                    },
                    Description = 'Zul\'Farrak',
                    LevelBracket = {35,60},
                    BestLevels = {44,54},
                    PlayerLimit = {5},
                },
                MARA = {
                    Abbrevs = {
                        'mara',
                    },
                    Description = 'Maraudon',
                    LevelBracket = {35,60},
                    BestLevels = {46,55},
                    PlayerLimit = {5},
                },
                -- Adj for SoD
                ST = {
                    Abbrevs = {
                        'st','sunk','templeofat',
                    },
                    Description = 'The Temple of Atal\'Hakkar',
                    LevelBracket = {35,60},
                    BestLevels = {50,58},
                    PlayerLimit = {5},
                },
                LBRD = {
                    Abbrevs = {
                        'brd','lbrd','brdlower','cellblock','brdarena',
                    },
                    Description = 'Blackrock Depths Cellblock',
                    LevelBracket = {40,60},
                    BestLevels = {52,60},
                    PlayerLimit = {5},
                },
                UBRD = {
                    Abbrevs = {
                        'brd','ubrd','brdupper','uppercity','coffer','angerforge','golemlord','pastguzzl',
                    },
                    Description = 'Blackrock Depths Upper City',
                    LevelBracket = {40,60},
                    BestLevels = {56,60},
                    PlayerLimit = {5},
                },
                DIREMAUL = {
                    Abbrevs = {
                        'dmn','dme','dmw','direm',
                    },
                    Description = 'Dire Maul',
                    LevelBracket = {52,60},
                    BestLevels = {56,60},
                    PlayerLimit = {5},
                },
                TRIBUTE = {
                    Abbrevs = {
                        'dmn','tribute',
                    },
                    Description = 'Dire Maul Tribute',
                    LevelBracket = {52,60},
                    BestLevels = {56,60},
                    PlayerLimit = {5},
                },
                LBRS = {
                    Abbrevs = {
                        'lbrs','lowerblack',
                    },
                    Description = 'Lower Blackrock Spire',
                    LevelBracket = {44,60},
                    BestLevels = {55,60},
                    PlayerLimit = {5},
                },
                UBRS = {
                    Abbrevs = {
                        'ubrs','upperblack',
                    },
                    Description = 'Upper Blackrock Spire',
                    LevelBracket = {48,60},
                    BestLevels = {56,60},
                    PlayerLimit = {5},
                },
                SCHOLO = {
                    Abbrevs = {
                        'scholo',
                    },
                    Description = 'Scholomance',
                    LevelBracket = {48,60},
                    BestLevels = {58,60},
                    PlayerLimit = {5},
                },
                STRATL = {
                    Abbrevs = {
                        'strat','stratliv','stratholmeliv',
                    },
                    Description = 'Stratholme Live',
                    LevelBracket = {48,60},
                    BestLevels = {58,60},
                    PlayerLimit = {5},
                },
                STRATU = {
                    Abbrevs = {
                        'strat','stratud','stratholmeund'
                    },
                    Description = 'Stratholme Undead',
                    LevelBracket = {48,60},
                    BestLevels = {58,60},
                    PlayerLimit = {5},
                },
            };
        end

        local GetDungeonRules = function( Seasonal )
            local Rules = {};
            if( Seasonal ) then
                Rules[ 'ST' ] = {
                };
                Rules[ 'GNOMER' ] = {
                };
                Rules[ 'BFD' ] = {
                };
                Rules['DFC'] = {
                    Abbrevs = {
                        'dfc','demonfall',
                    },
                    Description = 'Demonfall Canyon',
                    LevelBracket = {55,60},
                    BestLevels = {58,60},
                    PlayerLimit = {5},
                };
            end
            return Rules;
        end

        Addon.DUNGEONS.GetRaids = function()
            return {
                MC = {
                    Abbrevs = {
                        'mc','moltencore',
                    },
                    Description = 'Molten Core',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = 40,
                },
                ONY = {
                    Abbrevs = {
                        'ony','onixia',
                    },
                    Description = 'Onyxia\'s Lair',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = {40},
                },
                BWL = {
                    Abbrevs = {
                        'bwl','blackwing',
                    },
                    Description = 'Blackwing Lair',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = {40},
                },
                ZG = {
                    Abbrevs = {
                        'zg','zulgu',
                    },
                    Description = 'Zul\'Gurub',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = {40},
                },
                AQ20 = {
                    Abbrevs = {
                        'aq','aq20','ahnq','ruinsof',
                    },
                    Description = 'Ruins of Ahn\'Qiraj',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = {20},
                },
                AQ40 = {
                    Abbrevs = {
                        'aq','aq40','ahnq',
                    },
                    Description = 'Ahn\'Qiraj',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = {40},
                },
                NAXX = {
                    Abbrevs = {
                        'nax',
                    },
                    Description = 'Naxxxramas',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = {40},
                },
            };
        end

        local GetRaidRules = function( Seasonal )
            local Rules = {};
            if( Seasonal ) then
                Rules['ST'] = {
                    Abbrevs = {
                        'st','sunk','templeofat',
                    },
                    Description = 'The Temple of Atal\'Hakkar',
                    LevelBracket = {50,60},
                    BestLevels = {50,53},
                    PlayerLimit = {10},
                };
                Rules['GNOMER'] = {
                    Abbrevs = {
                        'gnom',
                    },
                    Description = 'Gnomeregan',
                    LevelBracket = {40,60},
                    BestLevels = {40,43},
                    PlayerLimit = {10},
                };
                Rules['BFD'] = {
                    Abbrevs = {
                        'bfd','blackfath',
                    },
                    Description = 'Blackfathom Deeps',
                    LevelBracket = {25,60},
                    BestLevels = {25,28},
                    PlayerLimit = {10},
                };
                Rules['MC'] = {
                    Abbrevs = {
                        'mc','moltencore',
                    },
                    Description = 'Molten Core',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = {20},
                };
                Rules['ONY'] = {
                    Abbrevs = {
                        'ony','onixia',
                    },
                    Description = 'Onyxia\'s Lair',
                    LevelBracket = {60},
                    BestLevels = {60},
                    PlayerLimit = {20,40},
                };
                Rules['BWL'] = {
                };
                Rules['ZG'] = {
                };
                Rules['AQ20'] = {
                };
                Rules['AQ40'] = {
                };
                Rules['NAXX'] = {
                };
            end
            return Rules;
        end

        local FormatData = function( InstanceData,MyLevel,PartySize )
            local Instances = {};
            table.sort( InstanceData );

            for Key,Instance in pairs( InstanceData ) do

                if( Instance.LevelBracket ) then
                    Instance.MyLevel = MyLevel;
                    Instances[ Key ] = Instance;

                    -- Average level
                    Instances[ Key ].AvgLevel = Instance.BestLevels[1];
                    if( Instance.BestLevels[2] ) then
                        Instances[ Key ].AvgLevel = tonumber( ( Instance.BestLevels[2] + Instance.BestLevels[1] ) / 2 );
                    end

                    -- Required level
                    Instances[ Key ].ReqLevel = Instance.LevelBracket[1];
                    if( MyLevel >= Instances[ Key ].ReqLevel ) then
                        Instances[ Key ].Disabled = false;
                    else
                        Instances[ Key ].Disabled = true;
                    end

                    -- Best level
                    Instances[ Key ].BestLevel = Instance.BestLevels[1]+1;

                    -- High level
                    Instances[ Key ].HighLevel = ( Instance.BestLevels[2] or Instance.BestLevels[1] )-1;

                    -- Name
                    Instances[ Key ].Name = Instances[ Key ].Name or Key;
                    Instances[ Key ].Name = Instances[ Key ].Name..' ['..Instances[ Key ].BestLevels[1];
                    if( Instances[ Key ].BestLevels[2] ) then
                        Instances[ Key ].Name = Instances[ Key ].Name..','..Instances[ Key ].BestLevels[2];
                    end
                    Instances[ Key ].Name = Instances[ Key ].Name..']';

                    -- Desc
                    Instances[ Key ].Description = Instances[ Key ].Description.."\rLevel Bracket: ["..Instances[ Key ].BestLevels[1];
                    if( Instances[ Key ].BestLevels[2] ) then
                        Instances[ Key ].Description = Instances[ Key ].Description..','..Instances[ Key ].BestLevels[2];
                    end
                    Instances[ Key ].Description = Instances[ Key ].Description..']';
                    Instances[ Key ].Description = Instances[ Key ].Description.."\rLevel Rquirement: ["..Instances[ Key ].LevelBracket[1];
                    if( Instances[ Key ].LevelBracket[2] ) then
                        Instances[ Key ].Description = Instances[ Key ].Description..','..Instances[ Key ].LevelBracket[2];
                    end
                    Instances[ Key ].Description = Instances[ Key ].Description..']';
                    Instances[ Key ].Description = Instances[ Key ].Description.."\rKeys: "..Addon:Implode( Instances[ Key ].Abbrevs,',' );
                    --[[
                    Addon:Dump( {
                        Key = Key,
                        MyLevel = Instances[ Key ].MyLevel,
                        ReqLevel = Instances[ Key ].ReqLevel,
                        GetQuestDifficultyColor = GetQuestDifficultyColor( Instances[ Key ].ReqLevel ),
                    } );
                    ]]
                    local Color = GetQuestDifficultyColor( Instances[ Key ].AvgLevel+1 );
                    Instances[ Key ].Color = { Color.r,Color.g,Color.b };
                end
            end
            return Instances;
        end

        Addon.DUNGEONS.GetDungeonsF = function( self,MyLevel,PartySize )
            local Instances = {};
            local InstanceData = self:GetDungeons();

            for Key,Instance in pairs( InstanceData ) do
                Instances[ Key ] = Instance;
            end

            -- Seasonal rules
            local Seasonal = ( Addon:IsClassic() and tonumber( #C_Engraving.GetRuneCategories(false, false) ) > 0 );
            local Rules = GetDungeonRules( Seasonal );
            for Key,Instance in pairs( Rules ) do
                Instances[ Key ] = Instance;
            end
            MyLevel = MyLevel or UnitLevel( 'player' );
            return FormatData( Instances,MyLevel,PartySize );
        end

        Addon.DUNGEONS.GetRaidsF = function( self,MyLevel,PartySize )
            local Instances = {};
            local InstanceData = self:GetRaids();

            for Key,Instance in pairs( InstanceData ) do
                Instances[ Key ] = Instance;
            end

            -- Seasonal rules
            local Seasonal = ( Addon:IsClassic() and tonumber( #C_Engraving.GetRuneCategories(false, false) ) > 0 );
            local Rules = GetRaidRules( Seasonal );
            for Key,Instance in pairs( Rules ) do
                Instances[ Key ] = Instance;
            end
            MyLevel = MyLevel or UnitLevel( 'player' );
            return FormatData( Instances,MyLevel,PartySize );
        end

        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );