package com.example.familyflow.ui.family;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.example.familyflow.R;

public class JoinFamilyFragment extends Fragment {

    private EditText etCode;
    private Button btnJoin;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_join_family, container, false);

        etCode = root.findViewById(R.id.et_code);
        btnJoin = root.findViewById(R.id.btn_join_family);

        btnJoin.setOnClickListener(v -> {
            String code = etCode.getText().toString().trim();

            Bundle bundle = new Bundle();
            bundle.putString("role", getArguments().getString("role", "parent"));
            bundle.putString("familyCode", code);

            Navigation.findNavController(v).navigate(R.id.action_join_to_surveyPrompt, bundle);
        });

        return root;
    }
}
