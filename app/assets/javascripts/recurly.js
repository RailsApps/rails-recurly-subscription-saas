// Recurly.js
// JavaScript library for the Recurly API
// adapted for the rails-recurly-subscription-saas example application
// from https://github.com/recurly/recurly-js

function createObject(o) {
  function F() {}
  F.prototype = o || this;
  return new F();
};

var Recurly = {};

$('.registrations.new').ready(function() {

  Recurly.settings = {
    enableGeoIP: true
  , acceptedCards: ['american_express', 'discover', 'mastercard', 'visa']
  , oneErrorPerField: true
  , baseURL: 'https://api.recurly.com/jsonp/' + $('#new_user').data('subdomain') + '/'
  };

  Recurly.version = '2.1.3';

  Recurly.ajax = function(options) {
    options.data = $.extend({js_version: Recurly.version}, options.data);
    return $.ajax(options);
  };

  Recurly.flattenErrors = function(obj, attr) {
    var arr = [];
    var attr = attr || '';
    if(  typeof obj == 'string'
      || typeof obj == 'number'
      || typeof obj == 'boolean') {
      if (attr == 'base') {
        return [obj];
      }
      return ['' + attr + ' ' + obj];
    }
    for(var k in obj) {
      if(obj.hasOwnProperty(k)) {
        // Inherit parent attribute names when property key
        // is a numeric string; how we deal with arrays
        attr = (parseInt(k).toString() == k) ? attr : k;
        var children = Recurly.flattenErrors(obj[k], attr);
        for(var i=0, l=children.length; i < l; ++i) {
          arr.push(children[i]);
        }
      }
    }
    return arr;
  };

  Recurly.Account = {
    create: createObject
  , toJSON: function(card) {
      return {
        first_name: card.first_name
      , last_name: card.last_name
      , account_code: card.customer_id
      , email: card.email
      };
    }
  };

  Recurly.BillingInfo = {
    create: createObject
  , toJSON: function(card) {
      return {
        first_name: card.first_name
      , last_name: card.last_name
      , month: card.expMonth
      , year: card.expYear
      , number: card.number
      , verification_value: card.cvc
      , country: card.country
      , ip_address: card.ip_address
      };
    }
  };

  Recurly.Subscription = {
    create: createObject
  , plan: Recurly.Plan
  , addOns: []

  , calculateTotals: function() {
      var totals = {
        stages: {}
      };

      // PLAN
      totals.plan = this.plan.cost.mult(this.plan.quantity);

      // ADD-ONS
      totals.allAddOns = new Recurly.Cost(0);
      totals.addOns = {};
      for(var l=this.addOns.length, i=0; i < l; ++i) {
        var a = this.addOns[i],
            c = a.cost.mult(a.quantity);
        totals.addOns[a.code] = c;
        totals.allAddOns = totals.allAddOns.add(c);
      }

      totals.stages.recurring = totals.plan.add(totals.allAddOns);

      totals.stages.now = totals.plan.add(totals.allAddOns);

      // FREE TRIAL
      if(this.plan.trial) {
        totals.stages.now = Recurly.Cost.FREE;
      }

      // COUPON
      if(this.coupon) {
        var beforeDiscount = totals.stages.now;
        var afterDiscount = totals.stages.now.discount(this.coupon);
        totals.coupon = afterDiscount.sub(beforeDiscount);
        totals.stages.now = afterDiscount;
      }

      // SETUP FEE
      if(this.plan.setupFee) {
        totals.stages.now = totals.stages.now.add(this.plan.setupFee);
      }

      // VAT
      if(this.billingInfo && Recurly.isVATChargeApplicable(this.billingInfo.country,this.billingInfo.vatNumber)) {
        totals.vat = totals.stages.now.mult( (Recurly.settings.VATPercent/100) );
        totals.stages.now = totals.stages.now.add(totals.vat);
      }

      return totals;
    }
  , redeemAddOn: function(addOn) {
    var redemption = addOn.createRedemption();
    this.addOns.push(redemption);
    return redemption;
  }

  , removeAddOn: function(code) {
    for(var a=this.addOns, l=a.length, i=0; i < l; ++i) {
      if(a[i].code == code) {
        return a.splice(i,1);
      }
    }
  }

  , findAddOnByCode: function(code) {
      for(var l=this.addOns.length, i=0; i < l; ++i) {
        if(this.addOns[i].code == code) {
          return this.addOns[i];
        }
      }
      return false;
    }

  , toJSON: function(plan, coupon) {
      var json = {
        plan_code: plan.plan_code
      , quantity: plan.quantity ? plan.quantity : 1
      , currency: plan.currency ? plan.quantity : 'USD'
      , coupon_code: coupon.coupon_code ? coupon.coupon_code : undefined
      , add_ons: []
      };

      for(var i=0, l=this.addOns.length, a=json.add_ons, b=this.addOns; i < l; ++i) {
        a.push({
          add_on_code: b[i].code
        , quantity: b[i].quantity
        });
      }

      return json;
    }

  , save: function(signature, plan, coupon, card, callback) {
      var json = {
        subscription: this.toJSON(plan, coupon)
      , account: Recurly.Account.toJSON(card)
      , billing_info: Recurly.BillingInfo.toJSON(card)
      , signature: signature
      };

      Recurly.ajax({
        url: Recurly.settings.baseURL+'subscribe',
        data: json,
        dataType: "jsonp",
        jsonp: "callback",
        timeout: 60000,
        success: function(response){
          callback(response)
        },
        error: function() {
          console.log(['Unknown error processing transaction. Please try again later.']);
        }
      });

    }
  };
});
