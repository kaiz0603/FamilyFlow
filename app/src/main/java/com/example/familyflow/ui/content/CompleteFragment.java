package com.example.familyflow.ui.content;

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

public class CompleteFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_complete, container, false);

        Button btnBackToQuestions = root.findViewById(R.id.btnBackToQuestions);

        btnBackToQuestions.setOnClickListener(v -> {
            // 回到问题选择界面
            Navigation.findNavController(v).navigate(R.id.action_complete_to_content);
        });

        return root;
    }
}
