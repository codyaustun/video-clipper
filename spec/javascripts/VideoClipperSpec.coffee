describe "VideoClipper", ->

  it "should have VideoClipper class", ->
    @clippy = new VideoClipper
    expect(@clippy).toBeDefined()

  # Not sure if a constructor actually makes sense yet
  xdescribe "when constructing", ->
    beforeEach ->
      @clippy = new VideoClipper

    it "should give reel a default but allow it to be set", ->
      expect(@clippy.reel).not.toBeFalsy

      reelString = "http://web.mit.edu/colemanc/www/bookmarklet/images/film2Small.png"
      @clippy2 = new VideoClipper
        reel: reelString

      expect(@clippy2.reel).toEqual(reelString)

    it "should give answerClass a default but allow it to be set", ->
      expect(@clippy.answerClass).not.toBeFalsy

      answerClass = "VC-answer"
      @clippy2 = new VideoClipper
        answerClass: answerClass 

      expect(@clippy2.answerClass).toEqual(answerClass)

    it "should require vid to be set", ->
      vid = "d_z2CA-o13U"
      @clippy2 = new VideoClipper
        videoID: vid 

      expect(@clippy2.vid).toEqual(vid)

      # Should throw error
      expect('pending').toEqual('completed')

    it "should require videoType to be set", ->
      videoType = "yt"
      @clippy2 = new VideoClipper
        videoType: videoType

      expect(@clippy2.videoType).toEqual(videoType)
      # Should throw error
      expect('pending').toEqual('completed')

    it "should require textareaID to be set", ->
      expect('pending').toEqual('completed')

    it "should allow button to be turned off", ->
      expect('pending').toEqual('completed')

  describe 'when generating the output box', ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      textareaID = 'bl-text'
      @selector = '#'+textareaID

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        generate: false

    it 'should only have one element specified by textareaID', ->
      expect($(@selector).length).toBe(1)
        
    it 'should get height of the element with textareaID', ->
      heightSpy = spyOn($.fn, 'height')
      spyOn(@clippy, 'generateOutputBox').andCallThrough()
      @clippy.generateOutputBox()
      expect(@clippy.generateOutputBox).toHaveBeenCalled()
      expect($.fn.height).toHaveBeenCalled()
      expect(heightSpy.mostRecentCall.object.selector).toEqual(@selector)

    it 'should get width of the element with textareaID', ->
      widthSpy = spyOn($.fn, 'width')
      @clippy.generateOutputBox()
      expect($.fn.width).toHaveBeenCalled()
      expect(widthSpy.mostRecentCall.object.selector).toEqual @selector

    it 'should get the value of the element with textareaID', ->
      valSpy = spyOn $.fn, 'val'
      @clippy.generateOutputBox()
      expect($.fn.val).toHaveBeenCalled()
      expect(valSpy.mostRecentCall.object.selector).toEqual @selector

    it 'should insert of an answerClass div after the textarea', ->
      @clippy.generateOutputBox()
      textarea = $(@selector)
      expect(textarea.next()).toBe 'div'
      expect(textarea.next()).toHaveClass @clippy.answerClass

    it 'should make the divcontenteditable', ->
      @clippy.generateOutputBox()
      textarea = $(@selector)
      expect(textarea.next()).toHaveAttr 'contenteditable', 'true'

    it 'should make the div have the same height and width as the textarea', ->
      @clippy.generateOutputBox()
      textarea = $(@selector)
      div = textarea.next()
      expect(div.height()).toEqual textarea.height()
      expect(div.width()).toEqual textarea.width()

    it 'should generate a bl data string', ->
      spyOn(@clippy, 'generateBLDataString')
      @clippy.generateOutputBox()
      expect(@clippy.generateBLDataString).toHaveBeenCalledWith
        type: 'generate'
        vid: @clippy.vid
        vtype: @clippy.videoType

    describe 'without a buttonid specified', ->
      it 'should create a button after the outputbox div', ->
        @clippy.generateOutputBox()
        div = $(@selector).next()
        expect(div.next()).toBe 'input[type=button]'

      it "should set the rel attribute of the button to 'blModal'", ->
        @clippy.generateOutputBox()
        button = $(@selector).next().next()
        expect(button).toHaveAttr 'rel', 'blModal'

      it 'should store the encoded BLDataString in the bl-data attribute', ->
        @clippy.generateOutputBox()
        button = $(@selector).next().next()

        blData = @clippy.generateBLDataString
          type: 'generate'
          vid: @clippy.vid
          vtype: @clippy.videoType
        encoded = encodeURI(blData)
        expect(button).toHaveAttr 'data-bl', encoded

      it 'should make the button respond to clicks', ->
        @clippy.generateOutputBox()
        expect($("#"+@clippy.buttonID)).toHandle('click')

    describe 'with a buttonid specified', ->
      beforeEach ->
        @testID = "button-test"
        textareaID = 'bl-text'

        @clippy = new VideoClipper
          textareaID: textareaID
          videoID: '8f7wj_RcqYk'
          videoType: 'TEST'
          buttonID: @testID
          generate: false

      it "should set the rel attribute of the button to 'blModal'", ->
        @clippy.generateOutputBox()
        button = $('#'+@testID)
        expect(button).toHaveAttr 'rel', 'blModal'

      it 'should store the encoded BLDataString in the bl-data attribute', ->
        @clippy.generateOutputBox()
        button = $('#'+@testID)

        blData = @clippy.generateBLDataString
          type: 'generate'
          vid: @clippy.vid
          vtype: @clippy.videoType
        encoded = encodeURI(blData)
        expect(button).toHaveAttr 'data-bl', encoded

      it 'should make the button respond to clicks', ->
        @clippy.generateOutputBox()
        expect($("#"+@clippy.buttonID)).toHandle('click')

  describe 'when generating an overlay', ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')

      @clippy = new VideoClipper
        textareaID: 'bl-text'
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        generate: false

    it "should create a bookMarklet-overlay div if doesn't exist", ->
      expect($("#bookMarklet-overlay").length).toEqual 0
      appendSpy = spyOn($.fn, 'appendTo').andCallThrough()
      @clippy.generateOverlay()
      expect($("#bookMarklet-overlay").length).toEqual 1
      expect($.fn.appendTo).toHaveBeenCalled()

    describe 'and one already exists', ->

      it 'should not create another overlay', ->
        @clippy.generateOverlay()
        expect($("#bookMarklet-overlay").length).toEqual 1
        appendSpy = spyOn($.fn, 'appendTo').andCallThrough()
        @clippy.generateOverlay()
        expect($("#bookMarklet-overlay").length).toEqual 1
        expect($.fn.appendTo).not.toHaveBeenCalled()

    it 'should make the overlay respond to click', ->
      @clippy.generateOverlay()
      expect($("#bookMarklet-overlay")).toHandle('click')

    describe 'and the overlay is clicked', ->
      it 'should call closeModal', ->
        @clippy.generateOverlay()
        spyOn(@clippy, "closeModal").andCallThrough
        $("#bookMarklet-overlay").click()
        expect(@clippy.closeModal).toHaveBeenCalled()

  describe "when generating snippet box", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID
        generate: false

      @clippy.player = new OmniPlayer
        type: "TEST"
      @clippy.generateSnippetBox()

    it "should make the start button respond to clicks", ->
      expect($('.bl-start')).toHandle("click")

    describe "and the start button is clicked", ->
  
      it "should get the current time from the player", ->
        spyOn(@clippy.player, 'getCurrentTime').andCallThrough()
        spyOn(@clippy, 'checkErrors')
        $('.bl-start').click()
        expect(@clippy.player.getCurrentTime).toHaveBeenCalled()

      it "should set the bl-start input to the current time", ->
        spyOn(@clippy.player, 'getCurrentTime').andReturn(300)
        spyOn(@clippy, 'checkErrors')
        inputSelector = "input[name='bl-start']"
        valSpy = spyOn($.fn, 'val').andCallThrough()
        $('.bl-start').click()
        expect($.fn.val).toHaveBeenCalledWith(300)
        expect(valSpy.mostRecentCall.object.selector).toEqual inputSelector

      it "should check for errors", ->
        spyOn(@clippy, 'checkErrors')
        $('.bl-start').click()
        expect(@clippy.checkErrors).toHaveBeenCalled()


    it "should make the end button respond to clicks", ->
      expect($('.bl-end')).toHandle("click")

    describe 'and end button is clicked', ->
      it "should get the current time from the player", ->
        spyOn(@clippy.player, 'getCurrentTime').andCallThrough()
        spyOn(@clippy, 'checkErrors')
        $('.bl-end').click()
        expect(@clippy.player.getCurrentTime).toHaveBeenCalled()

      it "should set the bl-start input to the current time", ->
        spyOn(@clippy.player, 'getCurrentTime').andReturn(300)
        spyOn(@clippy, 'checkErrors')
        inputSelector = "input[name='bl-end']"
        valSpy = spyOn($.fn, 'val').andCallThrough()
        $('.bl-end').click()
        expect($.fn.val).toHaveBeenCalledWith(300)
        expect(valSpy.mostRecentCall.object.selector).toEqual inputSelector

      it "should check for errors", ->
        spyOn(@clippy, 'checkErrors')
        $('.bl-end').click()
        expect(@clippy.checkErrors).toHaveBeenCalled()

    it "should make the reset button respond to clicks", ->
      expect($(".bl-reset")).toHandle("click")

    describe 'and the reset button is clicked', ->
      it 'should clear the snippet box inputs', ->
        spyOn(@clippy, 'clearInputs')
        $('.bl-reset').click()
        expect(@clippy.clearInputs).toHaveBeenCalled

      it 'should load the video by id', ->
        spyOn(@clippy.player, 'loadVideoById')
        $('.bl-reset').click()
        expect(@clippy.player.loadVideoById).toHaveBeenCalledWith(@clippy.vid, 0, "large")

    it "should make the done button respond to clicks", ->
      expect($('.bl-done')).toHandle("click")

    describe 'and the done button is clicked', ->
      it 'should close the modal', ->
        spyOn(@clippy, 'closeModal')
        $('.bl-done').click()
        expect(@clippy.closeModal).toHaveBeenCalled()

      it 'should generate a new tag', ->
        spyOn(@clippy, 'generateTag')
        $('.bl-done').click()
        expect(@clippy.generateTag).toHaveBeenCalled()

      it 'should use the generated tag to update', ->
        testString = 'Testing 1 2 3'
        spyOn(@clippy, 'generateTag').andReturn(testString)
        spyOn(@clippy, 'update')
        $('.bl-done').click()
        expect(@clippy.update).toHaveBeenCalledWith(testString)

  describe "when generating video box", ->
    # Do I need to test this?

  describe "when setting up", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID
        generate: false

    it "should generate a video box", ->
      expect($('#bl-vid').length).toBe(0)
      spyOn(@clippy, 'generateVideoBox')
      @clippy.setup()
      expect(@clippy.generateVideoBox).toHaveBeenCalled()

    it "should generate a snippet box", ->
      expect($('#bl').length).toBe(0)
      spyOn(@clippy, 'generateSnippetBox')
      @clippy.setup()
      expect(@clippy.generateSnippetBox).toHaveBeenCalled()

    it "should generate the output box", ->
      spyOn(@clippy, 'generateOutputBox')
      @clippy.setup()
      expect(@clippy.generateOutputBox).toHaveBeenCalled()

    it "should generate the video clipper overlay", ->
      expect($('#bookmarklet-overlay').length).toBe(0)
      spyOn(@clippy, 'generateOverlay')
      @clippy.setup()
      expect(@clippy.generateOverlay).toHaveBeenCalled()

    describe 'with a valid output box', ->
      beforeEach ->
        onSpy = spyOn($.fn,'on').andCallThrough()
        @clippy.setup()

      it 'should make the output box respond to clicks', ->
        expect($("."+@clippy.answerClass)).toHandle('click')

      it 'should make the output box respond to keyups', ->
        expect($("."+@clippy.answerClass)).toHandle('keyup')


  describe 'when cleaning up', ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

    it 'should remove the div with id of bl', ->
      expect($('#bl')).toExist()
      VideoClipper.cleanUp()
      expect($('#bl')).not.toExist()

    it 'should remove the div with id of bl-vid', ->
      expect($('#bl-vid')).toExist()
      VideoClipper.cleanUp()
      expect($('#bl-vid')).not.toExist()

    it 'should remove the div with id of bookMarklet-overlay', ->
      expect($('#bookMarklet-overlay')).toExist()
      VideoClipper.cleanUp()
      expect($('#bookMarklet-overlay')).not.toExist()

  describe "when closing a modal window", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      $('#'+@testID).click()

    it "should fade out the overlay", ->
      fadeSpy = spyOn($.fn, 'fadeOut')
      @clippy.closeModal(@clippy.modalID)
      expect($.fn.fadeOut).toHaveBeenCalled()
      expect(fadeSpy.mostRecentCall.object.selector).toEqual "#bookMarklet-overlay"

    it "should hide the modal window", ->
      expect($(@clippy.modalID)).toBeVisible()
      @clippy.closeModal(@clippy.modalID)
      expect($(@clippy.modalID)).toBeHidden()

    it "should stop the video player", ->
      spyOn(@clippy.player, 'stopVideo')
      @clippy.closeModal(@clippy.modalID)
      expect(@clippy.player.stopVideo).toHaveBeenCalled()

  describe "when opening a modal window", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      @el = $('#'+@testID)
      @blData = @clippy.getBLData @el

    it "should get the data from the element", ->
      spyOn(@clippy, 'getBLData').andReturn @blData
      @clippy.openModal @el
      expect(@clippy.getBLData).toHaveBeenCalledWith @el

    describe "with a snippet box", ->
      beforeEach ->
        spyOn(@clippy, 'getBLData').andReturn @blData

      afterEach ->
        @clippy.closeModal @clippy.modalID

      it "should get video type and id", ->
        @clippy.openModal @el
        expect(@clippy.vid).toEqual @blData.video.id
        expect(@clippy.videoType).toEqual @blData.video.type

      it "should clear inputs", ->
        spyOn(@clippy, 'clearInputs').andCallThrough()
        @clippy.openModal @el
        expect(@clippy.clearInputs).toHaveBeenCalled()

      it "should create a video player if it doesn't exist", ->
        @clippy.openModal @el
        expect(@clippy.player).toEqual jasmine.any(OmniPlayer)

      it "should show snippet box", ->
        fadeSpy = spyOn($.fn,'fadeTo').andCallThrough()
        @clippy.openModal @el
        expect($.fn.fadeTo).toHaveBeenCalled()
        expect(fadeSpy.mostRecentCall.object.selector).toEqual('#bl')

    describe "with a video box", ->
      beforeEach ->
        @clippy.startTime = 200
        @clippy.endTime = 300
        @blData = $.parseJSON(@clippy.generateBLDataString({type: 'show'}))
        spyOn(@clippy, 'getBLData').andReturn @blData

      afterEach ->
        @clippy.closeModal @clippy.modalID

      it "should get video type, id, start time and end time", ->
        @clippy.openModal @el
        expect(@clippy.vid).toEqual @blData.video.id
        expect(@clippy.videoType).toEqual @blData.video.type
        expect(@clippy.startTime).toEqual @blData.start
        expect(@clippy.endTime).toEqual @blData.end

      it "should create a video player if it doesn't exist", ->
        @clippy.openModal @el
        expect(@clippy.playerV).toEqual jasmine.any(OmniPlayer)

      it "should show video box", ->
        fadeSpy = spyOn($.fn,'fadeTo').andCallThrough()
        @clippy.openModal @el
        expect($.fn.fadeTo).toHaveBeenCalled()
        expect(fadeSpy.mostRecentCall.object.selector).toEqual('#bl-vid')

    it "should show overlay", ->
      fadeSpy = spyOn($.fn,'fadeTo').andCallThrough()
      @clippy.openModal @el
      expect($.fn.fadeTo).toHaveBeenCalled()
      expect(fadeSpy.calls[0].object.selector).toEqual('#bookMarklet-overlay')
      @clippy.closeModal @clippy.modalID

  describe "when checking for errors", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

    it "should parse floats from the  start input box", ->
      $("input[name='bl-start']").val("300")
      @clippy.checkErrors()
      expect(@clippy.startTime).toEqual 300

    it "should parse floats from the  end input box", ->
      $("input[name='bl-end']").val("300")
      @clippy.checkErrors()
      expect(@clippy.endTime).toEqual 300

    describe 'if correct', ->
      beforeEach ->
        $("input[name='bl-start']").val("300")
        $("input[name='bl-end']").val("400")

      it "should remove incorrect highlighting class", ->
        $("input[name='bl-start']").addClass "bl-incorrect"
        $("input[name='bl-end']").addClass "bl-incorrect"
        @clippy.checkErrors()
        expect($("input[name='bl-start']")).not.toHaveClass "bl-incorrect"
        expect($("input[name='bl-end']")).not.toHaveClass "bl-incorrect"

      it "should return true", ->
        expect(@clippy.checkErrors()).toBeTruthy()      


    describe 'if incorrect', ->
      beforeEach ->
        $("input[name='bl-start']").val("400")
        $("input[name='bl-end']").val("300")

      it "should add incorrect highlighting class", -> 
        @clippy.checkErrors()
        expect($("input[name='bl-start']")).toHaveClass "bl-incorrect"
        expect($("input[name='bl-end']")).toHaveClass "bl-incorrect"

      it 'should return false', ->
        expect(@clippy.checkErrors()).toBeFalsy() 

  describe "when getting data from an element", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      @testDataGenerate = encodeURI @clippy.generateBLDataString
        type: 'generate'

      @testDataShow = encodeURI @clippy.generateBLDataString
        type: 'show'
        start: '200'
        end: '300'
      
      $('body').append("<div id='test'></div>")

    afterEach ->
      $('#test').remove()

    it "should check if it has a data-bl attribute", ->
      el = $('#test').attr('data-bl', @testDataGenerate)
      attrSpy = spyOn($.fn, 'attr').andCallThrough()
      @clippy.getBLData(el)
      expect($.fn.attr).toHaveBeenCalledWith('data-bl')
      expect(attrSpy.calls[0].object).toEqual(el)

    describe "with a data-bl attribute", ->
      beforeEach ->
        @el = $('#test').attr 'data-bl', @testDataGenerate

      it 'should get the encoded data from the data-bl attribute', ->
        attrSpy = spyOn($.fn, 'attr').andCallThrough()
        @clippy.getBLData @el
        expect($.fn.attr.calls.length).toEqual 2
        expect(attrSpy.calls[1].object).toEqual @el

      it "should parse a JSON object from the data-bl attribute", ->
        spyOn($, 'parseJSON')
        @clippy.getBLData @el
        expect($.parseJSON).toHaveBeenCalledWith decodeURI @testDataGenerate

      it "should produce a valid JSON object with the correct data", ->
        blData = @clippy.getBLData @el
        expect(blData).toEqual $.parseJSON decodeURI @testDataGenerate

    describe "without a data-bl attribute", ->
      beforeEach ->
        @el = $('#test').text @testDataShow

      it 'should get the encoded data from the elements tesxt', ->
        textSpy = spyOn($.fn, 'text').andCallThrough()
        @clippy.getBLData @el
        expect($.fn.text).toHaveBeenCalled()
        expect(textSpy.calls[0].object).toEqual(@el)


      it "should parse a JSON object from the elements text", ->
        spyOn($, 'parseJSON')
        @clippy.getBLData @el
        expect($.parseJSON).toHaveBeenCalledWith decodeURI @testDataShow

      it "should produce a valid JSON object with the correct data", ->
        blData = @clippy.getBLData @el
        expect(blData).toEqual $.parseJSON decodeURI @testDataShow


  describe "when clearing start and end time inputs", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

    it "should clear values for input box in the snippet box", ->
      $("input[name='bl-end']").val 200
      $("input[name='bl-start']").val 300
      @clippy.clearInputs()
      expect($("input[name='bl-end']").val()).toEqual ""
      expect($("input[name='bl-start']").val()).toEqual ""      

    it "should clear values for the textarea in the snippet box", ->
      $(".bl-URL").text "Testing 1.. 2.. 3.."
      @clippy.clearInputs()
      expect($(".bl-URL").text()).toEqual "Generated URL goes here"

    it "should remove the bl-incorrect class from the input boxes", ->
      $("input[name='bl-end']").addClass "bl-incorrect"
      $("input[name='bl-start']").addClass "bl-incorrect"
      @clippy.clearInputs()
      expect($("input[name='bl-start']")).not.toHaveClass "bl-incorrect"
      expect($("input[name='bl-end']")).not.toHaveClass "bl-incorrect"

  describe "when updating an output box", -> 
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      @clippy.startTime = '300'
      @clippy.endTime = '400'

      data = encodeURI @clippy.generateBLDataString
        type: 'show'
      @newTag = $("<a rel='blModal' href='#bl-vid' class='bl'>"+data+"</a>").
        css
          'background-image': @reel

      $('body').append("<div id='test'></div>")

    afterEach ->
      $('#test').remove()

    it "should put the new link into the .bl-URL textarea", ->
      textSpy = spyOn($.fn, 'text').andCallThrough()
      @clippy.update(@newTag)
      expect($('.bl-URL')).toContainText(@newTag)

    it "should get the question's current contents", ->
      contentSpy = spyOn($.fn, 'contents').andCallThrough()
      @clippy.update(@newTag)
      expect($.fn.contents).toHaveBeenCalled()
      expect(contentSpy.mostRecentCall.object.selector).
        toEqual "."+@clippy.answerClass

    describe "that doesn't already have contents", ->
      it "the div's text equal the new link", ->
        console.log $('.'+@clippy.answerClass).contents().length
        @clippy.update(@newTag)
        expect($('.'+@clippy.answerClass).find('a').text()).
          toEqual @newTag.text()

    describe 'that already has contents', ->
      it "should iterate through the question's text and html", ->
        expect('pending').toEqual('completed')

      it "should place the new link at the caret position", ->
        expect('pending').toEqual('completed')

      it "should replace the question's content with the new content", ->
        expect('pending').toEqual('completed')

    it "should update the question's textarea", ->
      expect('pending').toEqual('completed')

  describe "when generating a clip's a tag", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      @el = $('#'+@testID)
      @blData = @clippy.getBLData @el

      @clippy.openModal @el

    afterEach ->
      @clippy.closeModal()

    it "should get start time from the snippet box", ->
      $("input[name='bl-start']").val("200.5")
      valSpy = spyOn($.fn, "val").andCallThrough()
      @clippy.generateTag()
      expect($.fn.val).toHaveBeenCalled()
      expect(@clippy.startTime).toEqual 200.5
      expect(valSpy.calls[0].object.selector).toEqual("input[name='bl-start']")

    it "should get end time from the snippet box", ->
      $("input[name='bl-end']").val("300.5")
      valSpy = spyOn($.fn, "val").andCallThrough()
      @clippy.generateTag()
      expect($.fn.val).toHaveBeenCalled()
      expect(@clippy.endTime).toEqual 300.5
      expect(valSpy.calls[1].object.selector).toEqual("input[name='bl-end']")


    it "should check for errors in the start and end times", ->
      spyOn(@clippy, 'checkErrors').andCallThrough()
      @clippy.generateTag()
      expect(@clippy.checkErrors).toHaveBeenCalled()


    describe "with correct values", ->
      beforeEach ->
        $("input[name='bl-start']").val("200.5")
        $("input[name='bl-end']").val("300.5")
  
      it "should set the endTime to the video duration if it isn't defined", ->
        $("input[name='bl-end']").val("")
        spyOn(@clippy.player, 'getDuration').andReturn 400
        @clippy.generateTag()
        expect(@clippy.player.getDuration).toHaveBeenCalled()

      it "should generate a show data JSON string", ->
        spyOn(@clippy, 'generateBLDataString').andCallThrough()
        @clippy.generateTag()
        expect(@clippy.generateBLDataString).toHaveBeenCalled()

      it "should encode the data string", ->
        spyOn(window, 'encodeURI')
        str = 'Test'
        spyOn(@clippy, 'generateBLDataString').andReturn (str)
        @clippy.generateTag()
        expect(window.encodeURI).toHaveBeenCalledWith(str)
  

      it "should create an a tag with the encodedData in the text", ->
        str = 'Test'
        spyOn(@clippy, 'generateBLDataString').andReturn (str)
        tag = @clippy.generateTag()
        expect(tag).toBe 'a'
        expect(tag.text()).toEqual encodeURI str

      it "should return the tag", ->
        tag = @clippy.generateTag()
        expect(tag).toBe 'a'

      it 'should make the tag respond to click', ->
        tag = @clippy.generateTag()
        expect(tag).toHandle 'click'

      describe 'the generated tag', ->
        it 'should open a modal window when click', ->
          spyOn(@clippy,'openModal')
          tag = @clippy.generateTag()
          tag.click()
          expect(@clippy.openModal).toHaveBeenCalled()
  

    describe "without correct values", ->

      it "should return and empty string", ->
        spyOn(@clippy, 'checkErrors').andReturn false
        expect(@clippy.generateTag()).toEqual ""  

  describe "when generating JSON clip data", ->
    beforeEach -> 
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'
      @vid = '8f7wj_RcqYk'
      @videoType = 'TEST'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoID: @vid
        videoType: @videoType
        buttonID: @testID

    describe "with a type of 'generate' ", ->
      beforeEach ->
        dataString = @clippy.generateBLDataString
          type: 'generate'
        @blData = $.parseJSON dataString

      it 'should create a JSON string with a type of generate', ->
        expect(@blData.type).toEqual "generate"

      it 'should use the vid of the instance in the JSON string', ->
        expect(@blData.video.id).toEqual @vid

      it 'should use the type of the instance in the JSON string', ->
        expect(@blData.video.type).toEqual @videoType

      describe 'and defaults values', ->
        beforeEach ->
          @obj = 
            type: "generate"
            vid: 'Test123'
            vtype: 'YT'

          dataString = @clippy.generateBLDataString(@obj)
          @blData = $.parseJSON dataString

        it 'should use the vid of the argument in the JSON string', ->
          expect(@blData.video.id).toEqual @obj.vid

        it 'should use the type of the argument in the JSON string', ->
          expect(@blData.video.type).toEqual @obj.vtype


    describe "with a type of 'show", ->
      beforeEach ->
        @startTime = '200'
        @endTime = '300'

        @clippy.startTime = @startTime
        @clippy.endTime = @endTime

        dataString = @clippy.generateBLDataString
          type: 'show'
        @blData = $.parseJSON dataString

      it 'should create a JSON string with a type of show', ->
        expect(@blData.type).toEqual "show"

      it 'should use the vid of the instance in the JSON string', ->
        expect(@blData.video.id).toEqual @vid

      it 'should use the type of the instance in the JSON string', ->
        expect(@blData.video.type).toEqual @videoType

      it 'should use the start time of the instance in the JSON string', ->
        expect(@blData.start).toEqual @startTime

      it 'should use the end time of the instance in the JSON string', ->
        expect(@blData.end).toEqual @endTime


      describe 'and defaults values', ->
        beforeEach ->
          @obj = 
            type: "show"
            vid: 'Test123'
            vtype: 'YT'
            start: '400'
            end: '500'

          dataString = @clippy.generateBLDataString(@obj)
          @blData = $.parseJSON dataString

        it 'should use the vid of the argument in the JSON string', ->
          expect(@blData.video.id).toEqual @obj.vid

        it 'should use the type of the argument in the JSON string', ->
          expect(@blData.video.type).toEqual @obj.vtype

        it 'should use the start time of the argument in the JSON string', ->
          expect(@blData.start).toEqual @obj.start

        it 'should use the end time of the argument in the JSON string', ->
          expect(@blData.end).toEqual @obj.end


    describe "without a type", ->

      it "should return an empty string", ->
        expect(@clippy.generateBLDataString()).toEqual ""
  

  describe "when getting caret position", ->

    it 'should check to see if there is a window selection', ->
      spyOn(window, 'getSelection').andReturn false

      expect(window.getSelection).toHaveBeenCalled()

    describe 'and the window selection exists', ->
      it 'should get the window selection', ->
        spyOn(window, 'getSelection').andReturn false

        expect(window.getSelection).toHaveBeenCalled()


  # describe "when stripping html", ->

  #   it "should create a div", ->
  #     expect('pending').toEqual('completed')

  #   it "should put the html into the div's innerHTML", ->
  #     expect('pending').toEqual('completed')

  #   it "should return div's textContent or innerText", ->
  #     expect('pending').toEqual('completed')

