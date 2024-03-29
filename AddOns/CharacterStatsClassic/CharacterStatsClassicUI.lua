-- Namespaces
-- core - table (namespace) shared between every lua file
local addonName, core = ...;
core.UIConfig = {};

-- Defaults
local UISettingsGlobal = {
}

local UISettingsCharacter = {
    selectedLeftStatsCategory = 1;
    selectedRightStatsCategory = 2;
}

-- for easier referencing the core config
local UIConfig = core.UIConfig;
local CSC_UIFrame = core.UIConfig;

local CSC_CharacterFrameRef = CharacterFrame;

local statsDropdownList = {
    "基础属性",
    "近战",
    "远程",
    "法术",
    "防御"
}

local NUM_STATS_TO_SHOW = 6;
local LeftStatsTable = { }
local RightStatsTable = { }

local function CSC_ResetStatFrames(statFrames)
    for i=1, NUM_STATS_TO_SHOW, 1 do
        statFrames[i]:Hide();
        statFrames[i]:SetScript("OnEnter", statFrames[i].OnEnterCallback);
        statFrames[i].tooltip = nil;
        statFrames[i].tooltip2 = nil;
        statFrames[i].tooltip3 = nil;
    end
end

function UIConfig:InitializeStatsFrames(leftParentFrame, rightParentFrame)
    local offsetStepY = 15;
    local accumulatedOffsetY = 0;
    
    for i = 1, NUM_STATS_TO_SHOW do
        accumulatedOffsetY = accumulatedOffsetY + offsetStepY;
        local actualOffset = accumulatedOffsetY;
        
        if i == 1 then 
            actualOffset = 35;
            accumulatedOffsetY = 35;
        end

        LeftStatsTable[i] = CreateFrame("Frame", nil, leftParentFrame, "CharacterStatFrameTemplate");
        LeftStatsTable[i]:SetPoint("LEFT", leftParentFrame, "TOPLEFT", 10, -actualOffset);
        LeftStatsTable[i]:SetWidth(130);
        LeftStatsTable[i].OnEnterCallback = LeftStatsTable[i]:GetScript("OnEnter");

        RightStatsTable[i] = CreateFrame("Frame", nil, rightParentFrame, "CharacterStatFrameTemplate");
        RightStatsTable[i]:SetPoint("LEFT", rightParentFrame, "TOPLEFT", 10, -actualOffset);
        RightStatsTable[i]:SetWidth(130);
        RightStatsTable[i].OnEnterCallback = RightStatsTable[i]:GetScript("OnEnter");
    end
end

function UIConfig:SetCharacterStats(statsTable, category)
    --local characterFrameTab = PanelTemplates_GetSelectedTab(CharacterFrame);
    --print(characterFrameTab);
    CSC_ResetStatFrames(statsTable);

    if category == "基础属性" then
        -- str, agility, stamina, intelect, spirit, armor
        CSC_PaperDollFrame_SetPrimaryStats(statsTable, "player");
    elseif category == "防御" then
        -- armor, defense, dodge, parry, block
        CSC_PaperDollFrame_SetArmor(statsTable[1], "player");
        CSC_PaperDollFrame_SetDefense(statsTable[2], "player");
        CSC_PaperDollFrame_SetDodge(statsTable[3], "player");
        CSC_PaperDollFrame_SetParry(statsTable[4], "player");
        CSC_PaperDollFrame_SetBlock(statsTable[5], "player");
        --CSC_PaperDollFrame_SetStagger(statsTable[6], "player"); Is this useful?
    elseif category == "近战" then
        -- damage, Att Power, speed, hit raiting, crit chance
        CSC_PaperDollFrame_SetDamage(statsTable[1], "player", category);
        CSC_PaperDollFrame_SetMeleeAttackPower(statsTable[2], "player");
        CSC_PaperDollFrame_SetAttackSpeed(statsTable[3], "player");
        CSC_PaperDollFrame_SetCritChance(statsTable[4], "player", category);
        CSC_PaperDollFrame_SetHitChance(statsTable[5], "player");
    elseif category == "远程" then
        CSC_PaperDollFrame_SetDamage(statsTable[1], "player", category);
        CSC_PaperDollFrame_SetRangedAttackPower(statsTable[2], "player");
        CSC_PaperDollFrame_SetAttackSpeed(statsTable[3], "player");
        CSC_PaperDollFrame_SetCritChance(statsTable[4], "player", category);
    elseif category == "法术" then
        -- bonus dmg, bonus healing, crit chance, mana regen
        CSC_PaperDollFrame_SetSpellPower(statsTable[1], "player");
        CSC_PaperDollFrame_SetHealing(statsTable[2], "player");
        CSC_PaperDollFrame_SetManaRegen(statsTable[3], "player");
        CSC_PaperDollFrame_SetCritChance(statsTable[4], "player", category);
    end
