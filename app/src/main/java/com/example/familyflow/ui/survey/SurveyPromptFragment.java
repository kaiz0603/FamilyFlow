package com.example.familyflow.ui.survey;

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

public class SurveyPromptFragment extends Fragment {

    private String role = "parent";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_survey_prompt, container, false);

        Button btnDoSurvey = root.findViewById(R.id.btn_do_survey);
        Button btnSkipSurvey = root.findViewById(R.id.btn_skip_survey);

        if (getArguments() != null) {
            role = getArguments().getString("role", "parent");
        }

        btnDoSurvey.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString("role", role);
            Navigation.findNavController(v).navigate(R.id.action_prompt_to_survey, bundle);
        });

        btnSkipSurvey.setOnClickListener(v -> {
            Bundle bundle = new Bundle();
            bundle.putString("role", role);
            bundle.putString("familyType", "ALL"); // 跳过问卷 → 显示全部
            Navigation.findNavController(v).navigate(R.id.action_prompt_to_content, bundle);
        });

        return root;
    }
}
