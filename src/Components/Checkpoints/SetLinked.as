class SetLinkedCheckpointsTab : Tab {
    SetLinkedCheckpointsTab(TabGroup@ parent) {
        super(parent, "Auto Linked Checkpoints", Icons::Link);
        RegisterNewItemCallback(ProcessItem(this.OnNewItem));
        RegisterNewBlockCallback(ProcessBlock(this.OnNewBlock));
    }

    protected bool active = false;

    bool OnNewItem(CGameCtnAnchoredObject@ item) {
        if (!active || item.WaypointSpecialProperty is null)
            return false;
        item.WaypointSpecialProperty.Order = m_order;
        if (m_linked) {
            item.WaypointSpecialProperty.LinkedCheckpointToggle();
        }
        return true;
    }

    bool OnNewBlock(CGameCtnBlock@ block) {
        if (!active || block.WaypointSpecialProperty is null)
            return false;
        block.WaypointSpecialProperty.Order = m_order;
        if (m_linked) {
            block.WaypointSpecialProperty.LinkedCheckpointToggle();
        }
        return true;
    }

    bool m_linked = false;
    uint m_order = 1;

    void DrawInner() override {
        active = UI::Checkbox("Set new CPs properties", active);
        UI::BeginDisabled(!active);
        m_linked = UI::Checkbox("Linked CP?", m_linked);
        m_order = UI::InputInt("CP Order", m_order);
        UI::EndDisabled();
    }
}