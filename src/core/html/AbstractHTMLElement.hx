/*
	This file is part of Cocktail http://www.silexlabs.org/groups/labs/cocktail/
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package core.html;

import core.dom.Element;
import core.dom.Node;
import core.HTMLElement;
import core.nativeElement.NativeElement;
import core.event.Event;
import core.event.KeyboardEvent;
import core.event.MouseEvent;
import cocktailCore.focus.FocusManager;
import core.keyboard.Keyboard;
import core.mouse.Mouse;
import core.ContainerStyle;
import core.nativeElement.NativeElementManager;
import core.Style;
import core.nativeElement.NativeElementData;
import core.style.StyleData;

/**
 * All HTML element interfaces derive from this class.
 * Elements that only expose the HTML core attributes are represented 
 * by the base HTMLElement interface.
 * 
 * @author Yannick DOMINGUEZ
 */
class AbstractHTMLElement extends Element
{
	//////////////////////////////////////////////////////////////////////////////////////////
	// Mouse attributes and callback
	//////////////////////////////////////////////////////////////////////////////////////////
	
	//TODO : add click event
	
	/**
	 * An instance of the cross-platform mouse class, used to listen
	 * to native mouse events
	 */
	private var _mouse:Mouse;
	
	/**
	 * The callback called on mouse down through the mouse instance
	 */
	private var _onMouseDown:MouseEvent->Void;
	public var onMouseDown(get_onMouseDown, set_onMouseDown):MouseEvent->Void;
	
	/**
	 * The callback called on mouse up through the mouse instance
	 */
	private var _onMouseUp:MouseEvent->Void;
	public var onMouseUp(get_onMouseUp, set_onMouseUp):MouseEvent->Void;
	
	/**
	 * The callback called when the mouse pointer hovers this dom element
	 */
	private var _onMouseOver:MouseEvent->Void;
	public var onMouseOver(get_onMouseOver, set_onMouseOver):MouseEvent->Void;
	
	/**
	 * The callback called on mouse out of this dom element
	 */
	private var _onMouseOut:MouseEvent->Void;
	public var onMouseOut(get_onMouseOut, set_onMouseOut):MouseEvent->Void;
	
	/**
	 * The callback called when the mouse pointer moves over this dom element
	 */
	private var _onMouseMove:MouseEvent->Void;
	public var onMouseMove(get_onMouseMove, set_onMouseMove):MouseEvent->Void;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Keyboard attributes and callback
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * An instance of the cross-platform keyboard class, used to listen
	 * to key down and up event
	 */
	private var _keyboard:Keyboard;
	
	/**
	 * The callback called on key down through the keyboard instance
	 */
	private var _onKeyDown:KeyboardEvent->Void;
	public var onKeyDown(get_onKeyDown, set_onKeyDown):KeyboardEvent->Void;
	
	/**
	 * The callback called on key up through the keyboard instance
	 */
	private var _onKeyUp:KeyboardEvent->Void;
	public var onKeyUp(get_onKeyUp, set_onKeyUp):KeyboardEvent->Void;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Focus attributes and callback
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * The tab index order of the DOMElement. If the DOMElement
	 * is tab enabled, this index will be used when the
	 * user presses the TAB key to determine the order
	 * of the focusable DOMElements in the DOM
	 */
	private var _tabIndex:Int;
	public var tabIndex(get_tabIndex, set_tabIndex):Int;
	
	/**
	 * callback called when the DOMElement recives 
	 * the focus
	 */
	private var _onFocus:Event->Void;
	public var onFocus(get_onFocus, set_onFocus):Event->Void;
	
	/**
	 * callback called when the DOMElement loses the focus
	 */
	private var _onBlur:Event->Void;
	public var onBlur(get_onBlur, set_onBlur):Event->Void;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Scroll attributes and callback
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Callback called when
	 * the content of the DOMElement
	 * is scrolled
	 */
	private var _onScroll:Event->Void;
	public var onScroll(get_onScroll, set_onScroll):Event->Void;
	
