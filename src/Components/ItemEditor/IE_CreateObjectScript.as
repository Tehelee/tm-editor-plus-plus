/**
 * Create a script to create an item from other items.
 *
 */

#if DEV
class IE_CreateObjectMacroTab : Tab {
    IE_CreateObjectMacroTab(TabGroup@ p) {
        super(p, "Create Object (Macro)", "");
    }

    void DrawInner() override {
//         UI::Markdown("""
// - Expand VarList to correct length (2)
// - Populate VarLists with prefabs
// - Expand prefab EntList to 5x2
// - Populate Prefabs with unique DynaObjects and KinamaticConstraints
//   - set index on kinematic constraints, set no static shadows
// - Populate DynaObjects with common rocks
//         """);
        if (UI::Button("Create Glitched Rock out of Curr Item")) {
            startnew(CreateObj::MakeGlitchedRock);
        }
        if (UI::Button("Create Lightning Bolt + Rock Explosion (replaces current)")) {
            startnew(CreateObj::MakeExplodingRocksLightning);
        }

        UI::Separator();

        UI::Text("AR_Down Firework:");
        if (UI::Button("ExpandEntList")) ExpandEntList();
        if (UI::Button("(Opt) FillModels")) FillModels();
        if (UI::Button("FillEntities")) FillEntities();
        if (UI::Button("SetEntityProperties 200")) SetEntityProperties(200);
        if (UI::Button("SetEntityProperties 400")) SetEntityProperties(400);
        if (UI::Button("SetEntityProperties 600")) SetEntityProperties(600);
        if (UI::Button("DedupStarEntities")) DedupStarEntities();
    }

    void ExpandEntList() {
        try {
            CreateObjDownStar::ExpandEntList();
            NotifySuccess("ExpandEntList completed!");
        } catch {
            NotifyError("ExpandEntList failed: " + getExceptionInfo());
        }
    }
    void FillModels() {
        CreateObjDownStar::FillModels();
        try {
            CreateObjDownStar::FillModels();
            NotifySuccess("FillModels completed!");
        } catch {
            NotifyError("FillModels failed: " + getExceptionInfo());
        }
    }
    void FillEntities() {
        try {
            CreateObjDownStar::FillEntities();
            NotifySuccess("FillEntities completed!");
        } catch {
            NotifyError("FillEntities failed: " + getExceptionInfo());
        }
    }
    void SetEntityProperties(float sizeHeight) {
        CreateObjDownStar::fireworkHeight = sizeHeight;
        try {
            CreateObjDownStar::SetEntityProperties();
            NotifySuccess("SetEntityProperties completed!");
        } catch {
            NotifyError("SetEntityProperties failed: " + getExceptionInfo());
        }
    }
    void DedupStarEntities() {
        try {
            CreateObjDownStar::DedupStarEntities();
            NotifySuccess("DedupStarEntities completed!");
        } catch {
            NotifyError("DedupStarEntities failed: " + getExceptionInfo());
        }
    }
}



namespace CreateObj {
    string[] varListSources = {
        "Tmpl\\VarList2.Item.Gbx",
        "Tmpl\\VarList11.Item.Gbx"
    };

    string kinSimple = "Tmpl\\KinematicSimple.Item.Gbx";
    string kinSimple2 = "Tmpl\\KinematicSimple2.Item.Gbx";
    string kinSimple3 = "Tmpl\\KinematicSimple3.Item.Gbx";
    string kinSimple4 = "Tmpl\\KinematicSimple4.Item.Gbx";
    string kinSimple5 = "Tmpl\\KinematicSimple5.Item.Gbx";
    string prefab7_1 = "Tmpl\\Prefab7-1.Item.Gbx";
    string prefab7_2 = "Tmpl\\Prefab7-2.Item.Gbx";
    string prefab7_3 = "Tmpl\\Prefab7-3.Item.Gbx";
    string prefab7_4 = "Tmpl\\Prefab7-4.Item.Gbx";
    string prefab7_5 = "Tmpl\\Prefab7-5.Item.Gbx";
    string dynaSources = "Tmpl\\Firework-50-Kinematics.Item.Gbx";
    string dynaSources2 = "Tmpl\\Firework-50-Kinematics2.Item.Gbx";
    string dynaSources3 = "Tmpl\\Firework-50-Kinematics3.Item.Gbx";
    string dynaSources4 = "Tmpl\\Firework-50-Kinematics4.Item.Gbx";
    string fireworkSource = "yyy_MovedFromRoot\\zzzy_DOWN_FIREWORK_8.Item.Gbx";
    string fireworkSource2 = "yyy_MovedFromRoot\\zzzy_DOWN_FIREWORK_9.Item.Gbx";
    string fireworkSource3 = "yyy_MovedFromRoot\\zzzy_DOWN_FIREWORK_7.Item.Gbx";

    string farAwayShapeSource = "Work\\EmptyShapeItem.Item.Gbx";

    string grBaseDir = "DTC\\Prometheus\\";
    string workFilenameBase = grBaseDir + "Work\\";
    string _itemName = "GlitchedRock";

    string[] rockNames = {
        "GlitchedRock\\top.Item.Gbx",
        "GlitchedRock\\upper.Item.Gbx",
        "GlitchedRock\\mid.Item.Gbx",
        "GlitchedRock\\lower.Item.Gbx",
        "GlitchedRock\\bottom.Item.Gbx",
        "GlitchedRock\\Core.Item.Gbx"
    };

