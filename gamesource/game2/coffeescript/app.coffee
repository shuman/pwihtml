class Game
  constructor: (el) ->
    @canvas = document.getElementById(el)
    @ctx = @canvas.getContext('2d')
    @_resizeCanvas()
    window.addEventListener 'resize', =>
      @_resizeCanvas()

    @envelope = new Envelope @ctx,
      texture: 'images/rsz_email_logo.png'
      size:
        w: 200
        h: 200
      pos:
        x: 1400
        y: 400

    @catapultBase = new Sprite @ctx,
      texture: 'images/rsz_catapult_base.png'
      size:
        w: 200
        h: 142
      pos:
        x: 200
        y: 938

    @catapultArm = new CatapultArm @ctx,
      texture: 'images/rsz_catapult_arm.png'
      size:
        w: 200
        h: 142
      pos:
        x: 210
        y: 880

    @sprites = [@envelope, @catapultArm, @catapultBase]

  run: ->
    setInterval ( =>
      @_clear()
      if @ball
        @_checkCollision() if @ball.pos.x + @ball.radius>= @envelope.pos.x
        @_checkBounds()
      @_render()
    ), 5
    @_controlCatapult()

  _resizeCanvas: ->
    @canvas.style.height = "#{@canvas.parentNode.clientHeight}px"
    @canvas.style.width = "#{parseInt(@canvas.style.height) / 9 * 16}px"
    if parseInt(@canvas.style.width) > @canvas.parentNode.clientWidth
      @canvas.style.width = "#{@canvas.parentNode.clientHeight}px"
      @canvas.style.height = "#{parseInt(@canvas.style.width) / 16 * 9}px"
    # @canvas.parentNode.style.maxWidth = @canvas.style.width
    @ctx.w = parseInt(@canvas.style.width)
    @ctx.h = parseInt(@canvas.style.height)

  _clear: =>
    @ctx.clearRect 0, 0, 1920, 1080

  _render: =>
    @sprites.forEach (s) -> s.draw()

  _controlCatapult: =>
    isPressed = false
    mY = 0
    startPosition = 0

    clickStart = (e) =>
      e.preventDefault()
      isPressed = true if @catapultArm.available
      startPosition = e.pageY
      startPosition = e.touches[0].pageY if e.touches
    clickEnd = =>
      isPressed = false
      @catapultArm.strength = @catapultArm.currentAngle
      @_shot() if @catapultArm.available and (@catapultArm.currentAngle < 0)
      @catapultArm.currentAngle = 0
      mY = 0
      startPosition = 0
    cursorMove = (e) =>
      e.preventDefault()
      if isPressed and @catapultArm.available
        pageY = e.pageY
        pageY = e.touches[0].pageY if e.touches
        if (pageY < mY) and (@catapultArm.currentAngle <= 0)
          @catapultArm.currentAngle = startPosition - pageY
        else if (@catapultArm.currentAngle >= -@catapultArm.availableAngle) and
                (@catapultArm.currentAngle <= 0)
          @catapultArm.currentAngle = startPosition - pageY
        mY = pageY

    @canvas.addEventListener 'mousedown', clickStart
    @canvas.addEventListener 'mouseup', clickEnd
    @canvas.addEventListener 'mousemove', cursorMove
    @canvas.addEventListener 'touchstart', clickStart
    @canvas.addEventListener 'touchend', clickEnd
    @canvas.addEventListener 'touchmove', cursorMove

  _checkCollision: =>
    return false unless @ball
    circle =
      x: @ball.pos.x
      y: @ball.pos.y
      r: @ball.radius
    rect =
      x: @envelope.pos.x
      y: @envelope.pos.y
      w: @envelope.size.w
      h: @envelope.size.h
    if @_rectCircleColliding(circle, rect)
      @_deleteBall()
      @envelope.notifications++

  _rectCircleColliding: (circle, rect) ->
    distX = Math.abs(circle.x - rect.x - rect.w / 2)
    distY = Math.abs(circle.y - rect.y - rect.h / 2)

    return false if (distX > (rect.w / 2 + circle.r))
    return false if (distY > (rect.h / 2 + circle.r))

    return true if (distX <= (rect.w / 2))
    return true if (distY <= (rect.h / 2))

    dx = distX - rect.w / 2;
    dy = distY - rect.h / 2;
    dx * dx + dy * dy <= (circle.r*circle.r)

  _checkBounds: =>
    if @ball? and ((1920 < @ball.pos.x) or (1080 < @ball.pos.y))
      @_deleteBall()

  _deleteBall: =>
    @sprites.pop()
    @ball = null
    @catapultArm.available = true
    @catapultArm.strength = 0

  _shot: =>
    @ball = new Ball @ctx,
      strength: @catapultArm.strength
      radius: 25
      pos:
        x: @catapultArm.pos.x
        y: @catapultArm.pos.y
    @sprites.push @ball
    @catapultArm.available = false



