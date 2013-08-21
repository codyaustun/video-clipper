// Generated by CoffeeScript 1.6.2
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.VideoClipper = (function() {
    var questionBox, snippetButton;

    VideoClipper.prototype.startTime = "";

    VideoClipper.prototype.endTime = "";

    VideoClipper.prototype.caretPos = 0;

    VideoClipper.prototype.answerClass = "";

    VideoClipper.prototype.videoId = "";

    VideoClipper.prototype.videoType = "";

    VideoClipper.prototype.generate = true;

    VideoClipper.prototype.buttonID = "";

    VideoClipper.prototype.textareaID = "";

    VideoClipper.prototype.clips = [];

    questionBox = null;

    snippetButton = null;

    VideoClipper.reel = 'http://web.mit.edu/colemanc/www/bookmarklet/images/film3Small.png';

    VideoClipper.player = false;

    VideoClipper.playerV = false;

    VideoClipper.answerClass = "bookMarklet-answer";

    VideoClipper.generateHtml = true;

    VideoClipper.modalID = "";

    VideoClipper.clipper = "";

    VideoClipper.clippers = [];

    VideoClipper.prepared = {
      snippet: false
    };

    function VideoClipper(obj) {
      this.update = __bind(this.update, this);
      this.setup = __bind(this.setup, this);
      this.getCaretPosition = __bind(this.getCaretPosition, this);
      this.generateQuestionBox = __bind(this.generateQuestionBox, this);      obj = obj || {};
      this.textareaID = obj.textareaID;
      this.videoId = obj.videoId;
      this.videoType = obj.videoType;
      this.mediaContentUrl = obj.mediaContentUrl;
      this.thumbnailUrl = obj.thumbnailUrl;
      this.reel = obj.reel || VideoClipper.reel;
      this.answerClass = obj.answerClass || VideoClipper.answerClass;
      this.buttonID = obj.buttonID || "bl-" + this.videoType + this.videoId;
      this.generate = obj.generate !== void 0 ? obj.generate : VideoClipper.generateHtml;
      if (this.generate) {
        this.setup();
      }
      VideoClipper.clippers = VideoClipper.clippers.concat(this);
    }

    VideoClipper.prototype.generateQuestionBox = function() {
      var blDataEncoded, content, dataString, element, h, that, w;

      element = $("#" + this.textareaID);
      w = element.width();
      h = element.height();
      content = element.val();
      this.questionBox = element.after("<div></div>").css("display", "none").next();
      this.questionBox.attr({
        contenteditable: "true"
      }).addClass(this.answerClass).css({
        width: w,
        height: h
      });
      dataString = VideoClipper.generateBLDataString("generate", this);
      blDataEncoded = encodeURI(dataString);
      if ($('#' + this.buttonID).length > 0) {
        $('#' + this.buttonID).attr({
          "data-bl": blDataEncoded,
          rel: "blModal"
        });
      } else {
        this.questionBox.after("<input type='button' value='Snippet'>").next().attr({
          "data-bl": blDataEncoded,
          rel: "blModal",
          id: this.buttonID
        });
      }
      that = this;
      this.snippetButton = $('#' + this.buttonID);
      return this.snippetButton.click(function() {
        VideoClipper.openModal(this, that);
      });
    };

    VideoClipper.prototype.getCaretPosition = function(editableDiv) {
      var containerEl, range, sel, temp1, temp2;

      this.caretPos = 0;
      containerEl = null;
      sel = void 0;
      range = void 0;
      if (window.getSelection != null) {
        sel = window.getSelection();
        if (sel.rangeCount) {
          range = sel.getRangeAt(0);
          if (range.commonAncestorContainer.parentNode === editableDiv) {
            temp1 = range.endContainer.data;
            temp2 = range.commonAncestorContainer.parentNode.innerHTML.replace(/&nbsp;/g, String.fromCharCode(160));
            temp2 = VideoClipper.stripHTML(temp2);
            this.caretPos = range.endOffset + temp2.split(temp1)[0].length;
          }
        }
      }
      return this.caretPos;
    };

    VideoClipper.prototype.setup = function() {
      this.generateQuestionBox();
      return VideoClipper.generate(this);
    };

    VideoClipper.prototype.update = function(newTag) {
      var beginPos, currContent, endPos, newContent, newVal, that,
        _this = this;

      $(".bl-URL").text(newTag);
      currContent = this.questionBox.contents();
      newContent = [];
      beginPos = 0;
      endPos = 0;
      if (currContent.length === 0) {
        newContent = newTag;
      } else {
        currContent.each(function(i, e) {
          var back, eString, front;

          if (((e.nodeType === 3) || (e.nodeType === 1)) && (endPos < _this.caretPos)) {
            eString = "";
            if (e.nodeType === 3) {
              eString = e.data;
            } else {
              eString = e.text;
            }
            beginPos = endPos;
            endPos = endPos + eString.length;
            if (endPos >= _this.caretPos) {
              front = eString.substring(0, _this.caretPos - beginPos);
              back = eString.substring(_this.caretPos - beginPos, eString.length);
              newContent = newContent.concat(front);
              newContent = newContent.concat(newTag);
              newContent = newContent.concat(back);
            } else {
              newContent = newContent.concat(e);
            }
          } else {
            newContent = newContent.concat(e);
          }
        });
      }
      this.questionBox.text("");
      $(newContent).each(function(i, e) {
        return _this.questionBox.append(e);
      });
      newVal = this.questionBox.html();
      this.questionBox.prev().val(newVal);
      that = this;
      this.questionBox.find('[rel*=blModal]').click(function() {
        return VideoClipper.openModal(this, that);
      });
      return this.questionBox.find('[rel*=blModal]').each(function(index, element) {
        var data, endTime, startTime;

        data = VideoClipper.getBLData($(element));
        startTime = VideoClipper.secondsToTime(data.start);
        endTime = VideoClipper.secondsToTime(data.end);
        return $(element).qtip({
          style: {
            classes: 'qtip-rounded qtip-dark'
          },
          content: {
            text: "Start: " + startTime + " - End: " + endTime
          }
        });
      });
    };

    VideoClipper.checkErrors = function() {
      var endTime, startTime;

      startTime = parseFloat(VideoClipper.getStartTime());
      endTime = parseFloat(VideoClipper.getEndTime());
      if ((startTime < endTime || isNaN(endTime)) && (!isNaN(startTime))) {
        $("input[name='bl-start']").removeClass("bl-incorrect");
        $("input[name='bl-end']").removeClass("bl-incorrect");
        return true;
      } else {
        $("input[name='bl-start']").addClass("bl-incorrect");
        $("input[name='bl-end']").addClass("bl-incorrect");
        return false;
      }
    };

    VideoClipper.cleanUp = function() {
      var clipper, _i, _len, _ref;

      $('#bl').remove();
      $('#bl-vid').remove();
      $("#bookMarklet-overlay").remove();
      VideoClipper.prepared.snippet = false;
      _ref = VideoClipper.clippers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clipper = _ref[_i];
        if (clipper.questionBox != null) {
          clipper.questionBox.remove();
        }
      }
      return VideoClipper;
    };

    VideoClipper.clearInputs = function() {
      VideoClipper.setStartTime("");
      VideoClipper.setEndTime("");
      $("input[name='bl-start']").removeClass("bl-incorrect");
      $("input[name='bl-end']").removeClass("bl-incorrect");
      $(".bl-URL").text("Generated URL goes here");
      return VideoClipper;
    };

    VideoClipper.closeModal = function(modalID) {
      modalID = modalID || VideoClipper.modalID;
      $("#bookMarklet-overlay").fadeOut(200);
      $(modalID).css({
        display: "none"
      });
      if (modalID === "#bl") {
        VideoClipper.player.stopVideo();
      } else {
        if (modalID === "#bl-vid") {
          VideoClipper.playerV.stopVideo();
        }
      }
      return VideoClipper;
    };

    VideoClipper.generate = function(clipper) {
      var that;

      if (clipper != null) {
        this.generateSnippetBox(clipper);
      }
      this.generateVideoBox();
      this.generateOverlay();
      that = this;
      if (clipper == null) {
        $('[rel*=blModal]').click(function() {
          return that.openModal(this);
        });
        $('[rel*=blModal]').each(function(index, element) {
          var data, endTime, startTime;

          data = VideoClipper.getBLData($(element));
          startTime = VideoClipper.secondsToTime(data.start);
          endTime = VideoClipper.secondsToTime(data.end);
          return $(element).qtip({
            style: {
              classes: 'qtip-rounded qtip-dark'
            },
            content: {
              text: "Start: " + startTime + " - End: " + endTime
            }
          });
        });
      }
      return that;
    };

    VideoClipper.generateBLDataString = function(type, clipper) {
      var dataEnd, dataMediaContentUrl, dataStart, dataString, dataThumbnailUrl, dataVType, dataVid;

      dataString = "";
      dataVid = clipper.videoId;
      dataVType = clipper.videoType;
      dataMediaContentUrl = clipper.mediaContentUrl;
      dataThumbnailUrl = clipper.thumbnailUrl;
      if (type === "generate") {
        dataString = "{\"type\": \"generate\", \"modal\": \"#bl\"," + "\"video\": {" + "\"id\": \"" + dataVid + "\", \"type\": \"" + dataVType + "\", \"mediaContentUrl\":\"" + dataMediaContentUrl + "\", \"thumbnailUrl\":\"" + dataThumbnailUrl + "\"}}";
      } else if (type === "show") {
        dataStart = clipper.startTime;
        dataEnd = clipper.endTime;
        dataString = "{\"start\": \"" + dataStart + "\", \"end\": \"" + dataEnd + "\", \"type\": \"show" + "\", \"modal\": \"#bl-vid" + "\", \"video\": {" + "\"id\": \"" + dataVid + "\", \"type\": \"" + dataVType + "\", \"mediaContentUrl\":\"" + dataMediaContentUrl + "\", \"thumbnailUrl\":\"" + dataThumbnailUrl + "\"}}";
      }
      return dataString;
    };

    VideoClipper.generateOverlay = function() {
      if ($("#bookMarklet-overlay").length === 0) {
        $("<div id='bookMarklet-overlay'></div>").appendTo("body");
      }
      $("#bookMarklet-overlay").click(function() {
        return VideoClipper.closeModal();
      });
      return VideoClipper;
    };

    VideoClipper.generateSnippetBox = function(clipper) {
      var that;

      if ($("#bl").length === 0) {
        $("<div id='bl'>\n  <div class='bl-top'>\n    <div class='bl-vid'>\n      <div id='bl-player'></div>\n    </div>\n    <div class='bl-controls'>\n      <div class='bl-title'>\n        <h1>Create a Clip</h1>\n      </div>\n      <div class='bl-instructions'>\n        Click \"Start Time\" and \"End Time\" buttons,or by type in the time in the text boxes.\n      </div>\n      <table class='bl-input'>\n        <tr>\n          <td>\n            <input class='bl-button bl-start' type='button' value='Start Time'>\n          </td>\n          <td>\n          </td>\n          <td>\n            <input class='bl-button bl-end' type='button' value='End Time'>\n          </td>\n        </tr>\n        <tr>\n          <td>\n            <input class='bl-data' type='text' name='bl-start'>\n          </td>\n          <td>\n            -\n          </td>\n          <td>\n            <input class='bl-data' type='text' name='bl-end'>\n          </td>\n        </tr>\n        <tr>\n          <td>\n            <input class='bl-button bl-done' type='button' value='Done'>\n          </td>\n          <td>\n          </td>\n          <td>\n            <input class='bl-button bl-reset' type='button' value='Reset'>\n          </td>\n        </tr>\n      </table>\n      <textarea class='bl-URL'>\n        Generated URL goes here\n      </textarea>\n    </div>\n  </div>\n  <div class='bl-bottom'>\n    Source URL:<a class='bl-srcURL'></a>\n  </div>\n</div>").appendTo("body");
      }
      that = VideoClipper;
      clipper.questionBox.click(function(e) {
        clipper.caretPos = clipper.getCaretPosition(this);
      });
      clipper.questionBox.keyup(function(e) {
        var divText;

        clipper.caretPos = clipper.getCaretPosition(this);
        divText = $(this).html();
        $(this).prev().val(divText);
      });
      if (!VideoClipper.prepared.snippet) {
        $(".bl-start").click(function(e) {
          var currTime;

          currTime = VideoClipper.player.getCurrentTime();
          that.setStartTime(currTime);
          that.checkErrors();
        });
        $(".bl-end").click(function(e) {
          var currTime;

          currTime = VideoClipper.player.getCurrentTime();
          that.setEndTime(currTime);
          that.checkErrors();
        });
        $(".bl-done").click(function(e) {
          that.closeModal();
          that.clipper.update(that.generateTag(that.clipper));
        });
        $(".bl-reset").click(function(e) {
          VideoClipper.clearInputs();
          VideoClipper.player.cueVideoById({
            videoId: that.clipper.videoId,
            startSeconds: 0,
            suggestedQuality: "large"
          });
        });
        VideoClipper.prepared.snippet = true;
      }
      return VideoClipper;
    };

    VideoClipper.generateTag = function(clipper) {
      var blDataEncoded, dataString, newTag, that;

      clipper.startTime = VideoClipper.getStartTime();
      clipper.endTime = VideoClipper.getEndTime();
      if (VideoClipper.checkErrors()) {
        if (isNaN(parseFloat(clipper.endTime))) {
          clipper.endTime = VideoClipper.player.getDuration();
        }
        newTag = "";
        dataString = VideoClipper.generateBLDataString("show", clipper);
        blDataEncoded = encodeURI(dataString);
        newTag = $("<a rel='blModal' href='#bl-vid' class='bl'>" + blDataEncoded + "</a>").css({
          'background-image': clipper.reel
        });
        that = VideoClipper;
        clipper.clips = clipper.clips.concat(newTag);
        return newTag;
      } else {
        return "";
      }
    };

    VideoClipper.generateVideoBox = function() {
      if ($("#bl-vid").length === 0) {
        $("<div id='bl-vid'>\n  <div class='bl-video-wrap'>\n    <div id='bl-playerV'></div>\n  </div>\n</div>").appendTo("body");
      }
      return VideoClipper;
    };

    VideoClipper.getBLData = function(el) {
      var blData;

      blData = void 0;
      if (typeof ($(el).attr("data-bl")) !== "undefined") {
        blData = $.parseJSON(decodeURI($(el).attr("data-bl")));
      } else {
        if (typeof ($(el).text()) !== "undefined") {
          blData = $.parseJSON(decodeURI($(el).text()));
        }
      }
      return blData;
    };

    VideoClipper.openModal = function(element, clipper) {
      var blData, endTime, modalWidth, startTime, that, url, videoId, videoType;

      that = VideoClipper;
      VideoClipper.closeModal();
      blData = that.getBLData(element);
      VideoClipper.clipper = clipper;
      if (blData.type === "generate") {
        clipper.videoId = blData.video.id;
        clipper.videoType = blData.video.type;
        url = "";
        if (clipper.videoType === "YT") {
          url = "http://www.youtube.com/embed/" + clipper.videoId;
        }
        $(".bl-srcURL").attr("href", url);
        $(".bl-srcURL").text(url);
        VideoClipper.clearInputs();
        if (VideoClipper.player === false) {
          VideoClipper.player = new OmniPlayer({
            elementId: "bl-player",
            videoId: clipper.videoId,
            type: clipper.videoType,
            mediaContentUrl: clipper.mediaContentUrl,
            thumbnailUrl: clipper.thumbnailUrl
          });
        } else {
          VideoClipper.player.cueVideoById({
            mediaContentUrl: clipper.mediaContentUrl,
            thumbnailUrl: clipper.thumbnailUrl,
            videoId: clipper.videoId,
            startSeconds: 0,
            suggestedQuality: "large"
          });
        }
      } else {
        videoId = blData.video.id;
        startTime = blData.start;
        endTime = blData.end;
        videoType = blData.video.type;
        if (VideoClipper.playerV === false) {
          VideoClipper.playerV = new OmniPlayer({
            elementId: "bl-playerV",
            videoId: videoId,
            type: videoType,
            startSeconds: startTime,
            endSeconds: endTime
          });
        } else {
          if (VideoClipper.playerV.videoId !== videoId) {
            VideoClipper.playerV.cueVideoById({
              videoId: videoId,
              startSeconds: startTime,
              endSeconds: endTime,
              suggestedQuality: "large"
            });
          } else {
            VideoClipper.playerV.remove();
            VideoClipper.playerV = new OmniPlayer({
              elementId: "bl-playerV",
              videoId: videoId,
              type: videoType,
              startSeconds: startTime,
              endSeconds: endTime
            });
          }
        }
      }
      VideoClipper.modalID = blData.modal;
      modalWidth = $(VideoClipper.modalID).outerWidth();
      $("#bookMarklet-overlay").css({
        display: "block",
        opacity: 0
      });
      $("#bookMarklet-overlay").fadeTo(200, 0.5);
      $(VideoClipper.modalID).css({
        display: "block",
        position: "fixed",
        opacity: 0,
        "z-index": 11000,
        left: 50 + "%",
        "margin-left": -(modalWidth / 2) + "px",
        top: "100px"
      });
      $(VideoClipper.modalID).fadeTo(200, 1);
      return VideoClipper;
    };

    VideoClipper.stripHTML = function(html) {
      var tmp;

      tmp = document.createElement("DIV");
      tmp.innerHTML = html;
      return tmp.textContent || tmp.innerText;
    };

    VideoClipper.secondsToTime = function(seconds) {
      var hours, minutes, result;

      if (seconds === "") {
        return seconds;
      } else {
        seconds = parseFloat(seconds).toFixed(2);
        hours = parseInt(seconds / 3600);
        minutes = parseInt(seconds / 60) % 60;
        seconds = parseFloat(seconds % 60).toFixed(2);
        result = "";
        if (hours > 0) {
          if ((minutes / 10) < 1) {
            minutes = "0" + minutes;
          }
          if ((seconds / 10) < 1) {
            seconds = "0" + seconds;
          }
          result = "" + hours + ":" + minutes + ":" + seconds;
        } else if (minutes > 0) {
          if ((seconds / 10) < 1) {
            seconds = "0" + seconds;
          }
          result = "" + minutes + ":" + seconds;
        } else {
          result = "" + seconds;
        }
        return result;
      }
    };

    VideoClipper.timeToSeconds = function(time) {
      var amount, amounts, index, len, seconds, _i, _len;

      amounts = time.split(':');
      seconds = 0;
      len = amounts.length;
      for (index = _i = 0, _len = amounts.length; _i < _len; index = ++_i) {
        amount = amounts[index];
        seconds += parseFloat(amount) * Math.pow(60, len - (index + 1));
      }
      return seconds.toFixed(2);
    };

    VideoClipper.getEndTime = function() {
      var val;

      val = $("input[name='bl-end']").val();
      return this.timeToSeconds(val);
    };

    VideoClipper.getStartTime = function() {
      var val;

      val = $("input[name='bl-start']").val();
      return this.timeToSeconds(val);
    };

    VideoClipper.setEndTime = function(val) {
      val = this.secondsToTime(val);
      $("input[name='bl-end']").val(val);
      return val;
    };

    VideoClipper.setStartTime = function(val) {
      val = this.secondsToTime(val);
      $("input[name='bl-start']").val(val);
      return val;
    };

    return VideoClipper;

  }).call(this);

}).call(this);
