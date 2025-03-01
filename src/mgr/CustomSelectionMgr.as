funcdef void OnCustomSelectionDoneF(CGameCtnEditorFree@ editor, CSmEditorPluginMapType@ pmt);

class CustomSelectionMgr {
    uint HIST_LIMIT = 10;

    bool active = false;
    array<array<nat3>@> history;
    nat3[]@ latestCoords = {};

    int currentlySelected = -1;
    OnCustomSelectionDoneF@ doneCB;

    CustomSelectionMgr() {
        AddHotkey(VirtualKey::F, true, false, false, HotkeyFunction(this.OnFillHotkey));
        trace('added custom selection mgr hotkey, ' + tostring(VirtualKey::F) + ', ' + int(VirtualKey::F));
        RegisterOnLeavingPlaygroundCallback(CoroutineFunc(HideCustomSelection), "HideCustomSelection");
        RegisterOnEditorLoadCallback(CoroutineFunc(HideCustomSelection), "HideCustomSelection");
    }

    void HideCustomSelection() {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        editor.PluginMapType.HideCustomSelection();
    }

    UI::InputBlocking OnFillHotkey() {
        startnew(CoroutineFunc(Enable));
        @doneCB = OnCustomSelectionDoneF(this.OnFillSelectionComplete);
        dev_trace('running enable hotkey');
        // blocks editor inputs, unblock next frame
        Editor::EnableCustomCameraInputs();
        startnew(Editor::DisableCustomCameraInputs);
        return UI::InputBlocking::DoNothing;
    }

    bool get_IsActive() {
        return active;
    }

    CGameEditorPluginMap::EPlaceMode origPlacementMode;


    void Enable() {
        if (active) {
            NotifyWarning("Cannot enable a new custom selection while one is still active.");
            return;
        }
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        origPlacementMode = editor.PluginMapType.PlaceMode;
        if (SupportedFillModes.Find(origPlacementMode) < 0) {
            NotifyWarning("Place mode not supported for fill: " + tostring(origPlacementMode));
        }
        Editor::CustomSelectionCoords_Clear(editor);
        editor.PluginMapType.CustomSelectionCoords.Add(nat3(uint(-1)));
        Editor::SetPlacementMode(editor, CGameEditorPluginMap::EPlaceMode::CustomSelection);
        editor.PluginMapType.CustomSelectionRGB = vec3(1.);
        editor.PluginMapType.ShowCustomSelection();
        active = true;
        // Editor::EnableCustomCameraInputs();
        startnew(CoroutineFunc(this.WatchLoop)); //.WithRunContext(Meta::RunContext::BeforeScripts);
    }

    // if user presses escape
    void Cancel() {
        _cancel = true;
    }

    nat3 startCoord;
    // bool updateML = false;
    protected nat3 updateMin;
    protected nat3 updateMax;
    // use UpdateSelection
    protected void _DoUpdateSelection() { // ref@ r
        // if (!updateML) return;
        // updateML = false;
        // dev_trace('updating selection: ');
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        if (editor is null) return;
        Editor::CustomSelectionCoords_Clear(editor);
        for (uint x = updateMin.x; x <= updateMax.x; x++) {
            for (uint y = updateMin.y; y <= updateMax.y; y++) {
                for (uint z = updateMin.z; z <= updateMax.z; z++) {
                    editor.PluginMapType.CustomSelectionCoords.Add(nat3(x, y, z));
                }
            }
        }
        auto pmt = cast<CSmEditorPluginMapType>(editor.PluginMapType);
        pmt.CustomSelectionRGB = vec3(Math::Sin(0.001 * Time::Now) * .5 + .5, Math::Cos(0.001 * Time::Now) * .5 + .5, 1);
    }

    protected bool _cancel = false;
    void WatchLoop() {
        auto app = GetApp();
        auto input = app.InputPort;

        auto editor = cast<CGameCtnEditorFree>(app.Editor);
        auto pmt = cast<CSmEditorPluginMapType>(editor.PluginMapType);
        // Editor::EnableCustomCameraInputs();
        while (!(UI::IsMouseDown() && int(input.MouseVisibility) == 0) && ((@editor = cast<CGameCtnEditorFree>(app.Editor)) !is null) && !_cancel) {
            if (pmt.PlaceMode != CGameEditorPluginMap::EPlaceMode::CustomSelection) break;
            currentlySelected = editor.PluginMapType.CustomSelectionCoords.Length;
            startCoord = editor.PluginMapType.CursorCoord;
            yield();
        }
        if (!_cancel) dev_trace('mouse is now down');
        while (UI::IsMouseDown() && ((@editor = cast<CGameCtnEditorFree>(app.Editor)) !is null) && !_cancel) {
            if (pmt.PlaceMode != CGameEditorPluginMap::EPlaceMode::CustomSelection) break;
            UpdateSelection(editor, pmt, startCoord, pmt.CursorCoord);
            auto minPos = CoordToPos(updateMin);
            nvgDrawBlockBox(mat4::Translate(minPos), CoordToPos(updateMax + 1) - minPos);
            yield();
        }
        if (editor !is null && pmt.PlaceMode == CGameEditorPluginMap::EPlaceMode::CustomSelection && !_cancel) {
            dev_trace('mouse released');
            try {
                dev_trace('running callback');
                if (doneCB !is null) doneCB(editor, pmt);
            } catch {
                warn('catch in custom selection done callback: ' + getExceptionInfo());
            }
            Editor::CustomSelectionCoords_Clear(editor);
            pmt.PlaceMode = origPlacementMode;
        }
        if (editor !is null) {
            pmt.HideCustomSelection();
        }
        active = false;
        @doneCB = null;
        _cancel = false;
        // Editor::DisableCustomCameraInputs();
    }

