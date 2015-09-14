(function() {
  var ready = function() {
    if ($("#add-user").length == 0) return;

    $("#add-user").autocomplete({
      source: "/users",
      select: function(event, ui) {
        var form = $(event.target).closest('form');
        form.find('#add-user-id').val(ui.item.id);
        form.submit();
      },
      response: function(event, ui) {
        $.each(ui.content, function(index, item) {
          item.label = item.name;
        });
      }
    }).data("ui-autocomplete")._renderItem = function(ul, item) {
      var link = $('<a>', { href: '#' });
      link.html(item.name);
      return link.appendTo(ul);
    };
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
