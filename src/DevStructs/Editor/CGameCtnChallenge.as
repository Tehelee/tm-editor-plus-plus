/// ! This file is generated from ../../../codegen/Editor/CGameCtnChallenge.xtoml !
/// ! Do not edit this file manually !

class DGameCtnChallenge : RawBufferElem {
	DGameCtnChallenge(RawBufferElem@ el) {
		if (el.ElSize != SZ_CTNCHALLENGE) throw("invalid size for DGameCtnChallenge");
		super(el.Ptr, el.ElSize);
	}
	DGameCtnChallenge(uint64 ptr) {
		super(ptr, SZ_CTNCHALLENGE);
	}

}


