package com.example.familyflow.ui.content;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;

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

public class QuestionSelectFragment extends Fragment {

    private String role;
    private String category;
    private List<SuggestionItem> allQuestions = new ArrayList<>();

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {

        ListView listView = new ListView(requireContext());

        if (getArguments() != null) {
            role = getArguments().getString("role", "parent");
            category = getArguments().getString("category", "ALL");
        }

        loadQuestions();

        List<String> questionTitles = new ArrayList<>();
        for (SuggestionItem s : allQuestions) {
            questionTitles.add(s.id + ". " + s.question);
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(
                requireContext(),
                android.R.layout.simple_list_item_1,
                questionTitles
        );
        listView.setAdapter(adapter);

        listView.setOnItemClickListener((parent, view, position, id) -> {
            SuggestionItem selected = allQuestions.get(position);

            Bundle bundle = new Bundle();
            bundle.putString("role", role);
            bundle.putString("category", selected.type);
            bundle.putInt("questionId", selected.id);

            Navigation.findNavController(view).navigate(R.id.action_question_to_suggestion, bundle);
        });

        return listView;
    }

    private void loadQuestions() {
        String fileName = role.equals("child") ? "child_suggestions.json" : "parent_suggestions.json";
        String json = JsonUtils.loadJSONFromAsset(requireContext(), fileName);

        if (json != null) {
            Gson gson = new Gson();
            Type listType = new TypeToken<List<SuggestionItem>>() {}.getType();
            List<SuggestionItem> allData = gson.fromJson(json, listType);

            if (!"ALL".equals(category)) {
                allQuestions = new ArrayList<>();
                for (SuggestionItem item : allData) {
                    if (item.type.equals(category)) {
                        allQuestions.add(item);
                    }
                }
            } else {
                allQuestions = allData; // 显示全部
            }
        }
    }
}
