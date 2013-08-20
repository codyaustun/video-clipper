// Generated by CoffeeScript 1.6.2
(function() {
  this.OmniPlayer = (function() {
    OmniPlayer.prototype.type = void 0;

    OmniPlayer.prototype.videoId = void 0;

    OmniPlayer.prototype.height = void 0;

    OmniPlayer.prototype.width = void 0;

    OmniPlayer.prototype.elementId = void 0;

    OmniPlayer.prototype.startSeconds = void 0;

    OmniPlayer.prototype.endSeconds = void 0;

    OmniPlayer.prototype.internal = void 0;

    OmniPlayer.loaded = {
      YT: false,
      TEST: false,
      JW: false
    };

    function OmniPlayer(obj) {
      this.elementId = obj.elementId;
      this.videoId = obj.videoId;
      this.type = obj.type;
      this.height = obj.height;
      this.width = obj.width;
      this.startSeconds = obj.startSeconds;
      this.endSeconds = obj.endSeconds;
      if (this.height == null) {
        this.height = $("#" + this.elementId).height();
      }
      if (this.width == null) {
        this.width = $("#" + this.elementId).width();
      }
      this[this.type].createPlayer.apply(this, [obj]);
    }

    OmniPlayer.prototype.getDuration = function() {
      return 0;
    };

    OmniPlayer.prototype.getCurrentTime = function() {
      return 0;
    };

    OmniPlayer.prototype.stopVideo = function() {
      return 0;
    };

    OmniPlayer.prototype.cueVideoById = function(options) {
      return 0;
    };

    OmniPlayer.prototype.loadVideoById = function(options) {
      return 0;
    };

    OmniPlayer.prototype.remove = function() {
      var el, new_el;

      el = $("#" + this.elementId);
      new_el = el.after("<div></div>").next();
      el.remove();
      new_el.attr({
        id: "" + this.elementId
      });
      return this;
    };

    OmniPlayer.prototype.JW = {
      build: function(obj) {
        var that;

        this.internal = jwplayer(this.elementId).setup({
          file: "http://www.youtube.com/watch?v=" + this.videoId,
          image: "http://img.youtube.com/vi/" + this.videoId + "/0.jpg",
          height: this.height,
          width: this.width
        });
        that = this;
        this.internal.seek(this.startSeconds);
        this.internal.onReady(function() {
          return that.internal.pause();
        });
        this.internal.onTime(function(e) {
          if (e.position > that.endSeconds) {
            return that.stopVideo();
          }
        });
        this.getDuration = function() {
          return this.internal.getDuration();
        };
        this.getCurrentTime = function() {
          return this.internal.getPosition();
        };
        this.stopVideo = function() {
          return this.internal.stop();
        };
        this.cueVideoById = function(options) {
          if (this.internal != null) {
            this.internal.remove();
          }
          this.endSeconds = options.endSeconds;
          this.startSeconds = options.startSeconds;
          this.videoId = options.videoId;
          this.internal = jwplayer(this.elementId).setup({
            file: "http://www.youtube.com/watch?v=" + this.videoId,
            image: "http://img.youtube.com/vi/" + this.videoId + "/0.jpg",
            height: this.height,
            width: this.width
          });
          that = this;
          this.internal.seek(this.startSeconds);
          this.internal.onReady(function() {
            return that.internal.pause();
          });
          return this.internal.onTime(function(e) {
            if (e.position > that.endSeconds) {
              return that.stopVideo();
            }
          });
        };
        this.loadVideoById = function(options) {};
        return this.remove = function() {
          return this.internal.remove();
        };
      },
      createPlayer: function(obj) {
        if (obj[0].key != null) {
          jwplayer.key = obj[0].key;
          this.JW.build.apply(this, [obj]);
          return OmniPlayer.loaded.JW = true;
        } else {

        }
      }
    };

    OmniPlayer.prototype.YT = {
      setup: function() {
        var firstScriptTag, tag;

        tag = document.createElement("script");
        tag.src = "https://www.youtube.com/iframe_api";
        firstScriptTag = document.getElementsByTagName("script")[0];
        return firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
      },
      build: function() {
        var _this = this;

        this.internal = new window.YT.Player(this.elementId, {
          videoId: this.videoId,
          height: this.height,
          width: this.width,
          events: {
            onReady: function(event) {
              if (_this.startSeconds || _this.endSeconds) {
                return event.target.cueVideoById({
                  videoId: _this.videoId,
                  startSeconds: _this.startSeconds,
                  endSeconds: _this.endSeconds,
                  suggestedQuality: "large"
                });
              } else {
                _this.startSeconds = 0;
                return _this.endSeconds = _this.endSeconds || _this.getDuration();
              }
            }
          }
        });
        this.getDuration = function() {
          return this.internal.getDuration();
        };
        this.getCurrentTime = function() {
          return this.internal.getCurrentTime();
        };
        this.stopVideo = function() {
          return this.internal.stopVideo();
        };
        this.cueVideoById = function(options) {
          return this.internal.cueVideoById(options);
        };
        return this.loadVideoById = function(options) {
          return this.internal.loadVideoById(options);
        };
      },
      createPlayer: function(obj) {
        var that;

        that = this;
        if (OmniPlayer.loaded.YT) {
          return this.YT.build.apply(this);
        } else {
          window.onYouTubeIframeAPIReady = function() {
            OmniPlayer.loaded.YT = true;
            return that.YT.build.apply(that);
          };
          return this.YT.setup();
        }
      }
    };

    OmniPlayer.prototype.TEST = {
      createPlayer: function(obj) {
        return OmniPlayer.loaded.TEST = true;
      }
    };

    return OmniPlayer;

  })();

}).call(this);
