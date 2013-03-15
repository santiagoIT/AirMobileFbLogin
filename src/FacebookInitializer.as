/**
 * Created with IntelliJ IDEA.
 * User: santiago
 * Date: 3/13/13
 * Time: 5:28 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.facebook.graph.FacebookMobile;

import flash.display.Stage;

import flash.geom.Rectangle;

import flash.media.StageWebView;

import starling.core.Starling;

public class FacebookInitializer {

    private var _appId:String;
    private var _appOrigin:String;

    private var _stage:Stage;
    private var _callback:Function;
    private var _callbackLogout:Function;

    // cache stage view in case user manually cancels login
   private var _webView:StageWebView;

    public function FacebookInitializer(appId:String, appOrigin:String, stage:Stage) {
        _appId = appId;
        _stage = stage;
        _appOrigin = appOrigin;
    }

    public function Init(callback:Function):void {
        _callback = callback;
        FacebookMobile.init(_appId, OnFbInit);
    }

    public function Logout(callback:Function): void {
        _callbackLogout = callback;
        // log out
        FacebookMobile.logout(OnFbLogout, _appOrigin);
    }

    public function CancelLogin(): void {
        if (_webView){
            _webView.dispose();
        }
    }

    private function OnFbInit(success:Object, fail:Object):void {

        // if user is not loged in, init call will fail
        if (fail) {
            // log in
            _webView =   new StageWebView();
            _webView.viewPort = new Rectangle(0,50, 600,800);//_webView.stage.width, _webView.stage.height);
            FacebookMobile.login(OnFbLogin, _stage, ["email"], _webView);
            trace('stage info', _stage.width, _stage.height);
            trace('full stage info', _stage.fullScreenWidth, _stage.fullScreenHeight);
            return;
        }

        //
        trace('FB init success 2');
        _callback(success, fail);
    }

    private function OnFbLogin(success:Object, fail:Object):void {

        // clear webview referece (FB API, kills the view)
        this._webView = null;

       _callback(success, fail);

        // get some data
       // FacebookMobile.api("/me", OnMe);
    }

    private function OnMe(success:Object, fail:Object): void {

        trace('Got some data', success);

        _callback(success);

        // log out
        FacebookMobile.logout(OnFbLogout, "https://apps.facebook.com/zehundah/");

    }

    private function OnFbLogout(ok:Object): void {

        if (_callbackLogout) {
            _callbackLogout(ok);
        }
    }
}
}
