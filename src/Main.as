package {
import away3d.containers.View3D;
import away3d.core.managers.Stage3DManager;
import away3d.core.managers.Stage3DProxy;
import away3d.entities.ParticleGroup;
import away3d.events.ParserEvent;
import away3d.events.Stage3DEvent;
import away3d.library.AssetLibrary;
import away3d.loaders.AssetLoader;
import away3d.loaders.misc.AssetLoaderContext;
import away3d.loaders.parsers.Parsers;
import away3d.loaders.parsers.ParticleGroupParser;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Vector3D;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

/**
 * ...
 * @author Shatalov Andrey
 */
public class Main extends Sprite {
	private var _view : View3D;
	private static const assetLoaderContext : AssetLoaderContext = new AssetLoaderContext();
	private var _dataToLoad : Dictionary = new Dictionary;
	private var _stage3DProxy : Stage3DProxy;
	private var _particleGroups : Vector.<ParticleGroup> = new Vector.<ParticleGroup>();
	
	private var _textField : TextField;
	private function createTextField() : void {
		if(_textField == null) {
			_textField = new TextField();
			_textField.x = _textField.y = 0;
			_textField.width = 500;
			_textField.textColor = 0xffffff;
			this.addChild(_textField);
		} 
	}

	private function log(message : String) : void { 
		if (_textField) {
			_textField.text = message + "\n";
		}
	}
	
	public function Main() {
		if (stage) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(e : Event = null) : void {
		removeEventListener(Event.ADDED_TO_STAGE, init);		
		setupStage();
		initialize3D();
	}

	private function setupStage():void {
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		Parsers.enableAllBundled();
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		createTextField();
	}
	
	private function onKeyDown(event:KeyboardEvent):void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
				for each (var item : ParticleGroup in _particleGroups) {
					trace("Reseting time");
					item.animator.resetTime();
					item.animator.start();
				}
			break;
			case Keyboard.EQUAL:
				for each (var item : ParticleGroup in _particleGroups) {
					item.animator.playbackSpeed += 0.1;
				}
			break;
			case Keyboard.MINUS:
				for each (var item : ParticleGroup in _particleGroups) {
					item.animator.playbackSpeed -= 0.1;
				}
			break;
		}
	}
		
	private function initialize3D() : void {		
		_stage3DProxy = Stage3DManager.getInstance(stage).getFreeStage3DProxy(false, Context3DProfile.BASELINE_EXTENDED);
		_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
		_stage3DProxy.antiAlias = 8;
		_stage3DProxy.color = 0;
		_stage3DProxy.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		
		_view = new View3D();
		_view.stage3DProxy = _stage3DProxy;
		_view.shareContext = true;
		_view.layeredView = true;	
		this.addChild(_view);
		
		new CameraController(_view.camera, stage);
	}
	
	private function onContextCreated(event:Stage3DEvent):void {
		stage.addEventListener(Event.RESIZE, onResize);
		onResize();

		loadEffect("http://r.playerio.com/r/moba-zpuzrjgvp0pk6vq9l6mfq/effects_debug/left_container/debug.awp", "firstEffect");
		loadEffect("http://r.playerio.com/r/moba-zpuzrjgvp0pk6vq9l6mfq/effects_debug/right_container/debug.awp", "secondEffect");
	}	
	
	private function onEnterFrame(e : Event) : void {
		_view.render();
		if (_particleGroups.length >= 1) {
			var help : String = "Press Enter to reset animation\nPress + to encrease the playback speed\nPress - to decrease the playback speed\n";
			log(help + "\nPlayback speed : " + _particleGroups[0].animator.playbackSpeed.toFixed(1));
		}
	}
	
	private function onResize(event : Event = null) : void {
		_view.width = stage.stageWidth;
		_view.height = stage.stageHeight;
	}
	
	private function loadEffect(effectPath : String, key : String) : void {
		var parser : ParticleGroupParser = new ParticleGroupParser();
		_dataToLoad[parser] = false;
		parser.addEventListener(ParserEvent.PARSE_COMPLETE, function (event : ParserEvent):void {
			parseComplete(event, key);
		});
		
		var loader : AssetLoader = new AssetLoader();
		loader.load(new URLRequest(effectPath), assetLoaderContext, null, parser);
	}	
	
	private function parseComplete(event : ParserEvent, key : String) : void {
		var parser : ParticleGroupParser = ParticleGroupParser(event.target);
		parser.particleGroup.name = key;
		AssetLibrary.addAsset(parser.particleGroup);
		parser.removeEventListener(event.type, parseComplete);
		_dataToLoad[parser] = true;
		
		checkLoadingComplete();
	}
	
	private function checkLoadingComplete():void {
		var loadedCount : int = 0;
		var prepareToLoading : int = 0;
		for each (var item : Boolean in _dataToLoad) {
			prepareToLoading++;
			if (item) {
				loadedCount++;
			}
		}
		if (loadedCount == prepareToLoading) {
			processLoadingComplete();
		}
	}
	
	private function processLoadingComplete():void {
		trace("loading complete");
		runEffect("firstEffect", new Vector3D(-400));
		runEffect("secondEffect", new Vector3D(400));		
	}
	
	private function runEffect(key : String, position : Vector3D) : void {
		var pg : ParticleGroup = AssetLibrary.getAsset(key) as ParticleGroup;
		if (pg) {
			_view.scene.addChild(pg);	
			pg.position = position;
			pg.animator.start();	
			_particleGroups.push(pg);
			trace(key + " add to scene complete");
		}
	}
}
}