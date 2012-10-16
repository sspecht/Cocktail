/*
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
*/
package cocktail.core.renderer;

import cocktail.core.background.BackgroundManager;
import cocktail.core.dom.Node;
import cocktail.core.html.HTMLElement;
import cocktail.core.layer.InitialLayerRenderer;
import cocktail.port.NativeElement;
import cocktail.core.geom.GeomData;
import cocktail.core.layout.formatter.BlockFormattingContext;
import cocktail.core.layout.formatter.FormattingContext;
import cocktail.core.layout.LayoutData;
import cocktail.core.css.CoreStyle;
import haxe.Log;
import cocktail.core.renderer.RendererData;
import cocktail.core.layer.LayerRenderer;
import cocktail.core.font.FontData;

/**
 * This is the root ElementRenderer of the rendering
 * tree, generated by the HTMLHTMLElement, which is the root
 * of the DOM tree
 * 
 * @author Yannick DOMINGUEZ
 */
class InitialBlockRenderer extends BlockBoxRenderer
{
	/**
	 * class constructor.
	 */
	public function new(node:HTMLElement) 
	{
		super(node);
		
		//as this is the root of the rendering
		//tree, it is considered to be its
		//own containing block
		//
		//TODO 3 :maybe not very clean, trouble is that
		//addedToRenderingTree never called as initial 
		//block is never attached to a parent
		containingBlock = this;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PUBLIC LAYOUT METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * for the initial bloc renderer, the global
	 * bounds are the viewport bounds
	 */
	override public function updateGlobalBounds():Void
	{
		
	}
	
	/**
	 * overriden as the bounds of the initial block container
	 * are always those of the Window (minus scrollbars dimensions
	 * if displayed)
	 */
	override public function updateBounds():Void
	{
		var containerBlockData:ContainingBlockVO = getContainerBlockData();
		bounds.x = 0.0;
		bounds.y = 0.0;
		bounds.width = containerBlockData.width;
		bounds.height = containerBlockData.height;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PRIVATE ATTACHEMENT METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Overriden as initial block renderer always create
	 * a new intitial layer renderer.
	 */
	override private function attachLayer():Void
	{
		layerRenderer = new InitialLayerRenderer(this);
	}
	
	/**
	 * never register with containing block as it is
	 * itself
	 */
	override private function registerWithContaininingBlock():Void
	{
		
	}
	
	/**
	 * same as above for unregister
	 */
	override private function unregisterWithContainingBlock():Void
	{
		
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PRIVATE INVALIDATION METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * As the initial block renderer has no containing block,
	 * do nothing
	 */
	override private function invalidateContainingBlock(styleName:String):Void
	{
		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PUBLIC HELPER METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * The initial block renderer is always considered positioned,
	 * as it always lays out the positioned children for whom it is
	 * the first positioned ancestor
	 */
	override public function isPositioned():Bool
	{
		return true;
	}
	
	/**
	 * The initial block container always establishes a block formatting context
	 * for its children
	 */
	override public function establishesNewFormattingContext():Bool
	{
		return true;
	}
	
	/**
	 * Overriden as initial block container alwyas establishes
	 * creates the root LayerRenderer of the
	 * LayerRenderer tree
	 */
	override public function createOwnLayer():Bool
	{
		return true;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PRIVATE HELPER METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Overriden as the scontaining dimensionsn for the scrollbars
	 * appearing for the initial containing block are the viewport's
	 */
	override private function getScrollbarContainerBlock():ContainingBlockVO
	{
		var width:Float = cocktail.Lib.window.innerWidth;
		var height:Float = cocktail.Lib.window.innerHeight;
		
		return new ContainingBlockVO(width, false, height, false);
	}
	
	/**
	 * When dispatched on the HTMLHTMLElement,
	 * the scroll event must bubble to be dispatched
	 * on the Document and Window objects
	 */
	override private function mustBubbleScrollEvent():Bool
	{
		return true;
	}
	
	/**
	 * A computed value of visible for the overflow on the initial
	 * block renderer is the same as auto, as it is likely that
	 * scrollbar must be displayed to scroll through the document
	 */
	override private function treatVisibleOverflowAsAuto():Bool
	{
		return true;
	}
	
	/**
	 * Retrieve the dimension of the Window
	 */
	override private function getWindowData():ContainingBlockVO
	{	
		var width:Float = cocktail.Lib.window.innerWidth;
		var height:Float = cocktail.Lib.window.innerHeight;
		
		//scrollbars dimension are removed from the Window dimension
		//if displayed to return the actual available space
		
		if (_verticalScrollBar != null)
		{
			width -= _verticalScrollBar.coreStyle.usedValues.width;
		}
		
		if (_horizontalScrollBar != null)
		{
			height -= _horizontalScrollBar.coreStyle.usedValues.height;
		}
		
		_containerBlockData.width = width;
		_containerBlockData.height = height;
		_containerBlockData.isHeightAuto = false;
		_containerBlockData.isWidthAuto = false;
		return _containerBlockData;
	}
	
	/**
	 * The dimensions of the initial
	 * block renderer are always the same as the Window's
	 */
	override public function getContainerBlockData():ContainingBlockVO
	{
		return getWindowData();
	}
	
	/**
	 * Returns itself as containing block, which is used
	 * during layout
	 */
	override private function getContainingBlock():FlowBoxRenderer
	{	
		return this;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN GETTER
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * For the initial container, the bounds and
	 * global bounds are the same
	 */
	override private function get_globalBounds():RectangleVO
	{
		return bounds;
	}
	
}