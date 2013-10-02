package io.hgeg.cloudboard;

import android.app.Activity;
import android.os.Bundle;

/**
 * Created by can on 10/2/13.
 */
public class SettingsActivity extends Activity{
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        getActionBar().setHomeButtonEnabled(true);
        getActionBar().setDisplayHomeAsUpEnabled(true);
    }
}
