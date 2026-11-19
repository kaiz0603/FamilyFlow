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

public class ContentFragment extends Fragment {

    private String role = "parent";      // parent / child
    private String familyType = "ALL";  // ALL 或 四种家庭类型
    private List<SuggestionItem> suggestions = new ArrayList<>();

    // JSON 映射类
    public static class SuggestionItem {
        public int id;
        public String type;      // 民主权威型 / 独断专权型 / ...
        public String question;  // 情境问题
        public String advice;    // 建议
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_content, container, false);
        ListView listView = root.findViewById(R.id.listView);

        if (getArguments() != null) {
            role = getArguments().getString("role", "parent");
            familyType = getArguments().getString("familyType", "ALL");
        }

        loadSuggestions();

        // 把问题放到 ListView
        List<String> questions = new ArrayList<>();
        for (SuggestionItem item : suggestions) {
            questions.add(item.id + ". " + item.question);
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(),
                R.layout.item_question, R.id.tvQuestion, questions);
        listView.setAdapter(adapter);

        // 点击跳转到 SuggestionFragment
        listView.setOnItemClickListener((parent, view, position, id) -> {
            SuggestionItem item = suggestions.get(position);
            Bundle bundle = new Bundle();
            bundle.putString("question", item.question);
            bundle.putString("advice", item.advice);
            Navigation.findNavController(view).navigate(R.id.action_content_to_suggestion, bundle);
        });

        return root;
    }

    /** 加载 JSON 并筛选 */
    private void loadSuggestions() {
        String fileName = role.equals("child") ? "child_suggestions.json" : "parent_suggestions.json";
        String json = JsonUtils.loadJSONFromAsset(requireContext(), fileName);
        if (json != null) {
            Gson gson = new Gson();
            Type listType = new TypeToken<List<SuggestionItem>>() {}.getType();
            List<SuggestionItem> all = gson.fromJson(json, listType);

            suggestions.clear();
            if ("ALL".equals(familyType)) {
                // 显示所有问题
                suggestions.addAll(all);
            } else {
                // 只显示对应类型
                for (SuggestionItem item : all) {
                    if (item.type.equals(familyType)) {
                        suggestions.add(item);
                    }
                }
            }
        }
    }
}
