package org.intermedia.view;

import js.Lib;
import js.Dom;
import org.intermedia.model.ApplicationModel;
import org.intermedia.view.ListViewBase;
import org.intermedia.model.Feeds;
import haxe.Firebug;
import feffects.Tween;
import feffects.easing.Quart;
import feffects.easing.Quint;

/**
 * A container for multiple list views which can be selected by swipping them.
 * 
 * @author Raphael Harmel
 */

class SwippableListView extends ListViewBase 
{

	static inline var DIRECTION_PIXEL_MINIMUM:Int = 5;
	static inline var VERTICAL_TWEEN_DELTA:Int = 150;
	static inline var HOMEPAGE_ITEM_PER_LIST:Int = 3;
	// number of lists taken in account for the homapage items
	static inline var LIST_QTY:Int = 2;
	static inline var HOMEPAGE_ITEMS:Int = HOMEPAGE_ITEM_PER_LIST * LIST_QTY;
	
	// the container of the swippable lists
	private var _listsContainer:HtmlDom;
	
	// a ref to each of the list views which can be swiped
	//private var _listViews:Array<ViewBase>;
	private var _listViews:Array<ListViewBase>;
	
	private var list0:ListViewText;
	private var list1:ThumbTextList1Bis;
	private var list2:ThumbTextList1;
	private var _list1Data:Array<CellData>;
	
	// The ListView currently displayed
	private var _currentListView:ListViewBase;
	
	// current list view index
	private var _index:Int;
	public var index(getIndex,setIndex):Int;
	
	// X offset used to scroll list left and right
	private var _offset:Coordinate;
	private var _offsetStart:Coordinate;
	private var _initialPosition:Coordinate;
	
	// main movement direction
	private var _direction:Direction;
	
	// horizontal tween end
	public var onHorizontalTweenEnd:Void->Void;
	
	// home page data
	private var _homePageData:Array<Dynamic>;
	
	private var _homePageDataSet:Bool;
	
	// view port
	//private var _viewport:Viewport;
	private var _viewportWidth:Int;
	private var _viewportHeight:Int;
	
