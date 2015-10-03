(function() {
  var keys = {
    // enter: 13,
    d: 68,
    f: 70,
    g: 71,
    i: 73,
    j: 74,
    k: 75,
    o: 79,
    s: 83,
    v: 86,
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
    if (focusedElementIndex > focusableElements().length) return;
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

  var _commandSelector = function(code) {
    var command = characterForCode(code);
    if (command === undefined) return;
    if (event.shiftKey) command = command.toUpperCase();
    return ('[data-command=' + command + ']');
  };

  var sendCommandThroughParents = function(event, code) {
    var selector = _commandSelector(code);
    var commandElement = findThroughParents(focusedElement(), selector);
    if (commandElement) {
      commandElement[0].click();
      event.preventDefault();
    };
  };

  var sendCommand = function(event, code) {
    var selector = _commandSelector(code);
    var commandElement = focusedElement().find(selector);
    if (commandElement.length === 1) {
      commandElement[0].click();
      event.preventDefault();
    };
  };

  var characterForCode = function(code) {
    for (key in keys) {
      if (keys[key] === code) return key;
    }
  };

  var selectedElement = null;
  var selectElement = function() {
    selectedElement = focusedElement();
    if (selectedElement.length == 1) selectedElement.addClass('selected');
  };

  var deselectElement = function() {
    if (selectedElement) selectedElement.removeClass('selected');
    selectedElement = null;
  }

  var flushChanges = function(element) {
    var widget = element.data("ui-sortable");
    widget._trigger("update", null, widget._uiHash(widget));
  }

  var move = function(direction) {
    var liParent = $(event.target).parents('li').eq(0);
    var nextElement = liParent[direction]('li');
    var directionMethod = (direction == 'next') ? 'insertAfter' : 'insertBefore';

    if (nextElement.length === 1) {
      var nextElement = liParent[direction]();
      liParent[directionMethod](nextElement);
      focusedElementIndex = focusableElements().index(event.target);
      var parentUl = liParent.parents('ul').eq(0);
      flushChanges(parentUl);
      focus();
    } else {
      var higherLiParent = liParent.parents('li');
      if (higherLiParent.length === 0) return;
      var nextLiParent = higherLiParent[direction]('li');
      if (nextLiParent.length === 1) {
        var additionMethod = (direction == 'next') ? 'prepend' : 'append';
        nextLiParent.removeClass('collapsed');
        var newUl = nextLiParent.find('ul');
        newUl[additionMethod](liParent);
        focusedElementIndex = focusableElements().index(event.target);
        flushChanges(newUl);
        focus();
      }
    }
  }

  var previousKeys = [];
  var maxPreviousKeys = 2;
  var previousKeysTTL = 400;
  var trackKeydown = function(code) {
    previousKeys.push(code);
    setTimeout(function() {
      previousKeys.shift();
    }, previousKeysTTL)
  };

  var initializeKeydown = function() {
    $(document).keydown(function(event) {
      var code = (event.keyCode || event.which);
      if (event.metaKey) return;
      trackKeydown(code);

      switch(code) {
        case(keys['j']):
          if (selectedElement) {
            move('next');
          } else {
            focusDown();
          }
          break;
        case(keys['k']):
          if (selectedElement) {
            move('prev');
          } else {
            focusUp();
          }
          break;
        case(keys['v']):
          if (!event.shiftKey) return;
          (selectedElement) ? deselectElement() : selectElement();
          return;
        case(keys['g']):
          var lastTwoKeys = previousKeys.slice(Math.max(previousKeys.length - 2, 0));

          if (event.shiftKey) {
            focusedElementIndex = focusableElements().length - 1;
            focus();
            break;
          }

          if (lastTwoKeys.length != 2) {
            break;
          };

          var isDoubleG = lastTwoKeys.reduce(function(isG, key) {
            return isG && (key = keys['g'])
          }, true);

          if (isDoubleG) {
            focusedElementIndex = 0;
            focus();
          };

          break;
        case(keys['escape']):
          focusedElement().blur();
          deselectElement();
          break;
        case(keys['space']):
          sendCommandThroughParents(event, code);
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
