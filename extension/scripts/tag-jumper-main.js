// Generated by CoffeeScript 1.4.0
var BodyActor, BodyWrapper, DomParser, ElementActor, ElementArticulator, ElementWrapper, GameUi, InputHandler, Player, tj,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

tj = {};

tj.overlay = document.createElement('div');

tj.overlay.id = 'main-overlay';

tj.overlay.className += 'overlay';

tj.canvas = document.createElement('canvas');

tj.canvas.id = 'main-canvas';

tj.canvas.className += 'canvas';

tj.overlay.appendChild(tj.canvas);

tj.ctx = tj.canvas.getContext("2d");

tj.$document = $(document);

document.body.appendChild(tj.overlay);

tj.SCALE = 32.0;

tj.FRAME_RATE = 1.0 / 60;

tj.VELOCITY_ITERATIONS = 10;

tj.POSITION_ITERATIONS = 10;

tj.GRAVITY = new Box2D.Common.Math.b2Vec2(0, 10);

tj.getWidth = function() {
  return tj.canvas.offsetWidth;
};

tj.getHeight = function() {
  return tj.canvas.offsetHeight;
};

/*
 Converts screen points (pixels) to points the 
 physics engine works with
*/


tj.scaleToPhys = function(x) {
  return x / tj.SCALE;
};

/*
 Converts screen points (pixels) vector to points 
 the physics engine works with
*/


tj.scaleVecToPhys = function(vec) {
  vec.Multiply(1 / tj.SCALE);
  return vec;
};

/*
 Converts physics engine points to UI
*/


tj.scaleVecFromPhys = function(vec) {
  vec.Multiply(tj.SCALE);
  return vec;
};

/*
 Converts physics points to points the screen points
 (pixels)
*/


tj.scaleToScreen = function(x) {
  return x * tj.SCALE;
};

tj.createB2Vec = function(x, y) {
  var vector;
  vector = new Box2D.Common.Math.b2Vec2(x, y);
  return vector;
};

tj.createB2VecScaledToPhys = function(x, y) {
  var scaledVec, vec;
  vec = tj.createB2Vec(x, y);
  scaledVec = tj.scaleVecToPhys(vec);
  return scaledVec;
};

/*
# Applies a horizontal force to a body
*/


tj.applyXForce = function(body, xForce) {
  var b2Vec2, centerPoint, force;
  b2Vec2 = Box2D.Common.Math.b2Vec2;
  centerPoint = body.GetPosition();
  force = new b2Vec2(xForce, 0);
  return body.ApplyForce(force, centerPoint);
};

/*
# Applies a vertical force to a body
*/


tj.applyYForce = function(body, yForce) {
  var b2Vec2, centerPoint, force;
  b2Vec2 = Box2D.Common.Math.b2Vec2;
  centerPoint = body.GetPosition();
  force = new b2Vec2(0, yForce);
  return body.ApplyForce(force, centerPoint);
};

tj.isBodyInContact = function(contact, body) {
  var bodyA, bodyB;
  bodyA = contact.GetFixtureA().GetBody();
  bodyB = contact.GetFixtureB().GetBody();
  if (bodyA === body || bodyB === body) {
    return true;
  } else {
    return false;
  }
};

ElementWrapper = (function() {

  function ElementWrapper(element) {
    this.element = element;
    this.isVisible = __bind(this.isVisible, this);

    this.getLocation = __bind(this.getLocation, this);

    this.$element = $(element);
  }

  ElementWrapper.prototype.getLocation = function() {
    var def;
    def = {
      top: this.$element.offset().top - tj.$document.scrollTop(),
      left: this.$element.offset().left - tj.$document.scrollLeft(),
      height: this.$element.height(),
      width: this.$element.width()
    };
    return def;
  };

  ElementWrapper.prototype.isVisible = function() {
    return this.$element.is(":visible");
  };

  return ElementWrapper;

})();

InputHandler = (function() {

  InputHandler.prototype.keysDown = {};

  function InputHandler(player) {
    var _this = this;
    this.player = player;
    $("body").keydown(function(e) {
      return _this.keysDown[e.keyCode] = true;
    });
    $("body").keyup(function(e) {
      return delete _this.keysDown[e.keyCode];
    });
  }

  InputHandler.prototype.update = function() {
    if (38 in this.keysDown) {
      this.player.up();
    }
    if (40 in this.keysDown) {
      this.player.down();
    }
    if (37 in this.keysDown) {
      this.player.left();
    }
    if (39 in this.keysDown) {
      return this.player.right();
    }
  };

  return InputHandler;

})();

Player = (function() {

  function Player(bodyActor) {
    this.bodyActor = bodyActor;
    this.right = __bind(this.right, this);

    this.left = __bind(this.left, this);

    this.down = __bind(this.down, this);

    this.up = __bind(this.up, this);

  }

  Player.prototype.up = function() {
    var vec;
    vec = tj.createB2Vec(0, -2);
    return this.bodyActor.applyImpulse(vec);
  };

  Player.prototype.down = function() {};

  Player.prototype.left = function() {
    var vec;
    vec = tj.createB2Vec(1, 0);
    return this.bodyActor.applyImpulse(vec);
  };

  Player.prototype.right = function() {
    var vec;
    vec = tj.createB2Vec(-1, 0);
    return this.bodyActor.applyImpulse(vec);
  };

  return Player;

})();

