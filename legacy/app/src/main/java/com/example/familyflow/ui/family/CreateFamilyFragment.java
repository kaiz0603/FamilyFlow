package com.example.familyflow.ui.family;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.example.familyflow.R;

import java.util.UUID;

public class CreateFamilyFragment extends Fragment {

    private TextView tvCode;
    private Button btnGenerate, btnNext;

    private String familyCode = "";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_create_family, container, false);

        tvCode = root.findViewById(R.id.tv_code);
        btnGenerate = root.findViewById(R.id.btn_generate_code);
        btnNext = root.findViewById(R.id.btn_next);

        btnGenerate.setOnClickListener(v -> {
            familyCode = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
            tvCode.setText("家庭编号: " + familyCode);
        });

        btnNext.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString("role", getArguments().getString("role", "parent"));
            bundle.putString("familyCode", familyCode);
            Navigation.findNavController(v).navigate(R.id.action_create_to_surveyPrompt, bundle);
        });

        return root;
    }
}
