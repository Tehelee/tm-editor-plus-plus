/// ! This file is generated from ../../../codegen/Editor/CursorItem.xtoml !
/// ! Do not edit this file manually !

class DGameCursorItem : RawBufferElem {
	DGameCursorItem(RawBufferElem@ el) {
		if (el.ElSize != SZ_CGAMECURSORITEM) throw("invalid size for DGameCursorItem");
		super(el.Ptr, el.ElSize);
	}
	DGameCursorItem(uint64 ptr) {
		super(ptr, SZ_CGAMECURSORITEM);
	}
	DGameCursorItem(CGameCursorItem@ nod) {
		if (nod is null) throw("not a CGameCursorItem");
		super(Dev_GetPointerForNod(nod), SZ_CGAMECURSORITEM);
	}
	CGameCursorItem@ get_Nod() {
		return cast<CGameCursorItem>(Dev_GetNodFromPointer(ptr));
	}

	iso4 get_mat() { return (this.GetIso4(0x38)); }
	void set_mat(iso4 value) { this.SetIso4(0x38, value); }
	vec3 get_pos() { return (this.GetVec3((0x38 + 0x24))); }
	void set_pos(vec3 value) { this.SetVec3((0x38 + 0x24), value); }
	CGameCtnBlock@ get_snappedBlock() { return cast<CGameCtnBlock>(this.GetNod(0x70)); }
	vec3 get_mouseInWorld() { return (this.GetVec3(0x8C)); }
	CGameResources@ get_resource() { return cast<CGameResources>(this.GetNod(0xA0)); }
	CGameItemModel@ get_itemModel() { return cast<CGameItemModel>(this.GetNod(0xA8)); }
	DGameCursorItem_ItemDescs@ get_displayedItems() { return DGameCursorItem_ItemDescs(this.GetBuffer(0xB8, 0xA0, false)); }
}

class DGameCursorItem_ItemDescs : RawBuffer {
	DGameCursorItem_ItemDescs(RawBuffer@ buf) {
		super(buf.Ptr, buf.ElSize, buf.StructBehindPtr);
	}
	DGameCursorItem_ItemDesc@ GetItemDesc(uint i) {
		return DGameCursorItem_ItemDesc(this[i]);
	}
}

class DGameCursorItem_ItemDesc : RawBufferElem {
	DGameCursorItem_ItemDesc(RawBufferElem@ el) {
		if (el.ElSize != 0xA0) throw("invalid size for DGameCursorItem_ItemDesc");
		super(el.Ptr, el.ElSize);
	}
	DGameCursorItem_ItemDesc(uint64 ptr) {
		super(ptr, 0xA0);
	}

	// -1 when not drawn
	uint get_u1() { return (this.GetUint32(0x0)); }
	void set_u1(uint value) { this.SetUint32(0x0, value); }
	// unused i think
	uint get_u2() { return (this.GetUint32(0x4)); }
	void set_u2(uint value) { this.SetUint32(0x4, value); }
	CGameItemModel@ get_itemModel() { return cast<CGameItemModel>(this.GetNod(0x8)); }
	// 0x10 to 0x94 unused? maybe a matrix (identity, mostly) in front of it
	iso4 get_matrix() { return (this.GetIso4(0x70)); }
}

