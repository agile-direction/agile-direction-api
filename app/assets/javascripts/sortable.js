(function() {
  var ui = {
    doingThings: function() {
      // $('body').addClass('loading');
    },
    doneWithThings: function() {
      // $('body').removeClass('loading');
    },
    error: function() {
      var message = I18n.t('actions.ajax-failed');
      Flasher.alert(message);
    }
  };

  var updateEstimates = function() {
    var totalTime = 0;
    $('ul#deliverables li.deliverable').each(function(index, deliverableList) {
      var elementHoldingEstimate = $(deliverableList).find('.timestop .count');
      $(deliverableList).find('li.requirement').each(function(index, requirementLi) {
        if ($(requirementLi).data('state') !== 'completed') {
          totalTime += parseInt($(requirementLi).data('estimate'));
        }
      });
      var timeInWeeks = Math.ceil(totalTime/7);
      elementHoldingEstimate.html(timeInWeeks);
    });
  };

  var request = function(url, data) {
    ui.doingThings();
    $.ajax({
      url: url,
      method: 'PUT',
      data: JSON.stringify(data),
      dataType: 'json',
      contentType: 'application/json',
      accepts: 'application/json',
      complete: function(_response, _textStatus) {
        ui.doneWithThings();
      },
      error: ui.error
    });
  };

  var updateOrderOfRequirements = function(deliverableUl) {
    var missionUl = $(deliverableUl).parents('ul');

    var requirements = Array.prototype.reduce.call($(deliverableUl).find('li'), function(previousValue, currentValue) {
      return previousValue.concat({ id: $(currentValue).data('id') });
    }, []);

    if (requirements.length === 0) {
      return;
    }

    var missionId = missionUl.data('id');
    var deliverableId = $(deliverableUl).data("id");

    var url = '/missions/' + missionId + '/deliverables/' + deliverableId + '/order_requirements';
    var data = { requirements: requirements };
    request(url, data);
  };

  var updateOrderOfDeliverables = function(missionUl) {
    var missionId = $(missionUl).data('id');
    var deliverables = Array.prototype.reduce.call(missionUl.children, function(previousValue, currentValue) {
      return previousValue.concat({ id: currentValue.dataset.id });
    }, []);

    var url = '/missions/' + missionId + '/order_deliverables';
    var data = { deliverables: deliverables };
    request(url, data);
  };

  var ready = function() {
    $('ul#deliverables').sortable({
      handle: '.deliverable_handle',
      axis: 'y',
      start: function(event, ui) {
        $(event.target).addClass("active");
      },
      stop: function(event, ui) {
        $(event.target).removeClass("active");
      },
      update: function(event, ui) {
        updateOrderOfDeliverables(event.target);
        updateEstimates();
      }
    });

    $('ul.requirements').sortable({
      handle: '.requirement_handle',
      axis: 'y',
      connectWith: '.requirements',
      update: function(event, ui) {
        updateOrderOfRequirements(event.target);
        updateEstimates();
      }
    });
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