	public function new()
	{
		super();
		// display loading
		displayLoading = true;
		
		// init attributes
		_offset = { x:0, y:0 };
		_offsetStart = { x:0, y:0 };
		_initialPosition = { x:0, y:0 };
		_direction = Direction.notYetSet;
		//_viewport = new Viewport();
		_viewportWidth = Lib.window.innerWidth;
		_viewportHeight = Lib.window.innerHeight;
		//_viewport.onResize = onResizeCallback;
		Lib.window.onresize = onResizeCallback;
		//Lib.window.onresize = function (event:Event) { positionLists(); };
		
		_homePageData = new Array<Dynamic>();
		_homePageDataSet = false;
		
		_listsContainer = Lib.document.createElement("div");
		SwippableListViewStyle.setListsContainerStyle(_listsContainer);
		node.appendChild(_listsContainer);
		
		// set style
		//SwippableListViewStyle.setListStyle(this);
		SwippableListViewStyle.setSwippableListStyle(node);
		// set onMouseDown callback
		//onMouseDown = onDownCallback;
		//onMouseDown = function(mouseEvent:MouseEventData) { onDownCallback(mouseEvent.mousePosition.localX, mouseEvent.mousePosition.localY); };
		
		// set _listView array
		_listViews = new Array<ListViewBase>();
		
		// create all needed lists and add them to the _listView array
		list0 = new ListViewText();
		list0.id = Feeds.FEED_1.url;
		_listViews.push(list0);
		
		// Home page data
		/*_homePageData = 
		[
			{
				id:130523,
				thumbUrl:"assets/400-156.png",
				title:"incredible plugin",
				author:"vador"
			},
			{
				id:130523,
				thumbUrl:"assets/200-156_red.png",
				title:"incredible plugin",
				author:"vador"
			},
			{
				id:130523,
				thumbUrl:"assets/200-156_purple.png",
				title:"incredible plugin",
				author:"vador"
			},
			{
				id:130523,
				thumbUrl:"assets/200-156_purple.png",
				title:"incredible plugin",
				author:"vador"
			},
			{
				id:130523,
				title:"incredible plugin",
				author:"itzel",
				thumbUrl:"assets/200-156_red.png"
			},
			{
				id:130523,
				title:"incredible theme",
				author:"raph",
				thumbUrl:"assets/200-156_red.png"
			},
			{
				id:130523,
				title:"incredible plugin",
				author:"itzel",
				thumbUrl:"assets/200-156_red.png"
			},
			{
				id:130523,
				title:"incredible theme",
				author:"raph",
				thumbUrl:"assets/200-156_red.png"
			},
			{
				id:130523,
				title:"incredible plugin",
				author:"itzel",
				thumbUrl:"assets/200-156_red.png"
			}
		];*/
		
		
		//var list1:ListViewBase = new ThumbTextList1Bis(3);Filters component
		//list1 = new ThumbTextList1Bis(2, homePageData);
		list1 = new ThumbTextList1Bis(2);
		//list1.buildHomePage(_homePageData);
		list1.id = Feeds.FEED_2.url;
		_listViews.push(list1);
		//list1.node.style.left = Std.string(_viewportWidth) + "px";
		
		list2 = new ThumbTextList1(2);
		list2.id = Feeds.FEED_3.url;
		_listViews.push(list2);
		//list2.node.style.left = Std.string(2 * _viewportWidth) + "px";
		
		// position the lists to their correct left offset
		positionLists();
		
		// add all lists to the view
		for (listView in _listViews)
		{
			listView.onDataRequest = onDataRequestCallback;
			listView.onListItemSelected = onListItemSelectedCallback;
			//listView.style.display = DisplayStyleValue.none;
			//node.appendChild(listView);
			_listsContainer.appendChild(listView.node);

		}
		
		// set index
		//_index = 1;
		_index = 1;
		// set current list to list1
		_currentListView = cast _listViews[_index];
		//node.scrollLeft = 0;
		//node.scrollLeft = _viewportWidth;
		//node.scrollLeft = _viewportWidth;
		//this.x = -_viewportWidth;
		
		
		// set listItemSelected callback on current list
		_currentListView.onListItemSelected = onListItemSelectedCallback;
		//_currentListView.onListScrolled = onScrolledCallback;
		//_currentListView.onDataRequest = onDataRequestCallback;
		
		// js touch events handling
		addTouchEvents();
	}
	
	/**
	 * set lists left offset value (used for resizing)
	 */
	private function positionLists():Void
	{
		//Firebug.trace("positionLists");
		list1.node.style.left = Std.string(1 * _viewportWidth) + "px";
		list2.node.style.left = Std.string(2 * _viewportWidth) + "px";
	}
	
	/**
	 * data setter which sets each list data
	 * 
	 * @param	v
	 * @return
	 */
	override private function setData(v:Dynamic):Dynamic
	{
		_data = v;
		
		// set the data on the correct list, depending on the list id
		for (list in _listViews)
		{
			//if (v.id == list.id)
			if (v.id == list.id && v.id != list1.id)
			{
				// if _homePageData is not fully filled, continue to fill it
				if (_homePageData.length < HOMEPAGE_ITEMS)
				{
					for (i in 0...HOMEPAGE_ITEM_PER_LIST)
					{
						_homePageData.push(data.cells[i]);
					}
				}
				
				// fill list with its corresponding data
				list.data = v.cells;
				
				break;
			}
			
			// if data id is main list one: list1, store this data into a temporary attribute so it can be pushed to the list once the homepage is loaded
			if (v.id == list1.id)
			{
				_list1Data = cast v.cells;
			}
			
		}
		
		// if home page data is not set yet and _homePageData elements quantity is equal to HOMEPAGE_ITEMS,
		// build home page, attach lists to swippable view, scroll to list1 and remove loading screen
		if (!_homePageDataSet && _homePageData.length == HOMEPAGE_ITEMS)
		{
			// build home page with its data
			list1.buildHomePage(_homePageData);
			// set _homePageDataSet flag to true
			_homePageDataSet = true;
			
			scrollToCurrentList();
			
			
			// add all lists to the view
			/*for (listView in _listViews)
			{
				//listView.onDataRequest = onDataRequestCallback;
				//node.appendChild(listView);
				//listView.style.display = "inline-block";
			}*/
			
			displayLoading = false;

		}
		
		// if homepage is set, add or update list1 data
		if (_homePageDataSet)
		{
			list1.data = _list1Data;
		}

		return _data;	
	}
	
