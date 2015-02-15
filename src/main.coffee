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
"use strict"

require("./css/style.css")

React = require("react")
Game = require("./components/Game")
mapping = require("./mapping.json")
helpers = require("./modules/helpers")
{div} = React.DOM

App = React.createClass

  textures: {}
  player: {}

  getInitialState: ->
    loading: true
    init: false

  handleLoading: (item, loaded, total) ->
    # console.log "#{Math.round(100 * loaded / total)} %\t #{item}"
    if loaded == total and not @state.init
      @heightMap = helpers.getImageData(@textures.heightMap.image)
      @setState {init: true}, @init

  componentWillMount: ->
    # Loading textures
    THREE.DefaultLoadingManager.onProgress = @handleLoading
    for key, path of mapping["textures"]
      if typeof path is 'string'
        @textures[key] = new THREE.ImageUtils.loadTexture(path)
      else
        @textures[key] = new THREE.ImageUtils.loadTextureCube(path)

  init: ->
    x = Math.floor(Math.random() * @heightMap.width)
    z = Math.floor(Math.random() * @heightMap.height)
    y = helpers.getPixel(@heightMap, x, z).r
    x -= @heightMap.width / 2
    z -= @heightMap.width / 2
    @position = new THREE.Vector3(x, y, z)
    @setState(loading: false)
    console.log "INIT position", @position

  render: ->
    if @state.loading
      div {id: "loading"}, "Loading..."
    else
      Game
        position: @position
        textures: @textures
        heightMap: @heightMap

React.render(React.createElement(App), document.getElementById("app"))