(function() {
  var missionNames = [];

  var startTyping = function() {
    $('#mission-name').typed({
      strings: I18n.t('home.index.examples'),
      cursorChar: ''
    });
  };

  var ready = function() {
    startTyping();
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
