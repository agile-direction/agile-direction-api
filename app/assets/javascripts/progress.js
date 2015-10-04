(function() {
  var ready = function() {
    $('.progress .progress-bar').each(function(_index, element) {
      var width = $(element).data('percent');
      $(element).animate({
        width: (width + '%')
      })
    });
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
