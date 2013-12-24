/*jshint indent:2, curly:true, eqeqeq:true, immed:true, latedef:true,
newcap:true, noarg:true, regexp:true, undef:true, strict:true, trailing:true,
white:true*/
/*global XT:true, XM:true, _:true */

(function () {
  "use strict";

  XT.extensions.purchasing.initVendorModels = function () {

    /**
      @class

      @extends XM.Model
    */
    XM.PurchaseVendorRelation = XM.Model.extend(/** @lends XM.PurchaseVendorRelation.prototype */{

      recordType: 'XM.PurchaseVendorRelation'

    });

    /**
      @class

      @extends XM.Model
    */
    XM.PurchaseVendorAddress = XM.Model.extend(/** @lends XM.PurchaseVendorAddress.prototype */{

      recordType: 'XM.PurchaseVendorAddress'

    });

    /**
      @class

      @extends XM.Model
    */
    XM.VendorContract = XM.Model.extend(/** @lends XM.VendorContract.prototype */{

      recordType: 'XM.VendorContract'

    });


    /**
      @class

      @extends XM.Model
    */
    XM.VendorContractRelation = XM.Info.extend(/** @lends XM.VendorContractRelation.prototype */{

      recordType: 'XM.VendorContractRelation',

      editableModle: 'XM.VendorContract'

    });

    // ..........................................................
    // COLLECTIONS
    //

    /**
      @class

      @extends XM.Collection
    */
    XM.PurchaseVendorRelationCollection = XM.Collection.extend({

      model: XM.PurchaseVendorRelation

    });

    /**
      @class

      @extends XM.Collection
    */
    XM.VendorContractCollection = XM.Collection.extend({

      model: XM.VendorContract

    });

    /**
      @class

      @extends XM.Collection
    */
    XM.VendorContractRelationCollection = XM.Collection.extend({

      model: XM.VendorContractRelation

    });

  };

}());

