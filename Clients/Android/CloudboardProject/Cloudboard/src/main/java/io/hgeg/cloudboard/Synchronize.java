package io.hgeg.cloudboard;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;

/**
 * Created by can on 9/30/13.
 */
public class Synchronize extends AsyncTask<Void, Void, String> {

    private boolean exception;
    private Activity context;
    private ClipboardManager clipboard;

    protected String doInBackground(Void... none) {
        this.context = MainActivity.model;
        this.clipboard = MainActivity.clipboard;
        HttpURLConnection connection;
        OutputStreamWriter request = null;

        URL url = null;
        String response = null;
        long timestamp = System.currentTimeMillis()/1000;
        String raw_sig = timestamp+"&"+md5("sokoban")+"&"+"UZepT6F8abA80DK1ilCz";
        String parameters = "user=Hgeg&timestamp="+timestamp+"&key=H4vlwkm8tvO8&signature="+md5(raw_sig);

        try
        {
            url = new URL("http://hgeg.io/cloudboard/get/");
            connection = (HttpURLConnection) url.openConnection();
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            connection.setRequestMethod("POST");

            request = new OutputStreamWriter(connection.getOutputStream());
            request.write(parameters);
            request.flush();
            request.close();
            String line = "";
            InputStreamReader isr = new InputStreamReader(connection.getInputStream());
            BufferedReader reader = new BufferedReader(isr);
            StringBuilder sb = new StringBuilder();
            while ((line = reader.readLine()) != null)
            {
                sb.append(line + "\n");
            }
            // Response from server after login process will be stored in response variable.
            response = sb.toString();
            // You can perform UI operations here
            isr.close();
            reader.close();
            this.exception = false;
            return response;
        } catch(Exception e) {
            this.exception = true;
            return e.toString();
        }
    }

    public static String md5(String message) {
        String digest = null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5"); byte[] hash = md.digest(message.getBytes("UTF-8"));
            //converting byte array to Hexadecimal
            StringBuilder sb = new StringBuilder(2*hash.length);
            for(byte b : hash){ sb.append(String.format("%02x", b&0xff)); }
            digest = sb.toString();
        } catch (Exception e) {}
        return digest;
    }

    protected void onPostExecute(String data) {
        TextView clipView = (TextView) this.context.findViewById(R.id.clipView);
        if(!this.exception) {

            SharedPreferences prefs = this.context.getSharedPreferences("clip", Context.MODE_PRIVATE);

            if(!prefs.getString("data","").equals(data)) {
                clipView.setText(data);
                ClipData clip = ClipData.newPlainText("io.hgeg.cloudboard.clipboard.data", data);
                clipboard.setPrimaryClip(clip);
                SharedPreferences.Editor editor = prefs.edit();
                editor.putString("data",data);
                editor.commit();
                Toast.makeText(this.context, "Clipboard updated!", Toast.LENGTH_LONG).show();
            }
        }else {
            clipView.setText("");
            Toast.makeText(this.context, "Error!", Toast.LENGTH_LONG).show();
        }

    }
}
