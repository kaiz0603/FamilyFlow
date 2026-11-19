package com.example.familyflow.ui.family;

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

public class FirstUseFragment extends Fragment {

    private Button btnCreate, btnJoin;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_first_use, container, false);

        btnCreate = root.findViewById(R.id.btn_create);
        btnJoin = root.findViewById(R.id.btn_join);

        btnCreate.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString("role", getArguments().getString("role", "parent"));
            Navigation.findNavController(v).navigate(R.id.action_first_to_create, bundle);
        });

        btnJoin.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString("role", getArguments().getString("role", "parent"));
            Navigation.findNavController(v).navigate(R.id.action_first_to_join, bundle);
        });

        return root;
    }
}