end

function UIConfig:CreateMenu()
    -- Hide the default stats
    CharacterAttributesFrame:Hide();

    CSC_UIFrame.CharacterStatsPanel = CreateFrame("Frame", nil, CharacterFrame); --CharacterFrameInsetRight
	CSC_UIFrame.CharacterStatsPanel:SetPoint("LEFT", CharacterFrame, "BOTTOMLEFT", 50, 75);
	CSC_UIFrame.CharacterStatsPanel:SetHeight(320);
    CSC_UIFrame.CharacterStatsPanel:SetWidth(200);

    UIConfig:SetupDropdown();

    UIConfig:InitializeStatsFrames(CSC_UIFrame.CharacterStatsPanel.leftStatsDropDown, CSC_UIFrame.CharacterStatsPanel.rightStatsDropDown);
    UIConfig:SetCharacterStats(LeftStatsTable, statsDropdownList[UISettingsCharacter.selectedLeftStatsCategory]);
    UIConfig:SetCharacterStats(RightStatsTable, statsDropdownList[UISettingsCharacter.selectedRightStatsCategory]);
end

function UIConfig:UpdateStats()
    UIConfig:SetCharacterStats(LeftStatsTable, statsDropdownList[UISettingsCharacter.selectedLeftStatsCategory]);
    UIConfig:SetCharacterStats(RightStatsTable, statsDropdownList[UISettingsCharacter.selectedRightStatsCategory]);
end

local function OnClickLeftStatsDropdown(self)
    UISettingsCharacter.selectedLeftStatsCategory = self:GetID();
    UIDropDownMenu_SetSelectedID(CSC_UIFrame.CharacterStatsPanel.leftStatsDropDown, UISettingsCharacter.selectedLeftStatsCategory);
    UIConfig:SetCharacterStats(LeftStatsTable, statsDropdownList[UISettingsCharacter.selectedLeftStatsCategory]);
end

local function OnClickRightStatsDropdown(self)
    UISettingsCharacter.selectedRightStatsCategory = self:GetID();
    UIDropDownMenu_SetSelectedID(CSC_UIFrame.CharacterStatsPanel.rightStatsDropDown, UISettingsCharacter.selectedRightStatsCategory);
    UIConfig:SetCharacterStats(RightStatsTable, statsDropdownList[UISettingsCharacter.selectedRightStatsCategory]);
end

function UIConfig:InitializeLeftStatsDropdown(self, level)
    local info = UIDropDownMenu_CreateInfo();
    for k,v in pairs(statsDropdownList) do
        info.text = v;
        info.func = OnClickLeftStatsDropdown;
        info.checked = false;
        UIDropDownMenu_AddButton(info, level);
     end
end

function UIConfig:InitializeRightStatsDropdown(self, level)
    local info = UIDropDownMenu_CreateInfo();
    for k,v in pairs(statsDropdownList) do
        info.text = v;
        info.func = OnClickRightStatsDropdown;
        info.checked = false;
        UIDropDownMenu_AddButton(info, level);
     end
end

function UIConfig:SetupDropdown()

    CSC_UIFrame.CharacterStatsPanel.leftStatsDropDown = CreateFrame("Frame", nil, CSC_UIFrame.CharacterStatsPanel, "UIDropDownMenuTemplate");
    CSC_UIFrame.CharacterStatsPanel.leftStatsDropDown:SetPoint("TOPLEFT", CSC_UIFrame.CharacterStatsPanel, "TOPLEFT", 0, 0);

    CSC_UIFrame.CharacterStatsPanel.rightStatsDropDown = CreateFrame("Frame", nil, CSC_UIFrame.CharacterStatsPanel, "UIDropDownMenuTemplate");
    CSC_UIFrame.CharacterStatsPanel.rightStatsDropDown:SetPoint("TOPLEFT", CSC_UIFrame.CharacterStatsPanel, "TOPLEFT", 115, 0);

    UIDropDownMenu_Initialize(CSC_UIFrame.CharacterStatsPanel.leftStatsDropDown, UIConfig.InitializeLeftStatsDropdown);
    UIDropDownMenu_SetSelectedID(CSC_UIFrame.CharacterStatsPanel.leftStatsDropDown, UISettingsCharacter.selectedLeftStatsCategory);
    UIDropDownMenu_SetWidth(CSC_UIFrame.CharacterStatsPanel.leftStatsDropDown, 99);
    UIDropDownMenu_JustifyText(CSC_UIFrame.CharacterStatsPanel.leftStatsDropDown, "LEFT");

    UIDropDownMenu_Initialize(CSC_UIFrame.CharacterStatsPanel.rightStatsDropDown, UIConfig.InitializeRightStatsDropdown);
    UIDropDownMenu_SetSelectedID(CSC_UIFrame.CharacterStatsPanel.rightStatsDropDown, UISettingsCharacter.selectedRightStatsCategory);
    UIDropDownMenu_SetWidth(CSC_UIFrame.CharacterStatsPanel.rightStatsDropDown, 99);
    UIDropDownMenu_JustifyText(CSC_UIFrame.CharacterStatsPanel.rightStatsDropDown, "LEFT");
