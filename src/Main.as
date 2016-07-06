package {
import away3d.containers.View3D;
import away3d.core.managers.Stage3DManager;
import away3d.core.managers.Stage3DProxy;
import away3d.debug.AwayStats;
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
import starling.core.Starling;
import starling.events.Event;

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
	protected var _awayStats : AwayStats;
	
	private var _textField : TextField;
	private var _playBackSpeed : Number = 1;
	private var _starling : Starling;
	
	private function createTextField() : void {
		if (_textField == null) {
			_textField = new TextField();
			_textField.x = _textField.y = 0;
			_textField.width = 500;
			_textField.textColor = 0xffffff;
			this.addChild(_textField);
		}
	}
	
	private function log(message : String) : void {
		if (gui) {
			gui.label.text = message;
		}
	}
	
	public function get gui() : Gui {
		return _starling ? _starling.root as Gui : null;
	}
	
	public function Main() {
		if (stage) {
			init();
		} else {
			addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(e : flash.events.Event = null) : void {
		removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		setupStage();
		initializeStats();
		initialize3D();
	}
	
	private function initializeStats() : void {
		addChild(_awayStats = new AwayStats());
		_awayStats.visible = true;
	}
	
	protected function tryPositionAwayStats() : void {
		if (_awayStats)
			_awayStats.x = stage.stageWidth - _awayStats.width;
	}
	
	private function setupStage() : void {
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		Parsers.enableAllBundled();
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		createTextField();
	}
	
	private function onKeyDown(event : KeyboardEvent) : void {
		switch (event.keyCode) {
			case Keyboard.ENTER: 
				for each (var item : ParticleGroup in _particleGroups) {
					trace("Reseting time");
					item.animator.resetTime();
					item.animator.start();
				}
				break;
			case Keyboard.EQUAL: 
				_playBackSpeed += 0.1;
				for each (var item : ParticleGroup in _particleGroups) {
					item.animator.playbackSpeed = _playBackSpeed;
				}
				break;
			case Keyboard.MINUS: 
				_playBackSpeed -= 0.1;
				for each (var item : ParticleGroup in _particleGroups) {
					item.animator.playbackSpeed = _playBackSpeed;
				}
				break;
			case Keyboard.P: 
				if (_particleGroups.length >= 1 && _particleGroups[0].animator.playbackSpeed != _playBackSpeed) {
					for each (var item : ParticleGroup in _particleGroups) {
						item.animator.playbackSpeed = _playBackSpeed;
					}
				} else if (_playBackSpeed != 0) {
					for each (var item : ParticleGroup in _particleGroups) {
						item.animator.playbackSpeed = 0;
					}
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
	
	private function onContextCreated(event : Stage3DEvent) : void {
		_starling = new Starling(Gui, this.stage, _stage3DProxy.viewPort, _stage3DProxy.stage3D);
		_starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
		_starling.start();
		
		stage.addEventListener(flash.events.Event.RESIZE, onResize);
		onResize();
	}
	
	private function onRootCreated(event : starling.events.Event) : void {
		_starling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
		Gui(_starling.root).sendButton.addEventListener(starling.events.Event.TRIGGERED, onSentURL);
	}
	
	private function onSentURL(event : starling.events.Event) : void {
		if (Gui(_starling.root).getURL() == "") {
			return;
		}
		loadEffect(Gui(_starling.root).getURL(), "firstEffect");
	}
	
	private function onEnterFrame(e : flash.events.Event) : void {
		_view.render();
		_starling.nextFrame();
		if (_particleGroups.length >= 1) {
			log("Animation speed : " + _particleGroups[0].animator.playbackSpeed.toFixed(1));
		}
	}
	
	private function onResize(event : flash.events.Event = null) : void {
		_view.width = stage.stageWidth;
		_view.height = stage.stageHeight;
		
		tryPositionAwayStats();
	}
	
	private function clear3DScene() : void {
		while (_view.scene.numChildren > 0) {
			_view.scene.removeChildAt(0);
		}
		if (_particleGroups.length != 0) {
			_particleGroups.length = 0;
		}
	}
	
	private function loadEffect(effectPath : String, key : String) : void {
		log("loading " +effectPath + " has started...");
		clear3DScene();
		var parser : ParticleGroupParser = new ParticleGroupParser();
		_dataToLoad[parser] = false;
		parser.addEventListener(ParserEvent.PARSE_COMPLETE, function(event : ParserEvent) : void {
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
	
	private function checkLoadingComplete() : void {
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
	
	private function processLoadingComplete() : void {
		trace("loading complete");
		log("loading complete");
		runEffect("firstEffect", new Vector3D());
	}
	
	private function runEffect(key : String, position : Vector3D) : void {
		var pg : ParticleGroup = AssetLibrary.getAsset(key) as ParticleGroup;
		if (pg) {
			_view.scene.addChild(pg);
			pg.position = position;
			pg.animator.playbackSpeed = _playBackSpeed;
			pg.animator.start();
			_particleGroups.push(pg);
			trace(key + " add to scene complete");
		}
	}
}
}