    bool hideNext = true;
    void UpdateSelection(CGameCtnEditorFree@ editor, CSmEditorPluginMapType@ pmt, nat3 start, nat3 end) {
        auto min = MathX::Min(start, end); // updateMin
        auto max = MathX::Max(start, end); // updateMax
        updateMin = min;
        updateMax = max;
        _DoUpdateSelection();
        return;
    }

    CGameUILayer@ FindUpdateCustomSelectionUILayer(CSmEditorPluginMapType@ pmt) {
        string attachId = "E++_UpdateCustomSelection";
        for (int i = pmt.UILayers.Length - 1; i >= 0; i--) {
            auto item = pmt.UILayers[i];
            if (item.AttachId == attachId) {
                return item;
            }
        }
        auto layer = pmt.UILayerCreate();
        layer.AttachId = attachId;
        return layer;
    }

    // string GenUpdateCustomSelectionML(nat3 s, nat3 e) {
    //     return (
    //         // "<mainialink version=\"3\" page=\"EppUpdateCustomSelection\">\n"
    //         // "<script><!--\n"
    //         "main() {\n"
    //         " log(\"mian test\");"
    //         " declare Int3 Start = {start};\n"
    //         " declare Int3 End = {end};\n"
    //         " CustomSelectionCoords.Clear();\n"
    //         " for (X, Start.X, End.X) {\n"
    //         "  for (Y, Start.Y, End.Y) {\n"
    //         "   for (Z, Start.Z, End.Z) {\n"
    //         "    CustomSelectionCoords.add(<X, Y, Z>);\n"
    //         "   }\n"
    //         "  }\n"
    //         " }\n"
    //         "}\n"
    //         // "--></script>\n"
    //         // "</manialink>"
    //     ).Replace("{start}", s.ToString())
    //      .Replace("{end}", e.ToString())
    //      ;
    // }

    void Disable() {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        CacheCustomSelectionCoords(editor.PluginMapType);
        editor.PluginMapType.HideCustomSelection();
        active = false;
    }

    void CacheCustomSelectionCoords(CGameEditorPluginMapMapType@ pmt) {
        nat3[] coords;
        for (uint i = 0; i < pmt.CustomSelectionCoords.Length; i++) {
            coords.InsertLast(pmt.CustomSelectionCoords[i]);
        }
        while (history.Length > HIST_LIMIT) {
            history.RemoveAt(0);
        }
        history.InsertLast(coords);
    }

    CGameEditorPluginMap::EPlaceMode[] SupportedFillModes = {
        CGameEditorPluginMap::EPlaceMode::Block,
        CGameEditorPluginMap::EPlaceMode::GhostBlock,
        // CGameEditorPluginMap::EPlaceMode::Item,
        // CGameEditorPluginMap::EPlaceMode::Macroblock
    };

    void OnFillSelectionComplete(CGameCtnEditorFree@ editor, CSmEditorPluginMapType@ pmt) {
        int3 coord;
        nat3 c;

        CGameCtnBlockInfo@ block;
        CGameCtnMacroBlockInfo@ macroblock;
        CGameItemModel@ item;
        if (origPlacementMode == CGameEditorPluginMap::EPlaceMode::Block) {
            @block = selectedBlockInfo is null ? null : selectedBlockInfo.AsBlockInfo();
        } else if (origPlacementMode == CGameEditorPluginMap::EPlaceMode::GhostBlock) {
            @block = selectedGhostBlockInfo is null ? null : selectedGhostBlockInfo.AsBlockInfo();
        } else if (origPlacementMode == CGameEditorPluginMap::EPlaceMode::Macroblock) {
            @macroblock = selectedMacroBlockInfo.AsMacroBlockInfo();
        } else if (origPlacementMode == CGameEditorPluginMap::EPlaceMode::Item) {
            @item = selectedItemModel.AsItemModel();
        }
        if (block is null && macroblock is null && item is null) return;
        dev_trace('Running OnFillSelectionComplete');
        for (uint i = 0; i < pmt.CustomSelectionCoords.Length; i++) {
            c = pmt.CustomSelectionCoords[i];
            coord = int3(c.x, c.y, c.z);
            if (origPlacementMode == CGameEditorPluginMap::EPlaceMode::Block) {
                pmt.PlaceBlock(block, coord, pmt.CursorDir);
            } else if (origPlacementMode == CGameEditorPluginMap::EPlaceMode::GhostBlock) {
                pmt.PlaceGhostBlock(block, coord, pmt.CursorDir);
            } else if (origPlacementMode == CGameEditorPluginMap::EPlaceMode::Item) {
                NotifyWarning("Item fill mode not implemented yet");
            } else if (origPlacementMode == CGameEditorPluginMap::EPlaceMode::Macroblock) {
                NotifyWarning("Macroblock fill mode not implemented yet");
            } else {
                NotifyWarning("Unsupported for fill mode: " + tostring(origPlacementMode));
            }
            CheckPause();
        }
        pmt.AutoSave();
        // pmt.Selection
    }
}

CustomSelectionMgr@ customSelectionMgr = CustomSelectionMgr();