	public var scrollTop(get_scrollTop, never):Int;
	
	public var scrollLeft(get_scrollLeft, never):Int;
	
	public var scrollHeight(get_scrollHeight, never):Int;
	
	public var scrollWidth(get_scrollWidth, never):Int;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// DOM attributes
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * An abstract reference to the native element wrapped by this DOMElement.
	 * Varies for each runtime : in JS it is an HTML element, in Flash a Sprite,
	 * in PHP a resource...
	 */
	private var _nativeElement:NativeElement;
	public var nativeElement(get_nativeElement, never):NativeElement;
	
	/////////////////////////////////
	// COORDS attributes
	////////////////////////////////
	
	public var offsetParent(get_offsetParent, never):HTMLElement;
	
	/**
	 * Read-only, returns the width of the domElement
	 * + horizontal paddings + horizontal margins
	 */
	public var offsetWidth(get_offsetWidth, never):Int;
	
	/**
	 * Read-only, returns the height of the domElement
	 * + vertical paddings + vertical margins
	 */
	public var offsetHeight(get_offsetHeight, never):Int;
	
	public var offsetLeft(get_offsetLeft, never):Int;
	
	public var offsetTop(get_offsetTop, never):Int;
	
	public var clientWidth(get_clientWidth, never):Int;
	
	public var clientHeight(get_clientHeight, never):Int;
	
	public var clientLeft(get_clientLeft, never):Int;
	
	public var clientTop(get_clientTop, never):Int;
	
	/////////////////////////////////
	// STYLE attribute
	////////////////////////////////
	
	/**
	 * This Style object stores the styles of
	 * a DOMElement and manages how they are applied
	 */
	private var _style:Style;
	public var style(get_style, never):Style;
	
	/////////////////////////////////
	// CONSTRUTOR & INIT
	/////////////////////////////////
	
	/**
	 * class constructor. Stores the reference to the
	 * native element triggering the initialisation
	 * of the DOMElement
	 */
	public function new() 
	{
		super();
		init();
	}
	
	/**
	 * Init the DOMElement properties. Called each time
	 * the NativeElement is set
	 * 
	 * TODO : add method for init mouse
	 */
	private function init():Void
	{	
		initNativeElement();
		
		//initialise the mouse listeners on this dom element by 
		//listening to the current native element
		initMouse();
		
		//init key listeners
		initKeyboard();
		
		//init the style for this DOMElement
		initStyle();
		
		//init the focus attributes
		initFocus();
	}
	
	/**
	 * instantiate the right nativeElement
	 */
	private function initNativeElement():Void
	{
		_nativeElement = NativeElementManager.createNativeElement(NativeElementTypeValue.neutral);
	}
	
	/**
	 * initialise the mouse listeners on this dom element by 
	 * listening to the current native element
	 */
	private function initMouse():Void
	{
		_mouse = new Mouse(this._nativeElement);
	}
	
	/**
	 * initialise the keyboard listener of this dom element 
	 */
	private function initKeyboard():Void
	{
		_keyboard = new Keyboard(this._nativeElement);
	}
	
	/**
	 * Instantiate the right style object for this
	 * DOMElement. Overriden by DOMElements with
	 * specific style objects, such as ContainerDOMElement
	 * 
	 * TODO : update doc
	 */
	private function initStyle():Void
	{
		this._style = new ContainerStyle(cast(this));
	}
	
