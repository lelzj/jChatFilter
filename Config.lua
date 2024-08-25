local _, Addon = ...;

Addon.CONFIG = CreateFrame( 'Frame' );
Addon.CONFIG:RegisterEvent( 'ADDON_LOADED' );
Addon.CONFIG:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then

        --
        --  Get module defaults
        --
        --  @return table
        Addon.CONFIG.GetDefaults = function( self )
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
                MentionAlert = true,
                MentionTime = 20,
                AliasList = {
                },
                ScrollBack = true,
                QuestAlert = true,
                AlertColor = {
                    224 / 255,
                    157 / 255,
                    240 / 255,
                    1,
                },
                AlertSound = false,
                AlertList = {
                },
                FullHighlight = true,
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
                AutoInvite = true,
                DungeonQueue = {
                },
                RaidQueue = {
                },
                ColorNamesByClass = true,
            };
        end

        --
        --  Get module settings
        --
        --  @return table
        Addon.CONFIG.GetSettings = function( self )
            local function GetAlerts()
                local Order = 1;
                local Settings = {
                    Alerts = {
                        type = 'header',
                        order = Order,
                        name = 'Custom Alerts',
                    },
                };
                Order = Order+1;
                Settings.AlertList = {
                    type = 'input',
                    order = Order,
                    multiline = true,
                    get = function( Info )
                        return Addon:Implode( self:GetAlerts(),',' );
                    end,
                    set = function( Info,Value )
                        self:SetAlerts( Value );
                    end,
                    name = 'Alert List',
                    desc = 'Words or phrases to be alerted on when they are mentioned in chat. Seperate individual things to alert on with a comma: e.g. healer,spriest,sfk,really cool',
                    arg = 'AlertList',
                    width = 'full',
                };
                Order = Order+1;
                Settings.IgnoreList = {
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
                    desc = 'Words or phrases which should be omitted in chat. Seperate individual things to ignore with a comma: e.g. boost,spam,anidiot,absolutely terrible',
                    arg = 'IgnoreList',
                    width = 'full',
                };
                Order = Order+1;
                Settings.AlertMention = {
                    type = 'toggle',
                    order = Order,
                    name = 'Mention Alert',
                    desc = 'Enable/disable alerting if anyone mentions your name. Note that mentions always produce an alert sound and have the whisper color',
                    arg = 'MentionAlert',
                };
                Order = Order+1;
                Settings.MentionTime = {
                    type = 'range',
                    order = Order,
                    name = 'Mention Duration',
                    desc = 'The duration of time in seconds to show mention alerts',
                    min = 10, max = 120, step = 10,
                    arg = 'MentionTime',
                };
                Order = Order+1;
                Settings.AliasList = {
                    type = 'input',
                    order = Order,
                    multiline = true,
                    get = function( Info )
                        return Addon:Implode( self:GetAliasList(),',' );
                    end,
                    set = function( Info,Value )
                        self:SetAliasList( Value );
                    end,
                    name = 'Alias List',
                    desc = 'Comma seperated list of aliases for your character name, to be used in mention alerts',
                    arg = 'Aliases',
                    width = 'normal',
                    multiline = false,
                };
                Order = Order+1;
                Settings.AlertQuest = {
                    type = 'toggle',
                    order = Order,
                    name = 'Quest Alert',
                    desc = 'Enable/disable alerting if anyone mentions a quest you are on',
                    arg = 'QuestAlert',
                };
                Order = Order+1;
                Settings.AlertColor = {
                    type = 'color',
                    order = Order,
                    get = function( Info )
                        if( self.persistence[ Info.arg ] ~= nil ) then
                            return unpack( self.persistence[ Info.arg ] );
                        end
                    end,
                    set = function( Info,R,G,B,A )
                        if( self.persistence[ Info.arg ] ~= nil ) then
                            self.persistence[ Info.arg ] = { R,G,B,A };
                        end
                    end,
                    name = 'Alert Color',
                    desc = 'Set the color of Alerts chat',
                    arg = 'AlertColor',
                };
                Order = Order+1;
                Settings.AlertSound = {
                    type = 'toggle',
                    order = Order,
                    name = 'Sound Alert',
                    desc = 'Enable/disable chat Alert sound',
                    arg = 'AlertSound',
                };
                for FilterName,FilterData in pairs( self:GetChatFilters() ) do
                    Order = Order+1;
                    local Disabled = false;
                    if( FilterName == 'WHISPER' ) then
                        Disabled = true;
                    end
                    Settings[ FilterName..'Alert' ] = {
                        type = 'toggle',
                        order = Order,
                        name = FilterName,
                        disabled = Disabled,
                        desc = 'Enable/disable alerting for '..FilterName..' messages',
                        arg = FilterName,
                        get = function( Info )
                            if( self.persistence.ChatFilters[ Info.arg ] ~= nil ) then
                                return self.persistence.ChatFilters[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            if( self.persistence.ChatFilters[ Info.arg ] ~= nil ) then
                                self.persistence.ChatFilters[ Info.arg ] = Value;
                                for _,FilterName in pairs( self:GetChatFilters()[ Info.arg ] ) do
                                    Addon.FILTER:SetFilter( FilterName,Value );
                                end
                            end
                        end,
                    };
                end
                --[[
                Order = Order+1;
                Settings.FullHighLight = {
                    type = 'toggle',
                    order = Order,
                    name = 'Fully Highlight Message',
                    desc = 'Enable/disable highlighting entire message alerts during match',
                    arg = 'FullHighlight',
                };
                ]]

                return Settings;
            end
            local function GetDungeons()
                local Order = 1;
                local Settings = {
                    DungeonGroups = {
                        type = 'header',
                        order = Order,
                        name = 'Classic Dungeon Groups',
                    },
                };
                for Abbrev,Instance in pairs( Addon.DUNGEONS:GetDungeonsF( UnitLevel( 'player' ) ) ) do
                    Order = Order + 1;
                    Settings[ Abbrev ] = {
                        type = 'toggle',
                        order = Order,
                        name = CreateColor( unpack( Instance.Color ) ):WrapTextInColorCode( Instance.Name ),
                        desc = Instance.Description,
                        arg = Abbrev,
                        disabled = Instance.Disabled,
                        get = function( Info )
                            if( self.persistence.DungeonQueue[ Info.arg ] ~= nil ) then
                                return self.persistence.DungeonQueue[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            self.persistence.DungeonQueue[ Info.arg ] = Value;
                        end,
                    };
                end
                for Abbrev,Instance in pairs( Addon.DUNGEONS:GetRaidsF( UnitLevel( 'player' ) ) ) do
                    Order = Order + 1;
                    Settings[ Abbrev ] = {
                        type = 'toggle',
                        order = Order,
                        name = CreateColor( unpack( Instance.Color ) ):WrapTextInColorCode( Instance.Name ),
                        desc = Instance.Description,
                        arg = Abbrev,
                        disabled = Instance.Disabled,
                        get = function( Info )
                            if( self.persistence.RaidQueue[ Info.arg ] ~= nil ) then
                                return self.persistence.RaidQueue[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            self.persistence.RaidQueue[ Info.arg ] = Value;
                        end,
                    };
                end

                return Settings;
            end
            local function GetTypes()
                local Order = 1;
                local Settings = {
                    FilterTypes = {
                        type = 'header',
                        order = Order,
                        name = 'Message Types',
                    }
                };
                for GroupName,GroupData in pairs( self:GetMessageGroups() ) do
                    Order = Order+1;
                    Settings[ GroupName..'Message' ] = {
                        type = 'toggle',
                        order = Order,
                        name = GroupName,
                        desc = 'Enable/disable messages for '..GroupName,
                        arg = GroupName,
                        get = function( Info )
                            if( self.persistence.ChatGroups[ Info.arg ] ~= nil ) then
                                return self.persistence.ChatGroups[ Info.arg ];
                            end
                        end,
                        set = function( Info,Value )
                            if( self.persistence.ChatGroups[ Info.arg ] ~= nil ) then
                                self.persistence.ChatGroups[ Info.arg ] = Value;
                                for _,GroupName in pairs( self:GetMessageGroups()[ Info.arg ] ) do
                                    -- Always allow outgoing whispers
                                    if( Addon:Minify( GroupName ):find( 'whisperinform' ) ) then
                                        Value = true;
                                    end
                                    Addon.FILTER:SetGroup( GroupName,Value );
                                end
                            end
                        end,
                    };
                end

                return Settings;
            end
            local function GetGeneral()
                local Order = 1;
                local Settings = {
                    General = {
                        type = 'header',
                        order = Order,
                        name = 'General',
                    },
                };
                Order = Order+1;
                Settings.ScrollBack = {
                    type = 'toggle',
                    order = Order,
                    name = 'Scroll Back',
                    desc = 'Extend chat history to 10,000 lines',
                    arg = 'ScrollBack',
                };
                Order = Order+1;
                Settings.FadeOut = {
                    type = 'toggle',
                    order = Order,
                    name = 'Fade Out',
                    desc = 'Enable/disable chat fading',
                    arg = 'FadeOut',
                };
                Order = Order+1;
                Settings.ClassColor = {
                    type = 'toggle',
                    order = Order,
                    name = 'Class Color',
                    desc = 'Enable/disable chat class colors',
                    arg = 'ColorNamesByClass',
                };
                Order = Order+1;
                Settings.FontFamily = {
                    type = 'select',
                    get = function( Info )
                        if( self.persistence.Font[ Info.arg ] ~= nil ) then
                            return self.persistence.Font[ Info.arg ];
                        end
                    end,
                    set = function( Info,Value )
                        if( self.persistence.Font[ Info.arg ] ~= nil ) then
                            self.persistence.Font[ Info.arg ] = Value;
                        end
                        Addon.CHAT:SetFont( {
                            Family = self:GetValue( 'Font' ).Family,
                            Size = self:GetValue( 'Font' ).Size,
                            Flags = self:GetValue( 'Font' ).Flags,
                        });
                    end,
                    values = {
                        skurri = 'skurri',
                        ARIALN = 'ARIALN',
                        MORPHEUS = 'MORPHEUS',
                        FRIZQT__ = 'FRIZQT__',
                    },
                    order = Order,
                    name = 'Font Family',
                    desc = 'Chat Font Family',
                    arg = 'Family',
                };
                Order = Order+1;
                Settings.FontSize = {
                    type = 'select',
                    get = function( Info )
                        if( self.persistence.Font[ Info.arg ] ~= nil ) then
                            return self.persistence.Font[ Info.arg ];
                        end
                    end,
                    set = function( Info,Value )
                        if( self.persistence.Font[ Info.arg ] ~= nil ) then
                            self.persistence.Font[ Info.arg ] = Value;
                        end
                        Addon.CHAT:SetFont( {
                            Family = self:GetValue( 'Font' ).Family,
                            Size = self:GetValue( 'Font' ).Size,
                            Flags = self:GetValue( 'Font' ).Flags,
                        });
                    end,
                    values = {
                        [10] = 10,
                        [12] = 12,
                        [14] = 14,
                        [16] = 16,
                        [18] = 18,
                    },
                    order = Order,
                    name = 'Font Size',
                    desc = 'Chat Font Size',
                    arg = 'Size',
                };
                Order = Order+1;
                Settings.ShowTimestamps = {
                    type = 'select',
                    values = Addon:ArrayReverse( {
                        none = 'none',
                        hour_min_12 = '%I:%M ',
                        hour_min_ext = '%I:%M %p ',
                        hour_min_sec_12_ext = '%I:%M:%S %p ',
                        hour_min_24 = '%H:%M ',
                        hour_min_sec_24 = '%H:%M:%S ',
                    } ),
                    order = Order,
                    name = 'Timestamps',
                    desc = 'Timestamp format',
                    arg = 'showTimestamps',
                };
                Order = Order+1;
                Settings.AutoInvite = {
                    type = 'toggle',
                    order = Order,
                    name = 'Auto Invite',
                    desc = 'Automatically accept party members who send "inv" messages',
                    arg = 'AutoInvite',
                };

                Order = Order+1;
                Settings.ChannelColors = {
                    type = 'header',
                    order = Order,
                    name = 'Channel Colors',
                };
                for _,ChannelData in pairs( Addon.CHAT:GetChannels() ) do
                    Order = Order+1;
                    Settings[ ChannelData.Name..'Color' ] = {
                        type = 'color',
                        order = Order,
                        get = function( Info )
                            if( Addon.CONFIG.persistence.Channels[ Info.arg ] ~= nil and Addon.CONFIG.persistence.Channels[ Info.arg ].Color ~= nil ) then
                                return unpack( Addon.CONFIG.persistence.Channels[ Info.arg ].Color );
                            end
                        end,
                        set = function( Info,R,G,B,A )
                            if( Addon.CONFIG.persistence.Channels[ Info.arg ] ~= nil ) then
                                Addon.CONFIG.persistence.Channels[ Info.arg ].Color = { R,G,B,A };
                                local Community,ClubId,StreamId = unpack( Addon:Explode( Info.arg,':' ) );
                                if( Addon:Minify( Community ) == 'community' ) then
                                    local Channel = Chat_GetCommunitiesChannel( ClubId,StreamId );
                                elseif( Channel ) then
                                    ChangeChatColor( Channel,R,G,B,A );
                                end
                            end
                            local Channel = Addon.CHAT:GetChannelId( Info.arg );
                            if( Channel ) then
                                ChangeChatColor( 'CHANNEL'..tostring( Channel ),R,G,B,A );
                            end
                        end,
                        name = ChannelData.Name..' Color',
                        desc = 'Set the color of '..ChannelData.Name..' chat',
                        arg = ChannelData.Name,
                    };
                end

                return Settings;
            end
            local Settings = {
                type = 'group',
                get = function( Info )
                    return self:GetValue( Info.arg );
                end,
                set = function( Info,Value )
                    self:SetValue( Info.arg,Value );
                end,
                name = 'jChat Settings',
                desc = 'Simple chat filter',
                childGroups = 'tab',
                args = {
                },
            };
            local Order = 1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'Custom Alerts',
                width = 'full',
                order = Order,
                args = GetAlerts(),
            };

            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'Dungeon Alerts',
                width = 'full',
                order = Order,
                args = GetDungeons(),
            };

            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'Message Types',
                width = 'full',
                order = Order,
                args = GetTypes(),
            };

            Order = Order+1;
            Settings.args[ 'tab'..Order ] = {
                type = 'group',
                name = 'General',
                width = 'full',
                order = Order,
                args = GetGeneral(),
            };

            return Settings;
        end

        --
        --  Create module config frames
        --
        --  @return void
        Addon.CONFIG.CreateFrames = function( self )
            self.Config = LibStub( 'AceConfigDialog-3.0' ):AddToBlizOptions( string.upper( 'jChat' ),'jChat' );
            self.Config.okay = function( self )
                RestartGx();
            end
            self.Config.default = function( self )
                Addon.CHAT.db:ResetDB();
            end
            LibStub( 'AceConfigRegistry-3.0' ):RegisterOptionsTable( string.upper( 'jChat' ),self:GetSettings() );

            --[[
            Test 1

            self.Config = CreateFrame( 'Frame',AddonName..'Main',UIParent,'UIPanelDialogTemplate' );
            self.Config:SetFrameStrata( 'HIGH' );

            self.Config:SetClampedToScreen( true );
            self.Config:SetSize( Addon.CHAT.ChatFrame:GetWidth(),Addon.CHAT.ChatFrame:GetHeight() );
            self.Config:DisableDrawLayer( 'OVERLAY' );
            self.Config:DisableDrawLayer( 'BACKGROUND' );

            self.Config:EnableKeyboard( true );
            self.Config:EnableMouse( true );
            self.Config:SetResizable( false );
            self.Config:SetPoint( 'bottomleft',Addon.CHAT.ChatFrame,'bottomleft',0,0 );
            self.Config:SetScale( 1 );

            self.Config.Background = self.Config:CreateTexture( nil,'ARTWORK',nil,0 );
            self.Config.Background:SetTexture( 'Interface\\Addons\\jChatFilter\\Libs\\jUI\\Textures\\frame' );
            self.Config.Background:SetAllPoints( self.Config );

            self.Config.Tools = CreateFrame( 'Frame',self.Config:GetName()..'Tools',self.Config );
            self.Config.Tools:SetSize( self.Config:GetWidth(),1 );
            self.Config.Tools:SetPoint( 'topleft',self.Config,'topleft' );
            self.Config.Tools.Background = self.Config:CreateTexture( nil,'ARTWORK',nil,0 );
            self.Config.Tools.Background:SetTexture( 'Interface\\Addons\\jChatFilter\\Libs\\jUI\\Textures\\frame' );
            self.Config.Tools.Background:SetAllPoints( self.Config.Tools );

            self.Config.Browser = CreateFrame( 'Frame',self.Config:GetName()..'Browser',self.Config );
            self.Config.Browser:SetSize( self.Config:GetWidth(),self.Config:GetHeight()-self.Config.Tools:GetHeight() );
            self.Config.Browser:SetPoint( 'topleft',self.Config.Tools,'bottomleft' );

            self.Config.Browser.Heading = CreateFrame( 'Frame',self.Config.Browser:GetName()..'Heading',self.Config );
            self.Config.Browser.Heading:SetSize( self.Config.Browser:GetWidth(),100 );
            self.Config.Browser.Heading:SetPoint( 'topleft',self.Config.Tools,'bottomleft' );



            -- Options scroll frame
            self.Config.Browser.Data = CreateFrame( 'ScrollFrame',nil,self.Config.Browser,'UIPanelScrollFrameTemplate' );

            -- Options scrolling content frame
            self.Config.Browser.Data.ScrollChild = CreateFrame( 'Frame' );

            -- Options scroll frame
            self.Config.Browser.Data:SetSize( self.Config.Browser:GetWidth(),self.Config.Browser:GetHeight()-self.Config.Browser:GetHeight()-self.Config.Tools:GetHeight() );
            self.Config.Browser.Data:SetPoint( 'topleft',self.Config.Browser.Heading,'bottomleft' );

            -- Options scroll content 
            self.Config.Browser.Data:SetScrollChild( self.Config.Browser.Data.ScrollChild );
            self.Config.Browser.Data.ScrollChild:SetSize( self.Config.Browser.Data:GetWidth()-18,20 );


            -- Configurations
            self.Switches = {
                General = {
                    TimeStamps = Addon.FRAMES:AddCheckBox( { Name='TimeStamps',DisplayText='Add Timestamps',Description='Timestamp prefix messsages'},self.Config.Browser.Data,self ),
                    ScrollBack = Addon.FRAMES:AddCheckBox( { Name='ScrollBack',DisplayText='Extend History',Description='Extend chat history to 1,000 lines'},self.Config.Browser.Data,self ),
                    FadeOut = Addon.FRAMES:AddCheckBox( { Name='FadeOut',DisplayText='Message Fading',Description='Messages will disappear from view after a period of time'},self.Config.Browser.Data,self ),
                },
            };

            -- Configuration display
            local MaxElems = 3;
            local X,Y = 10,0;
            local InitX,InitY = X,Y;
            local XSpacing = 100;

            local Children = {};
            local Iterator = 0;

            for SetName,SwitchData in pairs( self.Switches ) do
                for Index,Frame in pairs( SwitchData ) do

                    if( #Children % MaxElems == 0 ) then
                        X,Y = XSpacing,0
                    elseif( #Children > 0 ) then
                        X,Y = XSpacing + Children[ Iterator ]:GetWidth(),Y;
                    end

                    Iterator = Iterator + 1;

                    Children[ Iterator ] = Frame;
                    print( Index,X,Y )
                    Frame:SetPoint( 'topleft',self.Config.Browser.Data.ScrollChild,'topleft',X,Y );
                end
            end
            ]]
            --[[
            --Test 2 
            self.Panel = CreateFrame( 'Frame',AddonName..'Main',UIParent,'UIPanelDialogTemplate' );
            self.Panel:SetFrameStrata( 'HIGH' );

            self.Panel:SetClampedToScreen( true );
            self.Panel:SetSize( Addon.CHAT.ChatFrame:GetWidth(),Addon.CHAT.ChatFrame:GetHeight() );
            self.Panel:DisableDrawLayer( 'OVERLAY' );
            self.Panel:DisableDrawLayer( 'BACKGROUND' );

            self.Panel:EnableKeyboard( true );
            self.Panel:EnableMouse( true );
            self.Panel:SetResizable( false );
            self.Panel:SetPoint( 'bottomleft',Addon.CHAT.ChatFrame,'bottomleft',0,0 );
            self.Panel:SetScale( 1 );

            self.Panel.Background = self.Panel:CreateTexture( nil,'ARTWORK',nil,0 );
            self.Panel.Background:SetTexture( 'Interface\\Addons\\jChatFilter\\Libs\\jUI\\Textures\\frame' );
            self.Panel.Background:SetAllPoints( self.Panel );

            self.Panel.Tools = CreateFrame( 'Frame',self.Panel:GetName()..'Tools',self.Panel );
            self.Panel.Tools:SetSize( self.Panel:GetWidth(),1 );
            self.Panel.Tools:SetPoint( 'topleft',self.Panel,'topleft' );
            self.Panel.Tools.Background = self.Panel:CreateTexture( nil,'ARTWORK',nil,0 );
            self.Panel.Tools.Background:SetTexture( 'Interface\\Addons\\jChatFilter\\Libs\\jUI\\Textures\\frame' );
            self.Panel.Tools.Background:SetAllPoints( self.Panel.Tools );

            self.Panel.Browser = CreateFrame( 'Frame',self.Panel:GetName()..'Browser',self.Panel );
            self.Panel.Browser:SetSize( self.Panel:GetWidth(),self.Panel:GetHeight()-self.Panel.Tools:GetHeight() );
            self.Panel.Browser:SetPoint( 'topleft',self.Panel.Tools,'bottomleft' );

            self.Panel.Browser.Heading = CreateFrame( 'Frame',self.Panel.Browser:GetName()..'Heading',self.Panel );
            self.Panel.Browser.Heading:SetSize( self.Panel.Browser:GetWidth(),100 );
            self.Panel.Browser.Heading:SetPoint( 'topleft',self.Panel.Tools,'bottomleft' );


            Addon.CHAT.Test = function( self )
                return {
                    TimeStamps = {
                        Description = 'Timestamp prefix messsages',
                        KeyValue = 'TimeStamps',
                        DefaultValue = Addon.CONFIG:GetValue( 'TimeStamps' ),
                        KeyPairs = {
                            Option1 = {
                                Value = 0,
                                Description = 'Off',
                            },
                            Option2 = {
                                Value = 1,
                                Description = 'On',
                            },
                        },
                        Type = 'Toggle',
                    },
                    ScrollBack = {
                        Description = 'Extend chat history to 1,000 lines',
                        KeyValue = 'ScrollBack',
                        DefaultValue = Addon.CONFIG:GetValue( 'ScrollBack' ),
                        KeyPairs = {
                            Option1 = {
                                Value = 0,
                                Description = 'Off',
                            },
                            Option2 = {
                                Value = 1,
                                Description = 'On',
                            },
                        },
                        Type = 'Toggle',
                    },
                    FadeOut = {
                        Description = 'Messages will disappear from view after a period of time',
                        KeyValue = 'FadeOut',
                        DefaultValue = Addon.CONFIG:GetValue( 'FadeOut' ),
                        KeyPairs = {
                            Option1 = {
                                Value = 0,
                                Description = 'Off',
                            },
                            Option2 = {
                                Value = 1,
                                Description = 'On',
                            },
                        },
                        Type = 'Toggle',
                    },
                    AlertSound = {
                        Description = 'Alerts should produce a sound',
                        KeyValue = 'AlertSound',
                        DefaultValue = Addon.CONFIG:GetValue( 'AlertSound' ),
                        KeyPairs = {
                            Option1 = {
                                Value = 0,
                                Description = 'Off',
                            },
                            Option2 = {
                                Value = 1,
                                Description = 'On',
                            },
                        },
                        Type = 'Toggle',
                    },
                };
            end

            Addon.FRAMES:DrawFromSettings( Addon.CHAT:Test(),Addon.CHAT );
            ]]

            -- Fading
            Addon.CHAT:SetFading( self:GetValue( 'FadeOut' ) );

            -- Scrolling
            Addon.CHAT:SetScrolling( self:GetValue( 'ScrollBack' ) );

            -- Chat text
            Addon.CHAT:SetFont( {
                Family = self:GetValue( 'Font' ).Family,
                Size = self:GetValue( 'Font' ).Size,
                Flags = self:GetValue( 'Font' ).Flags,
            });

            -- Config
            self:EnableConfigEvents();

            -- 1. Pick HELLOWORLD as the unique identifier.
            -- 2. Pick /hiw and /hellow as slash commands (/hi and /hello are actual emotes)
            -- https://wowpedia.fandom.com/wiki/Creating_a_slash_command
            SLASH_JCHAT1, SLASH_JCHAT2 = '/jc', '/jchat'; -- 3.
            SlashCmdList['JCHAT'] = function( Msg,EditBox ) -- 4.
                Settings.OpenToCategory( 'jChat' );
            end
        end

        Addon.CONFIG.GetChatFilters = function( self )
            return {
                PARTY = {
                    'CHAT_MSG_PARTY',
                    'CHAT_MSG_PARTY_LEADER',
                },
                RAID = {
                    'CHAT_MSG_RAID',
                    'CHAT_MSG_RAID_LEADER',
                    'CHAT_MSG_RAID_WARNING',
                    'CHAT_MSG_INSTANCE_CHAT',
                    'CHAT_MSG_INSTANCE_CHAT_LEADER',
                    'CHAT_MSG_TARGETICONS',
                },
                GUILD = {
                    'CHAT_MSG_GUILD',
                    'GUILD_MOTD',
                    'PLAYER_GUILD_UPDATE',
                },
                YELL = {
                    'CHAT_MSG_YELL',
                },
                SAY = {
                    'CHAT_MSG_SAY',
                },
                CHANNEL = {
                    'CHAT_MSG_CHANNEL',
                    'CHAT_MSG_CHANNEL_JOIN',
                    'CHAT_MSG_CHANNEL_LEAVE',
                    'CHAT_MSG_COMMUNITIES_CHANNEL',
                },
                WHISPER = {
                    'CHAT_MSG_WHISPER',
                    'CHAT_MSG_WHISPER_INFORM',
                },
            };
        end

        Addon.CONFIG.GetMessageGroups = function( self )
            return {
                SAY = {
                    'SAY',
                    'MONSTER_SAY',
                },
                EMOTE = {
                    'EMOTE',
                    'MONSTER_EMOTE',
                    'MONSTER_BOSS_EMOTE',
                },
                YELL = {
                    'YELL',
                    'MONSTER_YELL',
                },
                GUILD = {
                    'GUILD',
                },
                WHISPER = {
                    'WHISPER',
                    'WHISPER_INFORM',
                    'SMART_WHISPER',
                    'MONSTER_BOSS_WHISPER',
                    'MONSTER_WHISPER',
                    'RAID_BOSS_WHISPER',
                    'BN_WHISPER',
                    'BN_WHISPER_INFORM',
                    'BN_WHISPER_PLAYER_OFFLINE',
                },
                BN = {
                    'BN_ALERT',
                    'BN_BROADCAST',
                    'BN_BROADCAST_INFORM',
                    'BN_INLINE_TOAST_ALERT',
                    'BN_INLINE_TOAST_BROADCAST',
                    'BN_INLINE_TOAST_BROADCAST_INFORM',
                    'BN_WHISPER',
                    'BN_WHISPER_INFORM',
                    'BN_WHISPER_PLAYER_OFFLINE',
                },
                PARTY = {
                    'PARTY',
                    'PARTY_LEADER',
                },
                RAID = {
                    'RAID',
                    'RAID_LEADER',
                    'RAID_WARNING',
                    'INSTANCE_CHAT',
                    'INSTANCE_CHAT_LEADER',
                },
                COMBAT = {
                    'COMBAT',
                    'COMBAT_XP_GAIN',
                    'COMBAT_HONOR_GAIN',
                    'COMBAT_FACTION_CHANGE',
                },
                SKILL = {
                    'SKILL',
                },
                LOOT = {
                    'LOOT',
                },
                MONEY = {
                    'MONEY',
                },
                TRADESKILLS = {
                    'TRADESKILLS',
                },
                OPENING = {
                    'OPENING',
                },
                PET = {
                    'PET',
                    'PET_INFO',
                },
                BATTLEGROUND = {
                    'BG_SYSTEM_HORDE',
                    'BG_SYSTEM_ALLIANCE',
                    'BG_SYSTEM_NEUTRAL',
                    'BATTLEGROUND',
                },
                ERRORS = {
                    'ERRORS',
                },
                IGNORED = {
                    'IGNORED',
                },
                CHANNEL = {
                    'CHANNEL',
                },
            };
        end

        --
        -- Set watch list
        --
        -- @param string
        --
        -- @return void
        Addon.CONFIG.SetAlerts = function( self,watch )
            watch = Addon:Explode( watch,',' );
            if( type( watch ) == 'table' ) then
                self.persistence.AlertList = {};
                for i,v in pairs( watch ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( self.persistence.AlertList,Addon:Minify( v ) );
                    end
                end
            else
                self.persistence.AlertList = { Addon:Minify( watch ) };
            end
            --Addon:Dump( self.persistence.AlertList )
        end

        --
        -- Get watch list
        --
        -- @return table
        Addon.CONFIG.GetAlerts = function( self )
            return self.persistence.AlertList;
        end

        --
        -- Set ignore list
        --
        -- @param string
        --
        -- @return void
        Addon.CONFIG.SetIgnores = function( self,ignore )
            ignore = Addon:Explode( ignore,',' );
            if( type( ignore ) == 'table' ) then
                self.persistence.IgnoreList = {};
                for i,v in pairs( ignore ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( self.persistence.IgnoreList,Addon:Minify( v ) );
                    end
                end
            else
                self.persistence.IgnoreList = { Addon:Minify( ignore ) };
            end
            --Addon:Dump( self.persistence.IgnoreList )
        end

        --
        -- Get ignore list
        --
        -- @return table
        Addon.CONFIG.GetIgnores = function( self )
            return self.persistence.IgnoreList;
        end

        --
        -- Set alias list
        --
        -- @param string
        --
        -- @return void
        Addon.CONFIG.SetAliasList = function( self,Alias )
            Alias = Addon:Explode( Alias,',' );
            if( type( Alias ) == 'table' ) then
                self.persistence.AliasList = {};
                for i,v in pairs( Alias ) do
                    if( string.len( v ) > 0 ) then
                        table.insert( self.persistence.AliasList,Addon:Minify( v ) );
                    end
                end
            else
                self.persistence.AliasList = { Addon:Minify( Alias ) };
            end
            --Addon:Dump( self.persistence.AliasList )
        end

        --
        --  Enable Config Events
        --
        --  @return void
        Addon.CONFIG.EnableConfigEvents = function( self )
            self.ConfigEvents = CreateFrame( 'Frame' );
            self.ConfigEvents:RegisterEvent( 'UPDATE_CHAT_COLOR' );
            self.ConfigEvents:SetScript( 'OnEvent',function( self,Event,ChannelId,R,G,B,A )
                local ChannelName = Addon.CHAT:GetChannelName( ChannelId );
                if( ChannelName and Addon.CONFIG.persistence.Channels[ ChannelName ] ) then
                    Addon.CONFIG.persistence.Channels[ ChannelName ].Color = { R,G,B,A };
                end
            end );
        end

        --
        -- Get alist list
        --
        -- @return table
        Addon.CONFIG.GetAliasList = function( self )
            return self.persistence.AliasList;
        end

        Addon.CONFIG.SetValue = function( self,Index,Value )
            if( self.persistence[ Index ] ~= nil ) then 
                self.persistence[ Index ] = Value;
            end
        end

        Addon.CONFIG.GetValue = function( self,Index )
            if( self.persistence[ Index ] ~= nil ) then 
                return self.persistence[ Index ];
            end
        end

        Addon.CONFIG.Init = function( self )
            -- Database
            self.db = LibStub( 'AceDB-3.0' ):New( AddonName,{ char = self:GetDefaults() },true );
            if( not self.db ) then
                return;
            end
            self.persistence = self.db.char;
            if( not self.persistence ) then
                return;
            end

            -- 1. Pick HELLOWORLD as the unique identifier.
            -- 2. Pick /hiw and /hellow as slash commands (/hi and /hello are actual emotes)
            -- https://wowpedia.fandom.com/wiki/Creating_a_slash_command
            SLASH_JCHAT1, SLASH_JCHAT2 = '/jc', '/jchat'; -- 3.
            SlashCmdList['JCHAT'] = function( Msg,EditBox ) -- 4.
                Settings.OpenToCategory( 'jChat' );
            end
        end

        -- Wait for chat windoww to load
        self:Init();

        local ChatFrame = CreateFrame( 'Frame' );
        ChatFrame:RegisterEvent( 'UPDATE_FLOATING_CHAT_WINDOWS' );
        ChatFrame:SetScript( 'OnEvent',function( self,Event )
            if( Event == 'UPDATE_FLOATING_CHAT_WINDOWS' and not Addon.CONFIG.Config ) then
                Addon.CONFIG:CreateFrames();
            end
        end );
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );