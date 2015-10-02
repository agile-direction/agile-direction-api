(function() {
  var handleClick = function(event) {
    event.preventDefault();
    $(event.target)
      .closest('.expandable')
      .toggleClass('collapsed');
  }

  var ready = function() {
    $('.expandable').each(function(index, ui) {
      var expandableElement = $(ui);
      expandableElement.find('.toggle-expand').eq(0).on('click', handleClick);
    });
  }

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
