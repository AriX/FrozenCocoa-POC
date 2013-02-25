package com.example.hellojni;

import android.content.Context;
import android.graphics.Color;
import android.view.DragEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.MotionEvent;
import android.widget.AbsoluteLayout;
import android.widget.FrameLayout;

@SuppressWarnings("deprecation")
public class UIViewBridge extends AbsoluteLayout implements OnTouchListener {
	int viewID;
	HelloJni app;

	public UIViewBridge(Context context, HelloJni app) {
		super(context);
		
		this.app = app;
		this.setOnTouchListener(this);
	}
	
	public UIViewBridge addSubview(final int viewID, int x, int y, int width, int height) {
		UIViewBridge subview = new UIViewBridge(this.app, this.app);
		subview.viewID = viewID;
		subview.setLayoutParams(new AbsoluteLayout.LayoutParams(width, height, x, y));
		this.addView(subview);
		subview.attachToView(subview.viewID);
		subview.setOnTouchListener(subview);
		return subview;
	}
	
	@Override
	public boolean onTouch(View v, MotionEvent event) {
		System.out.println(event.getX());
	    touchEvent(this.viewID, event.getX(), event.getY());
	    return false;
	}
	
	public void removeSubview(View view) {
		//?
	}
	
	public void initializeView() {
		this.viewID = initView(this.objcClassName(), this.getMeasuredWidth(), this.getMeasuredHeight());
		System.out.println("CLASS: " + this.objcClassName() + " VIEW ID: " + this.viewID);
	}
	
    public String objcClassName() {
    	return "UIView";
    }
    
    public void setBackgroundColorRGBA(float red, float green, float blue, float alpha) {
    	System.out.println("SETBGCOLOR");
    	this.setBackgroundColor(Color.argb((int)(alpha * 255.0), (int)(red * 255.0), (int)(green * 255.0), (int)(blue * 255.0)));
    }
    
    public void setFrame(int x, int y, int width, int height) {
    	AbsoluteLayout layout = (AbsoluteLayout)this;
    	AbsoluteLayout.LayoutParams params = new AbsoluteLayout.LayoutParams(width, height, x, y);
    	if (params.getClass() == layout.getLayoutParams().getClass()) {
	    	try {
	    		layout.setLayoutParams(new AbsoluteLayout.LayoutParams(width, height, x, y));
	    	} catch (Exception e) {
	    		
	    	}
    	}
    	//ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(width, height);
        //this.setLayoutParams(params);
    }
	
    static {
        System.loadLibrary("hello-jni");
    }
	
    public native int initView(String objcClassName, int width, int height);
    public native void touchEvent(int viewID, float x, float y);
    public native void attachToView(int viewID);
}
