(function() {
  var Filter, Game, Ray, canvas, colorToStrong, filterID, game;

  canvas = null;

  filterID = 0;

  colorToStrong = function(d) {
    var c;
    c = Number(d).toString(16);
    return "#" + ("000000".substr(0, 6 - c.length) + c.toUpperCase());
  };

  Filter = (function() {

    Filter.line = null;

    Filter.id = 0;

    Filter.noCollision = false;

    function Filter(begin, end, color) {
      var point1, point2;
      this.color = color;
      this.line = canvas.display.line({
        start: begin,
        end: end,
        stroke: "5px " + colorToStrong(color),
        cap: "round"
      });
      this.id = filterID++;
      point1 = canvas.display.arc({
        x: begin.x,
        y: begin.y,
        start: 1,
        end: 0,
        radius: 1,
        stroke: "15px " + colorToStrong(color),
        filter: this
      });
      point2 = canvas.display.arc({
        x: end.x,
        y: end.y,
        start: 1,
        end: 0,
        radius: 1,
        stroke: "15px " + colorToStrong(color),
        filter: this
      });
      canvas.addChild(this.line);
      canvas.addChild(point1);
      canvas.addChild(point2);
      point1.dragAndDrop({
        start: function() {
          return this.filter.noCollision = true;
        },
        move: function() {
          return this.filter.line.start = {
            x: this.x,
            y: this.y
          };
        },
        end: function() {
          return this.filter.noCollision = false;
        }
      });
      point2.dragAndDrop({
        start: function() {
          return this.filter.noCollision = true;
        },
        move: function() {
          return this.filter.line.end = {
            x: this.x,
            y: this.y
          };
        },
        end: function() {
          return this.filter.noCollision = false;
        }
      });
    }

    Filter.prototype.testCollision = function(rayClass) {
      var d, newColor, pos, post, pre, ray, x, y, z1, z2, z3, z4, _i, _len, _ref;
      if (this.noCollision) return null;
      _ref = rayClass.raySegments;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ray = _ref[_i];
        z1 = this.line.start.x - this.line.end.x;
        z2 = ray.start.x - ray.end.x;
        z3 = this.line.start.y - this.line.end.y;
        z4 = ray.start.y - ray.end.y;
        d = z1 * z4 - z3 * z2;
        if (d !== 0) {
          pre = this.line.start.x * this.line.end.y - this.line.start.y * this.line.end.x;
          post = ray.start.x * ray.end.y - ray.start.y * ray.end.x;
          x = (pre * z2 - z1 * post) / d;
          y = (pre * z4 - z3 * post) / d;
          if (x < Math.min(this.line.start.x, this.line.end.x) || x > Math.max(this.line.start.x, this.line.end.x) || x < Math.min(ray.start.x, ray.end.x) || x > Math.max(ray.start.x, ray.end.x) || y < Math.min(this.line.start.y, this.line.end.y) || y > Math.max(this.line.start.y, this.line.end.y) || y < Math.min(ray.start.y, ray.end.y) || y > Math.max(ray.start.y, ray.end.y)) {
            true;
          } else {
            pos = {
              x: x,
              y: y
            };
            newColor = ray.color - this.color;
            rayClass.cut(this.id, ray, pos, newColor);
            return pos;
          }
        }
      }
    };

    return Filter;

  })();

  Ray = (function() {

    Ray.prototype.raySegments = [];

    Ray.prototype.direction = {
      x: 0,
      y: 0
    };

    Ray.prototype.isActive = true;

    Ray.prototype.lastCut = {};

    function Ray(begin, direction, color) {
      var newSeg;
      this.direction = direction;
      newSeg = this.newSegment(begin, color, true);
      newSeg.first = true;
    }

    Ray.prototype.newSegment = function(begin, color, isSource) {
      var ray;
      ray = canvas.display.line({
        start: begin,
        end: {
          x: begin.x + this.direction.x,
          y: begin.y + this.direction.y
        },
        stroke: "2px " + colorToStrong(color),
        color: color,
        cap: "round"
      });
      canvas.addChild(ray);
      ray.spread = true;
      ray.isSource = isSource;
      this.raySegments.push(ray);
      ray.cutBy = [];
      return ray;
    };

    Ray.prototype.step = function() {
      var ray, _i, _len, _ref, _results;
      _ref = this.raySegments;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ray = _ref[_i];
        if (ray.spread === true) {
          ray.end = {
            x: ray.end.x + this.direction.x,
            y: ray.end.y + this.direction.y
          };
        }
        if (this.isActive === false || ray.isSource === false) {
          ray.start = {
            x: ray.start.x + this.direction.x,
            y: ray.start.y + this.direction.y
          };
        }
        if (!ray.first) ray.isSource = false;
        _results.push(ray.spread = true);
      }
      return _results;
    };

    Ray.prototype.cut = function(filterId, segment, pos, color) {
      var newSeg, newSeg2;
      console.log("Cut? ");
      if (segment.cutBy[filterId] === true) {
        segment.spread = true;
        return null;
      }
      if (this.lastCut[filterId] && Math.round(pos.x) === Math.round(this.lastCut[filterId].x) && Math.round(pos.y) === Math.round(this.lastCut[filterId].y)) {
        segment.spread = false;
        if (segment.next !== void 0) segment.next.isSource = true;
        return null;
      }
      this.lastCut[filterId] = pos;
      console.log("Cut!");
      newSeg = this.newSegment(pos, color, true);
      newSeg.cutBy[filterId] = true;
      if (Math.ceil(pos.x) !== Math.ceil(segment.end.x) || Math.ceil(pos.y) !== Math.ceil(segment.end.y)) {
        newSeg2 = this.newSegment(pos, segment.color, false);
        newSeg2.end = segment.end;
        newSeg2.stroke = segment.stroke;
      }
      segment.spread = false;
      segment.end = pos;
      return segment.next = newSeg;
    };

    return Ray;

  })();

  Game = (function() {

    Game.prototype.rays = [];

    Game.prototype.filters = [];

    function Game() {
      canvas = oCanvas.create({
        canvas: "#canvas",
        background: "#222",
        fps: 60
      });
    }

    Game.prototype.addFilter = function(begin, end, color) {
      var filter;
      filter = new Filter(begin, end, color);
      return this.filters.push(filter);
    };

    Game.prototype.addRay = function(begin, direction, color) {
      var ray;
      ray = new Ray(begin, direction, color);
      return this.rays.push(ray);
    };

    Game.prototype.run = function() {
      var _this = this;
      return canvas.setLoop(function() {
        var filter, ray, _i, _len, _ref, _results;
        _ref = _this.rays;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ray = _ref[_i];
          ray.step();
          _results.push((function() {
            var _j, _len2, _ref2, _results2;
            _ref2 = this.filters;
            _results2 = [];
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              filter = _ref2[_j];
              _results2.push(filter.testCollision(ray));
            }
            return _results2;
          }).call(_this));
        }
        return _results;
      }).start();
    };

    return Game;

  })();

  game = new Game();

  game.addFilter({
    x: 80,
    y: 160
  }, {
    x: 280,
    y: 170
  }, 0x00aa00);

  game.addFilter({
    x: 180,
    y: 60
  }, {
    x: 80,
    y: 70
  }, 0x0000aa);

  game.addRay({
    x: 20,
    y: 60
  }, {
    x: 0.1,
    y: .2
  }, 0x00aaaa);

  game.run();

}).call(this);
