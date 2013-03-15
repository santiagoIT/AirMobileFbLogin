package {

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import starling.core.Starling;
import starling.utils.RectangleUtil;
import starling.utils.ScaleMode;
import flash.display.Sprite;
import flash.events.MouseEvent;

[SWF(frameRate="30", backgroundColor="#000")]
public class MobileAs3FbTest extends Sprite {

    // log-in, log-out buttons
    private var _btnLogIn:Sprite;
    private var _btnLogOut:Sprite;
    private var _btnCancelLogIn:Sprite;

    // facebook bridge
    var _fb:FacebookInitializer;

    // text
    var _tfInfo:TextField;

    // Startup image for HD screens
    [Embed(source="../system/startupHD.jpg")]
    private static var BackgroundHD:Class;

    public function MobileAs3FbTest() {

        // set general properties
        var stageWidth:int   = 320;
        var stageHeight:int  = 480;
        var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;

        Starling.multitouchEnabled = true;  // useful on mobile devices
        Starling.handleLostContext = !iOS;  // not necessary on iOS. Saves a lot of memory!

        // create a suitable viewport for the screen size
        //
        // we develop the game in a *fixed* coordinate system of 320x480; the game might
        // then run on a device with a different resolution; for that case, we zoom the
        // viewPort to the optimal size for any display and load the optimal textures.

        var viewPort:Rectangle = RectangleUtil.fit(
                new Rectangle(0, 0, stageWidth, stageHeight),
                new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight),
                ScaleMode.SHOW_ALL);


        var background:Bitmap = new BackgroundHD();
        background.x = 0;
        background.y = 0;
        background.width  = viewPort.width;
        background.height = viewPort.height;
        background.smoothing = true;
        addChild(background);

        // add text info
        _tfInfo = new TextField();
        _tfInfo.x = 20;
        _tfInfo.y = 60;
        _tfInfo.width = 500;
        _tfInfo.height = 500;
        _tfInfo.textColor = 0xcccccc;
        _tfInfo.multiline = true;
        _tfInfo.wordWrap = true;
        addChild(_tfInfo);

        _fb = new FacebookInitializer("154719741349961", "https://apps.facebook.com/zehundah/", this.stage);

        PrepareForLogin();
    }

    private function PrepareForLogin():void {

        // clear text
        _tfInfo.text = "";

        // add login button ?
        if (!_btnLogIn) {
            _btnLogIn = CreateButton("Log In", 0x00ff00);
            this.addChild(_btnLogIn);
            _btnLogIn.addEventListener(MouseEvent.CLICK, OnBtnLogin, false, 0, true);
        }
        else {
            _btnLogIn.visible = true;
        }

        if (_btnLogOut) {
            if (_btnLogOut.parent) {
                _btnLogOut.parent.removeChild(_btnLogOut);
            }
            _btnLogOut = null;
        }
    }

    private function OnBtnLogin(e:MouseEvent):void {

        var self = this;
        // hide login button...
        _btnLogIn.visible = false;

        // add cancel login button
        _btnCancelLogIn =  CreateButton("CancelLogIn", 0xccff00);
        addChild(_btnCancelLogIn);
        _btnCancelLogIn.addEventListener(MouseEvent.CLICK, function(me:MouseEvent){
            _fb.CancelLogin();

            // kill cancel button
            self.removeChild(self._btnCancelLogIn);
            self._btnCancelLogIn = null;

            // show login
            self._btnLogIn.visible = true;

        }, false, 0, true);

        // init, login callback
        var self = this;
        var callback = function(success, fail) {

            // kill cancel button
            self.removeChild(self._btnCancelLogIn);
            self._btnCancelLogIn = null;


            // login failed?
            if (fail) {
                _tfInfo.text = JSON.stringify(fail);
                return;
            }

            // remove login button
            self.removeChild(self._btnLogIn);
            self._btnLogIn = null;

            // add logout button
            self._btnLogOut = self.CreateButton("Log Out", 0xff0000);
            self._btnLogOut.x = 400;
            self.addChild(_btnLogOut);
            self._btnLogOut.addEventListener(MouseEvent.CLICK, ObBtnLogout, false, 0, true);

            // data
            _tfInfo.text = JSON.stringify(success);
        }

        _fb.Init(callback);
    }

    private function ObBtnLogout(me:MouseEvent): void {
        var self = this;
        _fb.Logout(function(ok:Object){
            self.PrepareForLogin();
        });
    }

    private function CreateButton(text:String, color:uint): Sprite {

        var button:Sprite = new Sprite();
        button.graphics.beginFill(color, 1);
        button.graphics.drawRect(0, 0, 100, 50);
        button.graphics.endFill();
        if (text) {
            var tf:TextField = new TextField();
            tf.text = text;
            button.addChild(tf);
        }
        button.buttonMode = true;
        button.mouseChildren = false;

        return button;
    }
}
}
