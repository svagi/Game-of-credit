###
Copyright 2015 Jan Svager & Michael Muller

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
Key = require("keymaster")

class Controls

  offset: 10
  velocity: new THREE.Vector3
  speed: 10

  # Events
  animation: "stand"
  fired: false
  jumped: false
  moved: false
  sprinted: false

  constructor: (camera, @defaultPosition, @objects) ->
    @cameraPitch = camera
    @cameraYaw = camera
    @cameraYaw = new THREE.Object3D
    @cameraYaw.add(@cameraPitch)
    @cameraYaw.position.copy(@defaultPosition)
    @setProps()

    @rayCaster = new THREE.Raycaster()
    @rayCaster_under = new THREE.Raycaster()
    @height = @defaultPosition.y

  setProps: ->
    @position = @cameraYaw.position
    x = @cameraPitch.rotation._x
    y = @cameraYaw.rotation._y
    @rotation = new THREE.Vector3(x, y, 0)
    @animation = "stand"
    @animation = "crwalk" if @moved
    @animation = "jump" if @jumped
    @animation = "run" if @moved and @sprinted
    @animation = "attack" if @fired

  getCamera: ->
    @cameraYaw

  getIntersect: (direction) ->
    @rayCaster.set(new THREE.Vector3(@cameraYaw.position.x, @cameraYaw.position.y-5, @cameraYaw.position.z), direction)
    @rayCaster.far = if @sprinted then @speed * 2 else @speed
    intersections = @rayCaster.intersectObjects(@objects)
    console.log(@cameraYaw.position.y-11)
    return true if intersections.length > 0

  update: (delta, pointerLocked) ->
    # Gravity
    @velocity.y -= 9.823 * 3.0 * delta

    # Controls
    keyW = Key.isPressed("W")
    keyS = Key.isPressed("S")
    keyA = Key.isPressed("A")
    keyD = Key.isPressed("D")

    # Check if moving with sprint
    @moved = keyW or keyS or keyA or keyD
    @sprinted = Key.shift
    speed = if @sprinted then @speed * 2 else @speed

    # Intersects
    @rayCaster_under.set(@cameraYaw.position, new THREE.Vector3(0, -1, 0))
    intersections = @rayCaster_under.intersectObjects(@objects)
    intersect = intersections[0] if intersections.length > 0
    distance = Math.round(intersect.distance)
    @height = Math.abs(Math.round(@cameraYaw.position.y - distance)) + @defaultPosition.y

    x = -Math.sin(@cameraYaw.rotation._y)
    z = -Math.cos(@cameraYaw.rotation._y)
    x30 = -Math.sin(@cameraYaw.rotation._y + Math.PI/6)
    z30 = -Math.cos(@cameraYaw.rotation._y + Math.PI/6)
    x30m = -Math.sin(@cameraYaw.rotation._y - Math.PI/6)
    z30m = -Math.cos(@cameraYaw.rotation._y - Math.PI/6)
    if (@getIntersect(new THREE.Vector3(x, 0, z)) or @getIntersect(new THREE.Vector3(x30, 0, z30)) or @getIntersect(new THREE.Vector3(x30m, 0, z30m)))
      console.log(x30)
      intersectFront = false
    else
      intersectFront = true

    x = Math.sin(@cameraYaw.rotation._y)
    z = Math.cos(@cameraYaw.rotation._y)
    x30 = Math.sin(@cameraYaw.rotation._y + Math.PI/6)
    z30 = Math.cos(@cameraYaw.rotation._y + Math.PI/6)
    x30m = Math.sin(@cameraYaw.rotation._y - Math.PI/6)
    z30m = Math.cos(@cameraYaw.rotation._y - Math.PI/6)
    if (@getIntersect(new THREE.Vector3(x, 0, z)) or @getIntersect(new THREE.Vector3(x30, 0, z30)) or @getIntersect(new THREE.Vector3(x30m, 0, z30m)))
      intersectBack = false
    else
      intersectBack = true

    x = -Math.sin(@cameraYaw.rotation._y + Math.PI/2)
    z = -Math.cos(@cameraYaw.rotation._y + Math.PI/2)
    x30 = -Math.sin(@cameraYaw.rotation._y + Math.PI/2 + Math.PI/6)
    z30 = -Math.cos(@cameraYaw.rotation._y + Math.PI/2 + Math.PI/6)
    x30m = -Math.sin(@cameraYaw.rotation._y + Math.PI/2 - Math.PI/6)
    z30m = -Math.cos(@cameraYaw.rotation._y + Math.PI/2 - Math.PI/6)
    if (@getIntersect(new THREE.Vector3(x, 0, z)) or @getIntersect(new THREE.Vector3(x30, 0, z30)) or @getIntersect(new THREE.Vector3(x30m, 0, z30m)))
      intersectLeft = false
    else
      intersectLeft = true

    x = Math.sin(@cameraYaw.rotation._y + Math.PI/2)
    z = Math.cos(@cameraYaw.rotation._y + Math.PI/2)
    x30 = Math.sin(@cameraYaw.rotation._y + Math.PI/2 + Math.PI/6)
    z30 = Math.cos(@cameraYaw.rotation._y + Math.PI/2 + Math.PI/6)
    x30m = Math.sin(@cameraYaw.rotation._y + Math.PI/2 - Math.PI/6)
    z30m = Math.cos(@cameraYaw.rotation._y + Math.PI/2 - Math.PI/6)
    if (@getIntersect(new THREE.Vector3(x, 0, z)) or @getIntersect(new THREE.Vector3(x30, 0, z30)) or @getIntersect(new THREE.Vector3(x30m, 0, z30m)))
      intersectRight = false
    else
      intersectRight = true

    if @moved and pointerLocked
      @velocity.z -= speed * delta if keyW and intersectFront
      @velocity.z += speed * delta if keyS and intersectBack
      @velocity.x -= speed * delta if keyA and intersectLeft
      @velocity.x += speed * delta if keyD and intersectRight

    # Jumping
    if Key.isPressed("space")
      @velocity.y += 7.0 if not @jumped
      @jumped = true

    # Actual moving of player
    @cameraYaw.translateX(@velocity.x)
    @cameraYaw.translateY(@velocity.y)
    @cameraYaw.translateZ(@velocity.z)

    # Ground check
    if @cameraYaw.position.y < @height
      @jumped = false
      @velocity.y = 0
      @cameraYaw.position.y = @height

    @velocity.x -= @velocity.x * 10.0 * delta
    @velocity.z -= @velocity.z * 10.0 * delta

    # Set class properties based on class states
    @setProps()

  handleMouseMove: (event) ->
    movementX = event["movementX"] or event["mozMovementX"] or event["webkitMovementX"] or 0
    movementY = event["movementY"] or event["mozMovementY"] or event["webkitMovementY"] or 0
    @cameraYaw.rotation.y -= movementX * 0.002
    @cameraPitch.rotation.x -= movementY * 0.002
    @cameraPitch.rotation.x = Math.max(-Math.PI/2, Math.min(Math.PI/2, @cameraPitch.rotation.x))

module.exports = Controls