	/**
	 * index getter
	 * 
	 * @param	v
	 * @return
	 */
	private function getIndex():Int
	{
		return _index;
	}
	
	/**
	 * index setter: animate the swippable view from the current position to the list corresponding to the new index
	 * 
	 * @param	v
	 * @return
	 */
	private function setIndex(v:Int):Int
	{
		// unset current list item selected callback
		_currentListView.onListItemSelected = null;
		// set _index
		_index = v;
		// update current list to new index
		_currentListView = cast _listViews[v];
		// set current list item selected callback
		_currentListView.onListItemSelected = onListItemSelectedCallback;
		// launch horizontal tween
		horizontalReleaseTween();

		return v;
	}
	
	/**
	 * on rezize callback
	 */
	private function onResizeCallback(event:Event):Void
	{
		// reset viewport values
		_viewportWidth = Lib.window.innerWidth;
		_viewportHeight = Lib.window.innerHeight;

		// reset lists posistion
		positionLists();
		
		// scroll to current list
		scrollToCurrentList();
		
		// update swippable view position
		//this.x = -_currentListView.x;
	}
	
	/**
	 * A way to override onMouseDownCallback - not the best way, but Cocktail bug posted as no "nice" way to do it
	 * sets _xOffsetStart & _xInitial, and sets onMouseMove & onMouseUp callbacks
	 * 
	 * @param	mouseEventData
	 */
	private function onDownCallback(event:Dynamic):Void
	{
		//trace("onDownCallback");
		// done as a workaround for this bug: https://github.com/silexlabs/Cocktail/issues/139
		/*_viewport.onResize = null;
		
		// set onMouseMove & onMouseUp callbacks
		//onMouseMove = onMoveCallback;
		//onMouseUp = onUpCallback;
		//onMouseMove = function (mouseEvent:MouseEventData) { onMoveCallback(mouseEvent.mousePosition.localX, mouseEvent.mousePosition.localY); };
		//onMouseUp = function (mouseEvent:MouseEventData) { onUpCallback(mouseEvent.mousePosition.localX, mouseEvent.mousePosition.localY); };*/
		
		// initialise initial touch positions
		_initialPosition.x = event.touches[0].pageX;
		_initialPosition.y = event.touches[0].pageY;
		// set x offset start to swippableView left scroll
		_offsetStart.x = node.scrollLeft;
		// set y offset start to _currentListView top scroll
		_offsetStart.y = _currentListView.node.scrollTop;
		// reset _direction
		_direction = Direction.notYetSet;

	}

