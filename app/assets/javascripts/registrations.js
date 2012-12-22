$('.registrations.new').ready(function() {
  var signature = $('#new_user').data('signature')
  var ip_address = $('#new_user').data('ip_address')
  var subscription = {
    setupForm: function() {
      return $('.card_form').submit(function() {
        $('input[type=submit]').prop('disabled', true);
        if ($('#card_number').length) {
          subscription.processCard();
          return false;
        } else {
          return true;
        }
      });
    },
    processCard: function() {
      var plan;
      plan = {
        plan_code: $('#plan').val(),
      };
      var coupon;
      coupon = {
        coupon_code: $('#coupon').val(),
      };
      var card;
      card = {
        customer_id: $('#user_customer_id').val(),
        email: $('#user_email').val(),
        first_name: $('#user_first_name').val(),
        last_name: $('#user_last_name').val(),
        number: $('#card_number').val(),
        cvc: $('#card_code').val(),
        expMonth: $('#card_month').val(),
        expYear: $('#card_year').val(),
        country: $('#country').val(),
        ip_address: ip_address
      };
      return Recurly.Subscription.save(signature, plan, coupon, card, subscription.handleResponse);
    },
    handleResponse: function(response) {
      if(response.success) {
        $('#user_card_token').val(response.success.token)
        $('.card_form')[0].submit()
      }
      else if(response.errors) {
        $('#card_error').text(Recurly.flattenErrors(response.errors)).show();
        return $('input[type=submit]').prop('disabled', false);
      }
    }
  };
  return subscription.setupForm();
});
