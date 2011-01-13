  __ _         _            _ _             
 / _| |_____ _| |_ ___  ___| | |__  _____ __
|  _| / -_) \ /  _/ _ \/ _ \ | '_ \/ _ \ \ /
|_| |_\___/_\_\\__\___/\___/_|_.__/\___/_\_\

flexwires Library for Adobe Flex
Created by Josh Tynjala

---------------------------------------------------------------------------------
Links:
---------------------------------------------------------------------------------

Project Page:
   * http://github.com/joshtynjala/flexwires
   
API Documentation:
   * http://www.flextoolbox.com/components/flexwires/1/documentation/index.html

Getting Started:
   * http://wiki.github.com/joshtynjala/flexwires/getting-started

Author's Blog:
   * http://joshblog.net/

---------------------------------------------------------------------------------
Release Notes:
---------------------------------------------------------------------------------

The Next Release
   * Fixed issue where connecting property of WireManager could be incorrectly set to false.
   * Fixed null reference error in WireJack when calling disconnectAll().
   * WireJack skin now properly changes state when enabled changes.
   * Added getWireBetween() to IWireManager
   * Changing wireRenderer on IWireManager will now recreate existing wires.
   * Added cancelable WireManagerEvent.DELETING_CONNECTION to match CREATING_CONNECTION.
   
07/01/2010 - 1.1.0
   * Added "hasActiveConnectionRequest" to IWireManager and implementations.
   * Added "clickToDrag" static property to WireJack class as an alternative
     that does not require holding the mouse button down to connect wires.
   * Placeholder wire now properly displays while dragging in Adobe AIR.
   * Moved default styles to defaults.css and updated for Flex 4.
   * Minimum version is now Flex 3.5.0.
   
11/11/2008 - 1.0.0
   * Initial Release for Flex 3.2.0