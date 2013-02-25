package com.example.hellojni;

import android.content.Context;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;

public class CustomView extends UIViewBridge implements OnTouchListener {

	public CustomView(Context context, HelloJni app) {
		super(context, app);
	}
	
	@Override
	public boolean onTouch(View v, MotionEvent event) {
	    touchEvent(this.viewID, event.getX(), event.getY());
	    return false;
	}
	
    public String objcClassName() {
    	return "CustomView";
    }
	
}
