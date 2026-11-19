package com.example.familyflow.ui.auth;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.example.familyflow.R;

public class RoleSelectFragment extends Fragment {

    private Button btnParent, btnChild;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_role_select, container, false);

        btnParent = view.findViewById(R.id.btn_parent);
        btnChild = view.findViewById(R.id.btn_child);

        btnParent.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString("role", "parent");
            Navigation.findNavController(v).navigate(R.id.action_first_to_join, bundle);
        });

        btnChild.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString("role", "child");
            Navigation.findNavController(v).navigate(R.id.action_first_to_join, bundle);
        });

        return view;
    }
}
