class skyui.props.PropertyDataExtender implements skyui.components.list.IListProcessor
{
  /* PRIVATE VARIABLES */
    
    private var _propertyList;
    private var _iconList;
    private var _compoundPropertyList;

    private var _noIconColors: Boolean;
    
    
  /* PROPERTIES */

    public var propertiesVar: String;
    public var iconsVar: String;
    public var compoundPropVar: String;
    
  /* CONSTRUCTORS */
    
    public function PropertyDataExtender(a_configAppearance: Object, a_dataSource: Object, a_propertiesVar: String, a_iconsVar: String, a_compoundPropVar: String)
    {
        this.propertiesVar = a_propertiesVar;
        this.iconsVar = a_iconsVar;
        this.compoundPropVar = a_compoundPropVar;
        
        this._propertyList = new Array();
        this._iconList = new Array();
        this._compoundPropertyList = new Array();

        this._noIconColors = a_configAppearance.icons.item.noColor;
        
        var propertyLevel = "props";
        var compoundLevel = "compoundProps";
        
        // Set up our arrays with information from the config for use in ProcessConfigVars()
        if (this.propertiesVar) {
            var configProperties = a_dataSource[this.propertiesVar];
            if (configProperties instanceof Array) {
                for (var i = 0; i < configProperties.length; i++) {
                    var propName = configProperties[i];
                    var propertyData = a_dataSource[propertyLevel][propName];
                    var propLookup = new skyui.props.PropertyLookup(propertyData);
                    this._propertyList.push(propLookup);
                }
            }
        }
        
        if (this.iconsVar) {
            var configIcons = a_dataSource[this.iconsVar];
            if (configIcons instanceof Array) {
                for (var i = 0; i < configIcons.length; i++) {
                    var propName = configIcons[i];
                    var propertyData = a_dataSource[propertyLevel][propName];
                    var propLookup = new skyui.props.PropertyLookup(propertyData);
                    this._iconList.push(propLookup);
                }
            }
        }

        if (this.compoundPropVar) {
            var configCompoundList = a_dataSource[this.compoundPropVar];
            if (configCompoundList instanceof Array) {
                for (var i = 0; i < configCompoundList.length; i++) {
                    var propName = configCompoundList[i];
                    var propertyData = a_dataSource[compoundLevel][propName];
                    var compoundProperty = new skyui.props.CompoundProperty(propertyData);
                    this._compoundPropertyList.push(compoundProperty);
                }
            }
        }
    }
    
    
  /* PUBLIC FUNCTIONS */
    
    // @override IListProcessor
    public function processList(a_list: BasicList)
    {
        var entryList = a_list.entryList;
        
        for (var i = 0; i < entryList.length; i++)
            this.processEntry(entryList[i]);
    }
    
    
  /* PRIVATE FUNCTIONS */
    
    private function processEntry(a_entryObject: Object)
    {
        // Use the information from the arrays from the config to fill in additional info
        
        // Set properties based on other dataMembers and keywords
        // as defined in the config
        for (var i = 0; i < this._propertyList.length; i++)
            this._propertyList[i].processProperty(a_entryObject);

        // Set iconLabel, iconColor etc (run this even if skse not used)
        for (var i = 0; i < this._iconList.length; i++)
            this._iconList[i].processProperty(a_entryObject);
            
        // Process compound properties 
        // (concatenate several properties together, used for sorting)
        for (var i = 0; i < this._compoundPropertyList.length; i++)
            this._compoundPropertyList[i].processCompoundProperty(a_entryObject);	

        if (this._noIconColors && a_entryObject.iconColor != undefined)
            delete(a_entryObject.iconColor)
    }
}