    void SaveWork(const string &in itemName, const string &in suffix) {
        ItemEditor::SaveItemAs(workFilenameBase + itemName + suffix);
        ItemEditor::ReloadItem(true);
    }

    string boltSource = "Work\\Lightning\\LightningBolt.Item.Gbx";
    string explRockSource = "Work\\ExplodingRock\\ExplodedRock";
    vec3[] explRockOffsets = {
        vec3(-24.1864, 0.0000, -6.7492), // "ExplodedRock1"
        vec3(-0.5666, 0.0000, -46.8823), // "ExplodedRock2"
        vec3(-26.3640, 0.0000, 7.4169), // "ExplodedRock3"
        vec3(-21.1237, 0.0000, 18.6746), // "ExplodedRock4"
        vec3(26.9871, 0.0000, 15.0569), // "ExplodedRock5"
        vec3(-15.4046, 0.0000, -25.1279), // "ExplodedRock6"
        vec3(-15.8160, 0.0000, 24.4962), // "ExplodedRock7"
        vec3(20.5205, 0.0000, -12.5596), // "ExplodedRock8"
        vec3(-23.9299, 0.0000, -26.4440), // "ExplodedRock9"
        vec3(9.7260, 0.0000, -31.0201) // "ExplodedRock10"
    };

    float[] explRockRots = {
        -1.8565,
        -3.1301,
        -1.2987,
        -0.8511,
        1.0547,
        -2.5902,
        -0.5710,
        2.1174,
        -2.4027,
        2.8376
    };
   /*
        - Expand Varlist
        - Prefabs
        - Prefab expand
        - Add unique kinematic constraints
        - add empty shape
     */
    void MakeExplodingRocksLightning() {
        string itemName = "ExplodingRocksLightning";

        auto vl = ExpandVarList(null, 4);

        auto explRock = CreateExplodingRockVariant(vl, 0);
        auto lightningBolt = CreateLightningVariant(vl, 1);
        auto lightningBolt11 = PrepareLightning11();
        CreateCombinedVariant(vl, 2, {explRock, lightningBolt11}, prefab7_1);
        CreateCombinedVariant(vl, 2, {explRock, lightningBolt11}, prefab7_2);
    }

    CPlugPrefab@ CreateCombinedVariant(NPlugItem_SVariantList@ vl, uint ix, CMwNod@[]@ models, const string &in tmplItem) {
        auto pf7 = SetVarListVariantModel(vl, ix, tmplItem);
        auto dest = cast<CPlugPrefab>(vl.Variants[ix].EntityModel);
        ExpandEntList(dest, models.Length);
        for (uint i = 0; i < dest.Ents.Length; i++) {
            dest.Ents[i].Location.Trans = vec3(0);
            dest.Ents[i].Location.Quat = quat(1, 0, 0, 0);
            MeshDuplication::SetEntRefModel(dest, i, models[i]);
            // MeshDuplication::SetEntRef
            // todo: change params?
        }
        return dest;
    }

    CPlugPrefab@ PrepareLightning11() {
        // lightning bolt
        auto farShapeItem = GetModelFromSource(farAwayShapeSource);
        auto farShape = cast<CPlugStaticObjectModel>(cast<CGameCommonItemEntityModel>(farShapeItem.EntityModel).StaticObject).Shape;
        auto bolt = GetModelFromSource(boltSource);
        auto boltMesh = cast<CPlugStaticObjectModel>(cast<CGameCommonItemEntityModel>(bolt.EntityModel).StaticObject).Mesh;
        auto dest = cast<CPlugPrefab>(GetModelFromSource(kinSimple2).EntityModel);
        dest.Ents[0].Location.Trans = vec3(0, 2, 0);
        // dest.Ents[0].Location.Trans = vec3(0);
        dest.Ents[0].Location.Quat = quat(vec3(Math::PI, 0, 0));
        auto dyna = cast<CPlugDynaObjectModel>(dest.Ents[0].Model);
        auto kinCon = cast<NPlugDyna_SKinematicConstraint>(dest.Ents[0 + 1].Model);

        if (dyna is null) throw('null dyna');
        if (kinCon is null) throw('null kinCon');
        if (dest is null) throw('null dest');
        if (boltMesh is null) throw('null boltMesh');
        if (farShape is null) throw('null farShape');

        ExpandKCToMaxAnimFuncs(kinCon);
        SetKCBolt(kinCon);
        // zero indexed, so 11th dyna is index 10
        SetKinConTargetIx(dest, 1, 10);

        ManipPtrs::Replace(dyna, GetOffset(dyna, "Mesh"), boltMesh, true);
        ManipPtrs::Replace(dyna, GetOffset(dyna, "DynaShape"), farShape, true);
        ManipPtrs::Replace(dyna, GetOffset(dyna, "StaticShape"), null, false);
        if (dyna.Mesh !is null) dyna.Mesh.MwAddRef();
        if (dyna.DynaShape !is null) dyna.DynaShape.MwAddRef();
        if (dyna.StaticShape !is null) dyna.StaticShape.MwAddRef();

        return dest;
    }

