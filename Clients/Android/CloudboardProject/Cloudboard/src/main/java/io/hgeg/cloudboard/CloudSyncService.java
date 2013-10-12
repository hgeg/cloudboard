package io.hgeg.cloudboard;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

/**
 * Created by can on 10/8/13.
 */
public class CloudSyncService extends Service {

    String tag="io.hgeg.cloudboard";

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        //TODO do something useful
        Log.e(tag,"service started");
        //MainActivity.clipboard = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
        //((MainActivity.clipboard.addPrimaryClipChangedListener(new SyncListener());
        return Service.START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        //TODO for communication return IBinder implementation
        return null;
    }
}
