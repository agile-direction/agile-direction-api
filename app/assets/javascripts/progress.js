(function() {
  var animationLength = 1000;

  var ready = function() {
    $('.progress .progress-bar').each(function(index, element) {
      var width = $(element).data('percent');
      $(element).animate({ width: `${width}%` }, animationLength);
    });
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
