package io.hgeg.cloudboard;

import android.content.ClipboardManager;

/**
 * Created by can on 10/2/13.
 */
public class SyncListener implements ClipboardManager.OnPrimaryClipChangedListener {
    @Override
    public void onPrimaryClipChanged() {
        MainActivity.model.push();
    }
}
