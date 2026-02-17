class ItemCard extends MovieClip
{
	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = ItemCard.SKYUI_VERSION_MAJOR + "." + ItemCard.SKYUI_VERSION_MINOR + " SE";

	var ActiveEffectTimeValue;
	var ApparelArmorValue;
	var ApparelEnchantedLabel;
	var BookDescriptionLabel;
	var EnchantmentLabel;
	var ItemName;
	var ItemText;
	var ItemValueText;
	var ItemWeightText;
	var MagicCostLabel;
	var MagicCostPerSec;
	var MagicCostTimeLabel;
	var MagicCostTimeValue;
	var MagicCostValue;
	var MagicEffectsLabel;
	var MessageText;
	var PotionsLabel;
	var SecsText;
	var ShoutCostValue;
	var ShoutEffectsLabel;
	var SkillLevelText;
	var SkillTextInstance;
	var SliderValueText;
	var SoulLevel;
	var StolenTextInstance;
	var TotalChargesValue;
	var WeaponDamageValue;
	var WeaponEnchantedLabel;

	var ButtonRect;
	var ButtonRect_mc;
	var CardList_mc;
	var ChargeMeter_Default;
	var ChargeMeter_Enchantment;
	var ChargeMeter_SoulGem;
	var ChargeMeter_Weapon;
	var EnchantingSlider_mc;
	var Enchanting_Background;
	var Enchanting_Slim_Background;
	var ItemList;
	var ListChargeMeter;
	var PoisonInstance;
	var PrevFocus;
	var QuantitySlider_mc;
	var WeaponChargeMeter;

	var InputHandler;
	var dispatchEvent;

	var ItemCardMeters;
	var LastUpdateObj;

	var _bEditNameMode;
	var bFadedIn;


	function ItemCard()
	{
		super();
		Shared.GlobalFunc.MaintainTextFormat();
		Shared.GlobalFunc.AddReverseFunctions();
		gfx.events.EventDispatcher.initialize(this);
		QuantitySlider_mc = QuantitySlider_mc;
		ButtonRect_mc = ButtonRect;
		ItemList = CardList_mc.List_mc;
		SetupItemName();
		bFadedIn = false;
		InputHandler = undefined;
		_bEditNameMode = false;
	}

	function get bEditNameMode()
	{
		return _bEditNameMode;
	}

	function GetItemName()
	{
		return ItemName;
	}

	function SetupItemName(aPrevName)
	{
		ItemName = ItemText.ItemTextField;
		if (ItemName != undefined) {
			ItemName.textAutoSize = "shrink";
			ItemName.htmlText = aPrevName;
			ItemName.selectable = false;
		}
	}

	function onLoad()
	{
		QuantitySlider_mc.addEventListener("change", this, "onSliderChange");
		ButtonRect_mc.AcceptMouseButton.addEventListener("click", this, "onAcceptMouseClick");
		ButtonRect_mc.CancelMouseButton.addEventListener("click", this, "onCancelMouseClick");
		ButtonRect_mc.AcceptMouseButton.SetPlatform(0, false);
		ButtonRect_mc.CancelMouseButton.SetPlatform(0, false);
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		ButtonRect_mc.AcceptGamepadButton._visible = aiPlatform != 0;
		ButtonRect_mc.CancelGamepadButton._visible = aiPlatform != 0;
		ButtonRect_mc.AcceptMouseButton._visible = aiPlatform == 0;
		ButtonRect_mc.CancelMouseButton._visible = aiPlatform == 0;
		if (aiPlatform != 0) {
			ButtonRect_mc.AcceptGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
			ButtonRect_mc.CancelGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
		}
		ItemList.SetPlatform(aiPlatform, abPS3Switch);
	}

	function onAcceptMouseClick()
	{
		if (ButtonRect_mc._alpha == 100 && ButtonRect_mc.AcceptMouseButton._visible == true && InputHandler != undefined) {
			var inputEnterObj = {value: "keyDown", navEquivalent: gfx.ui.NavigationCode.ENTER};
			InputHandler(inputEnterObj);
		}
	}

	function onCancelMouseClick()
	{
		if (ButtonRect_mc._alpha == 100 && ButtonRect_mc.CancelMouseButton._visible == true && InputHandler != undefined) {
			var inputTabObj = {value: "keyDown", navEquivalent: gfx.ui.NavigationCode.TAB};
			InputHandler(inputTabObj);
		}
	}

	function FadeInCard()
	{
		if (bFadedIn)
			return;
		_visible = true;
		_parent.gotoAndPlay("fadeIn");
		bFadedIn = true;
	}

	function FadeOutCard()
	{
		if (bFadedIn) {
			_parent.gotoAndPlay("fadeOut");
			bFadedIn = false;
		}
	}

	function get quantitySlider()
	{
		return QuantitySlider_mc;
	}

	function get weaponChargeMeter()
	{
		return ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON];
	}

	function get itemInfo()
	{
		return LastUpdateObj;
	}

	function set itemInfo(aUpdateObj)
	{
		ItemCardMeters = new Array();
		var strItemNameHtml = ItemName != undefined ? ItemName.htmlText : "";
		var iItemType = aUpdateObj.type;
		var strIsPoisoned;
		var bCastTime;
		var i;
		var iLastWord;
		var strDragonWord;
		var strWord;
		var bWordKnown;
		var iEffectTimeRemaining;
		switch (iItemType)
		{
			case skyui.defines.Inventory.ICT_ARMOR:
				if (aUpdateObj.effects.length == 0) {
					gotoAndStop("Apparel_reg");
				} else {
					gotoAndStop("Apparel_Enchanted");
				}
				ApparelArmorValue.textAutoSize = "shrink";
				ApparelArmorValue.SetText(aUpdateObj.armor);
				ApparelEnchantedLabel.textAutoSize = "shrink";
				ApparelEnchantedLabel.htmlText = aUpdateObj.effects;
				SkillTextInstance.text = aUpdateObj.skillText;
				break;

			case skyui.defines.Inventory.ICT_WEAPON:
				if (aUpdateObj.effects.length == 0) {
					gotoAndStop("Weapons_reg");
				} else {
					gotoAndStop("Weapons_Enchanted");
					if (ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] == undefined) {
						ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(WeaponChargeMeter.MeterInstance);
					}
					if (aUpdateObj.usedCharge != undefined && aUpdateObj.charge != undefined) {
						ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
						ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetDeltaPercent(aUpdateObj.charge);
						WeaponChargeMeter._visible = true;
					} else {
						WeaponChargeMeter._visible = false;
					}
				}
				strIsPoisoned = aUpdateObj.poisoned != true ? "Off" : "On";
				PoisonInstance.gotoAndStop(strIsPoisoned);
				WeaponDamageValue.textAutoSize = "shrink";
				WeaponDamageValue.SetText(aUpdateObj.damage);
				WeaponEnchantedLabel.textAutoSize = "shrink";
				WeaponEnchantedLabel.htmlText = aUpdateObj.effects;
				break;

			case skyui.defines.Inventory.ICT_BOOK:
				if (aUpdateObj.description != undefined && aUpdateObj.description != "") {
					gotoAndStop("Books_Description");
					BookDescriptionLabel.SetText(aUpdateObj.description);
					break;
				}
				gotoAndStop("Books_reg");
				break;

			case skyui.defines.Inventory.ICT_POTION:
				gotoAndStop("Potions_reg");
				PotionsLabel.textAutoSize = "shrink";
				PotionsLabel.htmlText = aUpdateObj.effects;
				SkillTextInstance.text = aUpdateObj.skillName != undefined ? aUpdateObj.skillName : "";
				break;

			case skyui.defines.Inventory.ICT_FOOD:
				gotoAndStop("Potions_reg");
				PotionsLabel.textAutoSize = "shrink";
				PotionsLabel.htmlText = aUpdateObj.effects;
				SkillTextInstance.text = aUpdateObj.skillName != undefined ? aUpdateObj.skillName : "";
				break;

			case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
				gotoAndStop("Power_reg");
				MagicEffectsLabel.SetText(aUpdateObj.effects, true);
				MagicEffectsLabel.textAutoSize = "shrink";
				if (aUpdateObj.spellCost <= 0) {
					MagicCostValue._alpha = 0;
					MagicCostTimeValue._alpha = 0;
					MagicCostLabel._alpha = 0;
					MagicCostTimeLabel._alpha = 0;
					MagicCostPerSec._alpha = 0;
					break;
				}
				MagicCostValue._alpha = 100;
				MagicCostLabel._alpha = 100;
				MagicCostValue.text = aUpdateObj.spellCost.toString();
				break;

			case skyui.defines.Inventory.ICT_SPELL:
				bCastTime = aUpdateObj.castTime == 0;
				if (bCastTime) {
					gotoAndStop("Magic_time_label");
				} else {
					gotoAndStop("Magic_reg");
				}
				SkillLevelText.text = aUpdateObj.castLevel.toString();
				MagicEffectsLabel.SetText(aUpdateObj.effects, true);
				MagicEffectsLabel.textAutoSize = "shrink";
				MagicCostValue.textAutoSize = "shrink";
				MagicCostTimeValue.textAutoSize = "shrink";
				if (bCastTime) {
					MagicCostTimeValue.text = aUpdateObj.spellCost.toString();
					break;
				}
				MagicCostValue.text = aUpdateObj.spellCost.toString();
				break;

			case skyui.defines.Inventory.ICT_INGREDIENT:
				gotoAndStop("Ingredients_reg");
				i = 0;
				while (i < 4) {
					this["EffectLabel" + i].textAutoSize = "shrink";
					if (aUpdateObj["itemEffect" + i] != undefined && aUpdateObj["itemEffect" + i] != "") {
						this["EffectLabel" + i].textColor = 16777215;
						this["EffectLabel" + i].SetText(aUpdateObj["itemEffect" + i]);
					} else if (i < aUpdateObj.numItemEffects) {
						this["EffectLabel" + i].textColor = 10066329;
						this["EffectLabel" + i].SetText("$UNKNOWN");
					} else {
						this["EffectLabel" + i].SetText("");
					}
					i += 1;
				}
				break;

			case skyui.defines.Inventory.ICT_MISC:
				gotoAndStop("Misc_reg");
				break;

			case skyui.defines.Inventory.ICT_SHOUT:
				gotoAndStop("Shouts_reg");
				iLastWord = 0;
				i = 0;
				while (i < 3) {
					if (aUpdateObj["word" + i] != undefined && aUpdateObj["word" + i] != "" && aUpdateObj["unlocked" + i] == true) {
						iLastWord = i;
					}
					i += 1;
				}
				i = 0;
				while (i < 3) {
					strDragonWord = aUpdateObj["dragonWord" + i] != undefined ? aUpdateObj["dragonWord" + i] : "";
					strWord = aUpdateObj["word" + i] != undefined ? aUpdateObj["word" + i] : "";
					bWordKnown = aUpdateObj["unlocked" + i] == true;
					this["ShoutTextInstance" + i].DragonShoutLabelInstance.ShoutWordsLabel.textAutoSize = "shrink";
					this["ShoutTextInstance" + i].ShoutLabelInstance.ShoutWordsLabelTranslation.textAutoSize = "shrink";
					this["ShoutTextInstance" + i].DragonShoutLabelInstance.ShoutWordsLabel.SetText(strDragonWord.toUpperCase());
					this["ShoutTextInstance" + i].ShoutLabelInstance.ShoutWordsLabelTranslation.SetText(strWord);
					if (bWordKnown && i == iLastWord && LastUpdateObj.soulSpent == true) {
						this["ShoutTextInstance" + i].gotoAndPlay("Learn");
					} else if (bWordKnown) {
						this["ShoutTextInstance" + i].gotoAndStop("Known");
						this["ShoutTextInstance" + i].gotoAndStop("Known");
					} else {
						this["ShoutTextInstance" + i].gotoAndStop("Unlocked");
						this["ShoutTextInstance" + i].gotoAndStop("Unlocked");
					}
					i += 1;
				}
				ShoutEffectsLabel.htmlText = aUpdateObj.effects;
				ShoutCostValue.text = aUpdateObj.spellCost.toString();
				break;

			case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
				gotoAndStop("ActiveEffects");
				MagicEffectsLabel.html = true;
				MagicEffectsLabel.SetText(aUpdateObj.effects, true);
				MagicEffectsLabel.textAutoSize = "shrink";
				if (aUpdateObj.timeRemaining > 0) {
					iEffectTimeRemaining = Math.floor(aUpdateObj.timeRemaining);
					ActiveEffectTimeValue._alpha = 100;
					SecsText._alpha = 100;
					if (iEffectTimeRemaining >= 3600) {
						iEffectTimeRemaining = Math.floor(iEffectTimeRemaining / 3600);
						ActiveEffectTimeValue.text = iEffectTimeRemaining.toString();
						if (iEffectTimeRemaining == 1) {
							SecsText.text = "$hour";
							break;
						}
						SecsText.text = "$hours";
						break;
					}
					if (iEffectTimeRemaining >= 60) {
						iEffectTimeRemaining = Math.floor(iEffectTimeRemaining / 60);
						ActiveEffectTimeValue.text = iEffectTimeRemaining.toString();
						if (iEffectTimeRemaining == 1) {
							SecsText.text = "$min";
							break;
						}
						SecsText.text = "$mins";
						break;
					}
					ActiveEffectTimeValue.text = iEffectTimeRemaining.toString();
					if (iEffectTimeRemaining == 1) {
						SecsText.text = "$sec";
						break;
					}
					SecsText.text = "$secs";
					break;
				}
				ActiveEffectTimeValue._alpha = 0;
				SecsText._alpha = 0;
				break;

			case skyui.defines.Inventory.ICT_SOUL_GEMS:
				gotoAndStop("SoulGem");
				SoulLevel.text = aUpdateObj.soulLVL;
				break;

			case skyui.defines.Inventory.ICT_LIST:
				gotoAndStop("Item_list");
				if (aUpdateObj.listItems != undefined) {
					ItemList.entryList = aUpdateObj.listItems;
					ItemList.InvalidateData();
					ItemCardMeters[skyui.defines.Inventory.ICT_LIST] = new Components.DeltaMeter(ListChargeMeter.MeterInstance);
					ItemCardMeters[skyui.defines.Inventory.ICT_LIST].SetPercent(aUpdateObj.currentCharge);
					ItemCardMeters[skyui.defines.Inventory.ICT_LIST].SetDeltaPercent(aUpdateObj.currentCharge + ItemList.selectedEntry.chargeAdded);
					OpenListMenu();
				}
				break;

			case skyui.defines.Inventory.ICT_CRAFT_ENCHANTING:
			case skyui.defines.Inventory.ICT_HOUSE_PART:
				if (aUpdateObj.type == skyui.defines.Inventory.ICT_HOUSE_PART) {
					gotoAndStop("Magic_short");
					if (aUpdateObj.effects == undefined) {
						MagicEffectsLabel.SetText("", true);
					} else {
						MagicEffectsLabel.SetText(aUpdateObj.effects, true);
					}
				} else if (aUpdateObj.sliderShown == true) {
					gotoAndStop("Craft_Enchanting");
					ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(ChargeMeter_Default.MeterInstance);
					if (aUpdateObj.totalCharges != undefined && aUpdateObj.totalCharges != 0) {
						TotalChargesValue.text = aUpdateObj.totalCharges;
					}
				} else if (aUpdateObj.damage == undefined) {
					if (aUpdateObj.armor == undefined) {
						if (aUpdateObj.soulLVL == undefined) {
							if (QuantitySlider_mc._alpha == 0) {
								gotoAndStop("Craft_Enchanting_Enchantment");
								ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(ChargeMeter_Enchantment.MeterInstance);
							}
						} else {
							gotoAndStop("Craft_Enchanting_SoulGem");
							ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(ChargeMeter_SoulGem.MeterInstance);
							SoulLevel.text = aUpdateObj.soulLVL;
						}
					} else {
						gotoAndStop("Craft_Enchanting_Armor");
						ApparelArmorValue.SetText(aUpdateObj.armor);
						SkillTextInstance.text = aUpdateObj.skillText;
					}
				} else {
					gotoAndStop("Craft_Enchanting_Weapon");
					ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(ChargeMeter_Weapon.MeterInstance);
					WeaponDamageValue.textAutoSize = "shrink";
					WeaponDamageValue.SetText(aUpdateObj.damage);
				}
				if (aUpdateObj.usedCharge == 0 && aUpdateObj.totalCharges == 0) {
					ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].DeltaMeterMovieClip._parent._parent._alpha = 0;
				} else if (aUpdateObj.usedCharge != undefined) {
					ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
				}
				if (aUpdateObj.effects != undefined && aUpdateObj.effects.length > 0) {
					if (EnchantmentLabel != undefined) {
						EnchantmentLabel.SetText(aUpdateObj.effects, true);
					}
					EnchantmentLabel.textAutoSize = "shrink";
					WeaponChargeMeter._alpha = 100;
					Enchanting_Background._alpha = 60;
					Enchanting_Slim_Background._alpha = 0;
					break;
				}
				if (EnchantmentLabel != undefined) {
					EnchantmentLabel.SetText("", true);
				}
				WeaponChargeMeter._alpha = 0;
				Enchanting_Slim_Background._alpha = 60;
				Enchanting_Background._alpha = 0;
				break;

			case skyui.defines.Inventory.ICT_KEY:
			case skyui.defines.Inventory.ICT_NONE:
			default:
				gotoAndStop("Empty");
		}

		SetupItemName(strItemNameHtml);
		var strItemName;
		if (aUpdateObj.name != undefined) {
			strItemName = !(aUpdateObj.count != undefined && aUpdateObj.count > 1) ? aUpdateObj.name : aUpdateObj.name + " (" + aUpdateObj.count + ")";
			ItemText.ItemTextField.SetText(_bEditNameMode || aUpdateObj.upperCaseName == false ? strItemName : strItemName.toUpperCase(), false);
			ItemText.ItemTextField.textColor = aUpdateObj.negativeEffect != true ? 16777215 : 16711680;
		}
		ItemValueText.textAutoSize = "shrink";
		ItemWeightText.textAutoSize = "shrink";
		if (aUpdateObj.value != undefined && ItemValueText != undefined) {
			ItemValueText.SetText(aUpdateObj.value.toString());
		}
		if (aUpdateObj.weight != undefined && ItemWeightText != undefined) {
			ItemWeightText.SetText(RoundDecimal(aUpdateObj.weight, 2).toString());
		}
		StolenTextInstance._visible = aUpdateObj.stolen == true;
		LastUpdateObj = aUpdateObj;
	}

	function RoundDecimal(aNumber, aPrecision)
	{
		var significantFigures = Math.pow(10, aPrecision);
		return Math.round(significantFigures * aNumber) / significantFigures;
	}

	function PrepareInputElements(aActiveClip)
	{
		var iQuantitySlider_yOffset = 92;
		var iCardList_yOffset = 98;
		var iEnchantingSlider_yOffset = 147.3;
		var iButtonRect_iOffset = 130;
		var iButtonRect_iOffsetEnchanting = 166;
		switch (aActiveClip)
		{
			case EnchantingSlider_mc:
				QuantitySlider_mc._y = -100;
				ButtonRect._y = iButtonRect_iOffsetEnchanting;
				EnchantingSlider_mc._y = iEnchantingSlider_yOffset;
				CardList_mc._y = -100;
				QuantitySlider_mc._alpha = 0;
				ButtonRect._alpha = 100;
				EnchantingSlider_mc._alpha = 100;
				CardList_mc._alpha = 0;
				break;

			case QuantitySlider_mc:
				QuantitySlider_mc._y = iQuantitySlider_yOffset;
				ButtonRect._y = iButtonRect_iOffset;
				EnchantingSlider_mc._y = -100;
				CardList_mc._y = -100;
				QuantitySlider_mc._alpha = 100;
				ButtonRect._alpha = 100;
				EnchantingSlider_mc._alpha = 0;
				CardList_mc._alpha = 0;
				break;

			case CardList_mc:
				QuantitySlider_mc._y = -100;
				ButtonRect._y = -100;
				EnchantingSlider_mc._y = -100;
				CardList_mc._y = iCardList_yOffset;
				QuantitySlider_mc._alpha = 0;
				ButtonRect._alpha = 0;
				EnchantingSlider_mc._alpha = 0;
				CardList_mc._alpha = 100;
				break;

			case ButtonRect:
				QuantitySlider_mc._y = -100;
				ButtonRect._y = iButtonRect_iOffset;
				EnchantingSlider_mc._y = -100;
				CardList_mc._y = -100;
				QuantitySlider_mc._alpha = 0;
				ButtonRect._alpha = 100;
				EnchantingSlider_mc._alpha = 0;
				CardList_mc._alpha = 0;
			default:
				return;
		}
	}

	function ShowEnchantingSlider(aiMaxValue, aiMinValue, aiCurrentValue)
	{
		gotoAndStop("Craft_Enchanting");
		QuantitySlider_mc = EnchantingSlider_mc;
		QuantitySlider_mc.addEventListener("change", this, "onSliderChange");
		PrepareInputElements(EnchantingSlider_mc);
		QuantitySlider_mc.maximum = aiMaxValue;
		QuantitySlider_mc.minimum = aiMinValue;
		QuantitySlider_mc.value = aiCurrentValue;
		PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
		gfx.managers.FocusHandler.instance.setFocus(QuantitySlider_mc, 0);
		InputHandler = HandleQuantityMenuInput;
		dispatchEvent({type: "subMenuAction", opening: true, menu: "quantity"});
	}

	function ShowQuantityMenu(aiMaxAmount)
	{
		gotoAndStop("Quantity");
		PrepareInputElements(QuantitySlider_mc);
		QuantitySlider_mc.maximum = aiMaxAmount;
		QuantitySlider_mc.value = aiMaxAmount;
		SliderValueText.textAutoSize = "shrink";
		SliderValueText.SetText(Math.floor(QuantitySlider_mc.value).toString());
		PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
		gfx.managers.FocusHandler.instance.setFocus(QuantitySlider_mc, 0);
		InputHandler = HandleQuantityMenuInput;
		dispatchEvent({type: "subMenuAction", opening: true, menu: "quantity"});
	}

	function HideQuantityMenu(abCanceled)
	{
		gfx.managers.FocusHandler.instance.setFocus(PrevFocus, 0);
		QuantitySlider_mc._alpha = 0;
		ButtonRect_mc._alpha = 0;
		InputHandler = undefined;
		dispatchEvent({type: "subMenuAction", opening: false, canceled: abCanceled, menu: "quantity"});
	}

	function OpenListMenu()
	{
		PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
		gfx.managers.FocusHandler.instance.setFocus(ItemList, 0);
		ItemList._visible = true;
		ItemList.addEventListener("itemPress", this, "onListItemPress");
		ItemList.addEventListener("listMovedUp", this, "onListSelectionChange");
		ItemList.addEventListener("listMovedDown", this, "onListSelectionChange");
		ItemList.addEventListener("selectionChange", this, "onListMouseSelectionChange");
		PrepareInputElements(CardList_mc);
		ListChargeMeter._alpha = 100;
		InputHandler = HandleListMenuInput;
		dispatchEvent({type: "subMenuAction", opening: true, menu: "list"});
	}

	function HideListMenu()
	{
		gfx.managers.FocusHandler.instance.setFocus(PrevFocus, 0);
		ListChargeMeter._alpha = 0;
		CardList_mc._alpha = 0;
		ItemCardMeters[skyui.defines.Inventory.ICT_LIST] = undefined;
		InputHandler = undefined;
		ItemList._visible = true;
		dispatchEvent({type: "subMenuAction", opening: false, menu: "list"});
	}

	function ShowConfirmMessage(astrMessage)
	{
		gotoAndStop("ConfirmMessage");
		PrepareInputElements(ButtonRect_mc);
		var messageArray = astrMessage.split("\r\n");
		var strMessageText = messageArray.join("\n");
		MessageText.SetText(strMessageText);
		PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
		gfx.managers.FocusHandler.instance.setFocus(this, 0);
		InputHandler = HandleConfirmMessageInput;
		dispatchEvent({type: "subMenuAction", opening: true, menu: "message"});
	}

	function HideConfirmMessage()
	{
		gfx.managers.FocusHandler.instance.setFocus(PrevFocus, 0);
		ButtonRect_mc._alpha = 0;
		InputHandler = undefined;
		dispatchEvent({type: "subMenuAction", opening: false, menu: "message"});
	}

	function StartEditName(aInitialText, aiMaxChars)
	{
		if (Selection.getFocus() != ItemName) {
			PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
			if (aInitialText != undefined) {
				ItemName.text = aInitialText;
			}
			ItemName.type = "input";
			ItemName.noTranslate = true;
			ItemName.selectable = true;
			ItemName.maxChars = aiMaxChars != undefined ? aiMaxChars : null;
			Selection.setFocus(ItemName, 0);
			Selection.setSelection(0, 0);
			InputHandler = HandleEditNameInput;
			dispatchEvent({type: "subMenuAction", opening: true, menu: "editName"});
			_bEditNameMode = true;
		}
	}

	function EndEditName()
	{
		ItemName.type = "dynamic";
		ItemName.noTranslate = false;
		ItemName.selectable = false;
		ItemName.maxChars = null;
		var bPreviousFocusEnabled = PrevFocus.focusEnabled;
		PrevFocus.focusEnabled = true;
		Selection.setFocus(PrevFocus, 0);
		PrevFocus.focusEnabled = bPreviousFocusEnabled;
		InputHandler = undefined;
		dispatchEvent({type: "subMenuAction", opening: false, menu: "editName"});
		_bEditNameMode = false;
	}

	function handleInput(details, pathToFocus)
	{
		var bHandledInput = false;
		if (pathToFocus.length > 0 && pathToFocus[0].handleInput != undefined) {
			pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		if (InputHandler != undefined) {
			bHandledInput = InputHandler(details);
		}
		return bHandledInput;
	}

	function HandleQuantityMenuInput(details)
	{
		var bValidKeyPressed = false;
		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
				HideQuantityMenu(false);
				if (QuantitySlider_mc.value > 0) {
					dispatchEvent({type: "quantitySelect", amount: Math.floor(QuantitySlider_mc.value)});
				} else {
					itemInfo = LastUpdateObj;
				}
				bValidKeyPressed = true;
			} else if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
				HideQuantityMenu(true);
				itemInfo = LastUpdateObj;
				bValidKeyPressed = true;
			}
		}
		return bValidKeyPressed;
	}

	function HandleListMenuInput(details)
	{
		var bValidKeyPressed = false;
		if (Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == gfx.ui.NavigationCode.TAB) {
			HideListMenu();
			bValidKeyPressed = true;
		}
		return bValidKeyPressed;
	}

	function HandleConfirmMessageInput(details)
	{
		var bValidKeyPressed = false;
		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
				HideConfirmMessage();
				dispatchEvent({type: "messageConfirm"});
				bValidKeyPressed = true;
			} else if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
				HideConfirmMessage();
				dispatchEvent({type: "messageCancel"});
				itemInfo = LastUpdateObj;
				bValidKeyPressed = true;
			}
		}
		return bValidKeyPressed;
	}

	function HandleEditNameInput(details)
	{
		Selection.setFocus(ItemName, 0);
		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.ENTER && details.code != 32) {
				dispatchEvent({type: "endEditItemName", useNewName: true, newName: ItemName.text});
			} else if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
				dispatchEvent({type: "endEditItemName", useNewName: false, newName: ""});
			}
		}
		return true;
	}

	function onSliderChange()
	{
		var currentValue_tf = EnchantingSlider_mc._alpha > 0 ? TotalChargesValue : SliderValueText;
		var iCurrentValue = Number(currentValue_tf.text);
		var iNewValue = Math.floor(QuantitySlider_mc.value);
		if (iCurrentValue != iNewValue) {
			currentValue_tf.SetText(iNewValue.toString());
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
			dispatchEvent({type: "sliderChange", value: iNewValue});
		}
	}

	function onListItemPress(event)
	{
		dispatchEvent(event);
		HideListMenu();
	}

	function onListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0) {
			onListSelectionChange(event);
		}
	}

	function onListSelectionChange(event)
	{
		ItemCardMeters[skyui.defines.Inventory.ICT_LIST].SetDeltaPercent(ItemList.selectedEntry.chargeAdded + LastUpdateObj.currentCharge);
	}
}
