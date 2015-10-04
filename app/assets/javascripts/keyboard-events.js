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

  var handleG = function(event) {
    var lastTwoKeys = previousKeys.slice(Math.max(previousKeys.length - 2, 0));

    if (event.shiftKey) {
      focusedElementIndex = focusableElements().length - 1;
      focus(focusUp);
      return;
    }

    if (lastTwoKeys.length != 2) {
      return;
    };

    var isDoubleG = lastTwoKeys.reduce(function(isG, key) {
      return isG && (key = keys['g'])
    }, true);

    if (isDoubleG) {
      focusedElementIndex = 0;
      focus();
    };
  }

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
          handleG(event);
          break;
        case(keys['escape']):
          focusedElement().blur();
          clearFocusId();
          deselectElement();
          break;
        case(keys['space']):
          sendCommandThroughParents(event, code);
          break;
        case(keys['o']):
          if (focusedElement().is(':focus')) {
            sendCommandThroughParents(event, code);
          } else {
            var selector = _commandSelector(code);
            $('.add-deliverable' + selector)[0].click();
          }
          break;
        default:
          sendCommand(event, code);
          break;
      }
    });
  };

  var getFocusId = function() {
    return window.location.hash.substring(2);
  }

  var clearFocusId = function() {
    window.location.hash = "/";
  }

  var setFocusId = function(value) {
    return window.location.hash = ('#/' + value);
  }

  var ready = function() {
    focusedElementIndex = -1;
    var focusId = getFocusId();
    if (focusId != "") {
      var selector = '#' + focusId + ' .focus-area';
      var matches = $(selector);
      if (matches.length >= 1) {
        var element = matches.eq(0);
        var index = focusableElements().index(element);
        focusedElementIndex = index;
        focus(focusUp);
      }
    };

    $('.focus-area').on('focusin', function(event) {
      var parentWithId = $(event.target).parents('[data-id]');
      var id = parentWithId.data('id');
      setFocusId(id);
    });

  };

  $(document).ready(initializeKeydown);
  $(document).ready(ready);
  $(document).on('page:load', ready);
})();
