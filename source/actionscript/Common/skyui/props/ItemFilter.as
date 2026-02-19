class skyui.props.ItemFilter
{
   var reqs;
   function ItemFilter(requirementsObj)
   {
      this.setFromObject(requirementsObj);
   }
   function addRequirement(requiredProperty, requiredVal)
   {
      this.reqs[requiredProperty] = requiredVal;
   }
   function setFromArray(a)
   {
      this.reqs = new Object();
      var _loc2_ = 0;
      while(_loc2_ + 1 < a.length)
      {
         this.reqs[a[_loc2_]] = a[_loc2_ + 1];
         _loc2_ += 2;
      }
   }
   function setFromObject(requirements)
   {
      if(requirements instanceof Array)
      {
         this.setFromArray(Array(requirements));
      }
      else if(requirements instanceof Object)
      {
         this.reqs = requirements;
      }
      else
      {
         this.reqs = new Object();
      }
   }
   function passesFilter(objectToCheck)
   {
      for(var _loc3_ in this.reqs)
      {
         if(objectToCheck[_loc3_] != this.reqs[_loc3_])
         {
            return false;
         }
      }
      return true;
   }
}
