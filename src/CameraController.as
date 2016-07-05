package {
import away3d.cameras.Camera3D;
import away3d.controllers.HoverController;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

public class CameraController extends HoverController {
	private var _camera : Camera3D;
	private var _appStage : Stage;

	private var _lastX : Number;
	private var _lastY : Number;
	private var _lastPanAngle : Number;
	private var _lastTiltAngle : Number;
	
	public function CameraController(camera : Camera3D, appStage : Stage) {
		super(camera, null, 0, 30, 1000, 10);
		this._camera = camera;
		this._appStage = appStage;
		init();
	}
	
	private function init() : void {
		_appStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		_appStage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		this.tiltAngle = 30;
	}
	
	private function onMouseWheel(event:MouseEvent):void {
		this.distance -= event.delta;
	}
	
	private function onMouseDown(event : MouseEvent) : void {
		_lastX = _appStage.mouseX;
		_lastY = _appStage.mouseY;
		_lastPanAngle = this.panAngle;
		_lastTiltAngle = this.tiltAngle;
		_appStage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		_appStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}
	
	private function onMouseMove(event : MouseEvent) : void {
		this.tiltAngle = _lastPanAngle + (_appStage.mouseY - _lastY) / 5;
		this.panAngle = _lastTiltAngle + (_appStage.mouseX - _lastX) / 5;
		
		this.panAngle = 0.3 * (_appStage.mouseX - _lastX) + _lastPanAngle;
		this.tiltAngle = 0.3 * (_appStage.mouseY - _lastY) + _lastTiltAngle;
	}
	
	private function onMouseUp(event : MouseEvent) : void {
		_appStage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		_appStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}
}
}