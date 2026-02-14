package com.example.familyflow.ui.content;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.example.familyflow.R;

public class QuestionCategoryFragment extends Fragment {

    private String role;
    private String familyType;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {

        LinearLayout root = new LinearLayout(requireContext());
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(32, 32, 32, 32);

        if (getArguments() != null) {
            role = getArguments().getString("role", "parent");
            familyType = getArguments().getString("familyType", null);
        }

        if (familyType == null) {
            // 跳过问卷 → 直接进入所有问题
            Bundle bundle = new Bundle();
            bundle.putString("role", role);
            bundle.putString("category", "ALL");
            Navigation.findNavController(requireActivity().findViewById(R.id.nav_host_fragment))
                    .navigate(R.id.action_category_to_question, bundle);
        } else {
            // 做过问卷 → 只显示该类按钮
            Button btn = new Button(requireContext());
            btn.setText(familyType);
            btn.setOnClickListener(v -> {
                Bundle bundle = new Bundle();
                bundle.putString("role", role);
                bundle.putString("category", familyType);
                Navigation.findNavController(v).navigate(R.id.action_category_to_question, bundle);
            });
            root.addView(btn);
        }

        return root;
    }
}
