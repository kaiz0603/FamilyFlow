package com.example.familyflow.ui.content;

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

public class SuggestionFragment extends Fragment {

    private TextView tvQuestion, tvAdvice;
    private Button btnComplete;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_suggestion, container, false);

        tvQuestion = root.findViewById(R.id.tvQuestion);
        tvAdvice = root.findViewById(R.id.tvAdvice);
        btnComplete = root.findViewById(R.id.btnComplete);

        // 获取从 QuestionSelectFragment 传来的参数
        if (getArguments() != null) {
            String question = getArguments().getString("question", "未找到问题");
            String advice = getArguments().getString("advice", "未找到建议");

            tvQuestion.setText("问题：" + question);
            tvAdvice.setText("建议：" + advice);
        }

        // 点击按钮 → 跳转到 CompleteFragment
        btnComplete.setOnClickListener(v ->
                Navigation.findNavController(v).navigate(R.id.action_suggestion_to_complete)
        );

        return root;
    }
}