class Sprite
  constructor: (ctx, obj) ->
    @ctx = ctx
    @img = new Image()
    @_loadImage(obj.texture) if obj.texture
    @size = obj.size
    @pos = obj.pos

  draw: ->
    @ctx.drawImage @img, parseInt(@pos.x), parseInt(@pos.y), @size.w, @size.h

  _loadImage: (url) =>
    img = new Image
    img.src = url
    img.onload = =>
      @img = img

class Envelope extends Sprite
  constructor: (ctx, obj) ->
    super(ctx, obj)
    @direction = 1
    @availableHeight = 100
    @startPosition =
      x: obj.pos.x
      y: obj.pos.y
    @notifications = 0

  draw: ->
    @pos.y += @direction
    @_checkBounds()
    super()
    @_drawNotifications()

  _checkBounds: =>
    if (@pos.y < (@startPosition.y - @availableHeight)) || (@pos.y > (@startPosition.y + @availableHeight))
          @direction *= -1

  _drawNotifications: =>
    if @notifications > 0
      radius = 30
      @ctx.beginPath()
      @ctx.arc(@pos.x + @size.w, @pos.y, radius, 0, 2 * Math.PI, false)
      @ctx.fillStyle = 'red'
      @ctx.fill()
      @ctx.font = "bold #{radius}px sans-serif"
      @ctx.textBaseline = 'middle'
      @ctx.textAlign = 'center'
      @ctx.fillStyle = 'white'
      @ctx.fillText @notifications, @pos.x + @size.w, @pos.y, radius

class CatapultArm extends Sprite
  constructor: (ctx, obj) ->
    super(ctx, obj)
    @availableAngle = 70
    @currentAngle = 0
    @strength = 0
    @available = true

  draw: ->
    @ctx.save()
    @ctx.translate(@pos.x + (@size.w / 2), @pos.y + (@size.h / 2))
    @ctx.rotate @_toRadians(@currentAngle)
    @_drawBall() if @available
    @ctx.drawImage @img, parseInt(-(@size.w / 2)), parseInt(-(@size.h / 2)), @size.w, @size.h
    @ctx.restore()

  _toRadians: (angle) ->
    angle * (Math.PI / 180)

  _drawBall: ->
    radius = 25
    @ctx.beginPath()
    @ctx.arc(-(@size.w / 2 - 30), -(@size.h / 2 - 15), radius, 0, 2 * Math.PI, false)
    @ctx.fillStyle = 'red'
    @ctx.fill()

class Ball extends Sprite
  constructor: (ctx, obj) ->
    super(ctx, obj)
    @radius = obj.radius
    @strength = obj.strength
    @vel =
      x: 4.0
      y: @strength/10
    @gravity = 0.03

  draw: ->
    @ctx.beginPath()
    @ctx.arc(@pos.x, @pos.y, @radius, 0, 2 * Math.PI, false)
    @vel.y += @gravity
    @pos.x += @vel.x
    @pos.y += @vel.y
    @ctx.fillStyle = 'red'
    @ctx.fill()

@app = new Game('game')
@app.run()
