/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package cocktail.style.formatter;

import cocktail.domElement.ContainerDOMElement;
import cocktail.domElement.DOMElement;
import cocktail.style.StyleData;
import haxe.Log;

/**
 * ...
 * @author Yannick DOMINGUEZ
 */

class InlineFormattingContext extends FormattingContext
{

	private var _domElementInLineBox:Array<LineBoxElement>;
	
	private var _firstLineLaidOut:Bool;
	
	public function new(domElement:DOMElement, previousFormattingContext:FormattingContext) 
	{
		_firstLineLaidOut = false;
		super(domElement, previousFormattingContext);
		
		_domElementInLineBox = new Array<LineBoxElement>();
		
		applyTextIndent();
		
	}
	
	private function applyTextIndent():Void
	{
		_flowData.x += _containingDOMElement.style.computedStyle.textIndent;
	}
	

	override public function destroy():Void
	{
		startNewLine(0);
	}
	

	override public function insert(domElement:DOMElement):Void
	{
		if (getRemainingLineWidth() - domElement.offsetWidth < 0)
		{	
			switch(domElement.style.computedStyle.whiteSpace)
			{
				case WhiteSpaceStyleValue.normal,
				WhiteSpaceStyleValue.preLine:
					startNewLine(domElement.offsetWidth);
				
				default:	
					
			}
			
		}
		
		_domElementInLineBox.push({domElement:domElement, domElementType:InlineBoxValue.domElement});
		super.insert(domElement);
	}
	
	override public function insertSpace(domElement:DOMElement):Void
	{

		if (getRemainingLineWidth() - domElement.offsetWidth < 0)
		{	
			switch(domElement.style.computedStyle.whiteSpace)
			{
				case WhiteSpaceStyleValue.normal,
				WhiteSpaceStyleValue.preLine:
					startNewLine(domElement.offsetWidth);
				
				default:	
					
			}
		}
		_domElementInLineBox.push({domElement:domElement, domElementType:InlineBoxValue.space});
		
		super.insertSpace(domElement);
	}
	
	override private function place(domElement:DOMElement):Void
	{
		super.place(domElement);
		
		
		
		//domElement.x = _flowData.x + domElement.style.computedStyle.marginLeft ;
		domElement.y = _flowData.y + domElement.style.computedStyle.marginTop ;
		
		_flowData.x += domElement.offsetWidth;

		
		
	}
	
	override public function startNewLine(domElementWidth:Int):Void
	{
		if (_domElementInLineBox.length > 0)
		{
			removeSpaces();
			var lineBoxHeight:Int = computeLineBoxHeight();
			alignText(_firstLineLaidOut == false);
			_domElementInLineBox = new Array<LineBoxElement>();
			
			_flowData.y += lineBoxHeight;
			_flowData.y = _floatsManager.getFirstAvailableY(_flowData, domElementWidth, _containingDOMElementWidth);
			_flowData.totalHeight = _flowData.y + lineBoxHeight;
			
			if (_floatsManager.getLeftFloatOffset(_flowData.y) > _flowData.xOffset)
			{
				
				flowData.x =  _floatsManager.getLeftFloatOffset(_flowData.y);
			}
			else
			{
				_flowData.x = _flowData.xOffset;
			}
			
			_firstLineLaidOut = true;
		}
	}
	
	private function removeSpaces():Void
	{
		switch (_domElementInLineBox[0].domElement.style.computedStyle.whiteSpace)
		{
			case WhiteSpaceStyleValue.normal,
			WhiteSpaceStyleValue.nowrap,
			WhiteSpaceStyleValue.preLine:
				
				
				if (_domElementInLineBox[0].domElementType == InlineBoxValue.space)
				{
					_domElementInLineBox.shift();
				}
				
								
			default:
		}
		if (_domElementInLineBox.length > 0)
		{
			switch (_domElementInLineBox[_domElementInLineBox.length - 1].domElement.style.computedStyle.whiteSpace)
			{
				case WhiteSpaceStyleValue.normal,
				WhiteSpaceStyleValue.nowrap,
				WhiteSpaceStyleValue.preLine:
					
					

				if (_domElementInLineBox[_domElementInLineBox.length - 1].domElementType == InlineBoxValue.space)
				{
					_domElementInLineBox.pop();
				}
					
					
									
				default:
			}
		}	
		
	}
	
