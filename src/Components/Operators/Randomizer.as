class RandomizerEffectsTab : MultiEffectTab {
    RandomizerEffectsTab(TabGroup@ parent) {
        super(parent, "Randomizer", Icons::Magic + Icons::Random);
        SelectRandomBlockTab(Children);
        SelectRandomItemTab(Children);
        RandomizerTab(Children);
        canPopOut = false;
    }

    void DrawInner() override {
        Children.DrawTabsAsList();
    }
}

class RandomizerTab : Tab {
    RandomizerTab(TabGroup@ p) {
        super(p, "Randomize Props", "\\$bff"+Icons::Random+"\\$z");
    }

    bool applyToItems = true;
    bool applyToBlocks = true;
    bool applyToBakedBlocks = false;

    bool randomizeColor = true;
    bool randomizeLM = false;
    bool randomizeDir = true;

    void DrawInner() override {
        UI::TextWrapped("Randomize properties for blocks/items");

        UI::Columns(2);

        applyToItems = UI::Checkbox("Apply to Items", applyToItems);
        applyToBlocks = UI::Checkbox("Apply to Blocks", applyToBlocks);
        applyToBakedBlocks = UI::Checkbox("Apply to Baked Blocks", applyToBakedBlocks);
        randomizeColor = UI::Checkbox("Randomize Color", randomizeColor);

        if (UI::Button("Randomize " + Icons::Random)) {
            RunRandomize();
        }

        UI::NextColumn();

        randomizeLM = UI::Checkbox("Randomize LM Quality", randomizeLM);
        randomizeDir = UI::Checkbox("Randomize Block.Dir (N/S/E/W)", randomizeDir);
        UI::BeginDisabled();
        UI::Text("future features?");
        UI::Checkbox("Randomize Variant", false);
        UI::Checkbox("Randomize CP Linkage", false);
        UI::EndDisabled();

        UI::Columns(1);
    }

    void RunRandomize() {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        auto map = editor.Challenge;
        if (applyToBlocks) {
            for (uint i = 0; i < map.Blocks.Length; i++) {
                RandomizeBlock(map.Blocks[i]);
            }
        }
        if (applyToBakedBlocks) {
            for (uint i = 0; i < map.BakedBlocks.Length; i++) {
                RandomizeBlock(map.BakedBlocks[i]);
            }
        }
        if (applyToItems) {
            for (uint i = 0; i < map.AnchoredObjects.Length; i++) {
                RandomizeItem(map.AnchoredObjects[i]);
            }
        }
        Editor::RefreshBlocksAndItems(editor);
    }

    void RandomizeBlock(CGameCtnBlock@ block) {
        if (randomizeColor) block.MapElemColor = CGameCtnBlock::EMapElemColor(Math::Rand(0, 6));
        if (randomizeDir) block.BlockDir = CGameCtnBlock::ECardinalDirections(Math::Rand(0, 4));
        if (randomizeLM) block.MapElemLmQuality = CGameCtnBlock::EMapElemLightmapQuality(Math::Rand(0, 7));
    }
    void RandomizeItem(CGameCtnAnchoredObject@ item) {
        if (randomizeColor) item.MapElemColor = CGameCtnAnchoredObject::EMapElemColor(Math::Rand(0, 6));
        if (randomizeLM) item.MapElemLmQuality = CGameCtnAnchoredObject::EMapElemLightmapQuality(Math::Rand(0, 7));
    }
}



class SelectRandomBlockTab : EffectTab {
    SelectRandomBlockTab(TabGroup@ p) {
        super(p, "Randomize Next Block", "");
        RegisterNewBlockCallback(ProcessBlock(OnNewBlock));
    }

    bool OnNewBlock(CGameCtnBlock@ block) {
        // randomize check
        if (_IsActive) {
            startnew(CoroutineFunc(SelectRandomBlock));
        }
        return false;
    }

    void DrawInner() override {
        UI::TextWrapped("After placing a block, select a new random block.");
        _IsActive = UI::Checkbox("Enable next block randomization", _IsActive);
    }

    void SelectRandomBlock() {
        auto invCache = Editor::GetInventoryCache();
        auto ix = Math::Rand(0, invCache.BlockInvNodes.Length);
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        auto pmt = editor.PluginMapType;
        pmt.EditMode == CGameEditorPluginMap::EditMode::Place;
        Editor::EnsureBlockPlacementMode(editor);
        yield();
        pmt.Inventory.SelectArticle(invCache.BlockInvNodes[ix]);
    }
}

class SelectRandomItemTab : EffectTab {
    SelectRandomItemTab(TabGroup@ p) {
        super(p, "Randomize Next Item", "");
        RegisterNewItemCallback(ProcessItem(OnNewItem));
    }

    bool OnNewItem(CGameCtnAnchoredObject@ item) {
        // randomize check
        if (_IsActive) {
            startnew(CoroutineFunc(SelectRandomItem));
        }
        return false;
    }

    void DrawInner() override {
        UI::TextWrapped("After placing an item, select a new random item.");
        _IsActive = UI::Checkbox("Enable next item randomization", _IsActive);
    }

    void SelectRandomItem() {
        auto invCache = Editor::GetInventoryCache();
        auto ix = Math::Rand(0, invCache.ItemInvNodes.Length);
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        auto pmt = editor.PluginMapType;
        pmt.EditMode == CGameEditorPluginMap::EditMode::Place;
        Editor::EnsureItemPlacementMode(editor);
        yield();
        pmt.Inventory.SelectArticle(invCache.ItemInvNodes[ix]);
    }
}