    CPlugPrefab@ CreateLightningVariant(NPlugItem_SVariantList@ vl, uint ix) {
        // lightning bolt
        auto farShapeItem = GetModelFromSource(farAwayShapeSource);
        auto farShape = cast<CPlugStaticObjectModel>(cast<CGameCommonItemEntityModel>(farShapeItem.EntityModel).StaticObject).Shape;
        auto fw1 = SetVarListVariantModel(vl, ix, kinSimple);
        auto bolt = GetModelFromSource(boltSource);
        auto boltMesh = cast<CPlugStaticObjectModel>(cast<CGameCommonItemEntityModel>(bolt.EntityModel).StaticObject).Mesh;
        auto dest = cast<CPlugPrefab>(vl.Variants[ix].EntityModel);

        dest.Ents[0].Location.Trans = vec3(0, 2, 0);
        // dest.Ents[0].Location.Trans = vec3(0);
        dest.Ents[0].Location.Quat = quat(vec3(Math::PI, 0, 0));
        auto dyna = cast<CPlugDynaObjectModel>(dest.Ents[0].Model);
        auto kinCon = cast<NPlugDyna_SKinematicConstraint>(dest.Ents[0 + 1].Model);

        ExpandKCToMaxAnimFuncs(kinCon);
        SetKCBolt(kinCon);

        ManipPtrs::Replace(dyna, GetOffset(dyna, "Mesh"), boltMesh, true);
        ManipPtrs::Replace(dyna, GetOffset(dyna, "DynaShape"), farShape, true);
        ManipPtrs::Replace(dyna, GetOffset(dyna, "StaticShape"), null, false);
        if (dyna.Mesh !is null) dyna.Mesh.MwAddRef();
        if (dyna.DynaShape !is null) dyna.DynaShape.MwAddRef();
        if (dyna.StaticShape !is null) dyna.StaticShape.MwAddRef();

        return dest;
    }


    CPlugPrefab@ CreateExplodingRockVariant(NPlugItem_SVariantList@ vl, uint ix) {
        auto farShapeItem = GetModelFromSource(farAwayShapeSource);
        auto farShape = cast<CPlugStaticObjectModel>(cast<CGameCommonItemEntityModel>(farShapeItem.EntityModel).StaticObject).Shape;
        auto fw1 = SetVarListVariantModel(vl, ix, dynaSources);
        auto dest = cast<CPlugPrefab>(vl.Variants[ix].EntityModel);
        ExpandEntList(dest, 20);
        for (int i = 0; i < 10; i++) {
            auto name = explRockSource + tostring(i + 1);
            auto rock = GetModelFromSource(name + ".Item.Gbx");
            auto rockIEM = cast<CGameCommonItemEntityModel>(rock.EntityModel);
            auto rockStatic = cast<CPlugStaticObjectModel>(rockIEM.StaticObject);
            dest.Ents[2 * i].Location.Trans = explRockOffsets[i] * vec3(1., 1., -1.);
            // dest.Ents[2 * i].Location.Trans = vec3(0);
            dest.Ents[2 * i].Location.Quat = quat(vec3(Math::PI, explRockRots[i], 0));
            auto dyna = cast<CPlugDynaObjectModel>(dest.Ents[2 * i].Model);
            auto kinCon = cast<NPlugDyna_SKinematicConstraint>(dest.Ents[2 * i + 1].Model);

            SetKinConTargetIx(dest, 2 * i + 1, i);
            SetKCExplodingRock(kinCon);

            ManipPtrs::Replace(dyna, GetOffset(dyna, "Mesh"), rockStatic.Mesh, true);
            ManipPtrs::Replace(dyna, GetOffset(dyna, "DynaShape"), farShape, true);
            ManipPtrs::Replace(dyna, GetOffset(dyna, "StaticShape"), null, false);
            if (dyna.Mesh !is null) dyna.Mesh.MwAddRef();
            if (dyna.DynaShape !is null) dyna.DynaShape.MwAddRef();
            if (dyna.StaticShape !is null) dyna.StaticShape.MwAddRef();
            // auto rockSurfFid = Fids::GetUser(name + ".Shape.Gbx");
            // Fids::Preload(rockSurfFid);
        }

        return dest;
    }

    uint boltPreExplode = 15;
    uint delayFromStart = 6100;
    uint boltShowDuration = 40;
    uint explodeDuration = 1600;
    // uint afterExplodeResetDelay = 300 * 1000; // 5 min
    uint afterExplodeResetDelay = 2000; // 2 seconds

