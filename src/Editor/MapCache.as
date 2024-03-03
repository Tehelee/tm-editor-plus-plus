namespace Editor {
    MapCache@ _MapCache = MapCache();
    MapCache@ GetMapCache() {
        return _MapCache;
    }

    class ObjInMap {
        uint ix;
        vec3 pos;
        vec3 rot;
        int color;
        bool Exists = true;
        bool _hasSkin;
        uint Id;
        string IdName;
        mat4 mat;
        ObjInMap(uint index) {
            ix = index;
        }
        bool ReFindObj(CGameEditorPluginMap@ pmt) {
            throw('overload me');
            return true;
        }
        bool IsStale(CGameEditorPluginMap@ pmt) {
            throw('overload me');
            return true;
        }
        bool get_HasSkin() {
            return _hasSkin;
        }
    }

    class ItemInMap : ObjInMap {
        ItemInMap(uint i, CGameCtnAnchoredObject@ item) {
            super(i);
            pos = item.AbsolutePositionInMap;
            rot = Editor::GetItemRotation(item);
            color = int(item.MapElemColor);
            if (item.ItemModel is null) {
                NotifyError('MapCache: Item model is null!');
                return;
            }
            Id = item.ItemModel.Id.Value;
            IdName = item.ItemModel.IdName;
            mat = mat4::Translate(pos) * EulerToMat(rot);
            _hasSkin = Editor::GetItemBGSkin(item) !is null || Editor::GetItemFGSkin(item) !is null;
        }

        bool IsStale(CGameEditorPluginMap@ pmt) override {
            Exists = ix < pmt.Map.AnchoredObjects.Length
                && Matches(pmt.Map.AnchoredObjects[ix]);
            return !Exists;
        }

        bool ReFindObj(CGameEditorPluginMap@ pmt) override {
            Exists = false;
            auto map = pmt.Map;
            if (map.AnchoredObjects.Length == 0) {
                return Exists;
            }
            // item index can decrease, but not increase unless it's been edited and refreshed
            auto _ix = ix;
            if (ix >= map.AnchoredObjects.Length) {
                _ix = map.AnchoredObjects.Length - 1;
            }
            for (uint i = _ix; i <= _ix; i--) {
                if (Matches(map.AnchoredObjects[i])) {
                    ix = i;
                    Exists = true;
                    break;
                }
            }
            return Exists;
        }

        bool Matches(CGameCtnAnchoredObject@ item) {
            return Id == item.ItemModel.Id.Value
                && color == int(item.MapElemColor)
                && MathX::Vec3Eq(pos, item.AbsolutePositionInMap)
                && MathX::Vec3Eq(rot, Editor::GetItemRotation(item))
                ;
        }

        CGameCtnAnchoredObject@ FindMe(CGameEditorPluginMap@ pmt) {
            if (!IsStale(pmt)) {
                return pmt.Map.AnchoredObjects[ix];
            }
            return null;
        }
    }

    uint64 SwapMem100 = 0;

    class BlockInMap : ObjInMap {
        bool IsClassicElseGhost;
        vec3 size;
        int dir;
        uint64 hash;
        string hashStr;

        BlockInMap(uint i, CGameCtnBlock@ block) {
            // dev_trace("Adding block: " + block.BlockInfo.Name);
            super(i);
            pos = Editor::GetBlockLocation(block);
            rot = Editor::GetBlockRotation(block);
            // for duplicate detection, we need to hash pos + rot + info.Id / info.IdName
            // that would be 4*3*2+4 bytes = 28 bytes
            hashStr = GetBlockHash(pos, rot, block.BlockInfo.Name, block.BlockInfoVariantIndex, block.MobilVariantIndex);
            // dev_trace("Block hash: " + hashStr);
            color = int(block.MapElemColor);
            Id = block.BlockInfo.Id.Value;
            IdName = block.BlockInfo.IdName;
            IsClassicElseGhost = !block.IsGhostBlock();
            size = Editor::GetBlockSize(block);
            mat = mat4::Translate(pos) * EulerToMat(rot);
            _hasSkin = block.Skin !is null;
        }

        // if any of these differ, it's a different block
        string GetBlockHash(vec3 &in pos, vec3 &in rot, const string &in id, uint varIx, uint mobIx) {
            return Crypto::MD5(pos.ToString() + rot.ToString() + id + varIx + mobIx);
            // if (SwapMem100 == 0) SwapMem100 = RequestMemory(100);
            // Dev::Write(SwapMem100, pos);
            // Dev::Write(SwapMem100 + 0xC, rot);
            // Dev::Write(SwapMem100 + 0x18, id);
            // Dev::Write(SwapMem100 + 0x1C, varIx);
            // Dev::Write(SwapMem100 + 0x20, mobIx);
            // // ensure the rest of the memory region is zeroed
            // Dev::Write(SwapMem100 + 0x24, uint32(0));
            // auto bytes = Dev_GetBytes(SwapMem100, 0x24);

            // uint64 somePrime = 6256056576578937913;
            // uint64 mid = somePrime;
            // for (uint i = 0; i < bytes.Length; i++) {
            //     mid = mid + (bytes[i] ^ somePrime);
            //     mid = (mid << 7) + (mid >> 51);
            // }
            // return mid;
        }

        bool IsStale(CGameEditorPluginMap@ pmt) override {
            Exists = ix < NbPmtBlocks(pmt) && Matches(GetPmtBlock(pmt, ix));
            return !Exists;
        }

        protected uint NbPmtBlocks(CGameEditorPluginMap@ pmt) {
            return IsClassicElseGhost ? pmt.ClassicBlocks.Length : pmt.GhostBlocks.Length;
        }
        protected CGameCtnBlock@ GetPmtBlock(CGameEditorPluginMap@ pmt, uint i) {
            return IsClassicElseGhost ? pmt.ClassicBlocks[i] : pmt.GhostBlocks[i];
        }

        bool ReFindObj(CGameEditorPluginMap@ pmt) override {
            Exists = false;
            if (NbPmtBlocks(pmt) == 0) {
                return Exists;
            }
            // item index can decrease, but not increase unless it's been edited and refreshed
            auto _ix = ix;
            if (ix >= NbPmtBlocks(pmt)) {
                _ix = NbPmtBlocks(pmt) - 1;
            }
            for (uint i = _ix; i <= _ix; i--) {
                if (Matches(GetPmtBlock(pmt, i))) {
                    ix = i;
                    Exists = true;
                    break;
                }
            }
            return Exists;
        }

        bool Matches(CGameCtnBlock@ block) {
            return Id == block.BlockInfo.Id.Value
                && color == int(block.MapElemColor)
                && MathX::Vec3Eq(pos, Editor::GetBlockLocation(block))
                && MathX::Vec3Eq(rot, Editor::GetBlockRotation(block))
                ;
        }

        CGameCtnBlock@ FindMe(CGameEditorPluginMap@ pmt) {
            if (!IsStale(pmt)) {
                return GetPmtBlock(pmt, ix);
            }
            return null;
        }
    }

    class MapCache {
        MapCache() {
            RefreshCacheSoon();
            RegisterOnEditorLoadCallback(CoroutineFunc(RefreshCacheSoon), "MapCache");
        }
        bool isRefreshing = false;

        uint loadProgress = 0;
        uint loadTotal = 0;
        string LoadingStatus() {
            return tostring(loadProgress) + " / " + loadTotal + Text::Format(" (%2.1f%%)", float(loadProgress) / Math::Max(1, loadTotal) * 100);
        }

        // todo: BlockInMapI, ItemInMapI, dict for IdName => array<ObjInMapI>

        protected BlockInMap@[] _Blocks;
        const BlockInMap@[] get_Blocks() { return _Blocks; }
        protected BlockInMap@[] _SkinnedBlocks;
        const BlockInMap@[] get_SkinnedBlocks() { return _SkinnedBlocks; }
        protected ItemInMap@[] _Items;
        const ItemInMap@[] get_Items() { return _Items; }
        protected ItemInMap@[] _SkinnedItems;
        const ItemInMap@[] get_SkinnedItems() { return _SkinnedItems; }

        uint lastRefreshNonce = 0;
        void RefreshCache() {
            // if (isRefreshing) return;
            auto myNonce = ++lastRefreshNonce;
            isRefreshing = true;
            _ItemIdNameMap.DeleteAll();
            _BlockIdNameMap.DeleteAll();
            _BlocksByHash.DeleteAll();
            _Items.RemoveRange(0, _Items.Length);
            _Blocks.RemoveRange(0, _Blocks.Length);
            _SkinnedItems.RemoveRange(0, _SkinnedItems.Length);
            _SkinnedBlocks.RemoveRange(0, _SkinnedBlocks.Length);
            ItemTypes.RemoveRange(0, ItemTypes.Length);
            BlockTypes.RemoveRange(0, BlockTypes.Length);
            ItemTypesLower.RemoveRange(0, ItemTypesLower.Length);
            BlockTypesLower.RemoveRange(0, BlockTypesLower.Length);
            DuplicateBlockKeys.RemoveRange(0, DuplicateBlockKeys.Length);
            DuplicateBlockIxs.RemoveRange(0, DuplicateBlockIxs.Length);
            NbDuplicateFreeBlocks = 0;
            yield();
            if (myNonce != lastRefreshNonce) return;
            yield();
            if (myNonce != lastRefreshNonce) return;
            auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
            if (editor is null) return;
            auto pmt = editor.PluginMapType;

            loadTotal = pmt.ClassicBlocks.Length + pmt.GhostBlocks.Length + pmt.Map.AnchoredObjects.Length;

            trace('Caching map ClassicBlocks...');
            for (uint i = 0; i < pmt.ClassicBlocks.Length; i++) {
                if (myNonce != lastRefreshNonce) return;
                if (GetApp().Editor is null) return;
                // if (myNonce != lastRefreshNonce) return;
                AddBlock(BlockInMap(i, pmt.ClassicBlocks[i]));
                CheckPause();
            }
            yield();
            yield();
            trace('Caching map GhostBlocks...');
            for (uint i = 0; i < pmt.GhostBlocks.Length; i++) {
                CheckPause();
                if (myNonce != lastRefreshNonce) return;
                if (GetApp().Editor is null) return;
                if (myNonce != lastRefreshNonce) return;
                AddBlock(BlockInMap(i, pmt.GhostBlocks[i]));
            }
            yield();
            yield();
            trace('Caching map items...');
            for (uint i = 0; i < pmt.Map.AnchoredObjects.Length; i++) {
                CheckPause();
                if (myNonce != lastRefreshNonce) return;
                if (GetApp().Editor is null) return;
                if (myNonce != lastRefreshNonce) return;
                AddItem(ItemInMap(i, pmt.Map.AnchoredObjects[i]));
            }
            trace('Caching map complete. Indexing...');
            yield();
            yield();
            // todo
            if (myNonce != lastRefreshNonce) return;
            ItemTypes.SortAsc();
            yield();
            if (myNonce != lastRefreshNonce) return;
            BlockTypes.SortAsc();
            yield();
            if (myNonce != lastRefreshNonce) return;
            ItemTypesLower.SortAsc();
            yield();
            if (myNonce != lastRefreshNonce) return;
            isRefreshing = false;
            lastRefreshNonce++;
            BlockTypesLower.SortAsc();
        }

        dictionary _ItemIdNameMap;
        dictionary _BlockIdNameMap;
        dictionary _BlocksByHash;
        string[] BlockTypes;
        string[] ItemTypes;
        string[] BlockTypesLower;
        string[] ItemTypesLower;
        string[] DuplicateBlockKeys;
        int[] DuplicateBlockIxs;
        uint NbDuplicateFreeBlocks = 0;

        protected void AddBlock(BlockInMap@ b) {
            loadProgress++;
            _Blocks.InsertLast(b);
            if (b.HasSkin) _SkinnedBlocks.InsertLast(b);
            if (!_BlockIdNameMap.Exists(b.IdName)) {
                @_BlockIdNameMap[b.IdName] = array<BlockInMap@>();
                BlockTypes.InsertLast(b.IdName);
                BlockTypesLower.InsertLast(b.IdName.ToLower());
            }

            if (_BlocksByHash.Exists(b.hashStr)) {
                auto dupes = cast<BlockInMap@[]>(_BlocksByHash[b.hashStr]);
                dupes.InsertLast(b);
                DuplicateBlockIxs.InsertLast(b.ix);
                NbDuplicateFreeBlocks++;
                if (dupes.Length == 2) {
                    DuplicateBlockKeys.InsertLast(b.hashStr);
                    // don't ~~count the first block as a duplicate too~~
                    // NbDuplicateFreeBlocks++;
                }
            } else {
                array<BlockInMap@>@ arr = {b};
                _BlocksByHash[b.hashStr] = arr;
            }

            GetBlocksByType(b.IdName).InsertLast(b);
        }

        BlockInMap@[]@ GetBlocksByHash(const string &in blockHash) {
            if (_BlocksByHash.Exists(blockHash)) {
                return cast<BlockInMap@[]>(_BlocksByHash[blockHash]);
            }
            return {};
        }

        protected void AddItem(ItemInMap@ b) {
            loadProgress++;
            _Items.InsertLast(b);
            if (b.HasSkin) _SkinnedItems.InsertLast(b);
            if (!_ItemIdNameMap.Exists(b.IdName)) {
                @_ItemIdNameMap[b.IdName] = array<ItemInMap@>();
                ItemTypes.InsertLast(b.IdName);
                ItemTypesLower.InsertLast(b.IdName.ToLower());
            }
            GetItemsByType(b.IdName).InsertLast(b);
        }

        BlockInMap@[]@ GetBlocksByType(const string &in type) {
            if (_BlockIdNameMap.Exists(type))
                return cast<array<BlockInMap@>>(_BlockIdNameMap[type]);
            return {};
        }

        ItemInMap@[]@ GetItemsByType(const string &in type) {
            if (_ItemIdNameMap.Exists(type))
                return cast<array<ItemInMap@>>(_ItemIdNameMap[type]);
            return {};
        }

        void RefreshCacheSoon() {
            startnew(CoroutineFunc(RefreshCache));
        }

        uint get_NbItems() {
            return _Items.Length;
        }

        uint get_NbBlocks() {
            return _Blocks.Length;
        }
    }

    // todo: does not work
    void FixDuplicateBlocks() {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        if (editor is null) {
            NotifyWarning("Cannot fix duplicate blocks when editor is null.");
            return;
        }
        auto mapCache = GetMapCache();
        auto @dupKeys = mapCache.DuplicateBlockKeys;
        uint[] moveIxs = {};
        for (uint i = 0; i < dupKeys.Length; i++) {
            auto dupBlocks = mapCache.GetBlocksByHash(dupKeys[i]);
            for (uint j = 1; j < dupBlocks.Length; j++) {
                moveIxs.InsertLast(dupBlocks[j].ix);
                if (j < 5)
                    print(dupBlocks[j].IdName + ", " + dupBlocks[j].pos.ToString() + ", " + dupBlocks[j].rot.ToString());
            }
            yield();
        }
        auto map = editor.Challenge;
        int nbBlocks = map.Blocks.Length;
        int nbToDel = moveIxs.Length;

        int[] fakeBlocks = {};
        for (uint i = 0; i < nbBlocks; i++) {
            fakeBlocks.InsertLast(i);
        }

        NotifyWarning("About to delete " + nbToDel + " blocks");
        moveIxs.SortAsc();

        auto o_map_blocks = GetOffset(map, "Blocks");
        auto mapBlocksBufFakeNod = Dev::GetOffsetNod(map, o_map_blocks);
        uint32 mapBlocksBufLen = Dev::GetOffsetUint32(map, o_map_blocks + 0x8);
        if (mapBlocksBufLen != nbBlocks) throw("map blocks buf length != .Blocks.Length");

        for (int i = nbBlocks - 1; nbToDel > 0; i--) {
            nbToDel--;
            auto badIx = moveIxs[nbToDel];
            auto goodBlock = map.Blocks[i];
            auto badBlock = map.Blocks[badIx];
            // auto goodBlock = fakeBlocks[i];
            // auto badBlock = fakeBlocks[badIx];

            // swap
            Dev::SetOffset(mapBlocksBufFakeNod, 0x8 * i, badBlock);
            Dev::SetOffset(mapBlocksBufFakeNod, 0x8 * badIx, goodBlock);

            // fakeBlocks[i] = badBlock;
            // fakeBlocks[badIx] = goodBlock;

        }

        Dev::SetOffset(map, o_map_blocks + 0x8, uint(nbBlocks - nbToDel));

        SaveAndReloadMap();

        // string[] newOrder = {};
        // for (uint i = 0; i < fakeBlocks.Length; i++) {
        //     newOrder.InsertLast(tostring(fakeBlocks[i]));
        // }
        // yield();
        // string msg = "";
        // print("new block order: ");
        // for (uint i = 0; i < newOrder.Length; i++) {
        //     if (i % 100 == 99) {
        //         print(msg);
        //         msg = "";
        //         yield();
        //     }
        //     msg += newOrder[i] + ", ";
        // }
        // print(msg);
    }

}
