package com.example.familyflow.ui.survey;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.example.familyflow.R;
import com.example.familyflow.utils.JsonUtils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class SurveyFragment extends Fragment {

    private LinearLayout questionContainer;
    private Button btnSubmit;
    private List<Question> questions = new ArrayList<>();
    private List<RadioGroup> radioGroups = new ArrayList<>();
    private String role = "parent"; // 默认 parent

    /** 问卷问题类 */
    public static class Question {
        public int id;
        public String question;
        public List<Option> options;
    }

    /** 选项类 */
    public static class Option {
        public String text;
        public int[] scores;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_survey, container, false);

        questionContainer = view.findViewById(R.id.questionContainer);
        btnSubmit = view.findViewById(R.id.btnSubmit);

        if (getArguments() != null) {
            role = getArguments().getString("role", "parent");
        }

        loadQuestions();
        renderQuestions();

        btnSubmit.setOnClickListener(v -> calculateResult(v));

        return view;
    }

    /** 加载问卷 JSON */
    private void loadQuestions() {
        String fileName = role.equals("child") ? "child_questions.json" : "parent_questions.json";
        String json = JsonUtils.loadJSONFromAsset(requireContext(), fileName);
        if (json != null) {
            Gson gson = new Gson();
            Type listType = new TypeToken<List<Question>>() {}.getType();
            questions = gson.fromJson(json, listType);
        }
    }

    /** 渲染问卷 */
    private void renderQuestions() {
        for (Question q : questions) {
            TextView tv = new TextView(requireContext());
            tv.setText(q.id + ". " + q.question);
            tv.setTextSize(16);
            tv.setTextColor(getResources().getColor(R.color.black));
            tv.setPadding(0, 24, 0, 8);
            questionContainer.addView(tv);

            RadioGroup rg = new RadioGroup(requireContext());
            rg.setOrientation(RadioGroup.VERTICAL);

            for (Option opt : q.options) {
                RadioButton rb = new RadioButton(requireContext());
                rb.setText(opt.text);
                rb.setTextColor(getResources().getColor(R.color.purple));
                rg.addView(rb);
            }

            questionContainer.addView(rg);
            radioGroups.add(rg);
        }
    }

    /** 计算问卷结果 */
    private void calculateResult(View v) {
        int[] scores = new int[4]; // [民主权威型, 独断专权型, 宽松溺爱型, 忽视冷模型]

        for (int i = 0; i < radioGroups.size(); i++) {
            RadioGroup rg = radioGroups.get(i);
            int checkedId = rg.getCheckedRadioButtonId();
            if (checkedId == -1) continue;

            RadioButton rb = rg.findViewById(checkedId);
            String answer = rb.getText().toString();

            Question q = questions.get(i);
            for (Option opt : q.options) {
                if (opt.text.equals(answer)) {
                    addArray(scores, opt.scores);
                    break;
                }
            }
        }

        // 找到最大值
        int maxIndex = 0;
        for (int i = 1; i < scores.length; i++) {
            if (scores[i] > scores[maxIndex]) {
                maxIndex = i;
            }
        }

        String[] types = {"民主权威型", "独断专权型", "宽松溺爱型", "忽视冷模型"};
        String familyType = types[maxIndex];

        // 跳转到 ContentFragment
        Bundle bundle = new Bundle();
        bundle.putString("role", role);
        bundle.putString("familyType", familyType);

        Navigation.findNavController(v).navigate(R.id.action_survey_to_content, bundle);
    }

    private void addArray(int[] scores, int[] add) {
        for (int i = 0; i < scores.length; i++) {
            scores[i] += add[i];
        }
    }
}