    void SetKCBolt(NPlugDyna_SKinematicConstraint@ kc) {
        kc.RotAxis = EAxis::y;
        kc.AngleMinDeg = 0;
        kc.AngleMaxDeg = 0;
        kc.TransAxis = EAxis::y;
        kc.TransMin = 0;
        kc.TransMax = -20000.;
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 0, SubFuncEasings::None, true, delayFromStart - boltPreExplode);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 1, SubFuncEasings::None, false, boltShowDuration + boltPreExplode);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 2, SubFuncEasings::None, true, explodeDuration - boltShowDuration + afterExplodeResetDelay);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 3, SubFuncEasings::None, true, 0);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 0, SubFuncEasings::None, false, delayFromStart);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 1, SubFuncEasings::Linear, false, explodeDuration);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 2, SubFuncEasings::None, true, afterExplodeResetDelay);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 3, SubFuncEasings::None, true, 0);
    }

    void SetKCExplodingRock(NPlugDyna_SKinematicConstraint@ kc) {
        kc.RotAxis = EAxis::x;
        kc.AngleMinDeg = 0;
        kc.AngleMaxDeg = -210;
        kc.TransAxis = EAxis::z;
        kc.TransMin = 0;
        kc.TransMax = -20.;
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 0, SubFuncEasings::None, false, delayFromStart);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 1, SubFuncEasings::Linear, false, explodeDuration);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 2, SubFuncEasings::None, true, afterExplodeResetDelay);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 3, SubFuncEasings::None, false, 0);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 0, SubFuncEasings::None, false, delayFromStart);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 1, SubFuncEasings::Linear, false, explodeDuration);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 2, SubFuncEasings::None, true, afterExplodeResetDelay);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 3, SubFuncEasings::None, true, 0);
    }


    /*
        - Expand VarList to correct length (2)
        - Populate VarLists with prefabs
        - Expand prefab EntList to 5x2
        - Populate Prefabs with unique DynaObjects and KinamaticConstraints
        - set index on kinematic constraints, set no static shadows
        - Populate DynaObjects with common rocks
    */
    void MakeGlitchedRock() {
        auto vl = ExpandVarList(null, 3);
        auto fw1 = SetVarListVariantModel(vl, 0, fireworkSource);
        auto fw2 = SetVarListVariantModel(vl, 1, fireworkSource2);
        auto fw3 = SetVarListVariantModel(vl, 2, fireworkSource3);
        @vl = null;
        NotifySuccess("set varlist models");
        SaveWork("GlitchedRock", "-1");
        // entities in model are now unique from fw1 and fw2
        auto vl2 = GetRootVL();
        auto inner1 = cast<CPlugPrefab>(vl2.Variants[0].EntityModel);
        auto inner2 = cast<CPlugPrefab>(vl2.Variants[1].EntityModel);
        auto inner3 = cast<CPlugPrefab>(vl2.Variants[2].EntityModel);
        ExpandEntList(inner1, 10);
        ExpandEntList(inner2, 10);
        ExpandEntList(inner3, 11);
        CopyDynaKinematicsFromTo(cast<CPlugPrefab>(fw1.EntityModel), inner1);
        CopyDynaKinematicsFromTo(cast<CPlugPrefab>(fw2.EntityModel), inner2);
        CopyDynaKinematicsFromTo(cast<CPlugPrefab>(fw3.EntityModel), inner3);
        // ExpandEntList(inner3, 11);
        MeshDuplication::SetEntRefModel(inner3, 10, cast<CGameCommonItemEntityModel>(GetModelFromSource(rockNames[5]).EntityModel).StaticObject);
        SaveWork("GlitchedRock", "-2");
        // we now have unique dyna objects to play with
        FinalizeGlitchedRock();
        inner3.Ents[10].Location.Trans = vec3(0, .35, 0);
        SaveWork("GlitchedRock", "-3");
        // auto ieditor = cast<CGameEditorItem>(GetApp().Editor);
        // auto im = ieditor.ItemModel;
    }

    void FinalizeGlitchedRock() {
        CGameItemModel@[] sources;
        for (uint i = 0; i < 5; i++) {
            sources.InsertLast(GetModelFromSource(rockNames[i]));
        }
        // set set no shadows + kinematic entity ix
        auto vl3 = GetRootVL();
        for (uint vix = 0; vix < vl3.Variants.Length; vix++) {
            uint six = 0;
            auto prefab = cast<CPlugPrefab>(vl3.Variants[vix].EntityModel);
            vl3.Variants[vix].HiddenInManualCycle = false;
            for (uint pix = 0; pix < prefab.Ents.Length; pix++) {
                prefab.Ents[pix].Location.Quat = quat(1, 0, 0, 0);
                prefab.Ents[pix].Location.Trans = vec3(0);
                auto kc = cast<NPlugDyna_SKinematicConstraint>(prefab.Ents[pix].Model);
                auto dyna = cast<CPlugDynaObjectModel>(prefab.Ents[pix].Model);
                CreateObjDownStar::MbSetCastNoShadows(prefab, pix);
                if (kc !is null && pix >= 5 && pix < 10) {
                    SetKinematicEntityIx(prefab, pix - 5, pix);
                    SetGlitchedRockAnim(kc, vix, pix - 5);
                } else if (dyna !is null && pix < 5) {
                    // copy source items over
                    auto gciem = cast<CGameCommonItemEntityModel>(sources[six].EntityModel);
                    auto sourceStatic = cast<CPlugStaticObjectModel>(gciem.StaticObject);
                    ManipPtrs::Replace(dyna, GetOffset(dyna, "Mesh"), sourceStatic.Mesh, true);
                    ManipPtrs::Replace(dyna, GetOffset(dyna, "DynaShape"), sourceStatic.Shape, true);
                    ManipPtrs::Replace(dyna, GetOffset(dyna, "StaticShape"), sourceStatic.Shape, true);
                    if (sourceStatic.Mesh !is null) sourceStatic.Mesh.MwAddRef();
                    if (sourceStatic.Shape !is null) sourceStatic.Shape.MwAddRef();
                    if (sourceStatic.Shape !is null) sourceStatic.Shape.MwAddRef();
                    six++;
                } else {
                    warn("Unknown model type at prefab["+pix+"]");
                }
            }
        }
    }

    void SetGlitchedRockAnim(NPlugDyna_SKinematicConstraint@ kc, uint variant, uint ix) {
        kc.AngleMaxDeg = 360;
        kc.AngleMinDeg = 0;
        kc.RotAxis = EAxis::y;
        kc.TransAxis = EAxis::z;
        kc.TransMin = 0;
        kc.TransMax = 0.6 * (ix % 2 == 0 ? 1.0 : -1.0);

        if (variant == 2) {
            kc.TransAxis = EAxis::y;
            kc.TransMax = (ix < 2 ? 1.0 : ix == 2 ? 0.0 : -1.0);
            if (ix == 1 || ix == 3) kc.TransMax *= .5;
            kc.AngleMaxDeg = 0.;
        }

        int randDeviation = int(Math::Rand(-0.1, 0.1));

        while (SAnimFunc_GetLength(kc, transAnimFuncOffset) < 4) {
            SAnimFunc_IncrementEasingCountSetDefaults(kc, transAnimFuncOffset);
        }
        while (SAnimFunc_GetLength(kc, rotAnimFuncOffset) < 4) {
            SAnimFunc_IncrementEasingCountSetDefaults(kc, rotAnimFuncOffset);
        }
        if (variant == 0) {
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 0, SubFuncEasings::None, false, 1700);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 1, SubFuncEasings::None, true, 200);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 2, SubFuncEasings::None, false, 3423);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 3, SubFuncEasings::None, true, 400);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 0, SubFuncEasings::None, false, 1000);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 1, SubFuncEasings::None, false, 1000);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 2, SubFuncEasings::None, false, 1000);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 3, SubFuncEasings::None, false, 1000);
        } else if (variant == 1) {
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 0, SubFuncEasings::None, false, 1700);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 1, SubFuncEasings::None, false, 200);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 2, SubFuncEasings::None, false, 3423);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 3, SubFuncEasings::None, false, 400);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 0, SubFuncEasings::None, false, 1000);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 1, SubFuncEasings::QuadInOut, ix % 2 == 0, 2500);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 2, SubFuncEasings::None, false, 1000);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 3, SubFuncEasings::QuadInOut, ix % 2 != 0, 1500);
        } else if (variant == 2) {
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 0, SubFuncEasings::None, false, 1100);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 1, SubFuncEasings::QuadInOut, false, 2500);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 2, SubFuncEasings::None, true, 1200);
            SAnimFunc_SetIx(kc, transAnimFuncOffset, 3, SubFuncEasings::QuadInOut, true, 3500);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 0, SubFuncEasings::None, false, 1100);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 1, SubFuncEasings::QuadInOut, false, 2500);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 2, SubFuncEasings::None, true, 1200);
            SAnimFunc_SetIx(kc, rotAnimFuncOffset, 3, SubFuncEasings::QuadInOut, true, 3500);
        } else {
            warn("No variant with ix: " + variant);
        }
    }

    void CopyDynaKinematicsFromTo(CPlugPrefab@ source, CPlugPrefab@ dest) {
        uint spots = 10;
        uint nbPairs = spots / 2;
        uint destix = 0;
        for (uint six = 0; six < source.Ents.Length; six++) {
            auto item = cast<CPlugDynaObjectModel>(source.Ents[six].Model);
            if (item is null) continue;
            MeshDuplication::SetEntRefModel(dest, destix, item);
            MeshDuplication::CopyEntRefParams(source, six, dest, destix);
            destix++;
            if (destix >= nbPairs) break;
        }
        if (destix != nbPairs) throw("should have "+nbPairs+" things after filling dyna object models");
        for (uint six = 0; six < source.Ents.Length; six++) {
            auto item = cast<NPlugDyna_SKinematicConstraint>(source.Ents[six].Model);
            if (item is null) continue;
            MeshDuplication::SetEntRefModel(dest, destix, item);
            MeshDuplication::CopyEntRefParams(source, six, dest, destix);
            destix++;
            if (destix >= spots) break;
        }
        NotifySuccess("Copied " + nbPairs + " pairs of dyna objs and kinematic constraints over");
    }

    NPlugItem_SVariantList@ GetRootVL() {
        auto ieditor = cast<CGameEditorItem>(GetApp().Editor);
        auto model = ieditor.ItemModel;
        return cast<NPlugItem_SVariantList>(model.EntityModel);
    }

    NPlugItem_SVariantList@ ExpandVarList(NPlugItem_SVariantList@ varList, uint newCapacity) {
        if (varList is null) {
            auto ieditor = cast<CGameEditorItem>(GetApp().Editor);
            auto model = ieditor.ItemModel;
            @varList = cast<NPlugItem_SVariantList>(model.EntityModel);
        }
        if (newCapacity == 0 || newCapacity > 20000) throw('new capacity seems out of bounds');
        if (varList is null) throw('var list null');
        auto arrayPtr = Dev_GetPointerForNod(varList) + GetOffset(varList, "Variants");
        Dev_UpdateMwSArrayCapacity(arrayPtr, newCapacity, SZ_VARLIST_VARIANT);
        NotifySuccess("Set var list to length " + newCapacity);
        return varList;
    }


    void ExpandEntList(CPlugPrefab@ prefab, uint newCapacity) {
        auto arrayPtr = Dev_GetPointerForNod(prefab) + GetOffset(prefab, "Ents");
        Dev_UpdateMwSArrayCapacity(arrayPtr, newCapacity, SZ_ENT_REF);
    }

    CGameItemModel@ GetModelFromSource(const string &in path) {
        auto art = Editor::GetInventoryCache().GetItemByPath(path);
        if (art is null) {
            throw("Model source not found: " + path);
        }
        return cast<CGameItemModel>(art.GetCollectorNod());
    }

    CGameItemModel@ SetVarListVariantModel(NPlugItem_SVariantList@ varList, uint ix, const string &in source) {
        auto model = GetModelFromSource(source);
        if (model is null || model.EntityModel is null) throw("Model or entity model is null");
        MeshDuplication::SetVariantModel(varList, ix, model.EntityModel);
        NotifySuccess("Set varlist ix " + ix + " to " + source);
        return model;
    }

    void SetKinematicEntityIx(CPlugPrefab@ prefab, uint kinEntId, uint ix) {
        auto ents = Dev::GetOffsetNod(prefab, GetOffset("CPlugPrefab", "Ents"));

        auto ptr1 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params"));
        auto ptr2 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params") + 0x8);

        if (ptr2 > 0 && ptr2 % 8 == 0) {
            auto type = Dev::ReadCString(Dev::ReadUInt64(ptr2));
            auto clsId = Dev::ReadUInt32(ptr2 + 0x10);
            if (clsId == 0x2f0c8000 || type == "NPlugDyna::SPrefabConstraintParams") {
                Dev::Write(ptr1 + 0x4, kinEntId);
            } else {
                warn("got wrong params classid " + clsId + "; ix: " + ix);
            }
        } else {
            warn('params ptr null but expected it ' + ix);
        }
    }
}



