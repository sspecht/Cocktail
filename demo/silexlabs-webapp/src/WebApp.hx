/*
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package;

/**
 * Class for building an web application
 * 
 * @author	Raphael Harmel
 * @date	2001-12-16
 */

import cocktail.domElement.BodyDOMElement;
import cocktail.domElement.ContainerDOMElement;
import cocktail.geom.GeomData;
import cocktail.domElement.DOMElement;
import cocktail.domElement.GraphicDOMElement;
import cocktail.domElement.DOMElementData;

import cocktail.resource.ResourceLoaderManager;
import cocktail.nativeElement.NativeElementData;
import cocktail.nativeElement.NativeElementManager;

// Style
import cocktail.style.StyleData;
import cocktail.unit.UnitData;

// list specific
import components.lists.ListBase;
import components.lists.ListBaseModels;
import components.lists.ListBaseUtils;

// Utils
import Utils;

import cocktail.keyboard.KeyboardData;


class WebApp 
{
	
	// the main container which will be attached to the body of the publication
	private var _body:BodyDOMElement;
	private var _mainContainer:ContainerDOMElement;
	
	public static function main()
	{
		new WebApp();
	}
	
	/**
	 * Contructor
	 */
	public function new()
	{
		_body = new BodyDOMElement();
		WebAppStyle.getBodyStyle(_body);
		drawInterface();
	}
	
	/**
	 * Draws the main interface
	 */
	public function drawInterface()
	{
		// create pages
		var applicationStructure:ApplicationStructure = new ApplicationStructure();
		
		// initialize container
		_mainContainer = applicationStructure.pagesContainer;
		//WebAppStyle.getDefaultStyle(_mainContainer);
		WebAppStyle.getMainContainerStyle(_mainContainer);
		
		// attach main container to document root
		_body.addChild(_mainContainer);

		//_body.onKeyDown = onKeyDownBody;
		//_body.onKeyDown = _mainContainer.children[0].child.children[1].onListKeyDown;
		
	}
	
	/*private function onKeyDownBody(key:KeyEventData):Void
	{
		trace("onKeyDownBody: " + key.value);
		//trace(key.value);
		if (key.value == KeyboardKeyValue.right || key.value == KeyboardKeyValue.VK_RIGHT || key.value == KeyboardKeyValue.left || key.value == KeyboardKeyValue.VK_LEFT)
		{
			// dispatch menu list item change
			_mainContainer.children[0].child.children[1].onListKeyDown(key);
		}
	}*/

}