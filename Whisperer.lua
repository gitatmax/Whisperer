-- Check if WhispererDB exists, if not initialize it the first time the addon is loaded for this character
if not WhispererDB then
    WhispererDB = {
        playerName = "TargetPlayerName",
        message = "Message to send"
    }
end

-- Creating frame and registering events
local frame = CreateFrame("FRAME", "WhispererFrame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("VARIABLES_LOADED")

local function eventHandler(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if WhispererDB.playerName and WhispererDB.message then
            SendChatMessage(WhispererDB.message, "WHISPER", nil, WhispererDB.playerName)
        end
    elseif event == "VARIABLES_LOADED" then
        -- Set up the options panel here, after the VARIABLES_LOADED event is fired

        -- Create Interface options panel
        local options = CreateFrame("FRAME", "WhispererOptions");
        options.name = "Whisperer";
        InterfaceOptions_AddCategory(options);

        -- Create labels
        local playerNameLabel = options:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        playerNameLabel:SetPoint("TOPLEFT", 16, -16);
        playerNameLabel:SetText("Player Name:");

        local messageLabel = options:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        messageLabel:SetPoint("TOPLEFT", playerNameLabel, "BOTTOMLEFT", 0, -32);
        messageLabel:SetText("Message:");

        -- Create edit box for playerName
        local playerNameBox = CreateFrame("EditBox", "WhisperPlayerNameBox", options, "InputBoxTemplate");
        playerNameBox:SetSize(100, 30);
        playerNameBox:SetPoint("TOPLEFT", playerNameLabel, "TOPRIGHT", 8, 10);
        playerNameBox:SetAutoFocus(false);
        playerNameBox:SetText(WhispererDB.playerName);
        playerNameBox:SetCursorPosition(0);

        -- Save new playerName when the user presses enter
        playerNameBox:SetScript("OnEnterPressed", function(self)
            WhispererDB.playerName = self:GetText();
            self:ClearFocus();
        end);

        -- Create edit box for message
        local messageBox = CreateFrame("EditBox", "WhisperMessageBox", options, "InputBoxTemplate");
        messageBox:SetSize(200, 30);
        messageBox:SetPoint("TOPLEFT", messageLabel, "TOPRIGHT", 8, 10);
        messageBox:SetAutoFocus(false);
        messageBox:SetText(WhispererDB.message);
        messageBox:SetCursorPosition(0);

        -- Set a flag to check if text has changed
        local textChanged = false

        -- Create save button
        local saveButton = CreateFrame("Button", "WhispererSaveButton", options, "GameMenuButtonTemplate")
        saveButton:SetSize(80, 30)
        saveButton:SetPoint("TOPLEFT", messageBox, "BOTTOMLEFT", -80, -10)
        saveButton:SetText("Save")
        saveButton:Hide() -- Initially hide the save button

        -- Handle text changes for playerName
        playerNameBox:SetScript("OnTextChanged", function(self)
            textChanged = true
            saveButton:Show() -- Show save button when text changes
        end)

        -- Handle text changes for message
        messageBox:SetScript("OnTextChanged", function(self)
            textChanged = true
            saveButton:Show() -- Show save button when text changes
        end)

        -- Save new playerName and message when the user clicks the button
        saveButton:SetScript("OnClick", function(self)
            if textChanged then
                WhispererDB.playerName = playerNameBox:GetText()
                WhispererDB.message = messageBox:GetText()
                playerNameBox:ClearFocus()
                messageBox:ClearFocus()
                textChanged = false
                saveButton:Hide() -- Hide save button after saving
            end
        end)

        -- Save new message when the user presses enter
        messageBox:SetScript("OnEnterPressed", function(self)
            WhispererDB.message = self:GetText();
            self:ClearFocus();
        end);

        options.okay = function(self)
            playerNameBox:ClearFocus();
            messageBox:ClearFocus();
        end

        options.refresh = function(self)
            playerNameBox:SetText(WhispererDB.playerName);
            messageBox:SetText(WhispererDB.message);
        end
    end
end

frame:SetScript("OnEvent", eventHandler)
