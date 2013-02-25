/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.example.hellojni;

import android.app.Activity;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.os.Bundle;

import com.example.hellojni.UIViewBridge;
import com.example.hellojni.CustomView;


public class HelloJni extends Activity
{
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        
        initialize();
        
    	CustomView contentView = new CustomView(getApplicationContext(), this);
    	contentView.initializeView();
        setContentView(contentView);
        
        /*Button button = new Button(this);
        button.setOnClickListener(handler);
        button.setText("Run");
        //setContentView(button);
        contentView.addView(button);*/
    }

    public native void initialize();
    public native String stringFromJNI();
    
    static {
        System.loadLibrary("hello-jni");
    }
    
    View.OnClickListener handler = new View.OnClickListener() {
        public void onClick(View v) {        	
            TextView  tv = new TextView(getApplicationContext());
            tv.setText( stringFromJNI() );
            setContentView(tv);
        }
      };
}
