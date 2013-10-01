package io.hgeg.cloudboard;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.Menu;
import android.widget.TextView;
import android.widget.Toast;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubError;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.Hashtable;

public class MainActivity extends Activity {

    public static MainActivity model;
    Pubnub pubnub  = new Pubnub("pub-56806acb-9c46-4008-b8cb-899561b7a762","sub-26001c28-a260-11e1-9b23-0916190a0759","",false);
    String channel = "Hgeg";
    public static ClipboardManager clipboard;



    private void notifyUser(Object message) {
        try {
            if (message instanceof JSONObject) {
                final JSONObject obj = (JSONObject) message;
                this.runOnUiThread(new Runnable() {
                    public void run() {
                        Toast.makeText(getApplicationContext(), obj.toString(),
                                Toast.LENGTH_LONG).show();

                        Log.i("Received msg : ", String.valueOf(obj));
                    }
                });

            } else if (message instanceof String) {
                final String obj = (String) message;
                this.runOnUiThread(new Runnable() {
                    public void run() {
                        Toast.makeText(getApplicationContext(), obj,
                                Toast.LENGTH_LONG).show();
                        Log.i("Received msg : ", obj.toString());
                    }
                });

            } else if (message instanceof JSONArray) {
                final JSONArray obj = (JSONArray) message;
                this.runOnUiThread(new Runnable() {
                    public void run() {
                        Toast.makeText(getApplicationContext(), obj.toString(),
                                Toast.LENGTH_LONG).show();
                        Log.i("Received msg : ", obj.toString());
                    }
                });
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        model = this;
        clipboard = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
        this.registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context arg0, Intent intent) {
                pubnub.disconnectAndResubscribe();

            }

        }, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));

        TextView clipView = (TextView) this.findViewById(R.id.clipView);
        clipView.setMovementMethod(new ScrollingMovementMethod());

        subscribe();

    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    protected void onResume(){
        super.onResume();
        Synchronize s = new Synchronize();
        s.execute();
    }

    private void subscribe() {
        Hashtable args = new Hashtable(1);
        args.put("channel", channel);

        try {
            pubnub.subscribe(args, new Callback() {
                @Override
                public void connectCallback(String channel,Object message) {}
                @Override
                public void disconnectCallback(String channel,Object message) {}

                @Override
                public void reconnectCallback(String channel,Object message) {}
                @Override
                public void successCallback(String channel,Object message) {
                    Synchronize s = new Synchronize();
                    s.execute();
                }
                @Override
                public void errorCallback(String channel,PubnubError error) {}
            });
        } catch (Exception e) {
        }

    }

}

