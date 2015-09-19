(function() {
  var missionNames = [];

  var startTyping = function() {
    $('#mission-name').typed({
      strings: missionNames
    });
  };

  var typeMissionNames = function(missions) {
    missions.reduce(function(collection, mission) {
      collection.push(mission.name);
      return missionNames;
    }, missionNames);
    startTyping();
  };

  var ready = function() {
    $.ajax({
      url: '/missions',
      dataType: 'json'
    }).then(function(data) {
      typeMissionNames(data.missions);
    });
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
