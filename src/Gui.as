package {
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.themes.MetalWorksDesktopTheme;

/**
 * ...
 * @author Shatalov Andrey
 */
public class Gui extends LayoutGroup {
	
	private var _textInput : TextInput;
	private var _sendButton : Button;
	private var _label : Label;
	
	public function Gui() {
		super();
		this.autoSizeMode = LayoutGroup.AUTO_SIZE_MODE_STAGE;
		//new MetalWorksMobileTheme();	
		new MetalWorksDesktopTheme();
		this.layout = new AnchorLayout();
		
		_textInput = new TextInput();
		_sendButton = new Button();
		_label = new Label();
	}
	
	protected override function initialize():void {
		super.initialize();
		
		var help : Label = new Label();
		help.styleNameList.add(Label.ALTERNATE_STYLE_NAME_DETAIL);
		help.text = "Press Enter to reset animation\nPress + to encrease the playback speed\nPress - to decrease the playback speed\nPress P to pause/play animation";
		this.addChild(help);
		
		_label.layoutData = new AnchorLayoutData(10, NaN, NaN, 0);
		_label.styleNameList.add(Label.ALTERNATE_STYLE_NAME_DETAIL);
		AnchorLayoutData(_label.layoutData).topAnchorDisplayObject = help;
		this.addChild(_label);
		
		var footerGroup : LayoutGroup = new LayoutGroup();
		footerGroup.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
		footerGroup.layout = new HorizontalLayout();
		HorizontalLayout(footerGroup.layout).gap = 4;
		this.addChild(footerGroup);
		
		_textInput.prompt = "Input full URL to .awp file";
		_textInput.layoutData = new HorizontalLayoutData(100);
		footerGroup.addChild(_textInput);
		
		_sendButton.label = "Load";
		footerGroup.addChild(_sendButton);
	}
	
	public function getURL() : String {
		return _textInput.text;
	}
	
	public function setURL(text : String) : void {
		_textInput.text = text;
	}
	
	public function get sendButton():Button {
		return _sendButton;
	}
	
	public function get label():Label {
		return _label;
	}
}
}