	private function alignText(firstLine:Bool):Void
	{	
		
		var concatenatedLength:Int = 0;
		for (i in 0..._domElementInLineBox.length)
		{
			concatenatedLength += _domElementInLineBox[i].domElement.offsetWidth;
		}
		
		
		
		var remainingSpace:Int;
		var localFlow:Int;
		if (firstLine == true)
		{
			remainingSpace = _containingDOMElementWidth - concatenatedLength - _containingDOMElement.style.computedStyle.textIndent;
			localFlow = _containingDOMElement.style.computedStyle.textIndent;
		}
		else
		{
			remainingSpace = _containingDOMElementWidth - concatenatedLength;
			localFlow = 0;
		}
		
		localFlow += _floatsManager.getLeftFloatOffset(_flowData.y) + _flowData.xOffset;
		
		switch (_containingDOMElement.style.computedStyle.textAlign)
		{
			case left:
			
				for (i in 0..._domElementInLineBox.length)
				{
					_domElementInLineBox[i].domElement.x = localFlow + _domElementInLineBox[i].domElement.style.computedStyle.marginLeft;
					localFlow += _domElementInLineBox[i].domElement.offsetWidth;
				}
			case right:
				
				for (i in 0..._domElementInLineBox.length)
				{
					_domElementInLineBox[i].domElement.x = localFlow + _domElementInLineBox[i].domElement.style.computedStyle.marginLeft + remainingSpace;
					localFlow += _domElementInLineBox[i].domElement.offsetWidth;
				}
				
				
			case center:
				for (i in 0..._domElementInLineBox.length)
				{
					_domElementInLineBox[i].domElement.x = Math.round(remainingSpace / 2) + localFlow + _domElementInLineBox[i].domElement.style.computedStyle.marginLeft;
					localFlow += _domElementInLineBox[i].domElement.offsetWidth;
				}
				
			case justify:	
				var spacesNumber:Int = 0;
				for (i in 0..._domElementInLineBox.length)
				{
					switch (_domElementInLineBox[i].domElementType)
					{
						case space:
							spacesNumber++;
							
						default:	
					}
				}
				
				
				for (i in 0..._domElementInLineBox.length)
				{
					switch (_domElementInLineBox[i].domElementType)
					{
						case space:
							_domElementInLineBox[i].domElement.width += Math.round(remainingSpace / spacesNumber);
							
						default:	
					}
				}
				
				for (i in 0..._domElementInLineBox.length)
				{
					
					_domElementInLineBox[i].domElement.x = localFlow + _domElementInLineBox[i].domElement.style.computedStyle.marginLeft ;
					
					localFlow += _domElementInLineBox[i].domElement.offsetWidth;
				}
				
				
				
				
				
		}
	}
	
	/**
	 * To DO : separate processing from appling to x/y of DOMElements ?
	 */
	private function computeLineBoxHeight():Int
	{
		//get ascent and descent of the strut
		var lineBoxAscent:Float = _containingDOMElement.style.fontMetrics.ascent;
		var lineBoxDescent:Float = _containingDOMElement.style.fontMetrics.descent;
		
		for (i in 0..._domElementInLineBox.length)
		{
			
			//! warning only works if all domElement in line are aligned to the baseline of the strut or are direct children
			//of the block container
			if (_domElementInLineBox[i].domElement.style.fontMetrics.ascent - _domElementInLineBox[i].domElement.style.computedStyle.verticalAlign > lineBoxAscent)
			{
				
				lineBoxAscent = _domElementInLineBox[i].domElement.style.fontMetrics.ascent - _domElementInLineBox[i].domElement.style.computedStyle.verticalAlign;
			}
			
			if (_domElementInLineBox[i].domElement.style.fontMetrics.descent + _domElementInLineBox[i].domElement.style.computedStyle.verticalAlign > lineBoxDescent)
			{
				lineBoxDescent = _domElementInLineBox[i].domElement.style.fontMetrics.descent + _domElementInLineBox[i].domElement.style.computedStyle.verticalAlign;
			}
		}
		
		var lineBoxHeight:Float = lineBoxAscent + lineBoxDescent; 
		
		
		for (i in 0..._domElementInLineBox.length)
		{
			if (_domElementInLineBox[i].domElement.style.isEmbedded() == false)
			{
				_domElementInLineBox[i].domElement.y += Math.round(lineBoxAscent) + Math.round(_domElementInLineBox[i].domElement.style.computedStyle.verticalAlign);
			}
			
			
		}
		
	//	Log.trace(lineBoxHeight);
		return Math.round(lineBoxHeight);
	}
	
	

	
	
}