// manual prep: use a prefab item as template
// have X unique star items already created so they
//     all have different model references
//     (for kinematic constraints)
// expand ent list to capacity
// fill each entity
// - set location and quat
// - pipe, rocket, box, and X stars
// - set star dynamic objects to point to same source
// - set kinematic thing to ent ID
// - turn off shadows
// - set animation

namespace CreateObjDownStar {
    string[] sources = {
        "z-down-hide-stars-box.Item.Gbx",
        "Tube.Item.Gbx",
        "z-down-moving-light-cone.Item.Gbx",
        "Z_DOWN\\0061-down-moving-ID.Item.Gbx",
    };

    uint nbStars = 50;
    uint entCapacity = 2 + (1 + nbStars) * 2;

    void ExpandEntList() {
        auto ieditor = cast<CGameEditorItem>(GetApp().Editor);
        auto model = ieditor.ItemModel;
        auto prefab = cast<CPlugPrefab>(model.EntityModel);
        auto arrayPtr = Dev_GetPointerForNod(prefab) + GetOffset(prefab, "Ents");
        Dev_UpdateMwSArrayCapacity(arrayPtr, entCapacity, SZ_ENT_REF);
    }

    CGameItemModel@[] models;

    void AddModelFromSource(const string &in path) {
        auto art = Editor::GetInventoryCache().GetItemByPath(path);
        if (art is null) {
            warn("Path failed: " + path);
        } else {
            // print("found " + path);
            models.InsertLast(cast<CGameItemModel>(art.GetCollectorNod()));
        }
    }

