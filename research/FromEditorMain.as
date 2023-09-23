namespace Editor {
    const uint16 offsetMouseDown = 0xBB8; // +4: right click, +8 duplicate left click
    const uint16 offsetPickMode = 0xBF0; // uint, = 0 place, 1 = ?, 2 = delete, 3 = pick, 4 = select?, mb more
    uint8 DeleteItemFromMap(CGameCtnEditorFree@ editor, CGameCtnAnchoredObject@ item) {
        //
        trace("DeleteItemFromMap");
        SetEditorPickedNod(editor, item);
        auto prevMode = Dev::GetOffsetUint8(editor, offsetPickMode);
        Dev::SetOffset(editor, offsetPickMode, 2);

        // Dev::SetOffset(editor, offsetMouseDown, 1);
        // Dev::SetOffset(editor, offsetMouseDown + 8, 1);
        // Dev::SetOffset(editor, offsetMouseDown - 8, GetApp().TimeSinceInitMs);

        // Dev::SetOffset(editor, 0xFE8, Dev::GetOffsetUint32(editor, 0xFE8) + 1);
        // Dev::SetOffset(editor, 0x1040, Dev::GetOffsetUint32(editor, 0x1040) + 1);
        // PatchEditorInput::P_MOUSE_INPUT_TEST.Apply();
        // PatchEditorInput::P_MOUSE_BUTTON_ONE_TEST.Apply();
        // PatchEditorInput::P_MOUSE_BUTTON_TYPE_TEST.Apply();
        // yield();
        // Dev::SetOffset(editor, offsetPickMode, prevMode);
        // PatchEditorInput::P_MOUSE_BUTTON_TYPE_TEST.Unapply();
        // PatchEditorInput::P_MOUSE_BUTTON_ONE_TEST.Unapply();
        // PatchEditorInput::P_MOUSE_INPUT_TEST.Unapply();

        // a64?
        // special memory:
        return prevMode;
    }

    enum MouseOperationMode {
        Place = 0,
        Delete = 2,
        Pick = 3,
        Select = 4
    }

    uint8 SetMouseOperationMode(CGameCtnEditorFree@ editor, MouseOperationMode mode) {
        auto prevMode = Dev::GetOffsetUint8(editor, offsetPickMode);
        Dev::SetOffset(editor, offsetPickMode, uint8(mode));
        return prevMode;
    }
}



/*

Trackmania.exe+10DAA50 - 40 53                 - push rbx
Trackmania.exe+10DAA52 - 48 81 EC 90000000     - sub rsp,00000090 { 144 }
Trackmania.exe+10DAA59 - 48 83 79 70 00        - cmp qword ptr [rcx+70],00 { 0 }
Trackmania.exe+10DAA5E - 48 8B D9              - mov rbx,rcx
Trackmania.exe+10DAA61 - 0F84 99010000         - je Trackmania.exe+10DAC00
Trackmania.exe+10DAA67 - 48 83 79 68 00        - cmp qword ptr [rcx+68],00 { 0 }
Trackmania.exe+10DAA6C - 0F84 8E010000         - je Trackmania.exe+10DAC00
Trackmania.exe+10DAA72 - 48 8D 15 8751B100     - lea rdx,[Trackmania.exe+1BEFC00] { ("CGameCtnEditor::InputEditor") }
Trackmania.exe+10DAA79 - C7 44 24 30 00000000  - mov [rsp+30],00000000 { 0 }
Trackmania.exe+10DAA81 - 48 8D 4C 24 20        - lea rcx,[rsp+20]
Trackmania.exe+10DAA86 - E8 C5 B6 02FF           - call Trackmania.exe+106150
Trackmania.exe+10DAA8B - 83 BB 4C040000 00     - cmp dword ptr [rbx+0000044C],00 { 0 }
Trackmania.exe+10DAA92 - 74 7F                 - je Trackmania.exe+10DAB13
Trackmania.exe+10DAA94 - 83 BB C8010000 00     - cmp dword ptr [rbx+000001C8],00 { 0 }
Trackmania.exe+10DAA9B - 75 76                 - jne Trackmania.exe+10DAB13

*/

const string InputEditorPattern = "48 81 EC 90 00 00 00 48 83 79 70 00 48 8B D9 0F 84 99 01 00 00 48 83 79 68 00 0F 84 8E 01 00 00 48 8D 15 ?? ?? ?? ?? C7 44 24 30 00 00 00 00 48 8D 4C 24 20 E8 ?? ?? ?? ?? 83 BB 4C 04 00 00 00 74 7F 83 BB C8 01 00 00 00 75 76";
// padding 2 for hook
