(function() {
  var ready = function() {
    $('.flash').each(function(index, element) {
      setTimeout(function() {
        $(element).animate({ bottom: '-100%' });
      }, 2000);
    });
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