    void FillModels() {
        models.RemoveRange(0, models.Length);
        auto inv = Editor::GetInventoryCache();
        AddModelFromSource(sources[0]);
        AddModelFromSource(sources[1]);
        AddModelFromSource(sources[2]);
        for (uint i = 0; i < nbStars; i++) {
            auto path = sources[3].Replace("ID", tostring(i + 1));
            AddModelFromSource(path);
        }
    }

    void FillEntities() {
        FillModels();
        auto ieditor = cast<CGameEditorItem>(GetApp().Editor);
        auto model = ieditor.ItemModel;
        auto outerPrefab = cast<CPlugPrefab>(model.EntityModel);
        uint entIx = 0;
        for (uint i = 0; i < models.Length; i++) {
            // first two objs are static
            bool isMoving = i > 1;
            for (int j = 0; j < (isMoving ? 2 : 1); j++) {
                auto innerPrefab = cast<CPlugPrefab>(models[i].EntityModel);
                auto commonIEM = cast<CGameCommonItemEntityModel>(models[i].EntityModel);
                auto sourceModel = isMoving ? innerPrefab.Ents[j].Model : commonIEM.StaticObject;
                MeshDuplication::SetEntRefModel(outerPrefab, entIx, sourceModel);
                if (!isMoving)
                    MeshDuplication::ZeroEntRefParams(outerPrefab, entIx);
                else {
                    MeshDuplication::CopyEntRefParams(innerPrefab, j, outerPrefab, entIx);
                }
                entIx++;
            }
        }
    }