end

-- Extend the functionality of the default CharacterFrameTab
function CharacterFrameTab_OnClick(self, button)
	local name = self:GetName();
	if ( name == "CharacterFrameTab1" ) then
        ToggleCharacter("PaperDollFrame");
        CSC_UIFrame.CharacterStatsPanel:Show();
	elseif ( name == "CharacterFrameTab2" ) then
        ToggleCharacter("PetPaperDollFrame");
        CSC_UIFrame.CharacterStatsPanel:Hide();
	elseif ( name == "CharacterFrameTab3" ) then
        ToggleCharacter("ReputationFrame");
        CSC_UIFrame.CharacterStatsPanel:Hide();
	elseif ( name == "CharacterFrameTab4" ) then
        ToggleCharacter("SkillFrame");
        CSC_UIFrame.CharacterStatsPanel:Hide();
	elseif ( name == "CharacterFrameTab5" ) then
        ToggleCharacter("HonorFrame");
        CSC_UIFrame.CharacterStatsPanel:Hide();
	end

    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function ToggleCharacter(tab, onlyShow)
    if ( tab == "PaperDollFrame") then
        CSC_UIFrame.CharacterStatsPanel:Show();
    else
        CSC_UIFrame.CharacterStatsPanel:Hide();
    end

	if ( tab == "PetPaperDollFrame" and not HasPetUI() and not PetPaperDollFrame:IsVisible() ) then
		return;
	end
	if ( tab == "HonorFrame" and not HonorSystemEnabled() and not HonorFrame:IsVisible() ) then
		return;
	end
	local subFrame = _G[tab];
	if ( subFrame ) then
		if (not subFrame.hidden) then
			PanelTemplates_SetTab(CharacterFrame, subFrame:GetID());
			if ( CharacterFrame:IsShown() ) then
				if ( subFrame:IsShown() ) then
					if ( not onlyShow ) then
						HideUIPanel(CharacterFrame);
					end
				else
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
					CharacterFrame_ShowSubFrame(tab);
				end
			else
				CharacterFrame_ShowSubFrame(tab);
				ShowUIPanel(CharacterFrame);
			end
		end
    end
end

-- Serializing the DB
local dbLoader = CreateFrame("Frame");
dbLoader:RegisterEvent("ADDON_LOADED");
dbLoader:RegisterEvent("PLAYER_LOGOUT");

-- ADDON_LOADED is called after the code of the addon is being executed
-- Therefore I have to call any setup-functions dependent on the DB after the event (UIConfig:SetupDropdown())
function dbLoader:OnEvent(event, arg1)
    if (event == "ADDON_LOADED" and arg1 == "CharacterStatsClassic") then
        -- Global DB
        if (CharacterStatsClassicDB == nil) then
            CharacterStatsClassicDB = UISettingsGlobal;
        else
            UISettingsGlobal = CharacterStatsClassicDB;
        end
        
        -- Character DB
        if (CharacterStatsClassicCharacterDB == nil) then
            CharacterStatsClassicCharacterDB = UISettingsCharacter;
        else
            UISettingsCharacter = CharacterStatsClassicCharacterDB;
        end

        UIConfig:CreateMenu();
    elseif (event == "PLAYER_LOGOUT") then
        CharacterStatsClassicDB = UISettingsGlobal;
        CharacterStatsClassicCharacterDB = UISettingsCharacter;
    end
end

dbLoader:SetScript("OnEvent", dbLoader.OnEvent);