	/**
	 * init the focus attributes
	 * 
	 * TODO : reimplement tabenabled in another
	 * way
	 */
	private function initFocus():Void
	{
		_tabIndex = 0;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// MOUSE SETTER/GETTER
	// Proxies setting/getting properties from the mouse listener instance
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function set_onMouseDown(value:MouseEvent->Void):MouseEvent->Void
	{
		_onMouseDown = value;
		
		if (_onMouseDown == null)
		{
			_mouse.onMouseDown = null;
		}
		else
		{
			_mouse.onMouseDown = onMouseDownCallback;
		}
		
		return value;
	}
	
	private function get_onMouseDown():MouseEvent->Void
	{
		return _onMouseDown;
	}
	
	private function set_onMouseUp(value:MouseEvent->Void):MouseEvent->Void
	{
		_onMouseUp = value;
		
		if (_onMouseUp == null)
		{
			_mouse.onMouseUp = null;
		}
		else
		{
			_mouse.onMouseUp = onMouseUpCallback;
		}
		
		return value;
	}
	
	private function get_onMouseUp():MouseEvent->Void
	{
		return _onMouseUp;
	}
	
	private function set_onMouseOver(value:MouseEvent->Void):MouseEvent->Void
	{
		_onMouseOver = value;
		
		if (_onMouseOver == null)
		{
			_mouse.onMouseOver = null;
		}
		else
		{
			_mouse.onMouseOver = onMouseOverCallback;
		}
		
		return value;
	}
	
	private function get_onMouseOver():MouseEvent->Void
	{
		return _onMouseOver;
	}
	
	private function set_onMouseOut(value:MouseEvent->Void):MouseEvent->Void
	{
		_onMouseOut = value;
		
		if (_onMouseOut == null)
		{
			_mouse.onMouseOut = null;
		}
		else
		{
			_mouse.onMouseOut = onMouseOutCallback;
		}
		
		return value;
	}
	
	private function get_onMouseOut():MouseEvent->Void
	{
		return _onMouseOut;
	}
	
	private function set_onMouseMove(value:MouseEvent->Void):MouseEvent->Void
	{
		_onMouseMove = value;
		
		if (_onMouseMove == null)
		{
			_mouse.onMouseMove = null;
		}
		else
		{
			_mouse.onMouseMove = onMouseMoveCallback;
		}
		
		return value;
	}
	
	private function get_onMouseMove():MouseEvent->Void
	{
		return _onMouseMove;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// MOUSE EVENT CALLBACK
	// called by the Mouse instance when the user interacts
	// with the DOMElement with its mouse
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function onMouseDownCallback(mouseEvent:MouseEvent):Void
	{
		_onMouseDown(mouseEvent);
	}
	
	private function onMouseUpCallback(mouseEvent:MouseEvent):Void
	{
		_onMouseUp(mouseEvent);
	}
	
	private function onMouseMoveCallback(mouseEvent:MouseEvent):Void
	{
		_onMouseMove(mouseEvent);
	}
	
	private function onMouseOverCallback(mouseEvent:MouseEvent):Void
	{
		_onMouseOver(mouseEvent);
	}
	
	private function onMouseOutCallback(mouseEvent:MouseEvent):Void
	{
		_onMouseOut(mouseEvent);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// KEYBOARD SETTER/GETTER
	// Proxies setting/getting properties from the keyboard listener instance
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function set_onKeyDown(value:KeyboardEvent->Void):KeyboardEvent->Void
	{
		_onKeyDown = value;
		
		if (_onKeyDown == null)
		{
			_keyboard.onKeyDown = null;
		}
		else
		{
			_keyboard.onKeyDown = onKeyDownCallback;
		}
		
		return value;
	}
	
	private function get_onKeyDown():KeyboardEvent->Void
	{
		return _keyboard.onKeyDown;
	}
	
	private function set_onKeyUp(value:KeyboardEvent->Void):KeyboardEvent->Void
	{
		_onKeyUp = value;
		
		if (_onKeyUp == null)
		{
			_keyboard.onKeyUp = null;
		}
		else
		{
			_keyboard.onKeyUp = onKeyUpCallback;
		}
		
		return value;
	}
	
	private function get_onKeyUp():KeyboardEvent->Void
	{
		return _keyboard.onKeyUp;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// KEYBOARD EVENT CALLBACK
	// called by the Keyboard instance when the user interacts
	// with the keyboard while this DOMElement has the focus
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function onKeyDownCallback(keyEventData:KeyboardEvent):Void
	{
		_onKeyDown(keyEventData);
	}
	
	private function onKeyUpCallback(keyEventData:KeyboardEvent):Void
	{
		_onKeyUp(keyEventData);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// FOCUS SETTER/GETTER AND METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Set the focus on this DOMElement, the focus
	 * manager must determine if the DOMElement can
	 * actually receive focus
	 */
	public function focus():Void
	{
		FocusManager.getInstance().activeElement = cast(this);
	}
	
	//TODO : check if it actually work
	//TODO : FocusManager should no longer be singleton
	//but instance on the Document
	public function blur():Void
	{
		FocusManager.getInstance().activeElement = null;
	}
	
	private function set_onFocus(value:Event->Void):Event->Void
	{
		return _onFocus = value;
	}
	
	private function get_onFocus():Event->Void
	{
		return _onFocus;
	}
	
	private function set_onBlur(value:Event->Void):Event->Void
	{
		return _onBlur = value;
	}
	
	private function get_onBlur():Event->Void
	{
		return _onBlur;
	}
	
	/**
	 * when set, invalidate the focus manager
	 * tab list, as this DOMElement may appear
	 * at another index of the list
	 */
	private function set_tabIndex(value:Int):Int
	{
		FocusManager.getInstance().invalidate();
		return _tabIndex = value;
	}
	
	private function get_tabIndex():Int
	{
		return _tabIndex;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// SCROLLING SETTER/GETTER
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function set_onScroll(value:Event->Void):Event->Void
	{
		return _onScroll = value;
	}
	
	private function get_onScroll():Event->Void
	{
		return _onScroll;
	}
	
	/**
	 * called when a native scroll event is
	 * emitted, called the user on scroll
	 * callback if any
	 */
	private function onScrollCallback(event:Event):Void
	{
		if (_onScroll != null)
		{
			_onScroll(event);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// DOM GETTER
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Returns the reference to this DOMElement native DOM element
	 * @return a DisplayObject in AS, an HTML element in JS, a resource in PHP
	 */
	private function get_nativeElement():NativeElement
	{
		return this._nativeElement;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// POSITIONING SETTERS/GETTERS
	// Setters/Getters to manipulate a DOMElement position and dimensions in the publication
	//////////////////////////////////////////////////////////////////////////////////////////
	
	//TODO : should return Style.getFirstPositionedAncestor
	private function get_offsetParent():HTMLElement
	{
		return null;
	}
	
	/**
	 * constructs the offset width from the computed
	 * box of this domElement
	 * 
	 * TODO : removed margin, will cause issues
	 */
	private function get_offsetWidth():Int
	{
		var computedStyle:ComputedStyleData = this._style.computedStyle;
		return computedStyle.width + computedStyle.paddingLeft + computedStyle.paddingRight;
	}
	
	/**
	 * constructs the offset height from the computed
	 * box of this domElement
	 * 
	 * TODO :removed margin, will cause issues
	 */
	private function get_offsetHeight():Int
	{
		var computedStyle:ComputedStyleData = this._style.computedStyle;
		return computedStyle.height + computedStyle.paddingTop + computedStyle.paddingBottom;
	}
	
	//TODO : should return offset from offsetParent border
	private function get_offsetLeft():Int
	{
		return -1;
	}
	
	//TODO : should return offset from offsetParent border
	private function get_offsetTop():Int
	{
		return -1;
	}
	
	private function get_clientWidth():Int
	{
		return _style.computedStyle.width;
	}
	
	private function get_clientHeight():Int
	{
		return _style.computedStyle.height;
	}
	
	//TODO : will need to add border
	private function get_clientTop():Int
	{
		return _style.computedStyle.paddingTop;
	}
	
	//TODO : will need to add border
	private function get_clientLeft():Int
	{
		return _style.computedStyle.paddingLeft;
	}
	
	//TODO : implement
	private function get_scrollHeight():Int
	{
		return -1;
	}
	
	private function get_scrollWidth():Int
	{
		return -1;
	}
	
	private function get_scrollLeft():Int
	{
		return -1;
	}
	
	private function get_scrollTop():Int
	{
		return -1;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// STYLE GETTER
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function get_style():Style
	{
		return this._style;
	}
	
}