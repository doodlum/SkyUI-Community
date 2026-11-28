/*
 * Item card placement and the matching 3D item position, shared by the item menus (which place the card) and the HUD
 * (which applies the 3D item position before an item menu opens).
 *
 * The game draws the 3D item where the fInventory/Magic3DItemPos{X,Z}[Wide] INI settings say, and only reads them when
 * an item menu opens, before the menu's own code runs. The item menus set them as they place the card, which keeps
 * later opens right; the HUD computes the same values from config.txt, the MCM overrides and the screen whenever one of
 * those changes, so the next open is right too. Both use this class, so they cannot disagree.
 *
 * Coordinates are stage px of the item menus' 1280 x 720 stage ("showAll": visible area grows sideways on wider
 * screens and vertically on narrower ones). 3D item units: 1 unit = 8 px of a 1280 px wide visible area, measured from
 * the visible centre, +X left and +Z up (measured in game at 4:3, 16:9, 21:9 and 32:9).
 */
class skyui.util.ItemCardLayout
{
  /* CONSTANTS */

    public static var DEFAULT_ENTRY_WIDTH = 530;

    // Model centre above the card's top edge (stage px).
    public static var ITEM3D_GAP = 160;

    // Metrics of the stock SkyUI item menus (inventory list and item card), used until an item menu reports its own.
    // panel: list right edge + 25 px, from the visible left edge, at entryWidth 530; w: card width; xMin/xMax/yMin: card
    // bounds in its own space; y: card y before yOffset; safe: Stage.safeRect.x; ox/oy: stage position of the card's parent.
    public static var DEFAULT_METRICS = {panel: 582.45, w: 428.5, xMin: 0, xMax: 428.51, yMin: -24, y: 434.3, safe: 15, ox: 0, oy: 0,
                                         cardX: 0, cardY: -24};

    public static var INI_KEYS_X = ["fInventory3DItemPosX:Interface", "fInventory3DItemPosXWide:Interface",
                                    "fMagic3DItemPosX:Interface", "fMagic3DItemPosXWide:Interface"];
    public static var INI_KEYS_Z = ["fInventory3DItemPosZ:Interface", "fInventory3DItemPosZWide:Interface",
                                    "fMagic3DItemPosZ:Interface", "fMagic3DItemPosZWide:Interface"];


  /* PUBLIC FUNCTIONS */

    // Visible area of the item menus' stage for a screen aspect ratio (width / height).
    public static function visibleRectForAspect(a_aspect: Number)
    {
        if (isNaN(a_aspect) || a_aspect <= 0)
            a_aspect = 16 / 9;
        var w = 1280;
        var h = 720;
        if (a_aspect >= 1280 / 720)
            w = 720 * a_aspect;
        else
            h = 1280 / a_aspect;
        return {x: 640 - w / 2, y: 360 - h / 2, width: w, height: h};
    }

    // Item card settings as the item menus read them: entryWidth (> 0, else 530), align ("left", "right" or centre),
    // xOffset and yOffset (numbers, else 0).
    public static function cardSettings(a_entryWidth, a_align, a_xOffset, a_yOffset)
    {
        var e = Number(a_entryWidth);
        var xo = Number(a_xOffset);
        var yo = Number(a_yOffset);
        return {
            entryWidth: (e > 0) ? e : skyui.util.ItemCardLayout.DEFAULT_ENTRY_WIDTH,
            // Papyrus may hand the MCM value back with different case ("Right"): compare case-insensitively.
            align: String(a_align).toLowerCase(),
            xOffset: isNaN(xo) ? 0 : xo,
            yOffset: isNaN(yo) ? 0 : yo
        };
    }

