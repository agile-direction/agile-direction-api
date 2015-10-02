(function() {
  var keys = {
    enter: 13,
    c: 67,
    d: 68,
    j: 74,
    k: 75,
    o: 79,
    escape: 27,
    space: 32
  };

  var maxSearch = 5;
  var focusedElementIndex = -1;
  var scrollDelay = 400;

  var focusableElements = function() {
    return $('.focus-area');
  };

  var focusedElement = function() {
    return focusableElements().eq(focusedElementIndex);
  };

  var focus = function(nextCallback) {
    if (focusedElement().is(':visible')) {
      focusedElement().focus();
    } else {
      nextCallback();
    }
  };

  var focusUp = function() {
    if (focusedElementIndex == 0) return;
    focusedElementIndex--;
    focus(focusUp);
  };

  var focusDown = function() {
    if ((focusedElementIndex + 1) > focusableElements().length) return;
    focusedElementIndex++;
    focus(focusDown);
  };

  var findThroughParents = function(element, selector) {
    for (var i = 0; i <= maxSearch; i++) {
      var foundElement = element.find(selector);
      if (foundElement.length > 0) {
        return foundElement.last();
      } else {
        element = element.parent();
      }
    }
  };

  var sendCommand = function(event, code) {
    var command = characterForCode(code);
    if (command === undefined) return;
    var selector = '[data-command=' + command + ']:visible';
    var commandElement = findThroughParents(focusedElement(), selector) || $(selector).last();
    if (commandElement) {
      commandElement[0].click();
      event.preventDefault();
    };
  };

  var characterForCode = function(code) {
    for (key in keys) {
      if (keys[key] === code) return key;
    }
  };

  var initializeKeydown = function() {
    $(document).keydown(function(event) {
      var code = (event.keyCode || event.which);
      switch(code) {
        case(keys['j']):
          focusDown();
          break;
        case(keys['k']):
          focusUp();
          break;
        case(keys['escape']):
          focusedElement().blur();
          focusedElementIndex = -1;
          break;
        default:
          sendCommand(event, code);
          break;
      }
    });
  };

  // http://stackoverflow.com/questions/19491336/get-url-parameter-jquery
  var getUrlParameter = function getUrlParameter(paramKey) {
    var paramString = decodeURIComponent(window.location.search.substring(1));
    paramFragments = paramString.split('&');
    for (var i = 0; i < paramFragments.length; i++) {
      paramAsArray = paramFragments[i].split('=');
      if (paramAsArray[0] === paramKey) {
        return paramAsArray[1];
      }
    }
  };

  var ready = function() {
    focusedElementIndex = -1;
    var focusId = getUrlParameter('focus');
    var selector = '#' + focusId + ' .focus-area';
    var matches = $(selector);
    if (matches.length >= 1) {
      var element = matches.eq(0);
      var index = focusableElements().index(element);
      // wait until browser focuses on search
      setTimeout(function() {
        focusedElementIndex = index;
        element.focus();
      }, 1);
    }
  };

  $(document).ready(initializeKeydown);
  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
