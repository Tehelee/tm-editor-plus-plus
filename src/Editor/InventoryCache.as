namespace Editor {
    class InventoryCache {
        InventoryCache() {
            RefreshCacheSoon();
            itemsFolderPrefix = Fids::GetUserFolder("Items").FullDirName;
            RegisterOnEditorLoadCallback(CoroutineFunc(RefreshCacheSoon), "InventoryCache");
        }
        bool isRefreshing = false;

        uint loadProgress = 0;
        uint loadTotal = 0;
        string LoadingStatus() {
            return tostring(loadProgress) + " / " + loadTotal + Text::Format(" (%2.1f%%)", float(loadProgress) / loadTotal * 100);
        }

        uint cacheRefreshNonce = 0;
        void RefreshCache() {
            isRefreshing = true;
            auto myNonce = ++cacheRefreshNonce;
            cachedInvItemPaths.RemoveRange(0, cachedInvItemPaths.Length);
            cachedInvItemNames.RemoveRange(0, cachedInvItemNames.Length);
            cachedInvBlockNames.RemoveRange(0, cachedInvBlockNames.Length);
            cachedInvBlockArticleNodes.RemoveRange(0, cachedInvBlockArticleNodes.Length);
            cachedInvItemArticleNodes.RemoveRange(0, cachedInvItemArticleNodes.Length);
            cachedInvBlockIndexes.DeleteAll();
            cachedInvItemIndexes.DeleteAll();
            cachedInvBlockFolders.RemoveRange(0, cachedInvBlockFolders.Length);
            cachedInvItemFolders.RemoveRange(0, cachedInvItemFolders.Length);
            yield();
            auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
            if (editor is null) {
                @editor = cast<CGameCtnEditorFree>(GetApp().Switcher.ModuleStack[0]);
            }
            // this can be called when outside the editor
            if (editor is null) return;
            auto inv = editor.PluginMapType.Inventory;
            while (inv.RootNodes.Length < 4) yield();
            CGameCtnArticleNodeDirectory@ blockRN = cast<CGameCtnArticleNodeDirectory>(inv.RootNodes[1]);
            CGameCtnArticleNodeDirectory@ itemRN = cast<CGameCtnArticleNodeDirectory>(inv.RootNodes[3]);

            if (myNonce != cacheRefreshNonce) return;

            trace('Caching inventory blocks...');
            _IsScanningItems = false;
            CacheInvNode(blockRN, myNonce);
            yield();
            trace('Caching inventory items...');
            _IsScanningItems = true;
            CacheInvNode(itemRN, myNonce);
            trace('Caching inventory complete.');
            if (myNonce == cacheRefreshNonce) {
                // trigger update in other things
                cacheRefreshNonce++;
                isRefreshing = false;
            }
        }

        void RefreshCacheSoon() {
            startnew(CoroutineFunc(RefreshCache));
        }

        uint get_NbItems() {
            return cachedInvItemNames.Length;
        }

        uint get_NbBlocks() {
            return cachedInvBlockNames.Length;
        }

        const array<string>@ get_BlockNames() { return cachedInvBlockNames; }
        // const array<string>@ get_BlockPaths() { return cachedInvBlockPaths; }
        const array<CGameCtnArticleNodeArticle@>@ get_BlockInvNodes() { return cachedInvBlockArticleNodes; }
        const array<string>@ get_ItemNames() { return cachedInvItemNames; }
        const array<string>@ get_ItemPaths() { return cachedInvItemPaths; }
        const array<CGameCtnArticleNodeArticle@>@ get_ItemInvNodes() { return cachedInvItemArticleNodes; }
        const dictionary@ get_ItemIndexes() { return cachedInvItemIndexes; }
        const dictionary@ get_BlockIndexes() { return cachedInvBlockIndexes; }
        const array<string>@ get_BlockFolders() { return cachedInvBlockFolders; }
        const array<string>@ get_ItemFolders() { return cachedInvItemFolders; }

        protected bool _IsScanningItems = false;
        protected string itemsFolderPrefix;
        protected string[] cachedInvItemPaths;
        protected string[] cachedInvItemNames;
        protected string[] cachedInvBlockNames;
        protected string[] cachedInvBlockFolders;
        protected string[] cachedInvItemFolders;

        // protected string[] cachedInvBlockPaths;
        protected CGameCtnArticleNodeArticle@[] cachedInvBlockArticleNodes;
        protected CGameCtnArticleNodeArticle@[] cachedInvItemArticleNodes;
        protected dictionary cachedInvBlockIndexes;
        protected dictionary cachedInvItemIndexes;

        CGameCtnArticleNode@ GetBlockByName(const string &in name) {
            if (!cachedInvBlockIndexes.Exists(name)) return null;
            uint ix = uint(cachedInvBlockIndexes[name]);
            return cachedInvBlockArticleNodes[ix];
        }

        CGameCtnArticleNode@ GetItemByPath(const string &in path) {
            if (!cachedInvItemIndexes.Exists(path)) return null;
            uint ix = uint(cachedInvItemIndexes[path]);
            return cachedInvItemArticleNodes[ix];
        }

        protected void CacheInvNode(CGameCtnArticleNode@ node, uint nonce) {
            auto dir = cast<CGameCtnArticleNodeDirectory>(node);
            if (dir is null) {
                CacheInvNode(cast<CGameCtnArticleNodeArticle>(node), nonce);
            } else {
                CacheInvNode(dir, nonce);
            }
        }

        protected void CacheInvNode(CGameCtnArticleNodeDirectory@ node, uint nonce) {
            loadTotal += node.Children.Length + 1;
            loadProgress += 1;
            for (uint i = 0; i < node.ChildNodes.Length; i++) {
                CheckPause();
                if (GetApp().Editor is null) return;
                if (nonce != cacheRefreshNonce) return;
                CacheInvNode(node.ChildNodes[i], nonce);
            }
            if (_IsScanningItems) {
                cachedInvItemFolders.InsertLast(GetInvDirFullPath(node));
            } else {
                cachedInvBlockFolders.InsertLast(GetInvDirFullPath(node));
            }
        }

        string GetInvDirFullPath(CGameCtnArticleNodeDirectory@ node) {
            if (node.ParentNode !is null && (node.ParentNode.Name.Length > 0)) {
                return GetInvDirFullPath(node.ParentNode) + "\\" + node.NodeName;
            }
            return node.NodeName;
        }

        protected void CacheInvNode(CGameCtnArticleNodeArticle@ node, uint nonce) {
            if (node.Article is null) {
                warn('null article nod for ' + node.Name);
                return;
            }
            if (_IsScanningItems) {
                cachedInvItemIndexes[string(node.NodeName)] = cachedInvItemPaths.Length;
                cachedInvItemPaths.InsertLast(string(node.NodeName));
                cachedInvItemNames.InsertLast(string(node.Article.NameOrDisplayName));
                cachedInvItemArticleNodes.InsertLast(node);
            } else {
                cachedInvBlockIndexes[string(node.NodeName)] = cachedInvBlockNames.Length;
                // cachedInvBlockPaths.InsertLast(string(node.NodeName))
                cachedInvBlockNames.InsertLast(string(node.NodeName));
                cachedInvBlockArticleNodes.InsertLast(node);
            }
            loadProgress += 1;
        }
    }
}
