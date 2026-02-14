
package com.example.familyflow;
import android.content.Context;
import android.content.SharedPreferences;
public class Prefs {
    private static final String NAME = "familyflow_prefs";
    public static void putString(Context c, String k, String v){
        SharedPreferences p = c.getSharedPreferences(NAME, Context.MODE_PRIVATE);
        p.edit().putString(k, v).apply();
    }
    public static String getString(Context c, String k, String def){
        SharedPreferences p = c.getSharedPreferences(NAME, Context.MODE_PRIVATE);
        return p.getString(k, def);
    }
    public static void putBoolean(Context c, String k, boolean v){
        SharedPreferences p = c.getSharedPreferences(NAME, Context.MODE_PRIVATE);
        p.edit().putBoolean(k, v).apply();
    }
    public static boolean getBoolean(Context c, String k, boolean def){
        SharedPreferences p = c.getSharedPreferences(NAME, Context.MODE_PRIVATE);
        return p.getBoolean(k, def);
    }
}
