/**
 * Copyright 2015 Jan Svager
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @providesModule gameEngine
 **/

/* global THREE */
import { createModels } from "./Models";
import { getKeyFromCode } from "./Utils";

/**
 * Game engine factory
 * @param props {Object}
 * @return {Object} with public methods and properties
 */
export function createEngine(props) {

  const {
    emitter,
    // canvas
    canvasWidth = 0,
    canvasHeight = 0,
    // player
    speed = 20,
    position = [0, 0, 0],
    rotation = [0, 0, 0],
    } = props;

  const aspect = canvasWidth / canvasHeight;
  const velocity = new THREE.Vector3();
  const rayCaster = new THREE.Raycaster();
  const rayDirections = {
    down: new THREE.Vector3(0, -1, 0),
    front: new THREE.Vector3(0, 0, -1)
  };
  const defaultHeight = 10;

  const renderer = new THREE.WebGLRenderer(props.renderer);
  const scene = new THREE.Scene();
  const clock = new THREE.Clock();

  const camera = new THREE.PerspectiveCamera(45, aspect, 1, 10000);
  const cameraPitch = camera;
  const cameraYaw = new THREE.Object3D();

  const ambientLight = new THREE.AmbientLight(0x404040);
  const directionalLight = new THREE.DirectionalLight(0xffffff, 0.7);

  const models = createModels(props.textures);

  var delta = 0.0;
  var mouse = {
    x: 0,
    y: 0
  };
  var keys = {
    W: false,
    A: false,
    S: false,
    D: false,
    SPACE: false
  };
  var isJumping = false;
  var intersections;
  var distance;
  var height;

  // EVENTS
  const { eventTypes } = emitter;

  emitter.addListener(eventTypes.CLICK, () => {

  });
  emitter.addListener(eventTypes.MOUSE_MOVE, newMouse => {
    if (mouse.x !== newMouse.x || mouse.y !== newMouse.y) {
      mouse = newMouse;
      cameraYaw.rotation.y -= mouse.x * 0.002;
      cameraPitch.rotation.x -= mouse.y * 0.002;
      cameraPitch.rotation.x = Math.max(
        -Math.PI / 2, Math.min(Math.PI / 2, cameraPitch.rotation.x)
      );
    }
  });
  emitter.addListener(eventTypes.KEY_DOWN, getKeyFromCode(key =>
    keys[key] = keys.hasOwnProperty(key)
  ));
  emitter.addListener(eventTypes.KEY_UP, getKeyFromCode(key =>
      keys[key] = !keys.hasOwnProperty(key)
  ));

  // INITIALIZATION

  // Renderer
  renderer.setSize(canvasWidth, canvasHeight);
  renderer.shadowMapEnabled = true;

  // Camera
  cameraYaw.add(cameraPitch);
  cameraYaw.position.set(...position);
  cameraYaw.position.y += defaultHeight;
  cameraYaw.rotation.set(...rotation);
  scene.add(cameraYaw);

  // Lights
  directionalLight.position.set(-520, 520, 1000);
  directionalLight.castShadow = true;
  directionalLight.shadowCameraLeft = -720;
  directionalLight.shadowCameraRight = 700;
  directionalLight.shadowCameraBottom = -300;
  directionalLight.shadowCameraNear = 550;
  directionalLight.shadowCameraFar = 185;
  scene.add(ambientLight);
  scene.add(directionalLight);

  // Models
  models.forEach(mesh => scene.add(mesh));

  // public
  return {

    aspect: aspect,
    info: renderer.info,

    render() {
      delta = clock.getDelta();

      // Gravity
      velocity.y -= 9.823 * delta;

      rayCaster.far = 1000; // avoid skyBox
      rayCaster.set(cameraYaw.position, rayDirections.down);
      intersections = rayCaster.intersectObjects(models);
      distance = intersections[0].distance;
      height = Math.abs(cameraYaw.position.y - distance) + defaultHeight;

      rayCaster.far = speed;
      rayCaster.set(cameraYaw.position, rayDirections.front);
      intersections = rayCaster.intersectObjects(models);
      console.log(intersections);


      // Player move
      if (keys.W) velocity.z -= speed * delta;
      if (keys.S) velocity.z += speed * delta;
      if (keys.A) velocity.x -= speed * delta;
      if (keys.D) velocity.x += speed * delta;
      if (keys.SPACE && !isJumping) {
        velocity.y += 3.0;
        isJumping = true;
      }

      cameraYaw.translateX(velocity.x);
      cameraYaw.translateY(velocity.y);
      cameraYaw.translateZ(velocity.z);

      // Ground check
      if (cameraYaw.position.y < height) {
        velocity.y = 0.0;
        cameraYaw.position.y = height;
        isJumping = false;
      }

      velocity.x -= velocity.x * speed * delta;
      velocity.z -= velocity.z * speed * delta;

      renderer.render(scene, camera);
    },
    animate(callback) {
      const animationFrame = () => {
        this.render();
        callback();
        return requestAnimationFrame(animationFrame);
      };
      requestAnimationFrame(animationFrame);
    },
    resize(size) {
      camera.aspect = size.width / size.height;
      camera.updateProjectionMatrix();
      renderer.setSize(size.width, size.height);
    }
  };
}