    // Where the card goes: its x, y and scale in the item menu (whose coordinates are stage px), plus its visual centre
    // and top edge. a_panelEdge is the list's right edge + 25 px (the menu passes the live value; the HUD derives it).
    public static function placeCard(a_settings: Object, a_vr: Object, a_safe: Number, a_panelEdge: Number, a_m: Object)
    {
        var leftEdge = a_vr.x + a_safe;
        var rightEdge = a_vr.x + a_vr.width - a_safe;

        var scale = (rightEdge - a_panelEdge) / a_m.w;
        if (!(scale < 1))
            scale = 1;
        var w = a_m.w * scale;

        var x;
        if (a_settings.align == "left")
            x = a_panelEdge + a_safe + a_settings.xOffset;         // left of the free area (was panelEdge + leftEdge,
                                                                 // which put the card under the list on wide screens)
        else if (a_settings.align == "right")
            x = rightEdge - w + a_settings.xOffset;
        else
            x = a_panelEdge + a_settings.xOffset + (a_vr.x + a_vr.width - a_panelEdge - w) / 2;

        var y = a_m.y + a_settings.yOffset;

        return {
            x: x, y: y, scale: scale,
            centreX: x + scale * (a_m.xMin + a_m.xMax) / 2,
            top: y + scale * a_m.yMin
        };
    }

    // 3D item position for a card whose visual centre / top edge are (a_centreX, a_top) in stage px.
    public static function item3DPosition(a_centreX: Number, a_top: Number, a_vr: Object)
    {
        var unitPx = 8 * a_vr.width / 1280;
        return {
            x: -(a_centreX - (a_vr.x + a_vr.width / 2)) / unitPx,
            z: -((a_top - skyui.util.ItemCardLayout.ITEM3D_GAP) - (a_vr.y + a_vr.height / 2)) / unitPx
        };
    }

    // Full prediction (HUD): settings + screen + reported metrics -> 3D item position.
    public static function predictItem3D(a_settings: Object, a_vr: Object, a_m: Object)
    {
        var panelEdge = a_vr.x + a_m.panel + (a_settings.entryWidth - skyui.util.ItemCardLayout.DEFAULT_ENTRY_WIDTH);
        var card = skyui.util.ItemCardLayout.placeCard(a_settings, a_vr, a_m.safe, panelEdge, a_m);
        return skyui.util.ItemCardLayout.item3DPosition(card.centreX + a_m.ox, card.top + a_m.oy, a_vr);
    }

    // Whether all the 3D item position settings already hold a_pos (to within 0.01 units).
    public static function isApplied(a_pos)
    {
        if (_global.skse == undefined || _global.skse.GetINISetting == undefined)
            return false;
        for (var i = 0; i < skyui.util.ItemCardLayout.INI_KEYS_X.length; i++) {
            var x = Number(_global.skse.GetINISetting(skyui.util.ItemCardLayout.INI_KEYS_X[i]));
            var z = Number(_global.skse.GetINISetting(skyui.util.ItemCardLayout.INI_KEYS_Z[i]));
            if (!(Math.abs(x - a_pos.x) < 0.01) || !(Math.abs(z - a_pos.z) < 0.01))
                return false;
        }
        return true;
    }

    // The MCM / config.txt 3D item settings (ItemInfo.item3D.*): offsets from the automatic centre, in 3D item position
    // units, and whether SkyUI should leave the position alone (Disable Positioning, or a skin's own values).
    public static function item3DSettings(a_xOffset, a_yOffset, a_disabled)
    {
        var x = Number(a_xOffset);
        var z = Number(a_yOffset);
        return {
            x: isNaN(x) ? 0 : x,
            z: isNaN(z) ? 0 : z,
            disabled: (a_disabled == true || String(a_disabled).toLowerCase() == "true")
        };
    }

    public static function withOffsets(a_pos, a_item3D)
    {
        return {x: a_pos.x + a_item3D.x, z: a_pos.z + a_item3D.z};
    }

    // Writes the 3D item position for the inventory-type menus and the magic menu.
    public static function applyItem3D(a_pos: Object)
    {
        if (_global.skse == undefined || _global.skse.SetINISetting == undefined || isNaN(a_pos.x) || isNaN(a_pos.z))
            return false;
        for (var i = 0; i < skyui.util.ItemCardLayout.INI_KEYS_X.length; i++) {
            _global.skse.SetINISetting(skyui.util.ItemCardLayout.INI_KEYS_X[i], a_pos.x);
            _global.skse.SetINISetting(skyui.util.ItemCardLayout.INI_KEYS_Z[i], a_pos.z);
        }
        return true;
    }
}