    void SetEntityProperties() {
        auto ieditor = cast<CGameEditorItem>(GetApp().Editor);
        auto model = ieditor.ItemModel;
        auto outerPrefab = cast<CPlugPrefab>(model.EntityModel);
        SetBoxLocation(outerPrefab, 0);
        SetTubeLocation(outerPrefab, 1);
        SetRocketLocation(outerPrefab, 2);
        SetRocketAnim(outerPrefab, 3);
        uint kinEntIx = 1;
        float nextD = Math::Rand(fireworkHeight * 0.2, fireworkHeight * 0.7);
        for (uint i = 0; i < outerPrefab.Ents.Length; i++) {
            MbSetCastNoShadows(outerPrefab, i);
            if (i < 4) continue;
            bool isConstraint = i % 2 == 1;
            if (isConstraint) {
                SetStarAnim(outerPrefab, i, kinEntIx, nextD);
                kinEntIx++;
            } else {
                nextD = Math::Rand(fireworkHeight * 0.2, fireworkHeight * 0.7);
                SetStarProps(outerPrefab, i, nextD);
            }
        }
    }
    void MbSetCastNoShadows(CPlugPrefab@ prefab, uint ix) {
        auto ents = Dev::GetOffsetNod(prefab, GetOffset("CPlugPrefab", "Ents"));

        auto ptr1 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params"));
        auto ptr2 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params") + 0x8);

        if (ptr2 > 0 && ptr2 % 8 == 0) {
            auto type = Dev::ReadCString(Dev::ReadUInt64(ptr2));
            auto clsId = Dev::ReadUInt32(ptr2 + 0x10);

            if (clsId == 0x2f0b6000 || type == "NPlugDynaObjectModel::SInstanceParams") {
                auto offsetCSS = GetOffset("NPlugDynaObjectModel_SInstanceParams", "CastStaticShadow");
                auto offsetIK = GetOffset("NPlugDynaObjectModel_SInstanceParams", "IsKinematic");
                Dev::Write(ptr1 + offsetCSS, uint(0));
                Dev::Write(ptr1 + offsetIK, uint(1));
            }
        }

    }

    float fireworkHeight = 600.;

    void SetBoxLocation(CPlugPrefab@ prefab, uint ix) {
        prefab.Ents[ix].Location.Trans = vec3(0, fireworkHeight, 0);
        prefab.Ents[ix].Location.Quat = quat(1, 0, 0, 0);
    }
    void SetTubeLocation(CPlugPrefab@ prefab, uint ix) {
        prefab.Ents[ix].Location.Trans = vec3(0, 0, 0);
        prefab.Ents[ix].Location.Quat = quat(1, 0, 0, 0);
    }
    void SetRocketLocation(CPlugPrefab@ prefab, uint ix) {
        prefab.Ents[ix].Location.Trans = vec3(0, -8, 0);
        prefab.Ents[ix].Location.Quat = quat(1, 0, 0, 0);
    }

    uint launchDuraiton = 2500;
    uint starDuration = 5000;
    uint downtime = 1000;
    uint totalDuration = launchDuraiton + starDuration + downtime;

