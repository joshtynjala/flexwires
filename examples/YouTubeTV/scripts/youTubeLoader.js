/*
Constructs a YouTubeLoader object which uses ExternalInterface to interact with javascript
within the "youTubeLoader.js" file to create an ActionScript 3 Wrapper for the YouTube
chromeless player and API.

@author Matthew Richmond <matthew@choppingblock.com>
@version 1.0
@history 2008-10-07

@Copyright 2008 Matthew Richmond <matthew@choppingblock.com>
* 
* This file is part of Sawdust, a collection of useful frameworks
* managed by the folks at The Chopping Block, Inc.
* 
* Sawdust is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* Sawdust is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Lesser General Public License for more details.
* 
* You should have received a copy of the GNU Lesser General Public License
* along with Sawdust.  If not, see <http://www.gnu.org/licenses/>.
*/

//------------------------------------
// MAIN VARIABLES
//------------------------------------

var choppingblock = {};
choppingblock.SWFID = null; // Must be set to id of swf or nothing will work.
choppingblock.obj = {};

//------------------------------------
// UTILITY METHODS
//------------------------------------

function checkObj () {
	//console.log("youTubeLoader.js : checkObj");
	if (SWFID) {
		createObj();
		return true;
	} else{
		alert("YouTubeLoader: In order to call methods within a swf, you must first set the variable \"SWFID\"!");
		return false;
	}
}

function createObj () {
	//console.log("youTubeLoader.js : createObj");
	choppingblock.obj = document.getElementById(SWFID);
}

//------------------------------------
// SPECIAL YOUTUBE EVENT METHODS
//------------------------------------

function onYouTubePlayerReady(playerId) {
	
	if (checkObj()) {	
		choppingblock.obj.addEventListener("onStateChange", "onytplayerStateChange");
	}
	
	// PLEASE NOTE: For the purpose of this demo:
	// This calls a secondary method located in the index.html file allowing the html display to update.
	// You will most likely not need this, it's gross, remove this when you implement this code.
	secondaryOnYouTubePlayerReady(playerId);
}

function onytplayerStateChange(newState) {
   	//console.log("Player's new state: " + newState);
	choppingblock.obj.playerStateUpdateHandler(newState);
	
	// PLEASE NOTE: For the purpose of this demo:
	// This calls a secondary method located in the index.html file allowing the html display to update.
	// You will most likely not need this, it's gross, remove this when you implement this code.
	secondaryOnytplayerStateChange(newState)
}

//------------------------------------
// YOUTUBE METHODS
//------------------------------------

function loadVideoById(id, startSeconds) {
	//console.log("youTubeLoader.js : loadVideoById");
	if (checkObj()) {
		choppingblock.obj.loadVideoById(id,startSeconds);
	}
}

function cueNewVideo(id, startSeconds) {
	//console.log("youTubeLoader.js : loadVideoById");
	if (checkObj()) {
		choppingblock.obj.cueVideoById(id, startSeconds);
	}
}

function clearVideo() {
	//console.log("youTubeLoader.js : clearVideo");
	if (checkObj()) {
		choppingblock.obj.clearVideo();
	}
}

function setSize(w, h) {
	//console.log("youTubeLoader.js : setSize");
	if (checkObj()) {
		choppingblock.obj.setSize(w, h);
	}
}

function play() {
	//console.log("youTubeLoader.js : play");
	if (checkObj()) {
		choppingblock.obj.playVideo();
	}
}

function pause() {
	//console.log("youTubeLoader.js : pause");
	if (checkObj()) {
		choppingblock.obj.pauseVideo();
	}
}

function stop() {
	//console.log("youTubeLoader.js : stop");
	if (checkObj()) {
		choppingblock.obj.stopVideo();
	}
}

function seekTo(seconds) {
  	//console.log("youTubeLoader.js : seekTo");
	if (checkObj()) {
		choppingblock.obj.seekTo(seconds, true);
	}
}

function getPlayerState() {
	//console.log("youTubeLoader.js : getPlayerState");
	if (checkObj()) {
		return choppingblock.obj.getPlayerState();
	}
}

function getBytesLoaded() {
  	//console.log("youTubeLoader.js : getBytesLoaded");
	if (checkObj()) {
		return choppingblock.obj.getVideoBytesLoaded();
	}
}

function getBytesTotal() {
  	//console.log("youTubeLoader.js : getBytesTotal");
	if (checkObj()) {
		return choppingblock.obj.getVideoBytesTotal();
	}
}

function getCurrentTime() {
  	//console.log("youTubeLoader.js : getCurrentTime");
	if (checkObj()) {
    	return choppingblock.obj.getCurrentTime();
	}
}

function getDuration() {
  	//console.log("youTubeLoader.js : getDuration");
	if (checkObj()) {
		return choppingblock.obj.getDuration();
	}
}

function getStartBytes() {
	//console.log("youTubeLoader.js : getStartBytes");
	if (checkObj()) {
		return choppingblock.obj.getVideoStartBytes();
	}
}

function setVolume(newVolume) {
	//console.log("youTubeLoader.js : setVolume");
	if (checkObj()) {
		choppingblock.obj.setVolume(newVolume);
	}
}

function getVolume() {
	//console.log("youTubeLoader.js : setVolume");
	if (checkObj()) {
		return choppingblock.obj.getVolume();
	}
}

function mute() {
	//console.log("youTubeLoader.js : mute");
	if (checkObj()) {
		choppingblock.obj.mute();
	}
}

function unMute() {
	//console.log("youTubeLoader.js : unMute");
	if (checkObj()) {
		choppingblock.obj.unMute();
	}
}

function getEmbedCode() {
	//console.log("youTubeLoader.js : getEmbedCode");
	if (checkObj()) {
  		return choppingblock.obj.getVideoEmbedCode();
	}
}

function getVideoUrl() {
	//console.log("youTubeLoader.js : getVideoUrl");
	if (checkObj()) {
		return choppingblock.obj.getVideoUrl();
	}
}