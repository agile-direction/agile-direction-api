var Flasher = {
  alert: function(message) {
    var error = $('<p>', { class: 'flash alert' });
    error.text(message);
    $('#flashes').append(error);
    this.setExpiration();
  },

  setExpiration: function() {
    $('.flash').each(function(index, element) {
      setTimeout(function() {
        $(element).animate({ bottom: '-100%' });
      }, 2000);
    });
  }
};

(function() {
  var ready = function() {
    Flasher.setExpiration();
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
