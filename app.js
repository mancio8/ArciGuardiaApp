import { StatusBar, Style } from '@capacitor/status-bar';

window.addEventListener('DOMContentLoaded', async () => {
  try {
    await StatusBar.setOverlaysWebView({ overlay: false });
    await StatusBar.setBackgroundColor({ color: '#008c45' });
    await StatusBar.setStyle({ style: Style.Light });
  } catch (err) {
    console.log("StatusBar non disponibile", err);
  }
});