	/**
	 * A way to override onMouseMoveCallback - not the best way, but Cocktail bug posted as no "nice" way to do it
	 * computes offset & moves the swippable view according to the offset
	 * 
	 * @param	mouseEventData
	 */
	private function onMoveCallback(event:Dynamic):Void
	{
		//trace("onMoveCallback");
		//trace(_direction);
		
		// compute x & y offset
		_offset.x = Std.int(event.touches[0].pageX - _initialPosition.x);
		_offset.y = Std.int(event.touches[0].pageY - _initialPosition.y);
		
		//_currentListView.onListItemSelected = null;
		
		//trace(_direction + " - " + _offset.x + "," + _offset.y );
		// done to avoid top rebound effect - to be done also on bottom rebound one
		/*if (_currentListView.scrollTop <= 0 && _offset.y > 0)
		{
			event.preventDefault();
		}*/
		
		//trace(_direction + " - " + _offset.x);
		
		// if direction is not set
		if (_direction == Direction.notYetSet)
		{
			// compute absolute values as movement _offset can be positive or negative
			var absX:Float = Math.abs(_offset.x);
			var absY:Float = Math.abs(_offset.y);
			//trace(absX + ", " + absY);
				
			// as first move event can be dispatched with both x and y values bigger than DIRECTION_PIXEL_MINIMUM,
			// take the biggest as a reference
			if ( Math.max(absX, absY) >= DIRECTION_PIXEL_MINIMUM )
			{
				if (absX > absY)
				{
					_direction = Direction.horizontal;
				}
				else
				{
					_direction = Direction.vertical;
				}
			}
		}
		
		// if direction is horizontal
		if (_direction == Direction.horizontal)
		{
			// prevent default scroll behaviour
			event.preventDefault();
			// scroll to correct left position
			node.scrollLeft = _offsetStart.x - _offset.x;
		}
		// if direction is vertical
		else if (_direction == Direction.vertical)
		{
			// block left scroll position
			//node.scrollLeft = _offsetStart.x;
			// prevent default scroll behaviour
			event.preventDefault();
			// scroll to correct top position
			//node.scrollTop = _offsetStart.y - _offset.y;
			_currentListView.node.scrollTop = _offsetStart.y - _offset.y;
		}

	}
	
	/**
	 * A way to override onMouseUpCallback - not the best way, but Cocktail bug posted as no "nice" way to do it
	 * unset onMouseMove & onMouseUp callbacks
	 * 
	 * @param	mouseEventData
	 */
	private function onUpCallback(event:Dynamic):Void
	{
		//trace("onUpCallback");
		//trace("onUpCallback: " + "x:" + x + ", y:" + y + ", _offsetStart.x:" + _offsetStart.x + ", _offset.x:" + _offset.x + ", _viewportWidth:" + _viewportWidth + ", this.x:" + this.x + ", -_currentListView.x:" + -_currentListView.x);

		//trace(_direction);
		if (_direction == Direction.horizontal)
		{
			event.preventDefault();
			
			//onUpCallback(node.scrollLeft);
			/*var x = node.scrollLeft;

			// go to list which user has scrolled to
			var w = _viewportWidth / 2;
			if (x < w)
			{
				//node.scrollLeft = 0;
				index = 0;
			}
			else if (x < 3 * w)
			{
				//node.scrollLeft = _viewportWidth;
				index = 1;
			}
			else 
			{
				//node.scrollLeft = 2 * _viewportWidth;
				index = 2;
			}*/
			
			// if movement was negative and more that half of the size of the screen
			if (_offset.x < -_viewportWidth / 2)
			{
				// if the current list is not the last one, increment index using setter
				if (index < _listViews.length - 1)
					index++;
			}
			// if movement was positive and less that half of the size of the screen
			else if (_offset.x > _viewportWidth / 2)
			{
				// if the current list is not the first one, decrement index using setter
				if (index > 0)
					index--;
			}
			// else come back on the current list
			else
			{
				index = index;
			}
			
			// js workaround to scroll up
			/*#if js
			js.Lib.window.scrollTo(0, 0);
			//js.Lib.window.scrollTo(0,null);
			#end*/
		}
		else if (_direction == Direction.vertical)
		{
			verticalReleaseTween();
		}
			
		// unset onMouseMove & onMouseUp callbacks
		//onMouseMove = null;
		//onMouseUp = null;
		
		// reset direction
		//_direction = Direction.notYetSet;


		// done as a workaround for this bug: https://github.com/silexlabs/Cocktail/issues/139
		//_viewport.onResize = onResizeCallback;
		
		// reset direction
		_direction = Direction.notYetSet;

	}
	
	/**
	 * scroll the swippable view to the current list
	 */
	public function scrollToCurrentList():Void
	{
		node.scrollLeft = Std.parseInt(_currentListView.node.style.left.substr(0,-2));
	}
	
