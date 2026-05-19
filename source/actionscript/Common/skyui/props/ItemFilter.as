// For now this is a just a simple associative array of required values
class skyui.props.ItemFilter
{	
    var reqs: Object;
    
    function ItemFilter(requirementsObj: Object)
    {
        this.setFromObject(requirementsObj);
    }
    
    function addRequirement(requiredProperty: String, requiredVal)
    {
        this.reqs[requiredProperty] = requiredVal;
    }
    
    function setFromArray(a: Array)
    {
        this.reqs = new Object();
        // Unzip ("a", "b", "c", "d") to {a:"b", c:"d"}
        for (var i: Number = 0; i + 1 < a.length; i = i + 2) {
            this.reqs[a[i]] = a[i + 1];
        }
    }

    function setFromObject(requirements: Object)
    {
        if (requirements instanceof Array) {
            this.setFromArray(Array(requirements));
        }
        else if (requirements instanceof Object) {
            this.reqs = requirements;
        }
        else {
            this.reqs = new Object();
        }
    }

    function passesFilter(objectToCheck: Object)
    {
        // Check if this object passes all the filter criteria
        for (var filterProperty in this.reqs)
            if (objectToCheck[filterProperty] != this.reqs[filterProperty])
                return false;
        
        return true;
    }
}
