package com.arciguardia.online;

import android.os.Bundle;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
  @Override
  public void onBackPressed() {
    WebView webView = (WebView) this.bridge.getWebView();
    if (webView.canGoBack()) {
      webView.goBack();
    } else {
      super.onBackPressed(); // chiude l'app
    }
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
  }
}
