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
 * @providesModule actions
 **/

import dispatcher from "../dispatcher";
import actionTypes from "../constants/ActionTypes";

export default {
  pointerLockChanged(pointerLocked) {
    dispatcher.dispatch(actionTypes.POINTER_LOCK_CHANGE, pointerLocked);
  },
  loadingTexturesCompleted() {
    dispatcher.dispatch(actionTypes.LOADING_TEXTURES_COMPLETE, null);
  },
  loadingModelsCompleted(models) {
    dispatcher.dispatch(actionTypes.LOADING_MODELS_COMPLETE, models);
  },
  playerClick() {
    dispatcher.dispatch(actionTypes.PLAYER_CLICK, null);
  }
};
