local _,Addon = ...;

Addon.FRAMES = CreateFrame( 'Frame' );

--[[
Example of all types of widget settings:
Range       - Creates slider
List        - Creates dropdown
Color       - Creates colorpicker
Text        - Creates editbox
Toggle      - Creates checkbox

KeyValue    - Lookup key, useful in changeset handling such as onClick, onText, onValue, etc

Example call:
Addon.FRAMES:DrawFromSettings( Addon.WINDOWS:GetSettings(),Addon.WINDOWS );

Example types structure:
Addon.WINDOWS.GetSettings = function( self )
    return {
        nameplateNotSelectedAlpha = {
            Description = 'use this to display the class color in enemy nameplate health bars',
            KeyValue = 'nameplateNotSelectedAlpha',
            DefaultValue = GetCVarDefault( 'nameplateNotSelectedAlpha' ),
            KeyPairs = {
                Option1 = {
                    Value = 0.25,
                    Description = 'Low',
                },
                Option2 = {
                    Value = 1,
                    Description = 'Max',
                },
            },
            Step = 0.25,
            Type = 'Range',
        },
        chatStyle = {
            Description = 'The style of Edit Boxes for the ChatFrame. Valid values: "classic", "im"',
            KeyValue = 'chatStyle',
            DefaultValue = GetCVarDefault( 'chatStyle' ),
            KeyPairs = {
                Option1 = {
                    Value = 'im',
                    Description = 'IM',
                },
                Option2 = {
                    Value = 'classic',
                    Description = 'CLASSIC',
                },
            },
            Type = 'List',
        },
        WatchColor = {
            Description = 'Set the color of alerts in chat',
            KeyValue = 'WatchColor',
            Type = 'Color',
        },
        IgnoreList = {
            Description = 'Set words or phrases which should be omitted in chat',
            KeyValue = 'IgnoreList',
            CSV = true,
            Type = 'Text',
        },
        showtargetoftarget = {
            Description = 'Whether the target of target frame should be shown',
            KeyValue = 'showtargetoftarget',
            DefaultValue = GetCVarDefault( 'showtargetoftarget' ),
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
]]

--  Creates dynamic frame elements. Deps: Sushi/Poncho
--  
--  @param      table   Settings:   See above example
--  @param      table   ObjHandler: Reference back to calling library
--
--  @return     void
-- Two named frames. todo: make support only one/make sizing fully dynamic
Addon.FRAMES.DrawFromSettings = function( self,Settings,ObjHandler )

    local X,Y = 20,40; 
    -- Increment Y to control vertical spacing
    -- this will afect both columns, all rows

    -- Options scroll frame
    ObjHandler.ScrollFrame = CreateFrame( 'ScrollFrame',nil,ObjHandler.Panel,'UIPanelScrollFrameTemplate' );

    -- Options scrolling content frame
    ObjHandler.ScrollChild = CreateFrame( 'Frame' );

    -- Options scroll frame
    ObjHandler.ScrollFrame:SetPoint( 'TOPLEFT',3,-4 );
    ObjHandler.ScrollFrame:SetPoint( 'BOTTOMRIGHT',-27,4 );

    -- Options scroll content 
    ObjHandler.ScrollFrame:SetScrollChild( ObjHandler.ScrollChild );
    if( Addon:IsClassic() ) then
        ObjHandler.ScrollChild:SetWidth( InterfaceOptionsFramePanelContainer:GetWidth()-18 );
    else
        ObjHandler.ScrollChild:SetWidth( SettingsPanel:GetWidth()-18 );
    end
    ObjHandler.ScrollChild:SetHeight( 20 );

    -- Config screen left side
    ObjHandler.ScrollChild.Left = CreateFrame( 'Frame',ObjHandler.Panel:GetName()..'Left',ObjHandler.ScrollChild );
    ObjHandler.ScrollChild.Left:SetSize( ObjHandler.ScrollChild:GetWidth() / 3,ObjHandler.ScrollChild:GetHeight() - 10 );
    ObjHandler.ScrollChild.Left:SetPoint( 'topleft',ObjHandler.ScrollChild,'topleft' );

    -- Config screen right side
    ObjHandler.ScrollChild.Right = CreateFrame( 'Frame',ObjHandler.Panel:GetName()..'Right',ObjHandler.ScrollChild );
    ObjHandler.ScrollChild.Right:SetSize( ObjHandler.ScrollChild:GetWidth() / 3,ObjHandler.ScrollChild:GetHeight() - 10 );
    ObjHandler.ScrollChild.Right:SetPoint( 'topleft',ObjHandler.ScrollChild.Left,'topright' );

    local Children = {};
    local Iterator = 0;
    for Var,VarData in Addon:Sort( Settings ) do
        if( VarData.Type == 'Toggle' ) then

            local Parent;
            if( Iterator % 2 == 0 ) then
                Parent = ObjHandler.ScrollChild.Left;
            else
                Parent = ObjHandler.ScrollChild.Right;
            end
            if( not Children[ Parent:GetName() ] ) then
                Children[ Parent:GetName() ] = 1;
            else
                Children[ Parent:GetName() ] = Children[ Parent:GetName() ]+1;
            end

            --print( Parent:GetName(),'Toggle',X,-( Y*NumChildren ) )
            ObjHandler[ Var ] = LibStub( 'Sushi-3.1' ).Check( Parent );
            ObjHandler[ Var ]:SetChecked( Addon:Int2Bool( ObjHandler:GetValue( VarData.KeyValue ) ) );
            ObjHandler[ Var ]:SetPoint( 'topleft',Parent,'bottomleft',X,-( Y*Children[ Parent:GetName() ] ) );
            ObjHandler[ Var ]:SetTip( Var,VarData.Description );
            ObjHandler[ Var ]:SetLabel( Var );
            ObjHandler[ Var ].KeyValue = Var;
            ObjHandler[ Var ]:SetSmall( true );
            ObjHandler[ Var ]:SetCall('OnClick',function( self )
                ObjHandler:SetValue( self.KeyValue,Addon:BoolToInt( self:GetValue() ) );
            end );
            Iterator = Iterator+1;
        elseif( VarData.Type == 'Range' ) then

            local Parent;
            if( Iterator % 2 == 0 ) then
                Parent = ObjHandler.ScrollChild.Left;
            else
                Parent = ObjHandler.ScrollChild.Right;
            end
            if( not Children[ Parent:GetName() ] ) then
                Children[ Parent:GetName() ] = 1;
            else
                Children[ Parent:GetName() ] = Children[ Parent:GetName() ]+1;
            end

            --print( Parent:GetName(),'Range',X,-( Y*NumChildren ) )
            ObjHandler[ Var ] = LibStub( 'Sushi-3.1' ).Slider( Parent );
            ObjHandler[ Var ]:SetPoint( 'topleft',Parent,'bottomleft',X,-( Y*Children[ Parent:GetName() ] ) );
            ObjHandler[ Var ]:SetTip( Var,VarData.Description );
            ObjHandler[ Var ]:SetValue( ObjHandler:GetValue( VarData.KeyValue ) );
            ObjHandler[ Var ].Edit:SetValue( Addon:SliderRound( ObjHandler:GetValue( VarData.KeyValue ),VarData.Step ) );
            ObjHandler[ Var ]:SetRange( 
                VarData.KeyPairs.Option1.Value,
                VarData.KeyPairs.Option2.Value,
                VarData.KeyPairs.Option1.Description,
                VarData.KeyPairs.Option2.Description 
            );
            ObjHandler[ Var ]:SetStep( VarData.Step );
            ObjHandler[ Var ]:SetLabel( Var );
            ObjHandler[ Var ].KeyValue = Var;
            ObjHandler[ Var ]:SetSmall( true );
            ObjHandler[ Var ]:SetCall('OnValue',function( self )
                ObjHandler:SetValue( self.KeyValue,self:GetValue() );
            end );
            Iterator = Iterator+1;
        elseif( VarData.Type == 'Text' ) then

            local Parent;
            if( Iterator % 2 == 0 ) then
                Parent = ObjHandler.ScrollChild.Left;
            else
                Parent = ObjHandler.ScrollChild.Right;
            end
            if( not Children[ Parent:GetName() ] ) then
                Children[ Parent:GetName() ] = 1;
            else
                Children[ Parent:GetName() ] = Children[ Parent:GetName() ]+1;
            end

            --print( Parent:GetName(),'Range',X,-( Y*NumChildren ) )
            ObjHandler[ Var ] = LibStub( 'Sushi-3.1' ).BoxEdit( Parent );
            ObjHandler[ Var ]:SetPoint( 'topleft',Parent,'bottomleft',X+10,-( Y*Children[ Parent:GetName() ] ) );
            ObjHandler[ Var ]:SetTip( Var,VarData.Description );
            ObjHandler[ Var ]:SetMultiLine( true );
            if( VarData.CSV ) then
                ObjHandler[ Var ]:SetValue( table.concat( ObjHandler:GetValue( VarData.KeyValue ),',' ) );
                ObjHandler[ Var ].CSV = true;
            else
                ObjHandler[ Var ]:SetValue( ObjHandler:GetValue( VarData.KeyValue ) );
                ObjHandler[ Var ].CSV = false;
            end
            ObjHandler[ Var ]:SetLabel( Var );
            ObjHandler[ Var ].KeyValue = Var;
            ObjHandler[ Var ]:SetSmall( true );
            ObjHandler[ Var ]:SetCall('OnText',function( self )
                if( self.CSV ) then
                    local Values = Addon:Explode( self:GetValue(),',' );
                    if( type( Values ) == 'table' ) then
                        ObjHandler.persistence[ self.KeyValue ] = {};
                        for i,v in pairs( Values ) do
                            table.insert( ObjHandler.persistence[ self.KeyValue ],Addon:Minify( v ) );
                        end
                    else
                        ObjHandler.persistence[ self.KeyValue ] = {Addon:Minify( Values )};
                    end
                else
                    ObjHandler:SetValue( self.KeyValue,self:GetValue() );
                end
            end );
            Iterator = Iterator+1;
        elseif( VarData.Type == 'Color' ) then

            local Parent;
            if( Iterator % 2 == 0 ) then
                Parent = ObjHandler.ScrollChild.Left;
            else
                Parent = ObjHandler.ScrollChild.Right;
            end
            if( not Children[ Parent:GetName() ] ) then
                Children[ Parent:GetName() ] = 1;
            else
                Children[ Parent:GetName() ] = Children[ Parent:GetName() ]+1;
            end

            ObjHandler[ Var ] = LibStub( 'Sushi-3.1' ).ColorPicker( Parent );
            ObjHandler[ Var ]:SetPoint( 'topleft',Parent,'bottomleft',X,-( Y*Children[ Parent:GetName() ] ) );
            ObjHandler[ Var ]:SetTip( Var,VarData.Description );
            ObjHandler[ Var ]:SetLabel( Var );
            ObjHandler[ Var ].KeyValue = Var;
            ObjHandler[ Var ]:SetSmall( true );
            ObjHandler[ Var ]:SetValue( CreateColor( unpack( ObjHandler:GetValue( VarData.KeyValue ) ) ) );
            ObjHandler[ Var ]:SetCall('OnColor', function( self )
                ObjHandler.persistence[ self.KeyValue ] = { self.color.r,self.color.g,self.color.b,self.color.a };
            end )
            --ObjHandler[ Var ].hasOpacity = true;
            Iterator = Iterator+1;
        elseif( VarData.Type == 'List' ) then

            local Parent;
            if( Iterator % 2 == 0 ) then
                Parent = ObjHandler.ScrollChild.Left;
            else
                Parent = ObjHandler.ScrollChild.Right;
            end
            if( not Children[ Parent:GetName() ] ) then
                Children[ Parent:GetName() ] = 1;
            else
                Children[ Parent:GetName() ] = Children[ Parent:GetName() ]+1;
            end

            ObjHandler[ Var ] = LibStub( 'Sushi-3.1' ).DropChoice( Parent );
            ObjHandler[ Var ]:SetValue( ObjHandler:GetValue( VarData.KeyValue ) );
            ObjHandler[ Var ]:SetPoint( 'topleft',Parent,'bottomleft',X,-( Y*Children[ Parent:GetName() ] ) );
            ObjHandler[ Var ]:SetTip( Var,VarData.Description );
            ObjHandler[ Var ]:SetLabel( Var );
            ObjHandler[ Var ].KeyValue = Var;
            ObjHandler[ Var ]:SetSmall( true );
            if( tonumber( ObjHandler:GetValue( VarData.KeyValue ) ) ~= nil ) then
                ObjHandler[ Var ]:SetValue( tonumber( ObjHandler:GetValue( VarData.KeyValue ) ) );
            else
                ObjHandler[ Var ]:SetValue( ObjHandler:GetValue( VarData.KeyValue ) );
            end
            for i,v in pairs( VarData.KeyPairs ) do
                ObjHandler[ Var ]:Add( v.Value,v.Description );
            end
            ObjHandler[ Var ]:SetCall('OnInput',function( self )
                print( self.KeyValue,self:GetValue() )
                ObjHandler:SetValue( self.KeyValue,self:GetValue() );
            end );
            Iterator = Iterator+1;
        end
    end
end