    void SetRocketAnim(CPlugPrefab@ prefab, uint ix) {
        auto kc = cast<NPlugDyna_SKinematicConstraint>(prefab.Ents[ix].Model);
        auto ents = Dev::GetOffsetNod(prefab, GetOffset("CPlugPrefab", "Ents"));

        auto ptr1 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params"));
        auto ptr2 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params") + 0x8);

        if (ptr2 > 0 && ptr2 % 8 == 0) {
            auto type = Dev::ReadCString(Dev::ReadUInt64(ptr2));
            auto clsId = Dev::ReadUInt32(ptr2 + 0x10);
            if (clsId == 0x2f0c8000 || type == "NPlugDyna::SPrefabConstraintParams") {
                Dev::Write(ptr1 + 0x4, 0);
            } else {
                warn("got wrong params classid " + clsId + "; ix: " + ix);
            }
        } else {
            warn('params ptr null but expected it ' + ix);
        }

        kc.AngleMaxDeg = 360;
        kc.AngleMinDeg = 0;
        kc.RotAxis = EAxis::y;
        kc.TransAxis = EAxis::y;
        kc.TransMin = 0;
        kc.TransMax = fireworkHeight;

        while (SAnimFunc_GetLength(kc, transAnimFuncOffset) < 4) {
            SAnimFunc_IncrementEasingCountSetDefaults(kc, transAnimFuncOffset);
        }
        while (SAnimFunc_GetLength(kc, rotAnimFuncOffset) < 4) {
            SAnimFunc_IncrementEasingCountSetDefaults(kc, rotAnimFuncOffset);
        }
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 0, SubFuncEasings::QuadOut, false, launchDuraiton);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 1, SubFuncEasings::None, false, starDuration);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 2, SubFuncEasings::None, false, downtime);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 3, SubFuncEasings::None, false, 0);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 0, SubFuncEasings::QuadOut, false, launchDuraiton);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 1, SubFuncEasings::None, false, starDuration);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 2, SubFuncEasings::None, false, downtime);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 3, SubFuncEasings::None, false, 0);
    }

    void SetStarProps(CPlugPrefab@ prefab, uint ix, float d) {
        float alpha = Math::Rand(-Math::PI, Math::PI);
        float gradient = Math::Rand(-Math::PI/2., Math::PI/2.);
        mat4 starMat = mat4::Identity()
            * mat4::Translate(vec3(0, fireworkHeight, 0))
            * mat4::Rotate(alpha, vec3(0,1,0))
            * mat4::Rotate(gradient, vec3(1,0,0))
            // * mat4::Translate(vec3(0, 0, d));
            ;
        prefab.Ents[ix].Location.Trans = (starMat * vec3()).xyz;
        prefab.Ents[ix].Location.Quat = quat(starMat);
    }
    // void

    void SetStarAnim(CPlugPrefab@ prefab, uint ix, uint kinEntId, float d) {

        auto kc = cast<NPlugDyna_SKinematicConstraint>(prefab.Ents[ix].Model);
        auto ents = Dev::GetOffsetNod(prefab, GetOffset("CPlugPrefab", "Ents"));

        auto ptr1 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params"));
        auto ptr2 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params") + 0x8);

        if (ptr2 > 0 && ptr2 % 8 == 0) {
            auto type = Dev::ReadCString(Dev::ReadUInt64(ptr2));
            auto clsId = Dev::ReadUInt32(ptr2 + 0x10);
            if (clsId == 0x2f0c8000 || type == "NPlugDyna::SPrefabConstraintParams") {
                Dev::Write(ptr1 + 0x4, kinEntId);
            } else {
                warn("got wrong params classid " + clsId + "; ix: " + ix);
            }
        } else {
            warn('params ptr null but expected it ' + ix);
        }

        kc.AngleMaxDeg = 360 + Math::Rand(0, 720);
        kc.AngleMinDeg = -360;
        kc.RotAxis = EAxis::y;
        kc.TransAxis = EAxis::z;
        kc.TransMin = 0;
        kc.TransMax = d;

        int randDeviation = int(Math::Rand(-500., 500.));

        ExpandKCToMaxAnimFuncs(kc);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 0, SubFuncEasings::None, false, launchDuraiton);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 1, SubFuncEasings::QuadOut, false, starDuration - randDeviation);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 2, SubFuncEasings::None, false, downtime + randDeviation);
        SAnimFunc_SetIx(kc, transAnimFuncOffset, 3, SubFuncEasings::None, false, 0);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 0, SubFuncEasings::None, false, launchDuraiton);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 1, SubFuncEasings::QuadOut, false, starDuration - randDeviation);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 2, SubFuncEasings::None, false, downtime + randDeviation);
        SAnimFunc_SetIx(kc, rotAnimFuncOffset, 3, SubFuncEasings::None, false, 0);
    }

    void DedupStarEntities() {
        auto ieditor = cast<CGameEditorItem>(GetApp().Editor);
        auto model = ieditor.ItemModel;
        auto prefab = cast<CPlugPrefab>(model.EntityModel);
        auto firstDyna = cast<CPlugDynaObjectModel>(prefab.Ents[0].Model);
        if (firstDyna is null) throw('null first dyna');
        for (uint i = 1; i < prefab.Ents.Length; i += 1) {
            auto dyna = cast<CPlugDynaObjectModel>(prefab.Ents[i].Model);
            if (dyna is null) continue;
            // create a new one
            @dyna = CPlugDynaObjectModel();
            dyna.MwAddRef();
            MeshDuplication::SetEntRefModel(prefab, i, dyna);
            ManipPtrs::Replace(dyna, GetOffset(dyna, "Mesh"), firstDyna.Mesh, true);
            ManipPtrs::Replace(dyna, GetOffset(dyna, "DynaShape"), firstDyna.DynaShape, true);
            ManipPtrs::Replace(dyna, GetOffset(dyna, "StaticShape"), firstDyna.StaticShape, true);
            if (dyna.Mesh !is null) dyna.Mesh.MwAddRef();
            if (dyna.DynaShape !is null) dyna.DynaShape.MwAddRef();
            if (dyna.StaticShape !is null) dyna.StaticShape.MwAddRef();
        }
    }
}



void SetKinConTargetIx(CPlugPrefab@ prefab, uint ix, uint kinEntId) {
    auto ents = Dev::GetOffsetNod(prefab, GetOffset("CPlugPrefab", "Ents"));

    auto ptr1 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params"));
    auto ptr2 = Dev::GetOffsetUint64(ents, SZ_ENT_REF * ix + GetOffset("NPlugPrefab_SEntRef", "Params") + 0x8);

    if (ptr2 > 0 && ptr2 % 8 == 0) {
        auto type = Dev::ReadCString(Dev::ReadUInt64(ptr2));
        auto clsId = Dev::ReadUInt32(ptr2 + 0x10);
        if (clsId == 0x2f0c8000 || type == "NPlugDyna::SPrefabConstraintParams") {
            Dev::Write(ptr1 + 0x4, kinEntId);
        } else {
            warn("got wrong params classid " + clsId + "; ix: " + ix);
        }
    } else {
        warn('params ptr null but expected it ' + ix);
        }
}

void ExpandKCToMaxAnimFuncs(NPlugDyna_SKinematicConstraint@ kc) {
    while (SAnimFunc_GetLength(kc, transAnimFuncOffset) < 4) {
        SAnimFunc_IncrementEasingCountSetDefaults(kc, transAnimFuncOffset);
    }
    while (SAnimFunc_GetLength(kc, rotAnimFuncOffset) < 4) {
        SAnimFunc_IncrementEasingCountSetDefaults(kc, rotAnimFuncOffset);
    }
}

// CPlugDynaObject is 264 bytes long
void CloneDynaObjects() {
    // auto x = CPlugDynaObjectModel();

}


#endif
