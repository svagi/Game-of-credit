#!/usr/bin/env node

"use strict";

// ignore css require on server
require.extensions[".css"] = function () {
  return null;
};
require("babel/register");
require("./src/server");