	/**
	 * swipe animation when touch is released
	 */
	private function horizontalReleaseTween():Void
	{
		// create the tween
		//haxe.Firebug.trace("index: " + _index + " - scrollLeft: " + node.scrollLeft + " - " + "_currentListView.x:" + _currentListView.x);
        var tween = new Tween( node.scrollLeft, Std.parseInt(_currentListView.node.style.left), 600, Quint.easeOut );
		tween.setTweenHandlers( horizontalTweenMove, horizontalTweenEnd );
        // launch the tween
        tween.start();
	}
	
	/**
	 * move view on the x axis
	 * 
	 * @param	e
	 */
    private function horizontalTweenMove( e : Float )
    {
		//node.scrollLeft = Std.int(e);
		node.scrollLeft = Std.int(e);
    }

	/**
	 * Vertical tween callback
	 * 
	 * @param	e
	 */
    private function horizontalTweenEnd(e : Float )
	{
		if (onHorizontalTweenEnd != null)
		{
			onHorizontalTweenEnd();
		}
	}
	
	/**
	 * swipe animation when touch is released
	 */
	private function verticalReleaseTween():Void
	{
		//trace("releaseTween");
		//trace("releaseTween: " + "x:" + x + ", y:" + y + ", _offsetStart.x:" + _offsetStart.x + ", _offset.x:" + _offset.x + ", _viewportWidth:" + _viewportWidth + ", this.x:" + this.x + ", -_currentListView.x:" + -_currentListView.x);
		
		var verticalTweenEnd:Int = 0;
		// if scrolling direction is down
		if (_offset.y > 0 )
			verticalTweenEnd = _currentListView.node.scrollTop - VERTICAL_TWEEN_DELTA;
		else
			verticalTweenEnd = _currentListView.node.scrollTop + VERTICAL_TWEEN_DELTA;
		// create the tween
        var tween = new Tween( _currentListView.node.scrollTop, verticalTweenEnd, 600, Quint.easeOut );
		tween.setTweenHandlers( onVerticalTweenMove, onVerticalTweenEnd );
        // launch the tween
        tween.start();
	}
	
	/**
	 * move view on the x axis
	 * 
	 * @param	e
	 */
    private function onVerticalTweenMove( e : Float )
    {
		_currentListView.node.scrollTop = Std.int(e);
    }
	
	/**
	 * Vertical tween callback
	 * 
	 * @param	e
	 */
	private function onVerticalTweenEnd(e : Float )
	{
		
	}
	
	/**
	 * remove list scroll callback behaviour
	 * @param	event
	 */
	//override private function onScrollCallback(event:ScrollEventData):Void
	override private function onScrollCallback(event:Event):Void
	{
	}

	
// Touch event workaround	

	private function touchHandler(event:Dynamic):Void
	{
		//trace("touchHandler: " + event.type);
		switch(event.type)
		{
			//case "touchstart": type = "mousedown";
			//case "touchmove":  type="mousemove";        
			//case "touchend":   type="mouseup";
			//default: return;
			case "touchstart":
				onDownCallback(event);
			case "touchmove":
				onMoveCallback(event);
			case "touchend":
				onUpCallback(event);
			default: return;
		}
	}


	/**
	 * Adds touch events
	 */
	public function addTouchEvents():Void
	{
		#if js
		untyped
		{
		node.addEventListener("touchstart", touchHandler, false);
		node.addEventListener("touchmove", touchHandler, false);
		node.addEventListener("touchend", touchHandler, false);
		node.addEventListener("touchcancel", touchHandler, false);
		}
		#end
	}
	
	/**
	 * Removes touch events
	 */
	/*public function unsetTouchEvents():Void
	{
		#if js
		untyped
		{
		node.removeEventListener("touchstart", touchHandler, true);
		node.removeEventListener("touchmove", touchHandler, true);
		node.removeEventListener("touchend", touchHandler, true);
		node.removeEventListener("touchcancel", touchHandler, true);
		}
		#end
	}*/
	
}

typedef Coordinate = {
	var x:Int;
	var y:Int;
}

enum Direction {
	horizontal;
	vertical;
	notYetSet;
}

