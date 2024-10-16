local _, Addon = ...;

Addon.QUESTS = CreateFrame( 'Frame' );
Addon.QUESTS:RegisterEvent( 'ADDON_LOADED' );
Addon.QUESTS:SetScript( 'OnEvent',function( self,Event,AddonName )
    if( AddonName == 'jChatFilter' ) then
        --
        --  Accept Quest
        --
        --  @param  list
        --  @return void
        Addon.QUESTS.AcceptQuest = function( self,... )
            local QuestTitle,IsHeader;
            if( Addon:IsClassic() ) then
                QuestTitle,_,_,IsHeader = Addon:Minify( select( 1, GetQuestLogTitle( select( 1,... ) ) ) );
            else
                QuestTitle = Addon:Minify( C_QuestLog.GetTitleForQuestID( select( 1,... ) ) );
            end
            if( QuestTitle and not IsHeader ) then
                self.ActiveQuests[ QuestTitle ] = QuestTitle;
            end
        end

        --
        --  Complete Quest
        --
        --  @param  list
        --  @return void
        Addon.QUESTS.CompleteQuest = function( self,... )
            if( self.ActiveQuests[ QuestTitle ] ) then
                local QuestTitle;
                if( Addon:IsClassic() ) then
                    QuestTitle = Addon:Minify( C_QuestLog.GetQuestInfo( ... ) )
                else
                    QuestTitle = Addon:Minify( C_QuestLog.GetTitleForQuestID( ... ) )
                end
                self.ActiveQuests[ QuestTitle ] = nil;
            end
        end

        --
        --  Rebuild Quest Watch
        --
        --  @return void
        Addon.QUESTS.RebuildQuests = function( self )
            self.ActiveQuests = {};
            local QuestHeaders,QuestEntries;
            if( Addon:IsClassic() ) then
                QuestHeaders,QuestEntries = GetNumQuestLogEntries();
            else
                QuestHeaders,QuestEntries = C_QuestLog.GetNumQuestLogEntries();
            end
            for i=1, QuestEntries do
                local QuestTitle,IsHeader;
                if( Addon:IsClassic() ) then
                    QuestTitle,_,_,IsHeader = GetQuestLogTitle( i );
                else
                    QuestTitle = C_QuestLog.GetTitleForQuestID( i );
                end
                if( QuestTitle and not IsHeader ) then
                    self.ActiveQuests[ Addon:Minify( QuestTitle ) ] = Addon:Minify( QuestTitle );
                end
            end
        end

        --
        --  Enable Quest Events
        --
        --  @return void
        Addon.QUESTS.EnableQuestEvents = function( self )
            self.QuestEvents = self.QuestEvents or CreateFrame( 'Frame' );
            self.QuestEvents:RegisterEvent( 'QUEST_ACCEPTED' );
            self.QuestEvents:RegisterEvent( 'QUEST_TURNED_IN' );
            self.QuestEvents:SetScript( 'OnEvent',function( self,event,... )
                if( event == 'QUEST_ACCEPTED' ) then
                    Addon.QUESTS:AcceptQuest( ...  );
                elseif( event == 'QUEST_TURNED_IN' ) then
                    Addon.QUESTS:RebuildQuests();
                end
            end );
        end

        --
        --  Disable Quest Events
        --
        --  @return void
        Addon.QUESTS.DisableQuestEvents = function( self )
            self.ActiveQuests = {};
            self.QuestEvents = self.QuestEvents or CreateFrame( 'Frame' );
            self.QuestEvents:UnregisterEvent( 'QUEST_ACCEPTED' );
            self.QuestEvents:UnregisterEvent( 'QUEST_TURNED_IN' );
        end
        
        self:UnregisterEvent( 'ADDON_LOADED' );
    end
end );