BodyWrapper = (function() {

  function BodyWrapper(body) {
    this.body = body;
    this.applyImpulse = __bind(this.applyImpulse, this);

    this.getUiPosition = __bind(this.getUiPosition, this);

  }

  BodyWrapper.prototype.getUiPosition = function() {
    var position, scaledPos, worldPosition;
    worldPosition = this.body.worldBody.GetPosition();
    scaledPos = tj.scaleVecFromPhys(worldPosition);
    position = {
      x: scaledPos.x - tj.$document.scrollLeft(),
      y: scaledPos.y - tj.$document.scrollTop()
    };
    return position;
  };

  BodyWrapper.prototype.applyImpulse = function(b2Vec) {
    var worldPosition;
    worldPosition = this.body.worldBody.GetPosition();
    return this.body.worldBody.ApplyImpulse(b2Vec, worldPosition);
  };

  return BodyWrapper;

})();

BodyActor = (function() {

  function BodyActor(bodyWrapper, actor) {
    this.bodyWrapper = bodyWrapper;
    this.actor = actor;
    this.applyImpulse = __bind(this.applyImpulse, this);

    this.update = __bind(this.update, this);

  }

  BodyActor.prototype.update = function() {
    var position;
    position = this.bodyWrapper.getUiPosition();
    return this.actor.setLocation(position.x, position.y);
  };

  BodyActor.prototype.applyImpulse = function(b2Vec) {
    return this.bodyWrapper.applyImpulse(b2Vec);
  };

  return BodyActor;

})();

ElementActor = (function() {

  function ElementActor(elementWrapper, actor, body) {
    this.elementWrapper = elementWrapper;
    this.actor = actor;
    this.body = body;
    this.update = __bind(this.update, this);

  }

  ElementActor.prototype.update = function() {
    var def;
    def = this.elementWrapper.getLocation();
    return this.actor.setLocation(def.left, def.top);
  };

  return ElementActor;

})();

GameUi = (function() {

  function GameUi(canvas, world, loopCallback) {
    var height, width;
    this.world = world;
    this.createTextActor = __bind(this.createTextActor, this);

    this.createRectActorWithBody = __bind(this.createRectActorWithBody, this);

    this.rectBodyFromActor = __bind(this.rectBodyFromActor, this);

    this.bodyFromActor = __bind(this.bodyFromActor, this);

    width = canvas.offsetWidth;
    height = canvas.offsetHeight;
    this.director = new CAAT.Director().initialize(width, height, canvas);
    this.scene = this.director.createScene();
    CAAT.PMR = tj.SCALE;
    CAAT.enableBox2DDebug(true, this.director, this.world);
    this.scene.onRenderStart = loopCallback;
    CAAT.loop(tj.FRAME_RATE);
  }

  GameUi.prototype.getDefaultBodyDef = function(actor) {
    var def;
    def = {
      x: actor.x,
      y: actor.y,
      bodyType: Box2D.Dynamics.b2Body.b2_staticBody,
      density: 1,
      restitution: 1,
      friction: 1,
      image: null,
      polygonType: CAAT.B2DPolygonBody.Type.BOX,
      bodyDef: [
        {
          x: actor.x,
          y: actor.y
        }, {
          x: actor.x + actor.width,
          y: actor.y + actor.height
        }
      ],
      bodyDefScale: 1,
      bodyDefScaleTolerance: 0,
      userData: {}
    };
    return def;
  };

  GameUi.prototype.createPolygon = function(x, y, data) {
    var body;
    return body = new CAAT.B2DPolygonBody().enableEvents(false).createBody(world, {
      x: x,
      y: y,
      bodyType: Box2D.Dynamics.b2Body.b2_dynamicBody,
      density: data.density,
      restitution: data.restitution,
      friction: data.friction,
      image: null,
      polygonType: CAAT.B2DPolygonBody.Type.POLYGON,
      bodyDef: data.polygonDef,
      bodyDefScale: data.polygonScale,
      bodyDefScaleTolerance: data.tolerance,
      userData: null
    });
  };

  GameUi.prototype.bodyFromActor = function(actor, bodyDef) {
    var body;
    body = CAAT.B2DPolygonBody.createPolygonBody(this.world, bodyDef);
    return body;
  };

  GameUi.prototype.rectBodyFromActor = function(actor) {
    var body;
    body = CAAT.B2DPolygonBody.createPolygonBody(this.world, this.getDefaultBodyDef(actor));
    return body;
  };

  GameUi.prototype.createRectActorWithBody = function(def, world) {
    var actor;
    this.world = world;
    actor = new CAAT.Actor().setLocation(def.left, def.top).setSize(def.width, def.height).setFillStyle('orange').setAlpha(.6);
    this.scene.addChild(actor);
    return actor;
  };

  GameUi.prototype.createTextActor = function(def) {
    var actor;
    actor = new CAAT.TextActor().setLocation(def.left, def.top).setText(def.text).setFillStyle('black');
    this.scene.addChild(actor);
    return actor;
  };

  return GameUi;

})();

