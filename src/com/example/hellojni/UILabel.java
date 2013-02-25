package com.example.hellojni;

import android.content.Context;
import android.widget.TextView;

public class UILabel extends TextView {
	int viewID;

    public UILabel(Context context) {
		super(context);
	}
    
	public void initializeView() {
		this.viewID = initView(this.objcClassName(), this.getMeasuredWidth(), this.getMeasuredHeight());
		System.out.println("CLASS: " + this.objcClassName() + " VIEW ID: " + this.viewID);
	}
    
    public String objcClassName() {
    	return "UILabel";
    }
    
	static {
        System.loadLibrary("hello-jni");
    }
	
    public native int initView(String objcClassName, int width, int height);
    public native void touchEvent(int viewID, float x, float y);
    public native void attachToView(int viewID);
}
