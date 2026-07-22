local UserInputService = game:GetService("UserInputService")

local SubpageShell = {}

local function inside(guiObject, position)
    if not guiObject or not guiObject.Parent then return false end
    local point = Vector2.new(position.X, position.Y)
    local minimum = guiObject.AbsolutePosition
    local maximum = minimum + guiObject.AbsoluteSize
    return point.X >= minimum.X and point.X <= maximum.X
        and point.Y >= minimum.Y and point.Y <= maximum.Y
end

local function installTouchScroller(scroller, owner)
    if not scroller or scroller:GetAttribute("SquidNoMoDedicatedScroll") then return end
    scroller:SetAttribute("SquidNoMoDedicatedScroll", true)

    local activeInput = nil
    local origin = nil
    local originCanvas = nil
    local dragging = false
    local connections = {}

    local function maxCanvasY()
        local windowHeight = scroller.AbsoluteWindowSize.Y > 0
            and scroller.AbsoluteWindowSize.Y
            or scroller.AbsoluteSize.Y
        local canvasHeight = math.max(
            scroller.AbsoluteCanvasSize.Y,
            scroller.CanvasSize.Y.Offset + scroller.CanvasSize.Y.Scale * scroller.AbsoluteSize.Y
        )
        return math.max(0, canvasHeight - windowHeight)
    end

    local function setDragging(state)
        dragging = state == true
        scroller:SetAttribute("SquidNoMoTouchDragging", dragging)
        if owner and owner.Parent then
            owner:SetAttribute("SquidNoMoTouchDragging", dragging)
        end
    end

    table.insert(connections, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
            or activeInput
            or not scroller.Visible
            or not inside(scroller, input.Position)
        then
            return
        end

        activeInput = input
        origin = input.Position
        originCanvas = scroller.CanvasPosition
        setDragging(false)
    end))

    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if not activeInput
            or input.UserInputType ~= Enum.UserInputType.Touch
            or not scroller.Visible
        then
            return
        end

        -- Some mobile executors surface a replacement Touch InputObject during a
        -- drag, so once one touch begins inside this scroller we follow the live
        -- touch position instead of requiring object identity for every change.
        local delta = input.Position - (origin or input.Position)
        if not dragging then
            if math.abs(delta.Y) < 7 then return end
            if math.abs(delta.Y) <= math.abs(delta.X) * 0.72 then return end
            setDragging(true)
            scroller.ScrollingEnabled = false
        end

        scroller.CanvasPosition = Vector2.new(
            0,
            math.clamp(
                (originCanvas and originCanvas.Y or 0) - delta.Y,
                0,
                maxCanvasY()
            )
        )
    end))

    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if not activeInput or input.UserInputType ~= Enum.UserInputType.Touch then return end
        activeInput = nil
        origin = nil
        originCanvas = nil
        scroller.ScrollingEnabled = true
        task.delay(0.10, function()
            if scroller and scroller.Parent then setDragging(false) end
        end)
    end))

    scroller.Destroying:Connect(function()
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
    end)
end

function SubpageShell:Create(Page, App, options)
    options = options or {}
    Page:ClearAllChildren()
    Page:SetAttribute("SquidNoMoDedicatedShell", true)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.None
    Page.CanvasSize = UDim2.fromOffset(0, 0)
    Page.CanvasPosition = Vector2.zero
    Page.ScrollingEnabled = false
    Page.Active = false
    Page.ScrollBarThickness = 0

    local pageName = options.PageName or Page.Name or "Page"
    local padding = tonumber(options.Padding)
        or App:GetUIStyleValue(pageName, "PagePadding", "MainPage")
        or (App:IsMobile() and 10 or 14)
    local headerHeight = tonumber(options.HeaderHeight) or (App:IsMobile() and 104 or 112)
    local toolbarHeight = tonumber(options.ToolbarHeight) or 0
    local gap = tonumber(options.Gap) or (App:IsMobile() and 8 or 10)

    local root = Instance.new("Frame")
    root.Name = pageName .. "SubpageShell"
    root.Size = UDim2.fromScale(1, 1)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.ClipsDescendants = true
    root.Parent = Page

    local header = Instance.new("Frame")
    header.Name = "HeaderHost"
    header.Position = UDim2.fromOffset(padding, padding)
    header.Size = UDim2.new(1, -(padding * 2), 0, headerHeight)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.ClipsDescendants = true
    header.Parent = root

    local toolbar = nil
    local contentY = padding + headerHeight + gap
    if toolbarHeight > 0 then
        toolbar = Instance.new("Frame")
        toolbar.Name = "ToolbarHost"
        toolbar.Position = UDim2.fromOffset(padding, contentY)
        toolbar.Size = UDim2.new(1, -(padding * 2), 0, toolbarHeight)
        toolbar.BackgroundTransparency = 1
        toolbar.BorderSizePixel = 0
        toolbar.ClipsDescendants = true
        toolbar.Parent = root
        contentY = contentY + toolbarHeight + gap
    end

    local content = Instance.new("ScrollingFrame")
    content.Name = "SubpageScroller"
    content.Position = UDim2.fromOffset(0, contentY)
    content.Size = UDim2.new(1, 0, 1, -contentY)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.CanvasSize = UDim2.fromOffset(0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.None
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.ScrollingEnabled = true
    content.Active = true
    content.Selectable = false
    content.ClipsDescendants = true
    content.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    content.ScrollBarThickness = App:IsMobile() and 10 or 6
    content.ScrollBarImageTransparency = App:IsMobile() and 0.02 or 0.14
    content.ScrollBarImageColor3 = App:GetPageAccent(pageName)
    content.Parent = root

    installTouchScroller(content, Page)

    local shell = {
        Page = Page,
        Root = root,
        Header = header,
        Toolbar = toolbar,
        Content = content,
        Padding = padding,
        HeaderHeight = headerHeight,
        ToolbarHeight = toolbarHeight,
    }

    function shell:ResetScroll()
        if self.Content and self.Content.Parent then
            self.Content.CanvasPosition = Vector2.zero
        end
    end

    function shell:SetContentHeight(height, bottomPadding)
        if not self.Content or not self.Content.Parent then return end
        local viewport = math.max(
            0,
            self.Content.AbsoluteWindowSize.Y,
            self.Content.AbsoluteSize.Y
        )
        local total = math.max(
            tonumber(height) or 0,
            viewport + 1
        ) + (tonumber(bottomPadding) or (App:IsMobile() and 34 or 24))
        self.Content.CanvasSize = UDim2.fromOffset(0, total)
        self.Content.ScrollingEnabled = true
    end

    function shell:ClearContent()
        if not self.Content then return end
        for _, child in ipairs(self.Content:GetChildren()) do
            child:Destroy()
        end
        self.Content.CanvasPosition = Vector2.zero
        self.Content.CanvasSize = UDim2.fromOffset(0, 0)
    end

    return shell
end

return SubpageShell