ElementArticulator = (function() {

  function ElementArticulator() {
    this.isValid = __bind(this.isValid, this);

    this.articulateElement = __bind(this.articulateElement, this);

  }

  ElementArticulator.prototype.articulateElement = function(element) {
    if (!this.isValid(element)) {
      return false;
    }
    if (Math.random() < .9) {
      return false;
    }
    tj.createPlatform(element);
    return true;
  };

  ElementArticulator.prototype.isValid = function(element) {
    if (!element.offsetWidth) {
      return false;
    }
    if (element.offsetWidth > tj.canvas.offsetWidth / 2) {
      return false;
    }
    if (element.offsetHeight > tj.canvas.offsetHeight / 2) {
      return false;
    }
    if (element.offsetWidth < 5) {
      return false;
    }
    if (element.offsetHeight < 5) {
      return false;
    }
    return true;
  };

  return ElementArticulator;

})();

/*
# Able to parse the DOM and return a set of interesting 
# html elements for the page.
*/


DomParser = (function() {
  /*
  	# Constructor
  */

  function DomParser(articulator) {
    this.articulator = articulator;
    this.parseElement = __bind(this.parseElement, this);

    this.parsePage = __bind(this.parsePage, this);

  }

  DomParser.prototype.parsePage = function() {
    this.elementCount = 0;
    return this.parseElement(document.body);
  };

  DomParser.prototype.parseElement = function(element) {
    var child, wasArticulated, _i, _len, _ref, _results;
    wasArticulated = this.articulator.articulateElement(element);
    this.elementCount++;
    if (this.elementCount > 30000) {
      return;
    }
    _ref = element.childNodes;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      _results.push(this.parseElement(child));
    }
    return _results;
  };

  return DomParser;

})();

/*
 Creates a horizontal platform
*/


tj.createPlatform = function(element) {
  var actor, body, elementWrapper, platformDef;
  elementWrapper = new ElementWrapper(element);
  platformDef = elementWrapper.getLocation();
  actor = tj.ui.createRectActorWithBody(platformDef, tj.world);
  body = tj.ui.rectBodyFromActor(actor);
  return tj.updatables.push(new ElementActor(elementWrapper, actor, body));
};

tj.createPlayer = function() {
  var actor, body, bodyActor, bodyDef, bodyWrapper, platformDef, player;
  platformDef = {
    top: 200,
    left: 200,
    width: 10,
    height: 20
  };
  actor = tj.ui.createRectActorWithBody(platformDef, tj.world);
  actor.setFillStyle('green');
  actor.setAlpha(.8);
  bodyDef = tj.ui.getDefaultBodyDef(actor);
  bodyDef.bodyType = Box2D.Dynamics.b2Body.b2_dynamicBody;
  body = tj.ui.bodyFromActor(actor, bodyDef);
  bodyWrapper = new BodyWrapper(body);
  bodyActor = new BodyActor(bodyWrapper, actor);
  tj.updatables.push(bodyActor);
  return player = new Player(bodyActor);
};

/*
 Handles the BeginContact event from the physics 
 world.
*/


tj.beginContact = function(contact) {};

/*
 Does all the work we need to do at each tick of the
 game clock.
*/


tj.update = function() {
  var updatable, _i, _len, _ref;
  if (!tj.initComplete) {
    return;
  }
  tj.world.Step(tj.FRAME_RATE, tj.VELOCITY_ITERATIONS, tj.POSITION_ITERATIONS);
  tj.world.ClearForces();
  _ref = tj.updatables;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    updatable = _ref[_i];
    updatable.update();
  }
  return tj.inputHandler.update();
};

/*
 Initalizes everything we need to get started, should
 only be called once to set up.
*/


tj.init = function() {
  var allowSleep, b2DebugDraw, debugDraw, listener, player;
  tj.updatables = [];
  b2DebugDraw = Box2D.Dynamics.b2DebugDraw;
  allowSleep = true;
  tj.world = new Box2D.Dynamics.b2World(tj.GRAVITY, allowSleep);
  tj.elementArticulator = new ElementArticulator();
  tj.domParser = new DomParser(tj.elementArticulator);
  tj.ui = new GameUi(tj.canvas, tj.world, tj.update);
  tj.domParser.parsePage();
  listener = new Box2D.Dynamics.b2ContactListener;
  listener.BeginContact = tj.beginContact;
  tj.world.SetContactListener(listener);
  player = tj.createPlayer();
  tj.inputHandler = new InputHandler(player);
  debugDraw = new b2DebugDraw();
  debugDraw.SetSprite(tj.ctx);
  debugDraw.SetDrawScale(tj.SCALE);
  debugDraw.SetFillAlpha(0.4);
  debugDraw.SetLineThickness(1.0);
  debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
  return tj.initComplete = true;
};

tj.init();
